ITT = web3.eth.contract([{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"etherBalanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_ether","type":"uint256"}],"name":"withdraw","outputs":[{"name":"success_","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getBook","outputs":[{"name":"","type":"uint256[]"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"}],"name":"cancel","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_price","type":"uint256"},{"name":"_trader","type":"address"}],"name":"getAmount","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"version","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"getOpenOrdersOf","outputs":[{"name":"","type":"uint256[]"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"addr","type":"address"}],"name":"numOrdersOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_askPrice","type":"uint256"},{"name":"_amount","type":"uint256"},{"name":"_make","type":"bool"}],"name":"sell","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"contractBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_side","type":"bool"}],"name":"spread","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_trading","type":"bool"}],"name":"setTrading","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_price","type":"uint256"}],"name":"getPriceVolume","outputs":[{"name":"v_","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_bidPrice","type":"uint256"},{"name":"_amount","type":"uint256"},{"name":"_make","type":"bool"}],"name":"buy","outputs":[{"name":"","type":"bool"}],"payable":true,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"amounts","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"l","type":"uint256"}],"name":"sizeOf","outputs":[{"name":"s","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimalPlaces","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_list","type":"uint256"},{"name":"_node","type":"uint256"}],"name":"getNode","outputs":[{"name":"","type":"uint256[2]"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"trading","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"inputs":[{"name":"_totalSupply","type":"uint256"},{"name":"_decimalPlaces","type":"uint8"},{"name":"_symbol","type":"string"},{"name":"_name","type":"string"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"trader","type":"address"}],"name":"Ask","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"trader","type":"address"}],"name":"Bid","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"price","type":"uint256"},{"indexed":false,"name":"amount","type":"uint256"},{"indexed":true,"name":"buyer","type":"address"},{"indexed":true,"name":"seller","type":"address"}],"name":"Sale","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"trading","type":"bool"}],"name":"Trading","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"message","type":"string"}],"name":"Log","type":"event"}]);

ittDict = {
	"latestBlock": new ReactiveVar(),
	"name": new ReactiveVar(),
	"symbol": new ReactiveVar(),
	"decimalPlaces": new ReactiveVar(new BigNumber(0)),
	"format": new ReactiveVar(),
	"supply": new ReactiveVar(new BigNumber(0)),
	"balanceOf": new ReactiveVar(new BigNumber(0)),
	"etherBalanceOf": new ReactiveVar(new BigNumber(0)),
	"orderBook": new ReactiveVar(),
	"openOrders": new ReactiveVar(),
	"account": new ReactiveVar(new BigNumber(0)),
	"address": new ReactiveVar(),
	"accountBalance": new ReactiveVar(new BigNumber(0)),
	"ittAddress": new ReactiveVar(),
	"itts": new ReactiveVar(),
	"trading": new ReactiveVar(),
	"orderFormPrice": new ReactiveVar(new BigNumber(0)),
	"orderFormAmount": new ReactiveVar(new BigNumber(0)),
	"orderFormTotal": new ReactiveVar(new BigNumber(0)),
	"orderFormAsk": new ReactiveVar(),
	"orderFormBid": new ReactiveVar(),
	"totalStep": new ReactiveVar(new BigNumber(0)),
	"orderMake": new ReactiveVar(false),
	"orderMinPrice": new ReactiveVar(new BigNumber(0)),
	"orderMinAmount": new ReactiveVar(new BigNumber(0)),
	"priceStep": new ReactiveVar(new BigNumber(0)),
	"amountStep": new ReactiveVar(new BigNumber(0)),
	"accounts": new ReactiveVar(),
	"highestBid": new ReactiveVar(),
	"lowestAsk": new ReactiveVar(),
	"gasPrice": new ReactiveVar(),
}

ittAPI = {
	'setITT'() {
		itt = ITT.at(ittDict["ittAddress"].get());
		this.name();
		this.symbol();
		this.decimalPlaces();
		// this.format();
		this.supply();
		this.updateDesk();
		return itt;
	},
	'summary'(addr) {
		var ret = {};
		ret["address"] = addr;
		ret["name"] = ITT.at(addr).name();
		ret["symbol"] = ITT.at(addr).symbol();
		ret["balanceOf"] = ITT.at(addr).balanceOf(ittDict["address"].get());
		ret["etherBalanceOf"] = web3.fromWei(ITT.at(addr).etherBalanceOf(ittDict["address"].get()),'ether');
		return ret;
	},
	'updateDesk'() {
		this.latestBlock;
		this.accountBalance();
		this.balanceOf();
		this.etherBalanceOf();
		this.lowestAsk();
		this.highestBid();
		this.getBook();
		this.getOpenOrdersOf();
	},
	'latestBlock'() {
		ittDict["latestBlock"].set(web3.eth.blockNumber);
		return ittDict["latestBlock"].get();
	},
	'name'() {
		ittDict["name"].set(itt.name());
		return ittDict["name"].get();
	},
	'symbol'() {
		ittDict["symbol"].set(itt.symbol());
		return ittDict["symbol"].get();
	},
	'decimalPlaces'() {
		ittDict["decimalPlaces"].set(itt.decimalPlaces());
		return ittDict["decimalPlaces"].get().toNumber();
	},
	'supply'() {
		ittDict["supply"].set(this.toPlaces(itt.totalSupply()));
		return ittDict["supply"].get().toNumber();
	},
	'balanceOf' () {
		ittDict["balanceOf"].set(this.toPlaces(itt.balanceOf(ittDict["address"].get())));
		return ittDict["balanceOf"].get().toNumber();
	},
	'etherBalanceOf' () {
		ittDict["etherBalanceOf"].set(web3.fromWei(itt.etherBalanceOf(ittDict["address"].get()),"ether"));
		return ittDict["etherBalanceOf"].get().toNumber();
	},
	'accountBalance' () {
		ittDict["accountBalance"].set(new BigNumber(web3.fromWei(ittDict["account"].get().balance,"ether")));
		return ittDict["accountBalance"].get().toNumber();		
	},
	'tradeFunds' () {
		return ittDict["accountBalance"].get().plus(ittDict["etherBalanceOf"].get());
	},
	'spread' (dir) {
		return itt.spread(dir);
	},
	'highestBid' () {
		ittDict["highestBid"].set(this.fromPlaces(web3.fromWei(itt.spread(false), "ether")));
		return ittDict["highestBid"].get().toNumber();
	},
	'lowestAsk' () {
		ittDict["lowestAsk"].set(this.fromPlaces(web3.fromWei(itt.spread(true), "ether")));
		return ittDict["lowestAsk"].get().toNumber();
	},
  	'getBook' () {
		ittDict["orderBook"].set(itt.getBook());
		return ittDict["orderBook"].get();
	},
	'getOpenOrdersOf' () {
		ittDict["openOrders"].set(itt.getOpenOrdersOf(ittDict["address"].get(),{from:ittDict["address"].get()}));
		return ittDict["openOrders"].get();
	},
	'trading' () {
		ittDict["trading"].set(itt.trading());
		return ittDict["trading"].get();
	},
	'buy' (price, amount, make) {
		//TODO Handle make better
		make = true;
		price = this.toPlaces(web3.toWei(price,"ether"));
		amount = this.fromPlaces(amount);
		var reqFunds = price.mul(amount) - itt.etherBalanceOf(ittDict["address"].get());
		reqFunds = (reqFunds < 0) ? 0 : reqFunds;
		console.log(
			"Buy - price:", price.toNumber(),
			" amount", amount.toNumber(),
			" value", price.mul(amount).toNumber(),
			" make", make,
			" required funds", reqFunds);
		itt.buy(price, amount, make, {
			value: reqFunds,
			from: ittDict["address"].get(),
			gas: 1000000
		}, function(error, result){
		    if(!error)
		        console.log(result)
		    else
		        console.error(error);
		})
	},
	'sell' (price, amount, make) {
		//TODO Handle make better
		make = true;
		price = this.toPlaces(web3.toWei(price,"ether"));
		amount = this.fromPlaces(amount);

		console.log(
			"Sell - price:", price.toNumber(),
			" amount", amount.toNumber(),
			" value", price.mul(amount).toNumber(),
			" make", make);
		itt.sell(price, amount, make, {
			from: ittDict["address"].get(),
			gas: 1000000
		}, function(error, result){
		    if(!error)
		        console.log(result)
		    else
		        console.error(error);
		})
	},
	'cancel' (price) {
		price = this.toPlaces(web3.toWei(price,"ether"));
		console.log("Cancel - ", price.toNumber());
		itt.cancel(price, {
			from: ittDict["address"].get(),
			gas: 3000000
		}, function(error, result){
		    if(!error)
		        console.log(result)
		    else
		        console.error(error);
		})
	},
	'withdraw' (amount) {
		amount = web3.toWei(amount, "ether");
		itt.withdraw(amount, {
			from: ittDict["address"].get()
		}, function(error, result){
		    if(!error)
		        console.log(result)
		    else;
		        console.error(error);
		})
	},
	'setTrading' (state) {
		itt.setTrading(state, {
			from: ittDict["address"].get()
		}, function(error, result){
		    if(!error)
		        console.log(result);
		    else
		        console.error(error);			
		})
		return
	},
	'toPlaces' (bnum) {
		return bnum.shift(-ittDict["decimalPlaces"].get());
	},

	'fromPlaces' (bnum) {
		return bnum.shift(ittDict["decimalPlaces"].get());
	},
	'setTradeAccount' (acc) {
		ittDict["account"].set(acc);
		ittDict["address"].set(ittDict["account"].get().address);
	},
	'gasPrice' () {
		ittDict["gasPrice"].set(EthBlocks.lastest.gasPrice);
	},
	'itts' (ittsArray) {
		ittDict["itts"].set(ittsArray);
	},
}


function itt_init(ittAddress) {
	ittAPI.setTradeAccount(EthAccounts.findOne());
	ittDict["ittAddress"].set(ittAddress);
	ittAPI.setITT();
	ittDict["latestBlock"].set(web3.eth.getBlock("latest"));
	ittDict["orderMinPrice"].set(ittAPI.fromPlaces(web3.fromWei(new BigNumber(2), "ether")));
	ittDict["priceStep"].set(ittAPI.fromPlaces(web3.fromWei(new BigNumber(1), "ether")));
	ittDict["orderMinAmount"].set(ittAPI.toPlaces(new BigNumber(1)));
	ittDict["amountStep"].set(ittAPI.toPlaces(new BigNumber(1)));
	ittDict["totalStep"].set(ittAPI.toPlaces(new BigNumber(1)));
	ittDict["format"].set("0,0." + "00000000000000000000000000000000".slice(-ittDict["decimalPlaces"].get()))
	ittDict["accounts"].set(EthAccounts.find().fetch());
	ittDict["orderMake"].set(true);
	ittDict["orderFormPrice"].set(ittDict["highestBid"].get());
	ittDict["orderFormAmount"].set(new BigNumber(1));
    ittDict["orderFormAsk"].set(ittDict["orderFormPrice"].get().gt(ittDict["highestBid"].get()) ?
      "ASK" : "SELL");
    ittDict["orderFormBid"].set(ittDict["orderFormPrice"].get().lt(ittDict["lowestAsk"].get()) ?
      "BID" : "BUY");
}

accounts = EthAccounts.find().fetch();
ittAPI.itts(["0x3c41f2f97a27ba5dc1fcd54e63f099bfdb3ddc4e",
		"0x9224947628dce297a0adf69863fea3974a3fdfc6",
		"0x59798c5cf9533515d1cb18d51b5ea32d8473a493", // ver 0.3.4
		"0x335d03146f2118ff8dfc3a5cdc33e18895199400", // ver 0.3.4-take 2
		])

itt_init("0x59798c5cf9533515d1cb18d51b5ea32d8473a493");

web3.eth.filter().watch(function () {
	ittAPI.updateDesk();
});
