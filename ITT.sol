//import './misc.sol';
//import './MCLL.sol';
//import './EIP20.sol';

contract LibModifiers
{
/* Modifiers */

	uint constant NULL = 0;
	uint constant MINNUM = 1;
	uint constant MAXNUM = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
	bool constant LT = false;
	bool constant GT = true;

	// To throw call not made by owner
	modifier isOwner() {
		// if (msg.sender != owner) throw;
		_
	}

	// To lock a function from entry if it or another protected function
	// has already been called and not yet returned.
	modifier mutexProtected() {
		if (mutex) throw;
		else mutex = true;
		_
		delete mutex;
		return;  // Functions require singele exit and return parameters
	}

	address owner;
	bool public mutex;

	function cmpEq (uint a, uint b, bool _dir)
		// !_dir Tests a <= b
		// _dir  Tests a >= b
		constant
		returns (bool)
	{
		return (a==b) || ((a < b) != _dir);
	}

	function cmp (uint a, uint b, bool _dir)
		// !_dir Tests a < b
		// _dir  Tests a > b
		constant
		returns (bool)
	{
		if (_dir) return a > b;
		else return a < b;
	}
}

// EIP20 Standard Token Interface
contract EIP20Interface is LibModifiers
{
    /* Structs */
        
    /* Constants */

    /* State Valiables */
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowances;
    uint public totalSupply;
    string public symbol;
    uint public decimalPlaces;

/* State variable Accessor Functions (leave commented)

	function balances(address tokenHolder) returns (uint);
	function allowanaces (address tokenHolders, address proxy, uint allowance) returns (uint);
	function totalSupply() returns (uint);
	function symbol() returns(string);
	function decimalPlaces() returns(uint);
*/

/* Modifiers */
	
	modifier isAvailable(uint _amount) {
		// if (_amount < balances[msg.sender]) throw;
		_
	}
	
	modifier hasAllowance(address _from, uint _amount) {
		// if (_amount > allowances[_from][msg.sender] ||
		//    _amount > balances[_from]) throw;
		_
	}

/* Function Abstracts */
	
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) returns (bool success);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20Token is EIP20Interface
{
/* Modifiers */

/* Structs */
        
/* Constants */

/* State Valiables */

/* Funtions Public */
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) 
        mutexProtected()
		isAvailable(_value)
		returns (bool success)
    {
        if (balances[msg.sender] < _value) throw;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success = true;
    }


    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
        mutexProtected
        hasAllowance(_from, _value)
        returns (bool success)
    {
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value)
        mutexProtected
		returns (bool success)        
    {
        if (balances[msg.sender] == 0) throw;
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }

/* Events */

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   
}

contract MultiCircularLinkedList is LibModifiers
{
/* Modifiers */

	// To test if mapping keys point to a valid linked list node.
	modifier keyExists(uint _listKey, uint _nodeKey) { 
		if (lists[_listKey].nodes[_nodeKey].dataIndex == 0) throw; 
		_
	}

	modifier isValidData(uint _dataIdx) {
		if (_dataIdx == 0) throw; 
		_
	}

	modifier isNotEmpty(uint _listKey) {
		if (lists[_listKey].size == 0) throw; 
		_
	}
	
/* Structs */

	// Generic double linked list node.
	struct DoubleLinkNode {
		uint dataIndex;
		mapping (bool => uint) links;
	}
	
	// Generic circular linked list parameters. Head is static index 1.
	struct LinkedList {
		uint size;	// Number of nodes
		uint newNodeKey; // Next free mapping slot
		uint auxData; // auxilary data state variable.
		mapping (uint => DoubleLinkNode) nodes;
	}
	
/* Constants */

	uint constant NULL = 0;
	uint constant HEAD = NULL; // All linked lists are circular with static head.
	bool constant PREV = false;
	bool constant NEXT = true;
	bool constant DEC = false;
	bool constant ASC = true;
	

/* State valiables */

	mapping (uint => LinkedList) public lists;  

/* Functions */

	// Initialises circular linked list to a valid state
	function initLinkedList(uint _listKey, bool _reset) 
		// internal
		returns (bool)
	{
		LinkedList list = lists[_listKey];
		if (list.nodes[HEAD].dataIndex != NULL && !_reset) return false; // Already exisits.
		list.newNodeKey = 1; // key 0 is already head
		list.nodes[HEAD].links[NEXT] = HEAD; // set next link to head
		list.nodes[HEAD].links[PREV] = HEAD; // set previous link to head
		list.nodes[HEAD].dataIndex = 1;
		return true;
	}
	
	function getNode(uint _listKey, uint _nodeKey) public
		constant
		returns (uint _dataIndex, uint _prev, uint _next)
	{
		_dataIndex = lists[_listKey].nodes[_nodeKey].dataIndex;
		_prev = lists[_listKey].nodes[_nodeKey].links[PREV];
		_next = lists[_listKey].nodes[_nodeKey].links[NEXT];
	}

	function isValidKey(uint _listKey, uint _nodeKey) 
		constant
		returns (bool)
	{ 
		if (lists[_listKey].nodes[_nodeKey].dataIndex != NULL) 
			return true;
	}

	function insert(uint _listKey, uint _nodeKey, uint _dataIndex, bool _dir, bool dataIsKey)
		// _dir == false  Inserts new node BEFORE _nodeKey
		// _dir == true   Inserts new node AFTER _nodeKey
		// internal
		keyExists(_listKey, _nodeKey)
		isValidData(_dataIndex)
		returns (bool)
	{
		LinkedList list = lists[_listKey];
		uint a = _nodeKey;
		uint b = list.nodes[a].links[_dir];
		uint c;
		if (dataIsKey) 
			c = _dataIndex;
		else 
		{
			c = list.newNodeKey;
			list.newNodeKey++;
		}
		// A <-> C <-> B  Insert new node (C) between A and B
		list.nodes[c].links[!_dir] = a; // C -> A
		list.nodes[a].links[_dir] = c; // C <- A
		list.nodes[c].links[_dir] = b;	// B <- C
		list.nodes[b].links[!_dir] = c; // B -> C
		list.nodes[c].dataIndex = _dataIndex;
		list.size++;
		return true;
	}
	
	function update(uint _listKey, uint _nodeKey, uint _dataIndex)
		// internal
		keyExists(_listKey, _nodeKey)
		returns (bool)
	{
		lists[_listKey].nodes[_nodeKey].dataIndex = _dataIndex;
		return true;
	}
		
	function remove(uint _listKey, uint _nodeKey)
		// internal
		returns (bool)
	{
		LinkedList list = lists[_listKey];
		list.nodes[list.nodes[_nodeKey].links[PREV]].links[NEXT] = list.nodes[_nodeKey].links[NEXT];
		list.nodes[list.nodes[_nodeKey].links[NEXT]].links[PREV] = list.nodes[_nodeKey].links[PREV];
		list.size--;
		delete list.nodes[_nodeKey].links[PREV];
		delete list.nodes[_nodeKey].links[NEXT];
		delete list.nodes[_nodeKey].dataIndex;
		delete list.nodes[_nodeKey];
		return true;
	}
	
	function step(uint _listKey, uint _nodeKey, bool _dir)
		// get next or previous node key
		keyExists(_listKey, _nodeKey)
		constant returns (uint)
	{
		return lists[_listKey].nodes[_nodeKey].links[_dir];
	}
}





/* Intrinsically Tradable Token code */	
contract ITT is EIP20Token, MultiCircularLinkedList
{
	
/* Structs */

	struct Order {
		uint valueAmount; // Amount of Ask or Value of Bid. Price and swap are determined by FIFO
		address trader; // Token holder address
	}

	struct Trade {
		address buyer;
		address seller;
		address maker;
		address taker;
		uint orderId;
		uint buyValue;
		uint buyAmount;
		uint sellValue;
		uint sellAmount;
		uint makeValue;
		uint makeAmount;
		uint takeValue;
		uint takeAmount;
		bool swap;
		bool make;
	}
		
/* Constants */

	uint constant PRICE_BOOK = 0;
	bool constant BID = false;
	bool constant ASK = true;
	bool constant SELLER = false;
	bool constant BUYER = true;
	bool constant MAKE = false;
	bool constant TAKE = true;

/* State Valiables */

	// Orders in order of creation
	Order[] public orders;

    // Token holder accounts
    mapping (address => uint) public balances;
	mapping (address => uint) public etherBalances;
	
/* Modifiers */

	modifier isValidBuy(uint _bidPrice, uint _amount) {
		etherBalances[msg.sender] += msg.value;
		if (etherBalances[msg.sender] < (_amount * _bidPrice) ||
			_bidPrice == NULL ||
			_amount == NULL) throw;
		_	// has insufficient ether.
	}

	modifier isValidSell(uint _askPrice, uint _amount) {
		if (_amount > balances[msg.sender] - lockedTokens[msg.sender] ||
			_askPrice == NULL ||
			_amount == NULL) throw;
		_
	}

	modifier ownsOrder(uint _orderId) {
		// if (msg.sender != orders[_orderId].trader) throw;
		_		
	}
	
	modifier hasEther(address _member, uint _ether) {
		// if (etherBalances[_member] < _ether) throw;
		_
	}

	modifier hasBalance(address _member, uint _amount) {
		// if (balances[_member] < _amount) throw;
		_
	}

/* Functions */

	function ITT()
	{
		totalSupply = 1000000;
		balances[msg.sender] = 1000000;
		
		// setup pricebook spread.
		lists[PRICE_BOOK].nodes[HEAD].dataIndex = MINNUM;
		lists[PRICE_BOOK].nodes[HEAD].links[PREV] = MINNUM;
		lists[PRICE_BOOK].nodes[HEAD].links[NEXT] = MAXNUM;

		lists[PRICE_BOOK].nodes[MAXNUM].dataIndex = MAXNUM;
		lists[PRICE_BOOK].nodes[MAXNUM].links[PREV] = HEAD;
		lists[PRICE_BOOK].nodes[MAXNUM].links[NEXT] = MAXNUM;

		lists[PRICE_BOOK].nodes[MINNUM].dataIndex = MINNUM;
		lists[PRICE_BOOK].nodes[MINNUM].links[PREV] = MINNUM;
		lists[PRICE_BOOK].nodes[MINNUM].links[NEXT] = HEAD;
		
		// dummy order at index 0 to allow for order existance testing
		orders.push(Order(1,0));
	}
	
	function () 
		mutexProtected
	{ 
//		etherBalances[msg.sender] += msg.value;
		throw;
	}

/* Functions Getters */

	function getMetrics()
		constant
		returns (
			uint _balance,
			uint _etherBalance,
			uint _lowestAsk,
			uint _highestBid,
			uint _askVol,
			uint _bidVol
		)
	{
		_balance = balances[msg.sender];
		_etherBalance = etherBalances[msg.sender];
		_lowestAsk = spread(ASK);
		_highestBid = spread(BID);
		_askVol = lists[_lowestAsk].auxData;
		_bidVol = lists[_highestBid].auxData;
		return;
	}
	
	function getVolumeAtPrice(uint _price) public
		constant
		returns (uint)
	{
		return lists[_price].auxData;
	}
	
	function getFirstOrderIdAtPrice(uint _price) public
		constant
		returns(uint)
	{
		return lists[_price].nodes[step(_price, HEAD, true)].dataIndex;
	}
	
	function spread(bool _dir) public
		constant
		returns(uint)
	{
		return lists[PRICE_BOOK].nodes[HEAD].links[_dir];
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

	function buy (uint _value, uint _amount, bool _make) public
		mutexProtected
		isValidBuy(_bidPrice, _amount)
		returns (bool _success)
	{
		Trade memory tradeMsg;
		tradeMsg.buyer = msg.sender;
		tradeMsg.takeAmount = _amount;
		tradeMsg.takeValue = _value;
		tradeMsg.buyValue = etherBalances[msg.sender];
		tradeMsg.buyAmount = balances[msg.sender];
		tradeMsg.swap = BID;
		tradeMsg.make = _make;
		runTrade(tradeMsg);
	}
	// struct Trade {
	// 	address buyer;
	// 	address seller;
	//	address maker; // trader from prior make order
	//  address taker; // msg.sender
	//	uint orderId; // id of order in book
	// 	uint buyValue; // ether to spend
	// 	uint buyAmount; // accumulated tokens
	// 	uint sellValue; // accumulated ether
	// 	uint sellAmount; // tokens to sellAmount
	// 	uint makeValue; // value of booked order
	// 	uint makeAmount; // amount in booked order
	// 	uint takeValue; // value of order
	// 	uint takeAmount;  // amount in order
	// }

	function sell (uint _value, uint _amount, bool _make) public
		mutexProtected
		isValidSell(_bidPrice, _amount)
		returns (bool _success)
	{
		Trade memory tradeMsg;
		tradeMsg.seller = msg.sender;
		tradeMsg.takeAmount = _amount;
		tradeMsg.takeValue = _value;
		tradeMsg.sellValue = etherBalances[msg.sender];
		tradeMsg.sellAmount = balances[msg.sender];
		tradeMsg.swap = ASK;
		tradeMsg.make = _make;
		runTrade(tradeMsg);
	}

	function withdraw(uint _ether) public
		mutexProtected
		hasEther(msg.sender, _ether)
		returns (bool _success)
	{
		etherBalances[msg.sender] -= _ether;
		if(!msg.sender.send(_ether)) throw;
		_success = true;
	}

	function cancel(uint _orderId) public
		mutexProtected
		ownsOrder(_orderId)
		returns (bool _success)
	{
		closeOrder(_orderId);
		_success = true;
	}

/* Functions Internal */

	function runTrade(Trade tradeMsg)
		internal
		returns (bool success_)
	{
		take(tradeMsg);
		tradeMsg.maker = msg.sender;
		tradeMsg.makeValue = tradeMsg.takeValue;
		tradeMsg.makeAmount = tradeMsg.takeAmount;
		if (tradeMsg.make) {
			if (tradeMsg.swap)
				if(tradeMsg.makeAmount > 0)	make(tradeMsg);
			else
				if(tradeMsg.makeValue > 0)	make(tradeMsg);
		}
		balances[tradeMsg.taker] += tradeMsg.makeAmount;
		etherBalances[tradeMsg.taker] += tradeMsg.makeValue;
	}

	function take(Trade tradeMsg)
		internal
		returns (bool success_)
	{
		tradeMsg.makePrice = spread(tradeMsg.swap);
		tradeMsg.takePrice = toPrice(tradeMsg.takeValue, tradeMsg.takeAmount);
		if (cmp(takePrice, makePrice, tradeMsg.swap)
			// nothing to take
			return;

		tradeMsg.orderId = getFirstOrderIdAtPrice(makePrice);
		tradeMsg.makeValue = orders[tradeMsg.orderId]value;
		tradeMsg.makeAmount = orders[tradeMsg.orderId].amount;
		tradeMsg.maker = orders[tradeMsg.orderId].trader;
		if(tradeMsg.swap {			
			// Taker is selling
			if (tradeMsg.takeAmount < tradeMsg.makeAmount) {
				takePartial(tradeMsg);
			} else {
				takeFull(tradeMsg);
			}

		} else {
			// Taker is buying
			if (tradeMsg.takeValue < tradeMsg.makeValue) {
				takePartial(tradeMsg);
			} else {
				takeFull(tradeMsg);
			}
		}
		return;
	}
	
	function takeFull(Trade tradeMsg)
		internal
		returns (bool success_)
	{
		if(tradeMsg.swap {			
			// Taker is selling			
			balances[order.trader] += tradeMsg.makeAmount;	
			tradeMsg.takeAmount -= tradeMsg.makeAmount;		
			tradeMsg.takeValue += tradeMsg.makeValue;
			closeFIFOOrder(tradeMsg.makePrice);
			if (tradeMsg.takeAmount > 0) {
				// *** ANALYSIS REQ *** check recursion gas limit;
				// recurse to take next order.
				take(tradeMsg);
			}
		} else {
			// Taker is buying
			etherbalances[order.trader] += tradeMsg.makeValue;
			tradeMsg.takeValue -= tradeMsg.makeValue;
			tradeMsg.takeAmount += tradeMsg.makeAmount;
			closeFIFOOrder(tradeMsg.makePrice);
			if (tradeMsg.takeValue > 0) {
				// *** ANALYSIS REQ *** check recursion gas limit;
				// recurse to take next order.
				take(tradeMsg);
			}
		}
		return;
	}

	function takePartial(Trade tradeMsg)
		internal
		returns (bool success_)
	{
		if(tradeMsg.swap {			
			// Taker is selling			
			balances[order.trader] += tradeMsg.takeAmount;
			orders[taskMsg.orderId].amount -= tradeMsg.takeAmount;
			tradeMsg.takeAmount = 0;
			tradeMsg.takeValue += tradeMsg.makeValue;
		} else {
			// Taker is buying
			etherbalances[order.trader] += tradeMsg.takeValue;
			orders[taskMsg.orderId].value -= tradeMsg.takeValue
			tradeMsg.takeValue = 0;
			tradeMsg.takeAmount += tradeMsg.makeAmount;
		}
		return;
	}
	// struct Trade {
	// 	address buyer;
	// 	address seller;
	//	address maker; // trader from prior make order
	//  address taker; // msg.sender
	//	uint orderId; // id of order in book
	// 	uint buyValue; // ether to spend
	// 	uint buyAmount; // accumulated tokens
	// 	uint sellValue; // accumulated ether
	// 	uint sellAmount; // tokens to sellAmount
	// 	uint makeValue; // value of booked order
	// 	uint makeAmount; // amount in booked order
	// 	uint takeValue; // value of order
	// 	uint takeAmount;  // amount in order
	// }

	function make (Trade tradeMsg) 
		internal
		returns (uint orderId_)
	{
		if (tradeMsg.swap) {
			balances[msg.sender] -= tradeMsg.takeAmount;
			orderId_ = orders.push(Order(tradeMsg.takeAmount, msg.sender)) - 1;
		} else {
			etherBalances[msg.sender] -= tradeMsg.takeValue;
			orderId_ = orders.push(Order(tradeMsg.takeValue, msg.sender)) - 1;
		}

		uint price = toPrice(tradeMsg.takeValue, tradeMsg.takeAmount);
		if (!isValidKey(price, 0)) insertFIFO(price, _swap); // Make sure price FIFO exists
		insert(price, HEAD, orderId_, PREV, false); // Insert order ID into price FIFO
		lists[price].auxData += tradeMsg.takeAmount; // Update price volume
		return;
	}

	function closeFIFOOrder(uint _price)
		// internal
		returns (bool)
	{
		uint _orderId = lists[_price].nodes[step(_price, HEAD, NEXT)].dataIndex;
		closeOrder(_orderId);
		return true;
	}

	function closeOrder(uint _orderId)
		// internal
		returns (bool)
	{
		uint price = orders[_orderId].price;
		remove(price, _orderId);
		lists[price].auxData -= orders[_orderId].amount;
		if (lists[price].size == 0) {
			remove(PRICE_BOOK, price);
			delete lists[price].nodes[0];
			delete lists[price];
		}
		delete orders[_orderId];
		return true;
	}

	function closeTrade (Trade tradeMsg)
		internal
	{
		balances[tradeMsg] -= tradeMtx[B_VAL]
	}

	function seekInsert(uint _price, bool _dir)
		constant
		// internal
		returns (uint _ret)
	{
		_ret = spread(_dir);
		while (cmp( _price, _ret, _dir))
			_ret = lists[PRICE_BOOK].nodes[_ret].links[_dir];
		return;
	}
	
	function insertFIFO (uint _price, bool _dir)
		// internal
		returns (bool)
	{
		initLinkedList(_price, false);
		uint a = spread(_dir);
		while (cmp( _price, a, _dir))
			a = lists[PRICE_BOOK].nodes[a].links[_dir];
		insert(PRICE_BOOK, a, _price, !_dir, true); // Insert order ID into price FIFO
		return true;
	}
}
