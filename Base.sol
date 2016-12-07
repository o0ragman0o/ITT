/*
file:   Base.sol
ver:    0.2.3
updated:8-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

An basic contract furnishing inheriting contracts with ownership, reentry
protection and safe sending functions.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.
*/

pragma solidity ^0.4.0;

contract Base
{
/* Constants */

    string constant public VERSION = "Base 0.2.3";

/* State Variables */

    bool mutex;
    address public owner;

/* Events */

    event Log(string message);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

/* Modifiers */

    // To throw call not made by owner
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        if (mutex) throw;
        else mutex = true;
        _;
        delete mutex;
        return;
    }

    // This modifier can be applied to pulic access state mutation functions
    // to protect against reentry if a `mutextProtect` function is already
    // on the call stack.
    modifier noReentry() {
        if (mutex) throw;
        _;
    }

    // Same as noReentry() but intended to be overloaded
    modifier canEnter() {
        if (mutex) throw;
        _;
    }
    
/* Functions */

    function Base() { owner = msg.sender; }

    function contractBalance() public constant returns(uint) {
        return this.balance;
    }

    // Change the owner of a contract
    function changeOwner(address _newOwner)
        public onlyOwner returns (bool)
    {
        owner = _newOwner;
        ChangedOwner(msg.sender, owner);
        return true;
    }
    
    function safeSend(address _recipient, uint _ether)
        internal
        preventReentry()
        returns (bool success_)
    {
        if(!_recipient.call.value(_ether)()) throw;
        success_ = true;
    }
}

/* End of Base */