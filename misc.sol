contract Misc
{

/* Constants */

    uint constant NULL = 0;
    bool constant LT = false;
    bool constant GT = true;

/* Modifiers */

    // To throw call not made by owner
    modifier isOwner() {
        // if (msg.sender != owner) throw;
        _
    }
	
    address public owner;

	// Prevents a function from accepting sent ether
	modifier noEther(){
		if (msg.value > 0) throw;
		_
	}

    // To lock a contracts mutex protected functions from entry if it or another
	// protected function has not yet returned.
	// Protected functions must have only one point of exit.
	// Protected functions cannot use the `return` keyword
	// Protected functions return values must be through return parameters.
    modifier mutexProtected() {
        if (mutex) throw;
        else mutex = true;
        _
        mutex = false;
        return;
    }

    /// @returns Entry state.
    bool public mutex;

/* Functions */

	// Parametric comparitor for > or <
    // !_dir Tests a < b
    // _dir  Tests a > b
    function cmp (uint a, uint b, bool _dir)
    	public
        constant
        returns (bool)
    {
        if (_dir) return a > b;
        else return a < b;
    }

	// Parametric comparitor for >= or <=
    // !_dir Tests a <= b
    // _dir  Tests a >= b
     function cmpEq (uint a, uint b, bool _dir)
    	public
        constant
        returns (bool)
    {
        return (a==b) || ((a < b) != _dir);
    }

	function changeOwner(address _newOwner)
		public
		mutexProtected
		isOwner {
		owner = _newOwner;
	}
}