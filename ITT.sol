import './misc.sol';
import 'https://github.com/o0ragman0o/libCLLi/libCLLi.sol';
import './libCLLi.sol';
import 'https://github.com/o0ragman0o/EIP20/EIP20.sol';


contract ITTInterface
{

    using LibCLLi for LibCLLi.LinkedList;

/* Constants */

    uint constant PRICE_BOOK = 0;
	uint constant HEAD = 0;
    uint constant MINNUM = 1;
    uint constant MAXNUM = 2**128;
	bool constant PREV = false;
	bool constant NEXT = true;
    bool constant BID = false;
    bool constant ASK = true;
    uint constant MAXDEPTH = 100000; // remaning gas required to prevent out of gas on take recursion

    struct Order {
        // Price and swap are determined by FIFO price
        uint amount; // Token amount of Ask or ether Value of Bid. 
        address trader; // Token holder address
    }

    struct TradeMessage {
        uint amount;
        uint value;
        uint price;
        uint spent;
        uint bought;
        uint sold;
        uint orderId;
        bool swap;
        bool make;
    }
        
/* State Valiables */

    // Orders in order of creation
    Order[] public orders;


    LibCLLi.LinkedList public priceBook;
    mapping (uint => LibCLLi.LinkedList) public orderFIFOs;

    // Token holder accounts
    mapping (address => uint) public etherBalances;

/* Events */

    event Ask (uint indexed price, uint amount, uint indexed orderId, address indexed trader);
    event Bid (uint indexed price, uint amount, uint indexed orderId, address indexed trader);
    event Bought (uint indexed price, uint amount, uint indexed orderId, address seller, address indexed buyer);
    event Sold (uint indexed price, uint amount, uint indexed orderId, address indexed seller, address buyer);


/* Functions getters */
    function getMetrics()
		public constant returns (
            uint balance_,
            uint etherBalance_,
            uint lowestAsk_,
            uint highestBid_,
            uint askVol_,
            uint bidVol_,
            uint8 decimalPlaces_,
            string symbol_);

    function getVolumeAtPrice(uint _price)
        public constant returns (uint);
    
    function getFirstOrderIdAtPrice(uint _price)
        public constant returns(uint);
   
    function spread(bool _dir)
        public constant returns(uint);

/* Functions Public */

    function buy (uint _bidPrice, uint _amount, bool _make)
        public returns (bool success_);

    function sell (uint _askPrice, uint _amount, bool _make)
        public returns (bool success_);
 
    function withdraw(uint _ether)
        public returns (bool success_);

    function cancel(uint _price, uint _orderId)
        public returns (bool success_);
}


/* Intrinsically Tradable Token code */ 
contract ITT is Misc, ITTInterface, EIP20Token
{
    
/* Structs */

/* Modifiers */

    modifier isValidBuy(uint _bidPrice, uint _amount) {
        if ((etherBalances[msg.sender] + msg.value) < (_amount * _bidPrice) ||
            (_amount * _bidPrice ) == NULL) throw; // has insufficient ether.
        _
    }

    modifier isValidSell(uint _askPrice, uint _amount) {
        if (_amount > balances[msg.sender] ||
            (_amount * _askPrice ) == NULL) throw;
        _
    }

    modifier ownsOrder(uint _orderId) {
        if (msg.sender != orders[_orderId].trader) throw;
        _       
    }
    
    modifier hasEther(address _member, uint _ether) {
        if (etherBalances[_member] < _ether) throw;
        _
    }

    modifier hasBalance(address _member, uint _amount) {
        if (balances[_member] < _amount) throw;
        _
    }
    
    modifier limitRecurse() {
        if (msg.gas < MAXDEPTH) return;
        _
    }

        // !_dir Tests a < b
        // _dir  Tests a > b
    modifier takeAvailable(TradeMessage tmsg) {
        if (cmp(tmsg.price, spread(!tmsg.swap), tmsg.swap)) return;
        _
    }
	
	modifier isMake(TradeMessage tmsg) {
		if (!tmsg.make) {
			tmsg.amount = 0;
			return;
		}
		_
	}
	    
/* Functions */

//    function ITT(uint _totalSupply, uint8 _decimalPlaces, string _symbol, address _owner)
    function ITT()
    {
        // totalSupply = _totalSupply;
        // balances[_owner] = _totalSupply;
        // decimalPlaces = _decimalPlaces;
        // symbol = _symbol;
        totalSupply = 100;
        balances[msg.sender] = totalSupply;
        decimalPlaces = 0;
        symbol = 'ITT';
        
        // setup pricebook and maximum spread.10
        priceBook.init(true);
        priceBook.nodes[HEAD].dataIndex = MINNUM;
        priceBook.nodes[HEAD].links[PREV] = MINNUM;
        priceBook.nodes[HEAD].links[NEXT] = MAXNUM;

        priceBook.nodes[MAXNUM].dataIndex = MAXNUM;
        priceBook.nodes[MAXNUM].links[PREV] = HEAD;
        priceBook.nodes[MAXNUM].links[NEXT] = MAXNUM;

        priceBook.nodes[MINNUM].dataIndex = MINNUM;
        priceBook.nodes[MINNUM].links[PREV] = MINNUM;
        priceBook.nodes[MINNUM].links[NEXT] = HEAD;
        
        // dummy order at index 0 to allow for order existance testing
        orders.push(Order(1,0));
    }
    
    function () 
    { 
        throw;
    }

/* Functions Getters */

    function getMetrics()
		public constant returns (
            uint balance_,
            uint etherBalance_,
            uint lowestAsk_,
            uint highestBid_,
            uint askVol_,
            uint bidVol_,
            uint8 decimalPlaces_,
            string symbol_)
   {
        balance_ = balances[msg.sender];
        etherBalance_ = etherBalances[msg.sender];
        lowestAsk_ = spread(ASK);
        highestBid_ = spread(BID);
        askVol_ = orderFIFOs[lowestAsk_].auxData;
        bidVol_ = orderFIFOs[highestBid_].auxData;
		decimalPlaces_ = decimalPlaces;
		symbol_ = symbol;
        return;
    }
    
    function getVolumeAtPrice(uint _price) public
        constant
        returns (uint)
    {
        return orderFIFOs[_price].auxData;
    }
    
    function getFirstOrderIdAtPrice(uint _price) public
        constant
        returns(uint)
    {
        return orderFIFOs[_price].step(HEAD, true);
    }
    
    function spread(bool _dir) public
        constant
        returns(uint)
    {
		return priceBook.step(HEAD, _dir);
    }
	
	function getNode(uint _list, uint _node)
		constant
		returns(uint[3])
	{
		if (_list == 0) return [
			priceBook.nodes[_node].links[PREV],
			priceBook.nodes[_node].links[NEXT],
			priceBook.nodes[_node].dataIndex];
		else return [
			orderFIFOs[_list].nodes[_node].links[PREV],
		 	orderFIFOs[_list].nodes[_node].links[NEXT],
			orderFIFOs[_list].nodes[_node].dataIndex];
	}

    function toPrice (uint _value, uint _amount) public
        constant
        returns (uint)
    {
        return _value / _amount;
    }

    function toAmount (uint _value, uint _price) public
        constant
        returns (uint)
    {
        return _value / _price;
    }

    function toValue (uint _price, uint _amount) public
        constant
        returns (uint)
    {
        return _price * _amount;
    }

/* Functions Public */

    function buy (uint _bidPrice, uint _amount, bool _make)
        public
        mutexProtected
        returns (bool success_)
    {
        buyIntl(_bidPrice, _amount, _make);
        success_ = true;
    }

    function sell (uint _askPrice, uint _amount, bool _make)
        public
        mutexProtected
        returns (bool success_)
    {
        sellIntl(_askPrice, _amount, _make);
        success_ = true;
    }

    function withdraw(uint _ether)
		public
        mutexProtected
        hasEther(msg.sender, _ether)
        returns (bool success_)
    {
        etherBalances[msg.sender] -= _ether;
        if(!msg.sender.send(_ether)) throw;
        success_ = true;
    }

    function cancel(uint _price, uint _orderId)
		public
        mutexProtected
        ownsOrder(_orderId)
        returns (bool success_)
    {
        if (_price > spread(BID))
            etherBalances[msg.sender] += toValue(_price, orders[_orderId].amount);
        else
            balances[msg.sender] += orders[_orderId].amount;
        closeOrder(_price, _orderId);
        success_ = true;
    }

/* Functions Internal */

    function buyIntl (uint _bidPrice, uint _amount, bool _make)
        internal
        isValidBuy(_bidPrice, _amount)
    {
        TradeMessage memory tmsg;
        tmsg.amount = _amount;
        tmsg.value = toValue(_bidPrice, _amount);
        tmsg.price = _bidPrice;
        tmsg.swap = BID;
        tmsg.make = _make;

        takeAsks(tmsg);
        makeBid(tmsg);

        balances[msg.sender] += tmsg.bought;
        etherBalances[msg.sender] += msg.value - tmsg.spent;
    }

    function sellIntl (uint _askPrice, uint _amount, bool _make)
        internal
        isValidSell(_askPrice, _amount)
    {
        TradeMessage memory tmsg;
        tmsg.amount = _amount;
        tmsg.price = _askPrice;
        tmsg.swap = ASK;
        tmsg.make = _make;

        takeBids(tmsg);
        makeAsk(tmsg);

        balances[msg.sender] += tmsg.amount - tmsg.sold;
        etherBalances[msg.sender] += tmsg.value;
    }

    function takeAsks(TradeMessage tmsg)
        // * NOTE * This function can recurse by design.
        internal
        limitRecurse
        takeAvailable(tmsg)
    {
        uint bestPrice = spread(!tmsg.swap);
        tmsg.orderId = getFirstOrderIdAtPrice(bestPrice);
        Order order = orders[tmsg.orderId];
        uint orderValue = toValue(bestPrice, order.amount);
        if (tmsg.amount >= order.amount) {
            // Take full amount
            tmsg.spent += orderValue;
            tmsg.bought += order.amount;
            tmsg.amount -= order.amount;
            etherBalances[order.trader] += orderValue;
            Bought (tmsg.price, order.amount, tmsg.orderId, order.trader, msg.sender);
            closeOrder(bestPrice, tmsg.orderId);
            takeAsks(tmsg); // recurse
            return;
        }
        if (tmsg.amount == 0) return;
        // Insufficient funds, take partial ask.
        order.amount -= tmsg.amount;
        tmsg.bought += tmsg.amount;
        etherBalances[order.trader] += toValue(bestPrice, tmsg.amount);
        orderFIFOs[bestPrice].auxData -= tmsg.amount;
        tmsg.spent += toValue(bestPrice, tmsg.amount);
        Bought (tmsg.price, tmsg.amount, tmsg.orderId, order.trader, msg.sender);
        tmsg.amount = 0;
        return;
}

    function takeBids(TradeMessage tmsg)
        // * NOTE * This function can recurse by design.
        internal
        limitRecurse
        takeAvailable(tmsg)
    {
        uint bestPrice = spread(!tmsg.swap);
        tmsg.orderId = getFirstOrderIdAtPrice(bestPrice);
        Order order = orders[tmsg.orderId];
        uint orderValue = toValue(bestPrice, order.amount);
        if (tmsg.amount >= order.amount) {
            // Take full amount 
			tmsg.value += toValue(bestPrice, order.amount);
            tmsg.amount -= order.amount;
            balances[order.trader] += order.amount;
            tmsg.sold += order.amount;
            Sold (bestPrice, order.amount, tmsg.orderId, msg.sender, order.trader);
            closeOrder(bestPrice, tmsg.orderId);
            takeBids(tmsg); // recurse;
            return;
        }
        if(tmsg.amount == 0) return;
        // Insufficient funds, take partial bid.
        uint sellValue = toValue(bestPrice, tmsg.amount);
        tmsg.value += sellValue;
        order.amount -= sellValue;
        balances[order.trader] += tmsg.amount;
        orderFIFOs[bestPrice].auxData -= tmsg.amount;
        tmsg.sold += tmsg.amount;
        tmsg.amount = 0;
        Sold (bestPrice, tmsg.amount, tmsg.orderId, msg.sender, order.trader);
        return;
    }

    function makeAsk(TradeMessage tmsg)
        internal
		isMake(tmsg)
	{
        make(tmsg);
        tmsg.sold += tmsg.amount;
        Ask (tmsg.price, tmsg.amount, tmsg.orderId, msg.sender);
        tmsg.amount = 0;
    }

    function makeBid(TradeMessage tmsg)
        internal
		isMake(tmsg)
    {
        make(tmsg);
        tmsg.spent += toValue(tmsg.price, tmsg.amount);
        Bid (tmsg.price, tmsg.amount, tmsg.orderId, msg.sender);
        tmsg.amount = 0;
    }

    function make(TradeMessage tmsg)
        internal
    {
        if (tmsg.amount == 0) return;
        tmsg.orderId = orders.push(Order(tmsg.amount, msg.sender)) - 1;
        if (orderFIFOs[tmsg.price].newNodeKey == NULL) insertFIFO(tmsg.price, tmsg.swap); // Make sure price FIFO index exists
        orderFIFOs[tmsg.price].pushTail(tmsg.orderId); // Insert order ID into price FIFO
        orderFIFOs[tmsg.price].auxData += tmsg.amount; // Update price volume
    }

    function closeOrder(uint _price, uint _orderId)
        internal
        returns (bool)
    {
        orderFIFOs[_price].remove(_orderId);
        orderFIFOs[_price].auxData -= orders[_orderId].amount;
        if (orderFIFOs[_price].size == 0) {
            priceBook.remove(_price);
            delete orderFIFOs[_price].nodes[0];
            delete orderFIFOs[_price];
        }
        delete orders[_orderId];
        return true;
    }
    
    function seekInsert(uint _price, bool _dir)
        internal
        constant
        returns (uint _ret)
    {
        _ret = spread(_dir);
        while (cmp( _price, _ret, _dir))
            _ret = priceBook.nodes[_ret].links[_dir];
        return;
    }
    
    function insertFIFO (uint _price, bool _dir)
        internal
        returns (bool)
    {
        orderFIFOs[_price].init(true);
        uint a = spread(_dir);
        while (cmp( _price, a, _dir))
            a = priceBook.nodes[a].links[_dir];
		priceBook.insertNewNode(a, _price, !_dir); // Insert order ID into price FIFO
        return true;
    }
}
