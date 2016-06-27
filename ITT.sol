 contract LibModifiers
{
/* Modifiers */

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


contract MultiCircularLinkedList 
{
/* Modifiers */

	// To test if mapping keys point to a valid linked list node.
	modifier isValidKey(uint _listKey, uint _nodeKey) { 
		if (linkedLists[_listKey].nodes[_nodeKey].next == 0) throw; _
	}

	modifier isNotEmpty(uint _listKey) {
		if (linkedLists[_listKey].size == 0) throw; _
	}
	
	// modifier stepDirection(bool _dir) {
	// 	uint NEXT = 1;
	// 	uint PREV = 2;
	// 	if (_dir) {
	// 		NEXT = 2;
	// 		PREV = 1;
	// 	}
	// }

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

	uint constant HEAD = 1; // All linked lists are circular with static head.
	uint constant DATAINDEX = 0;

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

	mapping (uint => LinkedList) linkedLists;  

/* State variable Accessor Functions (For reference only. Leave commented)

	function linkedLists(uint listKey, uint nodeKey, uint DATAINDEX) returns (uint) // dataIndex
	function linkedLists(uint listKey, uint nodeKey, uint NEXT) returns (uint) // next
	function linkedLists(uint listKey, uint nodeKey, uint PREV) returns (uint) // prev
*/

/* Functions */

	// Initialises circular linked list to a valid state
	function initLinkedList(uint _listKey, bool _reset)
		internal
	{
		if (linkedLists[_listKey].nodes[HEAD].next != 0 && !_reset) return;
		linkedLists[_listKey].newNodeKey = 2; // key 1 is already head
		linkedLists[_listKey].nodes[1].next = HEAD; // set next link to head
		linkedLists[_listKey].nodes[1].prev = HEAD; // set previous link to head
	}

	// Inserts new node before or after node key.
	function insertNode(uint _listKey, uint _nodeKey, uint _dataIndex, bool _dir)
		isValidKey(_listKey, _nodeKey)
		returns (uint)
	{
		LinkedList list = linkedLists[_listKey];
		DoubleLinkNode newNode = list.nodes[list.newNodeKey];
		if (_dir) {
			// Insert before node.
			newNode.next = _nodeKey;
			newNode.prev = list.nodes[_nodeKey].prev;
			list.nodes[list.nodes[_nodeKey].prev].next = list.newNodeKey;
			list.nodes[_nodeKey].prev = list.newNodeKey;
		} else {
			// Insert after node.
			newNode.prev = _nodeKey;
			newNode.next = list.nodes[_nodeKey].next;
			list.nodes[list.nodes[_nodeKey].next].prev = list.newNodeKey;
			list.nodes[_nodeKey].next = list.newNodeKey;
		}
		newNode.dataIndex = _dataIndex; // Store new data.
		list.size++;
		list.newNodeKey++;
		return list.newNodeKey - 1;
	}
	
	function update(uint _listKey, uint _nodeKey, uint _dataIndex)
		isValidKey(_listKey, _nodeKey)
		returns (bool)
	{
		linkedLists[_listKey].nodes[_nodeKey].dataIndex = _dataIndex;
		return true;
	}
		
	function remove(uint _listKey, uint _nodeKey)
		isValidKey(_listKey, _nodeKey)
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
	
	function step(uint _listKey, uint _nodeKey, bool _dir)
//	function step(uint _listKey, uint _nodeKey, uint _dir)
		isValidKey(_listKey, _nodeKey)
		constant returns (uint)
	{
//		return linkedLists(_listKey,_nodeKey, _dir);
		 if (_dir) return linkedLists[_listKey].nodes[_nodeKey].prev;
		else return linkedLists[_listKey].nodes[_nodeKey].next;
	}
}


/* Intrinsically Tradable Token code */	
contract ITT is EIP20Token, MultiCircularLinkedList
{

/* Modifiers */

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
	uint constant PRICEBOOK = 0;


/* State Valiables */

	// Orders in order of creation
	Order[] public orders;
    // Token holder accounts
    mapping (address => uint) balances;
    mapping (address => uint) unavailable;

/* Functions */

	function ITT() {
		balances[msg.sender] = 1000000;
		}
	
	function () 
		isProtected
	{ 
		throw; // refuse payments
	}
		
/* Functions Getters */

	function getVolumeAtPrice(uint _price)
		constant
		returns (uint _volume)
	{
		_volume = linkedLists[PRICEBOOK].auxData;
	}
	
	function highestBid() constant returns(uint)
	{
		return step(PRICEBOOK, HEAD, BID);
	}
	
	function lowestAsk() constant returns(uint)
	{
		return step(PRICEBOOK, HEAD, ASK);
	}

/* Functions Public */

	function buy (uint _bidPrice, bool _make) public
		isProtected
		returns (bool _success, uint _spent, uint _ordId)
	{
		if (msg.value == 0 ||
			_bidPrice == 0) throw;	// has nothing to spend

		uint ethRemaining = msg.value; 
		_spent = ethRemaining; // tally to return unspent ether.
		
		while (_bidPrice >= lowestAsk() && ethRemaining > 0){
			// Take lowest sell order below the bid price.
			// *ANALYSIS REQ* LOOP -How prone to gas limit failures?
			ethRemaining = takeAsk(ethRemaining);
		}

		if (ethRemaining > 0 && _make) {
			// Make 'Buy' order with leftover ether.
			_ordId = makeBid(_bidPrice, ethRemaining / _bidPrice);
		} else {
			_ordId = 0;
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
		returns (bool _success, uint _sold, uint _ordId)
	{
		if (_amount > balances[msg.sender] ||
			_askPrice == 0 ||
			_amount == 0) throw;

		uint amountRemaining = _amount;
		while (_askPrice <= highestBid() && amountRemaining > 0)	{
			// Take highest bid order above the ask price.
			// *ANALYSIS REQ* LOOP - How prone to gas limit failures?
			amountRemaining = takeBid(amountRemaining);
		}

		if (amountRemaining > 0 && _make) {
			// Make 'Sell' order with remaining amount.
			_ordId = makeAsk(_askPrice, amountRemaining);
		} else {
			_ordId = 0;
		}
		_sold -= _amount;
		_success = true;
	}

	function cancel(uint _orderId) public
		isProtected
		returns (bool _success)
	{
		if (msg.sender != orders[_orderId].trader) throw;
		closeOrder(_orderId);
		_success = true;
	}

/* Functions Internal */

	function openOrder(uint _price, uint _amount, bool _swap)
		internal
		returns (uint _orderId)
	{
		Order order = orders[orders.length];
		_orderId = orders.length++;
		order.trader = msg.sender;
		order.price = _price;
		order.amount = _amount;
		initLinkedList(_price, false); // ensure price
		insertNode(_price, HEAD, _orderId, MAKE);
		linkedLists[_price].auxData += _amount; // update volume
		return _orderId;		
	}

	function makeBid(uint _price, uint _amount)
		internal
		returns (uint _ordId)
	{
		_ordId = openOrder(_price, _amount, BID);
		return;
	}

	function makeAsk(uint _price, uint _amount)
		internal
		returns (uint _ordId)
	{
		_ordId = openOrder(_price, _amount, ASK);
		return;
	}
	
	function takeAsk(uint _ether)
		internal
		returns (uint _ethRemaining)
	{
		Order order = orders[lowestAsk()];
		uint amount = _ether / order.price;
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
		internal
		returns (uint _amountRemaining)
	{
		Order order = orders[highestBid()];
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
		internal
		returns (bool)
	{
		uint price = orders[_orderId].price;
		remove(price, _orderId);
		linkedLists[price].auxData -= orders[_orderId].amount;
		if (linkedLists[orders[_orderId].price].size == 0)
			remove(PRICEBOOK, price);
		delete orders[_orderId];
		return true;
	}
		
	function swap(address _seller, address _buyer, uint _price, uint _amount)
		internal
		returns (bool)
	{
		if (balances[_seller] < _amount) throw;
		balances[_seller] -= _amount;
		unavailable[_seller] -= _amount;
		if(!_seller.send(_price * _amount)) throw;
		balances[_buyer] += _amount;
		return true;
	}
}
