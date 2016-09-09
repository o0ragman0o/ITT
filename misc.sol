/*
file:   misc.sol
ver:    0.1.0-alpha
updated:9-Sep-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An inheritable contract containing common constants, modifiers and functions.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

contract Misc
{

/* Constants */

    uint constant NULL = 0;
    bool constant LT = false;
    bool constant GT = true;

/* Modifiers */

    // To throw call not made by owner
    modifier isOwner() {
        if (msg.sender != owner) throw;
        _
    }

    // The owner of an inheriting contract
    address public owner;

    // Prevents a function from accepting sent ether
    modifier noEther(){
        if (msg.value > 0) throw;
        _
    }

    // To lock a contracts mutex protected functions from entry if it or 
    // another protected function has not yet returned.
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

    // The mutex entry state.
    bool mutex;

/* Functions */

    // Default to throw on no or invalid function call
    function () { throw; }

    // Change the owner of a contract
    function changeOwner(address _newOwner)
        public
        isOwner
        mutexProtected
        returns (bool success_)
    {
        owner = _newOwner;
        success_ = true;
    }

    // @dev Parametric comparitor for > or <
    // !_dir Tests a < b
    // _dir  Tests a > b
    function cmp (uint a, uint b, bool _dir)
        internal
        constant
        returns (bool)
    {
        if (_dir) return a > b;
        else return a < b;
    }

    /// @dev Parametric comparitor for >= or <=
    /// !_dir Tests a <= b
    /// _dir  Tests a >= b
     function cmpEq (uint a, uint b, bool _dir)
        internal
        constant
        returns (bool)
    {
        return (a==b) || ((a < b) != _dir);
    }
}