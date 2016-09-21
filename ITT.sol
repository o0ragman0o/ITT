/*
file:   ITT.sol
ver:    0.3.0
updated:16-Sep-2016
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

import "Base.sol"; //Browser Solidity breaks on nested imports
import "Math.sol";
import "ERC20.sol";
import "LibCLLi.sol";

contract ITTInterface
{

    using LibCLLi for LibCLLi.CLL;

/* Constants */

    string constant VERSION = "ITT 0.3.0";
    uint constant HEAD = 0;
    uint constant MINNUM = 1;
    uint constant MAXNUM = uint(-1); 
    bool constant PREV = false;
    bool constant NEXT = true;
    bool constant BID = false;
    bool constant ASK = true;
    
    // minimum gas required to prevent out of gas on 'take' recursion
    uint constant MINRECURSGAS = 100000;
    uint constant RECURSLMT = 100;

    // An internal message structure for staging state mutations during order
    // processing
    struct TradeMessage {
        uint amount;
        uint value;
        uint price;
        uint spent;
        uint bought;
        uint sold;
        bool side;
        bool make;
        uint rcrsStk;
    }

/* State Valiables */

    // To allow for trade halting by owner.
    bool public trading;

    // Orders are stored in circular linked list FIFO mappings with price as
    // key and value as trader address.  A trader can have only one open order
    // at each price.
    mapping (uint => LibCLLi.CLL) orderFIFOs;
    
    // Ether ownership for accumulation of deposits, sales and refunds.
    mapping (address => uint) public etherBalanceOf;
    
    // Order amount keys are `sha3` hashes of the price and trader address.
    // This mapping prevents more than one order at a particular price.
    // If a second is made, the first is canceled to prevent starving later
    // orders in the FIFO.
    mapping (bytes32 => uint) public amounts;

    // The pricebook is a linked list hold holding keys to lookup the price
    // FIFO's
    LibCLLi.CLL priceBook = orderFIFOs[0];


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

    /// @notice Returns the version string
    function version() public constant returns (string);
    
    /// @notice Returns the order amount for trader `_trader` at '_price'
    /// @param _trader Address of trader
    /// @param _price Price of order
    function getAmount(uint _price, address _trader) 
        public constant returns(uint);

    /// @notice Returns the collective order volume at a _price.
    /// @param _price FIFO for price.
    function getPriceVolume(uint _price) public constant returns (uint);

    /// @notice Returns an array of all prices and their volumes.
    /// @dev [even] indecies are the price. [odd] are the volume. [0] is the
    /// index of the spread.
    function getBook() public constant returns (uint[]);

    /// @notice Returns the best ask or bid prices.
    function bestPrice(bool _side) public constant returns(uint);

/* Functions Public */

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
            (_amount * _bidPrice ) == 0) throw; // has insufficient ether.
        _;
    }

    /// @dev Validates sell parameters. Price must be larger than 1.
    modifier isValidSell(uint _askPrice, uint _amount) {
        if (_amount > balanceOf[msg.sender] ||
            _amount == 0 ||
            _askPrice < 2) throw;
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
    
    /// @dev Prevents out of gas and stack errors during recursive calls
    modifier limitRecurse(TradeMessage tmsg) {
        if (msg.gas < MINRECURSGAS || tmsg.rcrsStk == RECURSLMT) return;
        tmsg.rcrsStk++;
        _;
    }
    
    /// @dev Tests is a take order is available 
    modifier takeAvailable(TradeMessage tmsg) {
        if (cmp(tmsg.price, bestPrice(!tmsg.side), tmsg.side)) return;
        _;
    }

    /// @dev Tests is trader wants to place a make order
    modifier isMake(TradeMessage tmsg) {
        if (!tmsg.make || tmsg.amount == 0) {
            tmsg.amount = 0;
            return;
        }
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
        priceBook.cll[HEAD][PREV] =
        priceBook.cll[MINNUM][PREV] = MINNUM;
        priceBook.cll[HEAD][NEXT] =
        priceBook.cll[MAXNUM][NEXT] = MAXNUM;
    }

/* Functions Getters */

    function version() public constant returns (string) {
        return VERSION;
    }
    
    function spread(bool _dir) public constant returns(uint) {
        return priceBook.step(HEAD, _dir);
    }

    function getAmount(uint _price, address _trader) 
        public constant returns(uint)
    {
        return amounts[sha3(_price, _trader)];
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

    function getNode(uint _list, uint _node) public constant returns(uint[2])
    {
        return [orderFIFOs[_list].cll[_node][PREV], 
            orderFIFOs[_list].cll[_node][NEXT]];
    }


/* Functions Public */

    function buy (uint _bidPrice, uint _amount, bool _make)
        payable
        noReentry
        isTrading
        returns (bool)
    {
        buyIntl(_bidPrice, _amount, _make);
        return true;
    }

    function sell (uint _askPrice, uint _amount, bool _make)
        public
        noReentry
        isTrading
        returns (bool)
    {
        sellIntl(_askPrice, _amount, _make);
        return true;
    }

    function withdraw(uint _ether)
        public
        hasEther(msg.sender, _ether)
        preventReentry
        returns (bool success_)
    {
        etherBalanceOf[msg.sender] -= _ether;
        if(!msg.sender.send(_ether)) throw;
        success_ = true;
    }

    function cancel(uint _price)
        public
        noReentry
        returns (bool)
    {
        cancelIntl(_price);
        return true;
    }
    
    function setTrading(bool _trading)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        trading = _trading;
        Trading(true);
        return true;
    }


/* Functions Internal */

    function buyIntl (uint _bidPrice, uint _amount, bool _make)
        internal
        isValidBuy(_bidPrice, _amount)
    {
        TradeMessage memory tmsg;
        tmsg.amount = _amount;
        tmsg.value = _bidPrice * _amount;
        tmsg.price = _bidPrice;
        tmsg.side = BID;
        tmsg.make = _make;

        takeAsks(tmsg);
        makeBid(tmsg);

        balanceOf[msg.sender] += tmsg.bought;
        etherBalanceOf[msg.sender] += msg.value - tmsg.spent;
    }

    function sellIntl (uint _askPrice, uint _amount, bool _make)
        internal
        isValidSell(_askPrice, _amount)
    {
        TradeMessage memory tmsg;
        tmsg.amount = _amount;
        tmsg.price = _askPrice;
        tmsg.side = ASK;
        tmsg.make = _make;

        takeBids(tmsg);
        makeAsk(tmsg);

        balanceOf[msg.sender] += tmsg.amount - tmsg.sold;
        etherBalanceOf[msg.sender] += tmsg.value;
    }

    function takeAsks(TradeMessage tmsg)
        // * NOTE * This function can recurse by design.
        internal
        limitRecurse(tmsg)
        takeAvailable(tmsg)
    {
        uint bestPrice = spread(!tmsg.side);
        address trader = address(orderFIFOs[bestPrice].step(HEAD, NEXT));
        bytes32 orderHash = sha3(bestPrice, trader);
        uint amount = amounts[orderHash];
        uint orderValue = bestPrice * amount;
        if (tmsg.amount >= amount) {
            // Has sufficient funds to fill order.
            tmsg.spent += orderValue;
            tmsg.bought += amount;
            tmsg.amount -= amount;
            etherBalanceOf[trader] += orderValue;
            Sale (bestPrice, amount, trader, msg.sender);
            closeOrder(bestPrice, trader);
            // Recurs to take the next order
            takeAsks(tmsg);
            return;
        }
        if (tmsg.amount == 0) return;
        // Has insufficient funds so fill partial order.
        uint spentValue = bestPrice * tmsg.amount;
        amounts[orderHash] -= tmsg.amount;
        tmsg.bought += tmsg.amount;
        etherBalanceOf[trader] += spentValue;
        tmsg.spent += spentValue;
        Sale (tmsg.price, tmsg.amount, trader, msg.sender);
        tmsg.amount = 0;
        return;
    }

    function takeBids(TradeMessage tmsg)
        // * NOTE * This function can recurse by design.
        internal
        limitRecurse(tmsg)
        takeAvailable(tmsg)
    {
        uint bestPrice = spread(!tmsg.side);
        address trader = address(orderFIFOs[bestPrice].step(HEAD, NEXT));
        bytes32 orderHash = sha3(bestPrice, trader);
        uint amount = amounts[orderHash];
        uint orderValue = bestPrice * amount;
        if (tmsg.amount >= amount) {
            // Has sufficient amount to fill order
            tmsg.value += orderValue;
            tmsg.amount -= amount;
            balanceOf[trader] += amount;
            tmsg.sold += amount;
            Sale (bestPrice, amount, msg.sender, trader);
            closeOrder(bestPrice, trader);
            // Recurs to take the next order
            takeBids(tmsg);
            return;
        }
        if(tmsg.amount == 0) return;
        // Insufficient amount so fill partial order.
        uint sellValue = bestPrice * tmsg.amount;
        tmsg.value += sellValue;
        amounts[orderHash] -= sellValue;
        balanceOf[trader] += tmsg.amount;
        tmsg.sold += tmsg.amount;
        tmsg.amount = 0;
        Sale (bestPrice, tmsg.amount, msg.sender, trader);
        return;
    }

    function makeAsk(TradeMessage tmsg)
        internal
        isMake(tmsg)
    {
        make(tmsg);
        tmsg.sold += tmsg.amount;
        Ask (tmsg.price, tmsg.amount, msg.sender);
        tmsg.amount = 0;
    }

    function makeBid(TradeMessage tmsg)
        internal
        isMake(tmsg)
    {
        make(tmsg);
        tmsg.spent += tmsg.price * tmsg.amount;
        Bid (tmsg.price, tmsg.amount, msg.sender);
        tmsg.amount = 0;
    }

    function make(TradeMessage tmsg)
        internal
    {
        if (tmsg.amount == 0) return;
        bytes32 orderHash = sha3(tmsg.price, msg.sender);
        if (amounts[orderHash] > 0)
            // Cancel existing order to prevent FIFO hogging.
            cancelIntl(tmsg.price);
        amounts[orderHash] = tmsg.amount;
        if (!orderFIFOs[tmsg.price].exists())
            // Register price in pricebook
            priceBook.insert(priceBook.seek(HEAD, tmsg.price, tmsg.side), 
                tmsg.price, !tmsg.side);
        // Push order to the back of the queue.
        orderFIFOs[tmsg.price].push(uint(msg.sender), PREV); 
    }

    function cancelIntl(uint _price)
    {
        uint amount = amounts[sha3(_price, msg.sender)];
        if (_price < spread(ASK)) 
            // was buy side
            etherBalanceOf[msg.sender] += _price * amount;
        else
            // was sell side
            balanceOf[msg.sender] += amount;
        closeOrder(_price, msg.sender);
    }

    function closeOrder(uint _price, address _trader)
        internal 
    {
        orderFIFOs[_price].remove(uint(_trader));
        if (!orderFIFOs[_price].exists())  {
            priceBook.remove(_price);
        }
        delete amounts[sha3(_price, _trader)];
    }

}