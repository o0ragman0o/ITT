import './orderForm.html';

// TODO incorporate 'Units'
Template.orderForm.onCreated(function() {
	this.autorun(setButtons);
})

Template.orderForm.helpers({
	balance: function () {
		return ittDict["balanceOf"].get();
	},
	symbol: function() {
		return ittDict["symbol"].get();
	},
	price: function() {
		return ittDict["orderFormPrice"].get();
	},
	priceMin: function() {
		return ittDict["orderMinPrice"].get();
	},
	priceStep: function() {
		return Math.pow(10,-ittDict["orderFormPrice"].get().decimalPlaces());
	},
	amount: function() {
		return ittDict["orderFormAmount"].get();
	},
	amountMin: function() {
		return ittDict["orderMinAmount"].get();
	},
	amountStep: function() {
		return Math.pow(10,-ittDict["orderFormAmount"].get().decimalPlaces());
	},
	total: function() {
		return ittDict["orderFormTotal"].get();
	},
	totalMin: function() {
		return ittAPI.toPlaces(ittDict["orderFormPrice"].get());
	},
	totalStep: function() {
		return ittAPI.toPlaces(ittDict["orderFormPrice"].get());
	},
	make: function () {
		return ittDict["orderMake"].get();
	},
	askSell: function() {
		return ittDict["orderFormAsk"].get();
	},
	bidBuy: function() {
		return ittDict["orderFormBid"].get();
	},
	swap: function() {
		return ittDict["orderFormSwap"].get();
	},
	tradeFunds: function() {
		return ittAPI.tradeFunds();
	}
});

Template.orderForm.events({
	'change #ordPrice': function (e, t) {
		ittDict["orderFormPrice"].set(new BigNumber(e.target.value));
		ittDict["orderFormTotal"].set(ittDict["orderFormPrice"].get().mul(ittDict["orderFormAmount"].get()));
	},
	'change #ordAmount': function (e, t) {
		ittDict["orderFormAmount"].set(new BigNumber(e.target.value));
		ittDict["orderFormTotal"].set(ittDict["orderFormPrice"].get().mul(ittDict["orderFormAmount"].get()));
	},
	'change #ordTotal': function (e, t) {
		ittDict["orderFormTotal"].set(new BigNumber(e.target.value));
		ittDict["orderFormAmount"].set(ittDict["orderFormTotal"].get().div(ittDict["orderFormPrice"].get()));
	},
	"click #make": function () {
		ittDict["orderMake"].set(!ittDict["orderMake"].get());
	},
	"click #setMaxTotal": function() {
		ittDict["orderFormTotal"].set(ittAPI.tradeFunds());
		ittDict["orderFormAmount"].set(ittDict["orderFormTotal"].get().div(ittDict["orderFormPrice"].get()));
	},
	"click #setMaxAmount": function() {
		ittDict["orderFormAmount"].set(ittDict["balanceOf"].get());
	},
	"click #buy_button": function (e, t) {
		e.preventDefault();
		EthElements.Modal.question({
			template: "placeOrder",
			 data: {
					 price: ittDict["orderFormPrice"].get(),
					 amount: ittDict["orderFormAmount"].get(),
					 total: ittDict["orderFormTotal"].get(),
					 swap: ittDict["orderFormBid"].get(),
					 address: ittDict["ittAddress"].get(),
					 name: ittDict["name"].get(),
					 symbol: ittDict["symbol"].get()
			 },
			 ok: function(){
				ittAPI.buy(
					 ittDict["orderFormPrice"].get(),
					 ittDict["orderFormAmount"].get(),
					 ittDict["orderMake"].get());
			 },
			 cancel: true,
		});
	},
	"click #sell_button": function (e, t) {
		e.preventDefault();
		EthElements.Modal.question({
			template: "placeOrder",
			 data: {
					 price: ittDict["orderFormPrice"].get(),
					 amount: ittDict["orderFormAmount"].get(),
					 total: ittDict["orderFormTotal"].get(),
					 swap: ittDict["orderFormBid"].get(),
					 address: ittDict["ittAddress"].get(),
					 name: ittDict["name"].get(),
					 symbol: ittDict["symbol"].get()
			 },
			 ok: function(){
				ittAPI.sell(
					ittDict["orderFormPrice"].get(),
					ittDict["orderFormAmount"].get(),
					ittDict["orderMake"].get());
			 },
			 cancel: true,
		});
	},
})

setButtons = function () {
		ittDict["orderFormAsk"].set(ittDict["orderFormPrice"].get().gt(ittDict["highestBid"].get()) ? "ask" : "sell");
		ittDict["orderFormBid"].set(ittDict["orderFormPrice"].get().lt(ittDict["lowestAsk"].get()) ? "bid" : "buy");

		$("#sell_button").attr("disabled", ittDict["orderFormAmount"].get().gt(ittDict["balanceOf"].get())? true : false);
		$("#buy_button").attr("disabled", ittDict["orderFormTotal"].get().gt(ittAPI.tradeFunds())? true : false);

}
