contract LibModifiers
{
/* Modifiers */

	uint constant MAXNUM = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
	uint constant MINNUM = 1;
	uint constant NULL = 0;

	// To throw call not made by owner
	modifier isOwner() {
		if (msg.sender != owner) throw;
		_
	}

	// To lock a function from entry if it or another protected function
	// has already been called and not yet returned.
	modifier isProtected() {
		if(mutex) throw;
		else mutex = true;
		_
		delete mutex;
		return;  // Functions require singele exit and return parameters
	}
	address owner;
	bool mutex;
}


contract MultiCircularLinkedList 
{
/* Modifiers */

	// To test if mapping keys point to a valid linked list node.
	modifier keyExists(uint _listKey, uint _nodeKey) { 
		if (linkedLists[_listKey].nodes[_nodeKey].dataIndex == 0) throw; _
	}

	modifier isValidData(uint _dataIdx) {
		if (_dataIdx == 0) throw; _
	}

	modifier isNotEmpty(uint _listKey) {
		if (linkedLists[_listKey].size == 0) throw; _
	}
	
/* Structs */

	// Generic double linked list node.
	struct DoubleLinkNode {
		uint dataIndex;
		uint next;
		uint prev;
	}
	
	// Generic circular linked list parameters. Head is static index 1.
	struct LinkedList {
		uint size;	// Number of nodes
		uint newNodeKey; // Next free mapping slot
		uint auxData; // auxilary data state variable.
		mapping (uint => DoubleLinkNode) nodes;
	}
	
/* Constants */

	uint constant HEAD = 0; // All linked lists are circular with static head.
	bool constant PREV = false;
	bool constant NEXT = true;

/* State valiables */

	// `linkedLists` is a mapping to store all circular linked lists.
	// The `dataIndex` of each node in the index list (key == 0) is the key for a
	// a child linked list, e.g:
	//
	//     linkedLists[0].dataIndex == 100 --> linkedLists[100]
	//
	// The dataIndex of a child list (key !=0) can be use as a key or index for
	// an array or mapping, e.g.
	//
	//     linkedLists[100].dataIndex == 123 --> data[123]
	//

	mapping (uint => LinkedList) public linkedLists;  

/* State variable Accessor Functions (For reference only. Leave commented)

	function linkedLists(uint listKey, uint nodeKey, uint DATAINDEX) returns (uint) // dataIndex
	function linkedLists(uint listKey, uint nodeKey, uint NEXT) returns (uint) // next
	function linkedLists(uint listKey, uint nodeKey, uint PREV) returns (uint) // prev
*/

/* Functions */

	// Initialises circular linked list to a valid state
	function initLinkedList(uint _listKey, bool _reset) 
		returns (bool)
//		internal
	{
		if (linkedLists[_listKey].nodes[HEAD].dataIndex != 0 && !_reset) 
			return false; // Already exisits.
		linkedLists[_listKey].newNodeKey = 1; // key 1 is already head
		linkedLists[_listKey].nodes[HEAD].next = HEAD; // set next link to head
		linkedLists[_listKey].nodes[HEAD].prev = HEAD; // set previous link to head
		linkedLists[_listKey].nodes[HEAD].dataIndex = 1;
		return true;
	}

	function insertBefore(uint _listKey, uint _nodeKey, uint _dataIndex)
//		internal
		keyExists(_listKey, _nodeKey)
		isValidData(_dataIndex)
		returns (uint)
	{
		LinkedList list = linkedLists[_listKey];
		DoubleLinkNode newNode = list.nodes[list.newNodeKey];
		newNode.next = _nodeKey;
		newNode.prev = list.nodes[_nodeKey].prev;
		list.nodes[list.nodes[_nodeKey].prev].next = list.newNodeKey;
		list.nodes[_nodeKey].prev = list.newNodeKey;
		newNode.dataIndex = _dataIndex; // Store new data.
		list.size++;
		list.newNodeKey++;
		return list.newNodeKey - 1;
	}

	function insertAfter(uint _listKey, uint _nodeKey, uint _dataIndex)
//		internal
		keyExists(_listKey, _nodeKey)
		isValidData(_dataIndex)
		returns (uint)
	{
		LinkedList list = linkedLists[_listKey];
		DoubleLinkNode newNode = list.nodes[list.newNodeKey];
		newNode.prev = _nodeKey;
		newNode.next = list.nodes[_nodeKey].next;
		list.nodes[list.nodes[_nodeKey].next].prev = list.newNodeKey;
		list.nodes[_nodeKey].next = list.newNodeKey;
		newNode.dataIndex = _dataIndex; // Store new data.
		list.size++;
		list.newNodeKey++;
		return list.newNodeKey - 1;
	}
	
	function update(uint _listKey, uint _nodeKey, uint _dataIndex)
//		internal
		keyExists(_listKey, _nodeKey)
		returns (bool)
	{
		linkedLists[_listKey].nodes[_nodeKey].dataIndex = _dataIndex;
		return true;
	}
		
	function remove(uint _listKey, uint _nodeKey)
//		internal
		keyExists(_listKey, _nodeKey)
		isNotEmpty(_listKey)
		returns (bool)
	{
		LinkedList list = linkedLists[_listKey];
		list.nodes[list.nodes[_nodeKey].prev].next = list.nodes[_nodeKey].next;
		list.nodes[list.nodes[_nodeKey].next].prev = list.nodes[_nodeKey].prev;
		list.size--;
		delete list.nodes[_nodeKey];  // delete the node.
		return true;
	}
	
	function stepPrev(uint _listKey, uint _nodeKey)
		keyExists(_listKey, _nodeKey)
		constant returns (uint)
	{
		return linkedLists[_listKey].nodes[_nodeKey].prev;
	}

	function stepNext(uint _listKey, uint _nodeKey)
		keyExists(_listKey, _nodeKey)
		constant returns (uint)
	{
		return linkedLists[_listKey].nodes[_nodeKey].next;
	}

	function seekUp(uint _listKey, uint _start, uint _target)
		keyExists(_listKey, _start)
		constant returns (uint)
	{
		LinkedList list = linkedLists[_listKey];
		while(list.nodes[_start].next < _target) _start = list.nodes[_start].next;
		return _start;
	}

	function seekDown(uint _listKey, uint _start, uint _target)
		keyExists(_listKey, _start)
		constant returns (uint)
	{
		LinkedList list = linkedLists[_listKey];
		while(list.nodes[_start].prev > _target) _start = list.nodes[_start].prev;
		return _start;
	}

	function isValidKey(uint _listKey, uint _nodeKey) 
		constant
		returns (bool)
	{ 
		if (linkedLists[_listKey].nodes[_nodeKey].dataIndex > 0) 
			return true;
	}
}
// EIP20 Standard Token Interface


contract EIP20Interface is LibModifiers
{
    /* Modifiers */
	modifier isAvailable(uint _amount) {
		if (_amount < balances[msg.sender]) throw;
		_
	}
	
	modifier hasAllowance(address _from, uint _amount) {
		if (_amount > allowances[_from][msg.sender] ||
		   _amount > balances[_from]) throw;
		_
	}

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
        isProtected()
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
        isProtected
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
        isProtected
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


/* Intrinsically Tradable Token code */	
contract ITT is EIP20Token, MultiCircularLinkedList
{

/* Modifiers */
	modifier isValidBuy(uint _bidPrice) {
		if (msg.value == 0 || _bidPrice == 0) throw; _	// has nothing to spend
	}

	modifier isValidSell(uint _askPrice, uint _amount) {
		if (_amount > balances[msg.sender] ||
			_askPrice == 0 ||
			_amount == 0) throw; _
	}

	modifier ownsOrder(uint _orderId) {
		if (msg.sender != orders[_orderId].trader) throw; _		
	}

/* Structs */

	struct Order {
		uint price; // Price in ether
		uint amount; // Amount of tokens to trade
		address trader; // Token holder address
	}
	
/* Constants */

	bool constant BUY = false;
	bool constant BID = false;
	bool constant SELL = true;
	bool constant ASK = true;
	bool constant MAKE = false;
	bool constant TAKE = true;
	bool constant NO_RESET = false;
	bool constant RESET = true;
	uint constant PRICE_BOOK = 0;



/* State Valiables */

	// Orders in order of creation
	Order[] public orders;
    // Token holder accounts
    mapping (address => uint) public balances;
    mapping (address => uint) public unavailable;

/* Functions */

	function ITT() {
		totalSupply = 1000000;
		balances[msg.sender] = 1000000;
		linkedLists[PRICE_BOOK].nodes[HEAD].dataIndex = 1;
		linkedLists[PRICE_BOOK].nodes[MINNUM].dataIndex = 1;
		linkedLists[PRICE_BOOK].nodes[MAXNUM].dataIndex = 1;
		linkedLists[PRICE_BOOK].nodes[HEAD].next = MAXNUM;
		linkedLists[PRICE_BOOK].nodes[MAXNUM].prev = HEAD;
		linkedLists[PRICE_BOOK].nodes[HEAD].prev = MINNUM;
		linkedLists[PRICE_BOOK].nodes[MINNUM].next = HEAD;
	}
	
	function () 
		isProtected
	{ 
		throw; // refuse payments
	}
		
/* Functions Getters */

	function getMetrics()
		constant
		returns (
			uint _balance,
			uint _available,
			uint _lowestAsk,
			uint _highestBid,
			uint _askVol,
			uint _bidVol
		)
	{
		_balance = balances[msg.sender];
		_available = _balance - unavailable[msg.sender];
		_lowestAsk = lowestAsk();
		_highestBid = highestBid();
		_askVol = linkedLists[_lowestAsk].auxData;
		_bidVol = linkedLists[_highestBid].auxData;
		return;
	}

	function getVolumeAtPrice(uint _price)
		constant
		returns (uint)
	{
		return linkedLists[_price].auxData;
	}
	
	function highestBid() 
		constant
		returns(uint)
	{
		return stepPrev(PRICE_BOOK, HEAD);
	}
	
	function lowestAsk() 
		constant 
		returns(uint)
	{
		return stepNext(PRICE_BOOK, HEAD);
	}


/* Functions Public */

	function buy (uint _bidPrice, bool _make) public
		isProtected
		isValidBuy(_bidPrice)
		returns (bool _success, uint _spent, uint _ordId)
	{

		uint ethRemaining = msg.value; 
		_spent = ethRemaining; // tally to return unspent ether.
		
		while (_bidPrice >= lowestAsk() && ethRemaining > 0){
			// Take lowest sell order below the bid price.
			// *ANALYSIS REQ* LOOP -How prone to gas limit failures?
			ethRemaining = takeAsk(ethRemaining);
		}

		if (ethRemaining > 0 && _make) {
			// Make 'Buy' order with leftover ether.
			_ordId = make(_bidPrice, ethRemaining / _bidPrice, BID);
		}

		if (ethRemaining > 0 && !_make) {
			// does not wish to make an order so refund leftover ether.
			// *ANALYSIS REQ* Is this prone to ether bootstrap failure?
			if(!msg.sender.send(ethRemaining)) throw;
		}
		_spent -= ethRemaining;
		_success = true;
	}

	function sell (uint _askPrice, uint _amount, bool _make) public 
		isProtected
		isValidSell(_askPrice, _amount)
		returns (bool _success, uint _sold, uint _ordId)
	{
		uint amountRemaining = _amount;
		while (_askPrice <= highestBid() && amountRemaining > 0)	{
			// Take highest bid order above the ask price.
			// *ANALYSIS REQ* LOOP - How prone to gas limit failures?
			amountRemaining = takeBid(amountRemaining);
		}

		if (amountRemaining > 0 && _make) {
			// Make 'Sell' order with remaining amount.
			_ordId = make(_askPrice, amountRemaining, ASK);
		}
		_sold -= _amount;
		_success = true;
	}

	function cancelOrder(uint _orderId) public
		isProtected
		ownsOrder(_orderId)
		returns (bool _success)
	{
		closeOrder(_orderId);
		_success = true;
	}

/* Functions Internal */

	function make(uint _price, uint _amount, bool _swap)
//		internal
		returns (uint _orderId)
	{
		Order memory order;
		order.trader = msg.sender;
		order.price = _price;
		order.amount = _amount;
		_orderId = orders.push(order);
		insertPrice(_price, _swap); // setup FIFO in price book
		insertBefore(_price, HEAD, _orderId); // insert order into FIFO
		addVolume(_price, _amount);
		return _orderId;		
	}
	
	function getNextOrderId(uint _price) 
		// internal
		constant
		returns (uint)
	{
		return linkedLists[_price].nodes[stepNext(_price,HEAD)].dataIndex;
	}

	function takeAsk(uint _ether)
//		internal
		returns (uint _ethRemaining)
	{
		Order order = orders[getNextOrderId(lowestAsk())];
		uint amount = _ether / lowestAsk();
		if (amount < order.amount) {
			swap(order.trader, msg.sender, order.price, amount);
			_ethRemaining = 0;
			order.amount -= amount;
			return;
		}
		swap(order.trader, msg.sender, order.price, order.amount);
		_ethRemaining = _ether - order.price * order.amount;
		closeOrder(lowestAsk());
		return;		
	}
	
	function takeBid(uint _amount)
//		internal
		returns (uint _amountRemaining)
	{
		Order order = orders[getNextOrderId(highestBid())];
		if (_amount < order.amount) {
			swap(msg.sender, order.trader, order.price, _amount);
			_amountRemaining = 0;
			order.amount -= _amount;
			return;
		}
		swap(msg.sender, order.trader, order.price, order.amount);
		_amountRemaining = _amount - order.amount;
		closeOrder(highestBid());
		return;		
	}
	
	function closeOrder(uint _orderId)
//		internal
		returns (bool)
	{
		uint price = orders[_orderId].price;
		remove(price, _orderId);
		linkedLists[price].auxData -= orders[_orderId].amount;
		if (linkedLists[orders[_orderId].price].size == 0) {
			remove(PRICE_BOOK, price);
		}
		delete orders[_orderId];
		return true;
	}
		
	function swap(address _seller, address _buyer, uint _price, uint _amount)
//		internal
		returns (bool)
	{
		if (balances[_seller] < _amount) throw;
		balances[_seller] -= _amount;
		unavailable[_seller] -= _amount;
		if(!_seller.send(_price * _amount)) throw;
		balances[_buyer] += _amount;
		return true;
	}

	function addVolume(uint _price, uint _amount) 
		internal
	{
		linkedLists[_price].auxData += _amount; // update volume		
	}

	function subVolume(uint _price, uint _amount) 
		internal
	{
		linkedLists[_price].auxData -= _amount; // update volume		
	}

	function insertPrice(uint _price, bool _swap)
		internal
		returns (uint _nodeKey)
	{
		if (!initLinkedList(_price, NO_RESET)) return; // already in Price_book
		linkedLists[0].newNodeKey = _price; // Price Book nodes are the actual prices

		if (_swap == SELL) {
			// Is selling
			if (_price < lowestAsk()) {
				// is lowest ask
				return insertBefore(PRICE_BOOK, lowestAsk(), _price);
			} else {
				// is higher than lowest ask 
				return insertAfter(PRICE_BOOK,
					seekUp(PRICE_BOOK, lowestAsk(), _price),
					_price);			
			}			
		} else {
			// Is buying
			if (_price > highestBid()) {
				// is highest bid
				return insertAfter(PRICE_BOOK, highestBid(), _price);
			} else {
				// is lower than highest bid
				return insertBefore(PRICE_BOOK,
					seekDown(PRICE_BOOK, highestBid(), _price),
					_price);
			}
				// return insertBefore(PRICE_BOOK, seekDown(PRICE_BOOK, highestBid(), _price), _price);
		}
		return;
	}
}
