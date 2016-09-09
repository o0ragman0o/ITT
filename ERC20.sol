/*
file:   ERC20.sol
ver:    0.1.0-alpha
updated:9-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An ERC20 compliant token.


This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/


import './misc.sol';

// ERC20 Standard Token Interface
contract ERC20Interface
{
/* Structs */

/* Constants */

/* State Valiables */
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimalPlaces;

/* Events */
    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value);

/* Modifiers */

/* Function Abstracts */

    /* State variable Accessor Functions (for reference - leave commented)

    // Get the account balance of another account with address _owner
    function balanceOf(address tokenHolder)
        public constant returns (uint);

    // Returns the allowable transfer of tokens by a proxy
    function allowance (address tokenHolders, address proxy, uint allowance)
        public constant returns (uint);

    // Get the total token supply
    function totalSupply()
        public constant returns (uint);

    // Returns token symbol
    function symbol()
        public constant returns(string);

    // Returns token symbol
    function name()
        public constant returns(string);

    // Returns decimal places designated for unit of token.
    function decimalPlaces()
        public returns(uint);
    */

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value)
        public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the current
    //  allowance with _value.
    function approve(address _spender, uint256 _value)
        public returns (bool success);
}

contract ERC20Token is ERC20Interface, Misc
{

/* Events */

/* Structs */

/* Constants */

/* State Valiables */

/* Modifiers */

    modifier hasBalance(address _member, uint _amount) {
        if (balanceOf[_member] < _amount) throw;
        _
    }
    
    modifier isAvailable(uint _amount) {
        if (_amount > balanceOf[msg.sender]) throw;
        _
    }

    modifier isAllowed(address _from, uint _amount) {
        if (_amount > allowance[_from][msg.sender] ||
           _amount > balanceOf[_from]) throw;
        _
        
    }

/* Funtions Public */

    function ERC20Token(
        uint _supply,
        uint8 _decimalPlaces,
        address _owner,
        string _symbol,
        string _name)
    {
        totalSupply = _supply;
        decimalPlaces = _decimalPlaces;
        symbol = _symbol;
        name = _name;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value)
        public
        noEther
        isAvailable(_value)
        mutexProtected()
        returns (bool success)
    {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
        public
        noEther
        isAllowed(_from, _value)
        mutexProtected
        returns (bool success)
    {
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the current
    // allowance with _value.
    function approve(address _spender, uint256 _value)
        public
        noEther
        hasBalance(msg.sender, 1)
        mutexProtected
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }
}
