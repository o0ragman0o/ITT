
contract MultiCircularLinkedList {
/* Constants */

    uint constant NULL = 0;
    uint constant HEAD = NULL; // Lists are circular with static head.
    uint constant MAXNODE = 2**128;
    bool constant PREV = false;
    bool constant NEXT = true;
    
/* Structs */

    // Generic double linked list node.
    struct DoubleLinkNode {
        uint dataIndex;
        mapping (bool => uint) links;
    }
    
    // Generic circular linked list parameters. Head is static index 0.
    struct LinkedList {
        uint size;  // Number of nodes
        uint newNodeKey; // Next free mapping slot
        uint auxData; // auxilary data state variable.
        mapping (uint => DoubleLinkNode) nodes;
    }
    

/* State valiables */

    mapping (uint => LinkedList) public lists; 

/* Modifiers */

    // To test if mapping keys point to a valid linked list node.
    modifier isValidKey(uint _listKey, uint _nodeKey) { 
        if (lists[_listKey].nodes[_nodeKey].dataIndex == 0) return; 
        _
    }

    // To test if supplied is >0. Does not test is data at index is valid 
    modifier isValidDataIndex(uint _dataIdx) {
        if (_dataIdx == 0) return; 
        _
    }

/* Functions */

    function getNode(uint _listKey, uint _nodeKey)
    	public
        constant
        returns (uint dataIndex_, uint prev_, uint next_)
    {
        dataIndex_ = lists[_listKey].nodes[_nodeKey].dataIndex;
        prev_ = lists[_listKey].nodes[_nodeKey].links[PREV];
        next_ = lists[_listKey].nodes[_nodeKey].links[NEXT];
    }

    function keyExists(uint _listKey, uint _nodeKey)
        public
        constant
        isValidKey(_listKey, _nodeKey)
        returns (bool)
    { 
        return true;
    }

    // Initialises circular linked list to a valid state
    function initLinkedList(uint _listKey, bool _reset) 
        internal
        returns (bool)
    {
        LinkedList list = lists[_listKey];
        if (list.nodes[HEAD].dataIndex != NULL && !_reset)
        	return false; // List already exisits.
        list.newNodeKey = 1; // key 0 is already head
        list.nodes[HEAD].links[NEXT] = HEAD; // set next link to head
        list.nodes[HEAD].links[PREV] = HEAD; // set previous link to head
        list.nodes[HEAD].dataIndex = 1;
        return true;
    }

    function stitch(uint _listKey, uint a, uint b, bool _dir)
    	internal
    {
     	lists[_listKey].nodes[a].links[_dir] = b;
    	lists[_listKey].nodes[b].links[!_dir] = a;
    }
	
    // Creates a new unlinked node or updates existing node dataIndex
    // `_nodeKey` is arbtrary or auto assigned if 0.
    function update(uint _listKey, uint _nodeKey, uint _dataIndex)
        internal
        returns (uint)
    {
        LinkedList list = lists[_listKey];
        if (_nodeKey == 0) _nodeKey = list.newNodeKey++;
        if (!keyExists(_listKey, _nodeKey)) list.size++;
        lists[_listKey].nodes[_nodeKey].dataIndex = _dataIndex;
        return _nodeKey;
    }
  
    function newNode(uint _listKey, uint _nodeKey, uint _dataIndex)
        internal
        returns (uint)
    {
            return update(_listKey, _nodeKey, _dataIndex);
    }

    // _dir == false  Inserts new node BEFORE _nodeKey
    // _dir == true   Inserts new node AFTER _nodeKey
    function insert (uint _listKey, uint a, uint b, bool _dir)
        internal
        isValidKey(_listKey, a)
    {
        LinkedList list = lists[_listKey];
        uint c = list.nodes[a].links[_dir];
        stitch (_listKey, a, b, _dir);
        stitch (_listKey, b, c, _dir);
    }

    function insertNewNode(uint _listKey,
    				uint _nodeKey,
                    uint _newKey,
                    uint _dataIndex,
                    bool _dir)
        internal
        returns (uint b)
    {
    	b = update(_listKey, _newKey, _dataIndex);
    	insert(_listKey, _nodeKey, _newKey, _dir);
    }

	function swap(uint _listKey, uint a, uint b)
		internal
	{
        LinkedList list = lists[_listKey];
		uint c = list.nodes[a].links[PREV];
		uint d = list.nodes[a].links[NEXT];
		uint e = list.nodes[b].links[PREV];
		uint f = list.nodes[b].links[NEXT];
	
		stitch (_listKey, c, b, NEXT);
		stitch (_listKey, b, d, NEXT);
		stitch (_listKey, e, a, NEXT);
		stitch (_listKey, a, f, NEXT);
	}
           
    function remove(uint _listKey, uint _nodeKey)
        internal
        isValidKey(_listKey, _nodeKey)
        returns (bool)
    {
        LinkedList list = lists[_listKey];
        uint a = list.nodes[_nodeKey].links[PREV];
        uint b = list.nodes[_nodeKey].links[NEXT];
        stitch(_listKey, a, b, NEXT);
        list.size--;
        // Explicit deletes for mapping elements
        delete list.nodes[_nodeKey].links[PREV];
        delete list.nodes[_nodeKey].links[NEXT];
        delete list.nodes[_nodeKey].dataIndex;
        delete list.nodes[_nodeKey];
        return true;
    }
    
    function step(uint _listKey, uint _nodeKey, bool _dir)
        // get next or previous node key
        isValidKey(_listKey, _nodeKey)
        constant returns (uint)
    {
        return lists[_listKey].nodes[_nodeKey].links[_dir];
    }
}


contract CLL is MultiCircularLinkedList
{
	uint list = 0;
	uint output;
	function CLL()	
	{
        lists[list].nodes[HEAD].links[NEXT] = HEAD; // set next link to head
        lists[list].nodes[HEAD].links[PREV] = HEAD; // set previous link to head
        lists[list].nodes[HEAD].dataIndex = 1;
	}
	
	function push(uint num) public
	{
		insertNewNode (list, HEAD, num, num, PREV);
	}

	function pull() public returns (uint)
	{
		output = step(list, HEAD, NEXT);
		remove(list, output);
		return output;
	}

	function pop() public returns (uint)
	{
		output = step(list, HEAD, PREV);
		remove(list, output);
		return output;
	}

}