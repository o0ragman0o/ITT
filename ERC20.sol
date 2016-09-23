/*
file:   ERC20.sol
ver:    0.2.2
updated:21-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An ERC20 compliant token.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.0;

import "Math.sol";
import "Base.sol";

// ERC20 Standard Token Interface with safe maths and reentry protection
contract ERC20Interface
{
/* Structs */

/* Constants */
    string constant VERSION = "ERC20 0.2.2-o0ragman0o";

/* State Valiables */
    uint public totalSupply;
    uint8 public decimalPlaces;
    string public name;
    string public symbol;
    
    // Token ownership mapping
    mapping (address => uint) public balanceOf;
    
    // Transfer allowances mapping
    mapping (address => mapping (address => uint)) public allowance;

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

    /* State variable Accessor Functions (for reference - leave commented) */

    // Get the account balance of another account with address _owner
    // function balanceOf(address tokenHolder) public constant returns (uint);

    // Returns the allowable transfer of tokens by a proxy
    // function allowance (address tokenHolders, address proxy, uint allowance) public constant returns (uint);

    // Get the total token supply
    // function totalSupply() public constant returns (uint);

    // Returns token symbol
    // function symbol() public constant returns(string);

    // Returns token symbol
    // function name() public constant returns(string);

    // Returns decimal places designated for unit of token.
    // function decimalPlaces() public returns(uint);

    // Send _value amount of tokens to address _to
    // function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    // function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount.
    // function approve(address _spender, uint256 _value) public returns (bool success);
}

contract ERC20Token is Base, Math, ERC20Interface
{

/* Events */

/* Structs */

/* Constants */

/* State Valiables */

/* Modifiers */

    modifier isAvailable(uint _amount) {
        if (_amount > balanceOf[msg.sender]) throw;
        _;
    }

    modifier isAllowed(address _from, uint _amount) {
        if (_amount > allowance[_from][msg.sender] ||
           _amount > balanceOf[_from]) throw;
        _;        
    }

/* Funtions Public */

    function ERC20Token(
        uint _supply,
        uint8 _decimalPlaces,
        string _symbol,
        string _name)
    {
        totalSupply = _supply;
        decimalPlaces = _decimalPlaces;
        symbol = _symbol;
        name = _name;
        balanceOf[msg.sender] = totalSupply;
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value)
        public
        canEnter
        isAvailable(_value)
        returns (bool success)
    {
        safeSub(balanceOf[msg.sender], _value);
        safeAdd(balanceOf[_to], _value);
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value)
        public
        canEnter
        isAllowed(_from, _value)
        returns (bool success)
    {
        safeSub(balanceOf[_from], _value);
        safeAdd(balanceOf[_to], _value);
        safeSub(allowance[_from][msg.sender], _value);
        Transfer(msg.sender, _to, _value);
        success = true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the current
    // allowance with _value.
    function approve(address _spender, uint256 _value)
        public
        canEnter
        returns (bool success)
    {
        if (balanceOf[msg.sender] == 0) throw;
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }
}
