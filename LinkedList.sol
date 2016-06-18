//Sample contract
contract LinkedList {
	
	struct node {
		uint32 next;
		uint32 prev;
		uint dataIdx;
	}
	
	uint32 head;
	uint32 tail;
	uint32 current;
	uint32 nonce;
	uint32 count;
	
	mapping (uint32 => node) list;
	
	function next() returns (bool) {
		if(current == head) return false;
		current == list[current].next;
		return true;
	}
	
	function prev() returns (bool) {
		if(current == tail) return false;
		current == list[current].prev;
		return true;
	}
	
	function add(uint256 _dataIdx, uint32 _after) returns (bool) {
		uint32 next = nonce++;
		list[next].dataIdx = _dataIdx;
		list[next].prev = _after;
		if (list[_after].next == head) head = next;
		list[_after].next = next;
		return true;
	}
	
	function remove(uint32 _nodeId) returns (bool) {
		list[list[_nodeId].prev].next = list[_nodeId].next;
		list[list[_nodeId].next].prev = list[_nodeId].prev;
		delete list[_nodeId];
		return true;
	} 	
}