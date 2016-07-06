import './misc.sol';

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
		if (_amount < balances[msg.sender]) throw;
		_
	}
	
	modifier hasAllowance(address _from, uint _amount) {
		if (_amount > allowances[_from][msg.sender] ||
		   _amount > balances[_from]) throw;
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
