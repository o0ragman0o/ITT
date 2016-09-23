/*
file:   Math.sol
ver:    0.2.0-alpha
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

pragma solidity ^0.4.0;

contract Math
{

/* Constants */

    uint constant NULL = 0;
    bool constant LT = false;
    bool constant GT = true;
    // No type bool <-> int type converstion in solidity :~(
    uint constant iTRUE = 1;
    uint constant iFALSE = 0;
    uint constant iPOS = 1;
    uint constant iZERO = 0;
    uint constant iNEG = uint(-1);


/* Modifiers */

/* Functions */

    function assert(bool assertion) internal constant
    {
      if (!assertion) throw;
    }
    
    // @dev Parametric comparitor for > or <
    // !_sym returns a < b
    // _sym  returns a > b
    function cmp (uint a, uint b, bool _sym) internal constant returns (bool)
    {
        return (a!=b) && ((a < b) != _sym);
    }

    /// @dev Parametric comparitor for >= or <=
    /// !_sym returns a <= b
    /// _sym  returns a >= b
    function cmpEq (uint a, uint b, bool _sym) internal constant returns (bool)
    {
        return (a==b) || ((a < b) != _sym);
    }
    
    function safeMul(uint a, uint b) internal constant returns (uint)
    {
      uint c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint)
    {
      assert(b <= a);
      return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint)
    {
      uint c = a + b;
      assert(c>=a && c>=b);
      return c;
    }
}
