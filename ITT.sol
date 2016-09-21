/*
file:   ITT.sol
ver:    0.3.2
updated:21-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An ERC20 compliant token with currency
exchange functionality here called an 'Intrinsically Tradable
Token' (ITT).

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.0;

import "Base.sol";
import "Math.sol";
import "ERC20.sol";
import "LibCLL.sol";

contract ITTInterface
{

    using LibCLLu for LibCLLu.CLL;

/* Constants */

    string constant VERSION = "ITT 0.3.2";
    uint constant HEAD = 0;
    uint constant MINNUM = uint(1);
    // use only 128 bits of uint to prevent mul overflows.
    uint constant MAXNUM = 2**128;
    uint constant MINPRICE = uint(1);
    uint constant NEG = uint(-1); //2**256 - 1
    bool constant PREV = false;
    bool constant NEXT = true;
    bool constant BID = false;
    bool constant ASK = true;

    // minimum gas required to prevent out of gas on 'take' loop
    uint constant MINGAS = 100000;

    // For staging and commiting trade details 
    struct TradeMessage {
        bool make;
        bool side;
        uint price;
        uint tradeAmount;
        uint ownTokens;
        uint ownEther;
    }

/* State Valiables */

    // To allow for trade halting by owner.
    bool public trading;

    // Mapping for ether ownership of accumulated deposits, sales and refunds.
    mapping (address => uint) public etherBalanceOf;

    // Orders are stored in circular linked list FIFO's which are mappings with
    // price as key and value as trader address.  A trader can have only one
    // order open at each price. Reordering at that price will cancel the first
    // order and push the new one onto the back of the queue.
    mapping (uint => LibCLLu.CLL) orderFIFOs;
    
    // Order amounts are stored in a seperate lookup. The keys of this mapping
    // are `sha3` hashes of the price and trader address.
    // This mapping prevents more than one order at a particular price.
    mapping (bytes32 => uint) public amounts;

    // The pricebook is a linked list holding keys to lookup the price FIFO's
    LibCLLu.CLL priceBook = orderFIFOs[0];


/* Events */

    // Triggered on a make sell order
    event Ask (uint indexed price, uint amount, address indexed trader);

    // Triggered on a make buy order
    event Bid (uint indexed price, uint amount, address indexed trader);

    // Triggered on a filled order
    event Sale (uint indexed price, uint amount, address indexed buyer, address indexed seller);

    // Triggered when trading is started or halted
    event Trading(bool trading);

/* Functions Public constant */

    /// @notice Returns best bid or ask price. 
    function spread(bool _side) public constant returns(uint);
    
    /// @notice Returns the order amount for trader `_trader` at '_price'
    /// @param _trader Address of trader
    /// @param _price Price of order
    function getAmount(uint _price, address _trader) 
        public constant returns(uint);

    /// @notice Returns the collective order volume at a `_price`.
    /// @param _price FIFO for price.
    function getPriceVolume(uint _price) public constant returns (uint);

    /// @notice Returns an array of all prices and their volumes.
    /// @dev [even] indecies are the price. [odd] are the volume. [0] is the
    /// index of the spread.
    function getBook() public constant returns (uint[]);

/* Functions Public non-constant*/

    /// @notice Will buy `_amount` tokens at or below `_price` each.
    /// @param _bidPrice Highest price to bid.
    /// @param _amount The requested amount of tokens to buy.
    /// @param _make Value of true will make order if not filled.
    function buy (uint _bidPrice, uint _amount, bool _make)
        payable returns (bool);

    /// @notice Will sell `_amount` tokens at or above `_price` each.
    /// @param _askPrice Lowest price to ask.
    /// @param _amount The requested amount of tokens to buy.
    /// @param _make A value of true will make an order if not market filled.
    function sell (uint _askPrice, uint _amount, bool _make)
        public returns (bool);

    /// @notice Will withdraw `_ether` to your account.
    /// @param _ether The amount to withdraw
    function withdraw(uint _ether) public returns (bool success_);

    /// @notice Cancel order at `_price`
    /// @param _price The price at which the order was placed.
    function cancel(uint _price) public returns (bool);

    /// @notice Will set trading state to `_trading`
    /// @param _trading State to set trading to.
    function setTrading(bool _trading) public returns (bool);
}


/* Intrinsically Tradable Token code */ 

contract ITT is ERC20Token, ITTInterface
{

/* Structs */

/* Modifiers */

    /// @dev Passes if token is currently trading
    modifier isTrading() {
        if (!trading) throw;
        _;
    }

    /// @dev Validate buy parameters
    modifier isValidBuy(uint _bidPrice, uint _amount) {
        if ((etherBalanceOf[msg.sender] + msg.value) < (_amount * _bidPrice) ||
            _amount == 0 || _amount > totalSupply ||
            _bidPrice < MINPRICE || _bidPrice > MAXNUM) throw; // has insufficient ether.
        _;
    }

    /// @dev Validates sell parameters. Price must be larger than 1.
    modifier isValidSell(uint _askPrice, uint _amount) {
        if (_amount > balanceOf[msg.sender] || _amount == 0 ||
            _askPrice < MINPRICE || _askPrice > MAXNUM) throw;
        _;
    }
    
    /// @dev Validates ether balance
    modifier hasEther(address _member, uint _ether) {
        if (etherBalanceOf[_member] < _ether) throw;
        _;
    }

    /// @dev Validates token balance
    modifier hasBalance(address _member, uint _amount) {
        if (balanceOf[_member] < _amount) throw;
        _;
    }

/* Functions */

    function ITT(
        uint _totalSupply,
        uint8 _decimalPlaces,
        string _symbol,
        string _name
        )
            ERC20Token(
                _totalSupply,
                _decimalPlaces,
                _symbol,
                _name
                )
    {
        // setup pricebook and maximum spread.
        priceBook.cll[HEAD][PREV] = MINPRICE;
        priceBook.cll[MINPRICE][PREV] = MAXNUM;
        priceBook.cll[HEAD][NEXT] = MAXNUM;
        priceBook.cll[MAXNUM][NEXT] = MINPRICE;
        trading = true;
        balanceOf[owner] = totalSupply;
    }

/* Functions Getters */

    function version() public constant returns(string) {
        return VERSION;
    }

    function spread(bool _side) public constant returns(uint) {
        return priceBook.step(HEAD, _side);
    }

    function getAmount(uint _price, address _trader) 
        public constant returns(uint) {
        return amounts[sha3(_price, _trader)];
    }

    function sizeof(uint l) constant returns (uint s) {
        if(l == 0) return priceBook.sizeOf();
        return orderFIFOs[l].sizeOf();
    }
    
    function getPriceVolume(uint _price) public constant returns (uint v_)
    {
        uint n = orderFIFOs[_price].step(HEAD,NEXT);
        while (n != HEAD) { 
            v_ += amounts[sha3(_price, address(n))];
            n = orderFIFOs[_price].step(n, NEXT);
        }
        return;
    }

    function getBook() public constant returns (uint[])
    {
        uint i; 
        uint p = MINNUM;
        uint[] memory volumes = new uint[](priceBook.sizeOf() * 2);
        while (p < MAXNUM) {
            volumes[i++] = p;
            volumes[i++] = getPriceVolume(p);
            p = priceBook.step(p, NEXT);
        }
        return volumes; 
    }
    
    function numOrdersOf(address addr) public constant returns (uint)
    {
        uint c;
        uint p = MINNUM;
        while (p < MAXNUM) {
            if (amounts[sha3(p, msg.sender)] > 0) c++;
            p = priceBook.step(p, NEXT);
        }
        return c;
    }
    function getOpenOrdersOf(address addr) public constant returns (uint[])
    {
        uint i;
        uint c;
        uint p = MINNUM;
        uint[] memory open = new uint[](numOrdersOf(addr)*2);
        p = MINNUM;
        while (p < MAXNUM) {
            if (amounts[sha3(p, msg.sender)] > 0) {
                open[i++] = p;
                open[i++] = amounts[sha3(p, msg.sender)];
            }
            p = priceBook.step(p, NEXT);
        }
        return open;
    }

    function getNode(uint _list, uint _node) public constant returns(uint[2])
    {
        return [orderFIFOs[_list].cll[_node][PREV], 
            orderFIFOs[_list].cll[_node][NEXT]];
    }
    
    function contractBalance() public constant returns(uint) {
        return this.balance;
    }


/* Functions Public */

// Here non-constant public functions act as a security layer. They are re-entry
// protected so cannot call each other. For this reason, they
// are being used for parameter and enterance validation, while internal
// functions manage the logic. This also allows for deriving contracts to
// overload the public function with customised validations and not have to
// worry about rewritting the logic.

    function buy (uint _bidPrice, uint _amount, bool _make)
        payable
        canEnter
        isTrading
        isValidBuy(_bidPrice, _amount)
        returns (bool)
    {
        trade(_bidPrice, _amount, BID, _make);
        return true;
    }

    function sell (uint _askPrice, uint _amount, bool _make)
        public
        canEnter
        isTrading
        isValidSell(_askPrice, _amount)
        returns (bool)
    {
        trade(_askPrice, _amount, ASK, _make);
        return true;
    }

    function withdraw(uint _ether)
        public
        canEnter
        hasEther(msg.sender, _ether)
        returns (bool success_)
    {
        etherBalanceOf[msg.sender] -= _ether;
        safeSend(msg.sender, _ether);
        success_ = true;
    }

    function cancel(uint _price)
        public
        canEnter
        returns (bool)
    {
        TradeMessage memory tmsg;
        tmsg.price = _price;
        tmsg.ownTokens = balanceOf[msg.sender];
        tmsg.ownEther = etherBalanceOf[msg.sender];
        cancelIntl(tmsg);
        balanceOf[msg.sender] = tmsg.ownTokens;
        etherBalanceOf[msg.sender] = tmsg.ownEther;
        return true;
    }
    
    function setTrading(bool _trading)
        public
        onlyOwner
        canEnter
        returns (bool)
    {
        trading = _trading;
        Trading(true);
        return true;
    }

/* Functions Internal */

// Internal functions handle this contract's logic.

    function trade (uint _price, uint _amount, bool _side, bool _make) internal {
        TradeMessage memory tmsg;
        tmsg.price = _price;
        tmsg.tradeAmount = _amount;
        tmsg.side = _side;
        tmsg.make = _make;
        
        // Cached state balances to memory and commit once after trade.
        tmsg.ownTokens  = balanceOf[msg.sender];
        tmsg.ownEther = etherBalanceOf[msg.sender] + msg.value;

        take(tmsg);
        make(tmsg);
        
        balanceOf[msg.sender] = tmsg.ownTokens;
        etherBalanceOf[msg.sender] = tmsg.ownEther;
    }
    
    function take (TradeMessage tmsg)
        internal
    {
        address maker;
        bytes32 orderHash;
        uint takeAmount;
        uint takeEther;
        uint sign = tmsg.side ? uint(1) : uint(-1);
        uint bestPrice = spread(!tmsg.side);

        // Loop with available gas to take orders
        while (cmpEq(tmsg.price, bestPrice, !tmsg.side) && msg.gas > MINGAS)
        {
            Log("Taking");
            maker = address(orderFIFOs[bestPrice].step(HEAD, NEXT));
            orderHash = sha3(bestPrice, maker);
            takeAmount = amounts[orderHash];
            if (msg.sender == maker) {
                // Can't trade with self so cancel order if owned by taker.
                Log("Can't trade with self.");
                cancelIntl(tmsg);
                bestPrice = spread(!tmsg.side);
                continue;
            }
            if (takeAmount > tmsg.tradeAmount) {
                // Prepare to take partial order
                amounts[orderHash] -= tmsg.tradeAmount;
                takeAmount = tmsg.tradeAmount;
                tmsg.tradeAmount = 0;
            } else {
                // Prepare to take full order
                tmsg.tradeAmount -= takeAmount;
                closeOrder(bestPrice, maker);
            }
            takeEther = bestPrice * takeAmount;
            tmsg.ownEther += takeEther * sign;
            tmsg.ownTokens -= takeAmount * sign;
            if (tmsg.side) {
                // Sell to bidder
                balanceOf[maker] += takeAmount;
            } else {
                // Buy from asker;
                etherBalanceOf[maker] += takeEther;
            }
            bestPrice = spread(!tmsg.side);
            Sale (bestPrice, takeAmount, msg.sender, maker);
        }
    }
    
    function make(TradeMessage tmsg)
        internal
    {
        bytes32 orderHash;
        if (tmsg.tradeAmount == 0 || !tmsg.make) return;
        orderHash = sha3(tmsg.price, msg.sender);
        if (amounts[orderHash] != 0) {
            // Cancel any pre-existing owned order at this price
            cancelIntl(tmsg);
        }
        if (!orderFIFOs[tmsg.price].exists()) {
            // Register price in pricebook
            priceBook.insert(
                priceBook.seek(HEAD, tmsg.price, tmsg.side),
                tmsg.price, !tmsg.side);
        }

        amounts[orderHash] = tmsg.tradeAmount;
        orderFIFOs[tmsg.price].push(uint(msg.sender), PREV); 

        if (tmsg.side) {
            tmsg.ownTokens -= tmsg.tradeAmount;
            Ask (tmsg.price, tmsg.tradeAmount, msg.sender);
        } else {
            tmsg.ownEther -= tmsg.tradeAmount * tmsg.price;
            Bid (tmsg.price, tmsg.tradeAmount, msg.sender);
        }
    }

    function cancelIntl(TradeMessage tmsg) internal {
        uint amount = amounts[sha3(tmsg.price, msg.sender)];
        if (tmsg.price > spread(BID)) tmsg.ownTokens += amount; // was ask
        else tmsg.ownEther += tmsg.price * amount; // was bid
        closeOrder(tmsg.price, msg.sender);
    }

    function closeOrder(uint _price, address _trader) internal {
        orderFIFOs[_price].remove(uint(_trader));
        if (!orderFIFOs[_price].exists())  {
            priceBook.remove(_price);
        }
        delete amounts[sha3(_price, _trader)];
    }
}

