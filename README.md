# ITT - Intrinsically Tradeable Token
ver:    0.3.2

An Ethereum ERC20 compliant token with in built currency exchange functionality.

ITT's extend the Ethereum Standard Token API to include exchange trading functionality of 'Buy' and 'Sell' within the contract itself. This renders the token entirely decentralised from any third party trading desk requirements.

This implementation embodies a First In First Out (FIFO) continuous trading algorithm. Buy and Sell orders can *take* multiple at market orders until filled in the one call and/or *make* and order of the remaining amount if so desired.

Traders may only *make* one order at any particular price.  Making a second order at the same price will cancel the first and the new order is placed at the back of the FIFO queue. This prevents queue hogging by topping up volumes before they are completely filled.

Traders can cancel and order at any time.

Traders are not prevented from withdrawing their accumulated ether. If trading is halted, buyers may cancel their outstanding orders and withdraw the refunded value.

Placing an make order will lock that amount (in tokens or ether) from the the trader's balances.  The balances show only tokens or either *available* for trading. Values and amounts held in orders are best calculated off chain.

The functionality of `transfer` and `transferFrom` remains as per the intention of ERC20, though transfers will be limited to the *available* balance and not the total owned balance which includes amounts held in sell orders.

##Contract Security
This contract has one external call which is in the *withdraw* function in order to send ether.  The send function `safeSend(recipient, amount)` (found in Base.sol) sets a reentry mutex which all other non-constant public functions test for when they are called.

## State Variables

### trading
```
bool public trading
```
To record state of trading as set by the owner.

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
Will a sender's order at a given price.
`_price` The price at which the order was placed.

### setTrading
```
function setTrading(bool _trading) public returns (bool);
```
Allows the owner to set the trading state.
`_trading` false: Trading is halted. true: Trading is live.

## Functions Public constant

### spread
```
function spread(bool _side) public constant returns(uint);
```
Returns best Bid or Ask price.
`_side` `false` returns highest Bid. `true` returns lowest Ask.

### getAmount
```
function getAmount(uint _price, address _trader) public constant returns(uint);
```
Returns the order amount for trader given the order price.
`_trader` Address of trader
`_price` Price of order

### getPriceVolume
```
function getPriceVolume(uint _price) public constant returns (uint);
```
Returns the collective order volume at a given price.
`_price` price of a FIFO containing orders.

### getBook
```
function getBook() public constant returns (uint[]);
```
Returns an array of all price and volumes pairs as a 1D array with price on odd indices and volumes on even.

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
