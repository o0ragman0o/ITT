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
	modifier mtxProtect() {
		// if(mutex) throw;
		// else mutex = true;
		_
		// delete mutex;
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
        mtxProtect()
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
        mtxProtect
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
        mtxProtect
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
		uint price; // Price in ether
		uint amount; // Amount of tokens to trade
		address trader; // Token holder address
	}
	
/* Constants */

	uint constant PRICE_BOOK = 0;
	bool constant BID = false;
	bool constant ASK = true;
	bool constant SELLER = false;
	bool constant BUYER = true;

/* State Valiables */

	// Orders in order of creation
	Order[] public orders;

    // Token holder accounts
    mapping (address => uint) public balances;
    mapping (address => uint) public lockedTokens;
	mapping (address => uint) public etherBalances;
	mapping (address => uint) public lockedEther;

    // LinkedList public lists[PRICE_BOOK] = lists[PRICE_BOOK];
	
/* Modifiers */

	modifier isValidBuy(uint _bidPrice, uint _amount) {
		etherBalances[msg.sender] += msg.value;
		if (etherBalances[msg.sender] < (_amount * _bidPrice)
		 	|| _bidPrice == NULL) throw;
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
		lists[PRICE_BOOK].nodes[HEAD].dataIndex = MINNUM;
		lists[PRICE_BOOK].nodes[HEAD].links[PREV] = MINNUM;
		lists[PRICE_BOOK].nodes[HEAD].links[NEXT] = MAXNUM;

		lists[PRICE_BOOK].nodes[MAXNUM].dataIndex = MAXNUM;
		lists[PRICE_BOOK].nodes[MAXNUM].links[PREV] = HEAD;
		lists[PRICE_BOOK].nodes[MAXNUM].links[NEXT] = MAXNUM;

		lists[PRICE_BOOK].nodes[MINNUM].dataIndex = MINNUM;
		lists[PRICE_BOOK].nodes[MINNUM].links[PREV] = MINNUM;
		lists[PRICE_BOOK].nodes[MINNUM].links[NEXT] = HEAD;
		
		orders.push(Order(1,1,0)); // dummy order at index 0 to allow for order validation
	}
	
	function () 
		mtxProtect
	{ 
//		etherBalances[msg.sender] += msg.value;
		throw;
	}

/* Functions Getters */

	function getMetrics()
		constant
		returns (
			uint _balance,
			uint _available,
			uint _etherBalance,
			uint _unlockedEth,
			uint _lowestAsk,
			uint _highestBid,
			uint _askVol,
			uint _bidVol
		)
	{
		_balance = balances[msg.sender];
		_available = unlockedTokens(msg.sender);
		_etherBalance = etherBalances[msg.sender];
		_unlockedEth = unlockedEther(msg.sender);
		_lowestAsk = spread(ASK);
		_highestBid = spread(BID);
		_askVol = lists[_lowestAsk].auxData;
		_bidVol = lists[_highestBid].auxData;
		return;
	}

	function unlockedTokens(address _addr) public
		constant
		returns (uint)
	{
		return balances[_addr] - lockedTokens[_addr];
	}
	
	function unlockedEther(address _addr) public
		constant
		returns (uint)
	{
		return etherBalances[_addr] - lockedEther[_addr];
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

/* Functions Public */

	function buy (uint _bidPrice, uint _amount, bool _make) public
		mtxProtect
		isValidBuy(_bidPrice, _amount)
		returns (bool _success, uint _spent, uint _ordId)
	{
		uint ethRemaining = _bidPrice * _amount;
		_spent = ethRemaining; // tally to return unspent ether.
		
		while (ethRemaining > 0 && _bidPrice >= spread(ASK)){
			// Take lowest sell order below the bid price.
			// *ANALYSIS REQ* LOOP -How prone to gas limit failures?
			lockedEther[msg.sender] += ethRemaining;
			ethRemaining = take(ethRemaining / _bidPrice, ASK) * _bidPrice;
		}

		if (_make && ethRemaining > 0) {
			// Make 'Buy' order with leftover ether.
			_ordId = make(_bidPrice, ethRemaining / _bidPrice, BID);
			lockedEther[msg.sender] += ethRemaining; // lock ether from withdrawal
		}
		_spent -= ethRemaining;
		_success = true;
	}

	function sell (uint _askPrice, uint _amount, bool _make) public 
		mtxProtect
		isValidSell(_askPrice, _amount)
		returns (bool _success, uint _sold, uint _ordId)
	{
		uint amountRemaining = _amount;
		_sold = amountRemaining;
		while (amountRemaining > 0 && _askPrice <= spread(BID))	{
			// Take highest bid order above the ask price.
			// *ANALYSIS REQ* LOOP - How prone to gas limit failures?
			lockedTokens[msg.sender] += amountRemaining;
			amountRemaining = take(amountRemaining, BID);
		}

		if (_make && amountRemaining > 0) {
			// Make 'Sell' order with remaining amount.
			_ordId = make(_askPrice, amountRemaining, ASK); // Store order details
			lockedTokens[msg.sender] += _amount; // lock tokens from double sell attemps
		}
		_sold -= _amount;
		_success = true;
	}
	
	function withdraw(uint _ether) public
		mtxProtect
		hasEther(msg.sender, _ether)
		returns (bool _success)
	{
		etherBalances[msg.sender] -= _ether;
		if(!msg.sender.send(_ether)) throw;
		_success = true;
	}

	function cancel(uint _orderId) public
		mtxProtect
		ownsOrder(_orderId)
		returns (bool _success)
	{
		closeOrder(_orderId);
		_success = true;
	}

	// Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) 
        mtxProtect	
		returns (bool success)

    {
        if (unlockedTokens(msg.sender) < _value) throw;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success = true;
    }


    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
        mtxProtect
		returns (bool success)
    {
        if (unlockedTokens(_from) < _value || _value < allowances[_from][msg.sender]) throw;
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        success = true;
    }



/* Functions Internal */

	function make (uint _price, uint _amount, bool _swap)
		// internal
		returns (uint _orderId)
	{
		_orderId = orders.push(Order(_price, _amount, msg.sender)) - 1;
		if (!isValidKey(_price, 0)) 
			insertFIFO(_price, _swap); // Make sure price FIFO exists
		insert(_price, HEAD, _orderId, PREV, false); // Insert order ID into price FIFO
		lists[_price].auxData += _amount; // Update price volume
		return;
	}
		
	function take(uint _amount, bool _swap)
		// internal
		returns (uint _amountRemaining)
	{
		mapping (bool => address) traders;
		Order order = orders[getFirstOrderIdAtPrice(spread(_swap))];
		traders[_swap] = msg.sender;
		traders[!_swap] = order.trader;

		if (_amount < order.amount) {
			_amountRemaining = 0;
			swap(traders[SELLER], traders[BUYER], order.price * _amount, _amount);
			order.amount -= _amount;
			lists[order.price].auxData -= _amount;
			return;
		}
		swap(traders[SELLER], traders[BUYER], order.price * _amount, order.amount);
		
		_amountRemaining = _amount - order.amount;
		closeFIFOOrder(spread(_swap));
		return;
	}

	function swap(address _seller, address _buyer, uint _ether, uint _amount)
		// internal
		hasBalance(_seller, _amount)
		hasEther(_buyer, _ether)
		returns (bool)
	{
		balances[_seller] -= _amount;
		balances[_buyer] += _amount;
		etherBalances[_seller] += _ether;
		etherBalances[_buyer] -= _ether;
		lockedTokens[_seller] -= _amount;
		lockedEther[_buyer] -= _ether;
		return true;
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
		uint a = seekInsert(_price, _dir);
		insert(PRICE_BOOK, a, _price, !_dir, true); // Insert order ID into price FIFO
		return true;
	}
}
