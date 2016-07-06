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

	function cmp (uint a, uint b, bool _dir)
		// !_dir Tests a <= b
		// _dir  Tests a >= b
		constant
		returns (bool)
	{
		return (a==b) || ((a < b) != _dir);
	}
}