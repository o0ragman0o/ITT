import './misc.sol';

// EIP20 Standard Token Interface
contract EIP20Interface
{
    /* Structs */
        
    /* Constants */

    /* State Valiables */
    uint public totalSupply;
    uint8 public decimalPlaces;
    string public symbol;
    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowances;

/* State variable Accessor Functions (leave commented)

	function balances(address tokenHolder) public returns (uint);
	function allowanaces (address tokenHolders, address proxy, uint allowance) public returns (uint);
	function totalSupply() public returns (uint);
	function symbol() public returns(string);
	function decimalPlaces() public returns(uint);
*/

/* Function Abstracts */
	
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20Token is EIP20Interface, Misc
{
/* Constants */

/* Structs */
        
/* State Valiables */

/* Events */
	
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

/* Funtions Public */
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value)
		public
        mutexProtected()
		isAvailable(_value)
		returns (bool success_)
    {
        if (balances[msg.sender] < _value) throw;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success_ = true;
    }


    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
		public
        mutexProtected
        hasAllowance(_from, _value)
        returns (bool success_)
    {
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success_ = true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value)
		public
        mutexProtected
		returns (bool success_)        
    {
        if (balances[msg.sender] == 0) throw;
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success_ = true;
    }

}
