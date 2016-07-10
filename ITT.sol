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
		// Price and swap are determined by FIFO price
		uint valueAmount; // Token amount of Ask or ether Value of Bid. 
		address trader; // Token holder address
	}

	struct TradeMessage {
		uint amount;
		uint value;
		uint price;
		uint orderId;
		bool swap;
		bool make;
	}
		
/* Constants */

	uint constant PRICE_BOOK = 0;
	bool constant BID = false;
	bool constant ASK = true;
	uint8 constant MAXDEPTH = 5; // prevent out of gas on take recursion

/* State Valiables */

	// Orders in order of creation
	Order[] public orders;

    // Token holder accounts
    // mapping (address => uint) public balances; // inherited
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
		if (_amount > balances[msg.sender] ||
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
	
	modifier notTooDeep(uint8 depth) {
		if (depth == 0) return;
		depth--;
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

// /* Functions Public */

	function buy (uint _amount, uint _bidPrice, bool _make)
		mutexProtected
		isValidBuy(_bidPrice, _amount)
		returns (bool _success)
	{
		TradeMessage memory tmsg;
		tmsg.value = toValue(_bidPrice, _amount);
		tmsg.price = _bidPrice;
		tmsg.swap = BID;
		tmsg.make = _make;

		takeAsks(tmsg);
		makeBid(tmsg);

		balances[msg.sender] += tmsg.amount;
		etherBalances[msg.sender] -= tmsg.value;
	}

	function sell (uint _amount, uint _askPrice, bool _make)
		mutexProtected
		isValidSell(_askPrice, _amount)
		returns (bool _success)
	{
		TradeMessage memory tmsg;
		//tmsg.value = toValue(_amount, _askPrice);
		tmsg.amount = _amount;
		tmsg.price = _askPrice;
		tmsg.swap = ASK;
		tmsg.make = _make;

		takeBids(tmsg);
		makeAsk(tmsg);

		balances[msg.sender] -= _amount - tmsg.amount;
		etherBalances[msg.sender] += tmsg.value;
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
//		closeOrder(_orderId);
		_success = true;
	}

// /* Functions Internal */

	function takeAsks(TradeMessage tmsg)
		internal
		returns (TradeMessage)
	{
		if (cmp(tmsg.price, spread(ASK), BID))
			// nothing to take
			return tmsg;
		takeFullAsk(tmsg, MAXDEPTH);
		takePartialAsk(tmsg);
		return tmsg;
	}	

	function takeFullAsk(TradeMessage tmsg, uint8 depth)
		// * NOTE * This function can recurse by design.
		internal
		notTooDeep(depth)
//		returns (TradeMessage)
	{
//		if (depth == 0) return tmsg;
		if (depth == 0) return;
		uint curPrice = spread(ASK);
		Order ord = orders[getFirstOrderIdAtPrice(curPrice)];
		if (tmsg.value < ord.valueAmount)
			// insufficient funds for full take
//			return tmsg;
			return;
		tmsg.value -= ord.valueAmount;
		tmsg.amount += toAmount(ord.valueAmount, curPrice);
		closeFIFOAskOrder(curPrice);
		takeFullAsk(tmsg, depth);
//		return tmsg;
	}

	function takePartialAsk(TradeMessage tmsg)
		internal
//		returns (TradeMessage)
	{
		uint curPrice = spread(ASK);
		Order ord = orders[getFirstOrderIdAtPrice(curPrice)];
		tmsg.amount += toAmount(tmsg.value, curPrice);
		ord.valueAmount -= tmsg.value;
		etherBalances[ord.trader] += tmsg.value;
		tmsg.value = 0;
//		return tmsg;
	}

	function makeBid(TradeMessage tmsg)
		internal
//		returns (TradeMessage)
	{
		uint orderId = orders.push(Order(tmsg.value, msg.sender)) - 1;
		uint price = toPrice(tmsg.value, tmsg.amount);
		tmsg.value = 0;
		if (!isValidKey(price, 0)) insertFIFO(price, BID); // Make sure price FIFO exists
		insert(price, HEAD, orderId, PREV, false); // Insert order ID into price FIFO
		lists[price].auxData += tmsg.amount; // Update price volume
//		return tmsg;
	}

	function closeFIFOAskOrder(uint _price)
		// internal
		returns (bool)
	{
		uint _orderId = lists[_price].nodes[step(_price, HEAD, NEXT)].dataIndex;
		closeAskOrder(_orderId, _price);
		return true;
	}

	function closeAskOrder(uint _orderId, uint _price)
		// internal
		returns (bool)
	{
		remove(_price, _orderId);
		lists[_price].auxData -= toAmount(_price, orders[_orderId].valueAmount);
		if (lists[_price].size == 0) {
			remove(PRICE_BOOK, _price);
			delete lists[_price].nodes[0];
			delete lists[_price];
		}
		delete orders[_orderId];
		return true;
	}

	function takeBids(TradeMessage tmsg)
		internal
//		returns (TradeMessage)
	{
		if (cmp(tmsg.price, spread(BID), ASK))
			// nothing to take
//			return tmsg;
			return;
		takeFullBid(tmsg, MAXDEPTH);
		takePartialBid(tmsg);
//		return tmsg;
	}	

	function takeFullBid(TradeMessage tmsg, uint8 depth)
		// * NOTE * This function can recurse by design.
		internal
		notTooDeep(depth)
//		returns (TradeMessage)
	{
		uint curPrice = spread(BID);
		Order ord = orders[getFirstOrderIdAtPrice(curPrice)];
		if (tmsg.value < ord.valueAmount)
			// insufficient funds for full take
//			return tmsg;
			return ;
		tmsg.value += ord.valueAmount;
		tmsg.amount -= toAmount(ord.valueAmount, curPrice);
		closeFIFOAskOrder(curPrice);
		takeFullAsk(tmsg, depth);
//		return tmsg;
	}

	function takePartialBid(TradeMessage tmsg)
		internal
//		returns (TradeMessage)
	{
		uint curPrice = spread(BID);
		Order ord = orders[getFirstOrderIdAtPrice(curPrice)];
		tmsg.amount -= toAmount(tmsg.value, curPrice);
		ord.valueAmount += tmsg.value;
		etherBalances[ord.trader] += tmsg.value;
		tmsg.value = 0;
//		return tmsg;
	}

	function makeAsk(TradeMessage tmsg)
		internal
//		returns (TradeMessage)
	{
		uint orderId = orders.push(Order(tmsg.amount, msg.sender)) - 1;
		uint price = toPrice(tmsg.value, tmsg.amount);
		tmsg.amount = 0;
		if (!isValidKey(price, 0)) insertFIFO(price, ASK); // Make sure price FIFO exists
		insert(price, HEAD, orderId, PREV, false); // Insert order ID into price FIFO
		lists[price].auxData += tmsg.amount; // Update price volume
//		return tmsg;
	}

	function closeFIFOBidOrder(uint _price)
		// internal
		returns (bool)
	{
		uint _orderId = lists[_price].nodes[step(_price, HEAD, NEXT)].dataIndex;
		closeAskOrder(_orderId, _price);
		return true;
	}

	function closeBidOrder(uint _orderId, uint _price)
		// internal
		returns (bool)
	{
		remove(_price, _orderId);
		lists[_price].auxData -= toAmount(_price, orders[_orderId].valueAmount);
		if (lists[_price].size == 0) {
			remove(PRICE_BOOK, _price);
			delete lists[_price].nodes[0];
			delete lists[_price];
		}
		delete orders[_orderId];
		return true;
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
