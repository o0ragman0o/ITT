# ITT - Intrinsically Tradable Token
ver:    0.3.6
```
[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"etherBalanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_ether","type":"uint256"}],"name":"withdraw","outputs":[{"name":"success_","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getBook","outputs":[{"name":"","type":"uint256[]"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"}],"name":"cancel","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_price","type":"uint256"},{"name":"_trader","type":"address"}],"name":"getAmount","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"version","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"getOpenOrdersOf","outputs":[{"name":"","type":"uint256[]"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"numOrdersOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_askPrice","type":"uint256"},{"name":"_amount","type":"uint256"},{"name":"_make","type":"bool"}],"name":"sell","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"contractBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_side","type":"bool"}],"name":"spread","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_trading","type":"bool"}],"name":"setTrading","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_price","type":"uint256"}],"name":"getPriceVolume","outputs":[{"name":"v_","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_bidPrice","type":"uint256"},{"name":"_amount","type":"uint256"},{"name":"_make","type":"bool"}],"name":"buy","outputs":[{"name":"","type":"bool"}],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"amounts","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"l","type":"uint256"}],"name":"sizeOf","outputs":[{"name":"s","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimalPlaces","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_list","type":"uint256"},{"name":"_node","type":"uint256"}],"name":"getNode","outputs":[{"name":"","type":"uint256[2]"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"trading","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"inputs":[{"name":"_totalSupply","type":"uint256"},{"name":"_decimalPlaces","type":"uint8"},{"name":"_symbol","type":"string"},{"name":"_name","type":"string"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"trader","type":"address"}],"name":"Ask","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"trader","type":"address"}],"name":"Bid","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"buyer","type":"address"},{"indexed":true,"name":"seller","type":"address"}],"name":"Sale","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"trading","type":"bool"}],"name":"Trading","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"message","type":"string"}],"name":"Log","type":"event"}]
```
Ropsten test chain `0xa9e001bebe4b281f7229b0305f553ab3c511fef5`

ITT's are an Ethereum ERC20 compliant token with in built currency exchange functionality. This realises the fully decentralised ideal for exchangeable tokens by way of removing any necessity of any third party to manage value exchanges between peers.

ITT's extend the Ethereum Standard Token API to include exchange trading functions 'Buy', 'Sell', 'Cancel' and 'Withdraw' within the contract itself.  The owner of the ITT can also set the trading state to *live* or *halted*.
```
buy(uint [bid price], uint [tokens amount], bool [make limit order])
sell(uint [ask price], uint [tokens amount], bool [make limit order])
cancel(uint [order price])
withdraw(uint [ether amount])
setTrading(bool [trading state])
```
Additionally, a number of informational functions returns various state information.
```
spread(bool [bid/ask])
getBook()
getPriceVolume(uint [price])
etherBalanceOf(address [trader])
getOpenOrdersOf(address [trader])
```

## Implementation
The intent of this particular implementation of an ITT is to present a functional demonstration of the ITT API and offer a code base from which to inherit and extend.
  
This implementation embodies a First In First Out (FIFO) continuous trading algorithm. Buy and Sell orders can *take* multiple at market orders until filled and/or *make* a limit order of the remaining amount if so desired.

Orders can be created only if the the contracts trading state is live. Orders can be cancelled at any time.  Trader owned ether balances can also be withdrawn at any time.

Traders may only *make* one order at any particular price.  Making a second order at the same price will cancel the first and the new order is placed at the back of the FIFO queue. This prevents queue hogging by topping up volumes before they are completely filled.

There is no explicit *deposit()* function and funds are instead sent to the `payable` function `buy()`. Ether can accumulate from sales, refunds and cancellations in their ITT traders account.  Traders are not prevented from withdrawing their accumulated ether. If trading is halted, buyers may cancel their outstanding buy orders and withdraw the refunded value.

The balances show only tokens or ether *available* for trading. Placing a `make` order will reduce trader's balances accordingly.   Values and amounts held in open orders are best calculated off chain with the assistance of the `getOpenOrdersOf()` function.

The functionality of `transfer` `transferFrom` and approve remains as per the intention of ERC20, though transfers will be limited to the *available* balance and not the total owned balance which includes amounts held in sell orders.  It is foreseeable that the token may also be traded in parallel on a third-party exchange using `approve()` and `transferFrom` though no assumptions are made as to how a third party might otherwise secure order amounts.

This implementation takes no fees beyond the gas costs of the contract's transactions.

##Contract Security
**ATTN: This contract contains complex logic and has yet to be reviewed and audited.**

This contract has one external call which is in the `withdraw()` function in order to send ether out of the contract. To prevent reentry attacks upon the contract's state variables, `withdraw()` calls the sending function `safeSend(recipient, amount)` (found in Base.sol) which sets a reentry mutex.  All other non-constant public functions test for when they are called and throw if they find it true.
Additional entry modifiers such as trading state and order validation test are applied to public functions as per the nature of the function.
Ether held in the contract is owned by traders and can be withdrawn at any time.


## Primary Storage Structures and Operation
Excluding the balance states of `balanceOf` and `etherBalanceOf`, the exchange functionality works upon two storage structures, a multiply nested `mapping` acted upon as Circular Doubly Linked Lists (by the LibCLL.sol library) to manage price and order queues (FIFO's) and a simple mapping to hold order amounts.
Schematically, the order FIFO's can be shown as:

`mapping([price] => ([trader address] => ([prev/next] => trader address)))`

 The price lookup list is held in the same structure at primary key value of `0` but with keys and values implied in the following manner:
 
`mapping([0] => ([price] => ([prev/next] => price)))`

A price and an address are then hashed together to derive a key into the order amounts mapping:

`mapping(sha3([price],[address]) => [amount])`

So in effect only two pieces of data, *trader address* and *order amount*  are exclusive to the order.  The price is implied by the FIFO into which the order is inserted.  However, three state slots are used, one for amount, and two for address which is recorded by both the previous and next nodes as the double link.  The double link is necessary to prevent potentially gas exhausting search loops when closing/cancelling an order. 

An insertion of a linked list node writes to 4 state slots to establish the double link. A fifth slot is used for the order amount.  So a *make* order at an *unlisted* price will create a node in the pricebook (4 slots), a node in the FIFO (4 slots), and write to `amounts` (1 slot) then adjust the trader's ether and token balances (2 slots) for a total of 11 state slot updates. If there is an existing FIFO at the chosen price, only 7 slot updates are required as the price book needs no update, only the FIFO.

To take an order, a minimum of 4 slots are updated being 3 for the trader's balances and 1 for updating an 'unfilled' amount.  If the order is filled, the FIFO's node is destroyed by explicitly deleting the mapping elements, freeing up 2 slots and updating 2 slots. Afterwards if the FIFO is empty, it's node in the price book is also destroyed freeing up another 2 slots and updating 2 slots.  The gas refunded from these `delete` operations means taking multiple orders is reasonably efficient.

## State Variables
The following state variables are in addition to ERC20.
### owner
```
address public owner
```

### trading
```
bool public trading
```
To record state of trading (live or halted) as set by the owner.

### orderFIFOs
```
mapping (uint => LibCLLu.CLL) orderFIFOs
```
where `LibCLLu.CLL` is:
```
mapping (uint => bool => uint) cll
```
`orderFIFOs` stores the Circular Doublely Linked Lists which contain price and trader addresses for open orders.
    
### amounts
```
mapping (bytes32 => uint) public amounts;
```
`amounts` stores the order amounts of open order and is keyed by the sha3 of the order price and trader address.

### etherBalanceOf
```
mapping (address => uint) public etherBalanceOf
```
The contract necessarily accepts ether through the `buy()` function. `etherBalanceOf` keeps account of ether accumulated from the sale of tokens and refunds from cancelled or over funded `buy()` orders.

## Functions Public non-constant

This contract implements the following functions in addition to the ERC20 interface.

### buy
```
function buy (uint _bidPrice, uint _amount, bool _make) payable returns (bool);
```
 Will buy up to an amount of tokens at or below the Bid price. If the order isn't market filled, it can drop or make an order for the remaining amount.
`_bidPrice` The highest price to bid.
`_amount` The amount of tokens to buy.
`_make` A value of true will make a Bid order if not filled.

### sell
```
function sell (uint _askPrice, uint _amount, bool _make) public returns (bool);
```
Will sell an amount of owned tokens at or above the Ask price. If the order isn't market filled, it can drop or make and order for the remaining amount.
`_askPrice` The lowest price to ask.
`_amount` The amount of tokens to sell.
`_make` A value of true will make an Ask order if not market filled.

### withdraw
```
function withdraw(uint _ether) public returns (bool success_);
```
Will withdraw the senders available ether to the calling account. Available ether can be withdrawn at any time regardless of the trading state of the contract.
`_ether` The amount to withdraw

### cancel
```
function cancel(uint _price) public returns (bool);
```
Will cancel a sender's order at a given price.
`_price` The price at which the order was placed.

### setTrading
```
function setTrading(bool _trading) public returns (bool);
```
Allows the owner to set the trading state.
`_trading` false: Trading is halted. true: Trading is live.

## Functions Public constant
### ITT - constructor
```
function ITT(
        uint _totalSupply,
        uint8 _decimalPlaces,
        string _symbol,
        string _name)
```
`_totalSupply` The integer number of tradable units irrelevant of the decimal places.
`_decimalPlaces` Number of decimal places to interpret a number of tradable units as one token.
`_symbol` Token symbol
`_name` Descriptive token name

### () - default function
```
function ()
```
Throws on call.

### version
```
function version() public constant returns(string);
```
Returns the contract's version string. Version strings are required to begin with `ITT` for easy identification.

### spread
```
function spread(bool _side) public constant returns(uint);
```
Returns best Bid or Ask price.
`_side` `false` returns highest Bid. `true` returns lowest Ask.

### getBook
```
function getBook() public constant returns (uint[]);
```
Returns an array of all price and volumes pairs as a 1D array with price on even indices and volumes on odd (i+1).

### getPriceVolume
```
function getPriceVolume(uint _price) public constant returns (uint);
```
Returns the collective order volume at a given price.
`_price` price of a FIFO containing orders.

### getAmount
```
function getAmount(uint _price, address _trader) public constant returns(uint);
```
Returns the order amount for trader given the order price.
`_trader` Address of trader
`_price` Price of order

### numOrdersOf
```
function numOrdersOf(address _trader) public constant returns (uint);
```
Returns the number of open orders (bids and asks) of a trader
`_trader` Address of trader

### getOpenOrdersOf
```
function getOpenOrdersOf(address _trader) public constant returns (uint[])
```
`_trader` Address of trader
Returns an array of order information pairs from the given trader address with price at even indices and amounts at odd (i+1).

## Events
```
Ask (uint indexed price, uint amount, address indexed trader)
```
Triggered on a make Ask order

```
Bid (uint indexed price, uint amount, address indexed trader)
```
Triggered on a make Bid order

```
Sale (uint indexed price, uint amount, address indexed buyer, address indexed seller)
```
Triggered on a filled order

```
Trading(bool trading)
```
Triggered when trading is started or halted
