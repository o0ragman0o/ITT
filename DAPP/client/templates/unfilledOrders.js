import './unfilledOrders.html';

Template.unfilledOrders.helpers({
	unfilledOrders: function () {
		var i = 0;
		var ret = [];
		var orders = ittDict["openOrders"].get();
		while (i < orders.length){
			price = ittAPI.fromPlaces(web3.fromWei(orders[i],"ether"));
			amount = ittAPI.toPlaces(orders[i+1]);
			value = price * amount;
				ret.push({
					price: price,
					amount: amount,
					value: value,
					swap: price.gt(ittDict["highestBid"].get()) ? "ask" : "bid",
				});
			i +=2;
		}
		return ret;
	}
})

Template.unfilledOrders.events({
	'click li.priceQuote': function(){
		self = this
		EthElements.Modal.question({
			template: "confirmCancel",
			ok: function(e, t) { ittAPI.cancel(self.price); },
			cancel: true,
			data: {
				price: self.price,
				amount: self.amount,
				swap: self.swap,
				name: ittDict["name"].get(),
				symbol: ittDict["symbol"].get(),
			}
		});
	}
})

// Template.confirmCancel.helpers({
// 	'price': function (e, t) {
// 		return ittAPI.fromPlaces(web3.fromWei(orders[i],"ether"));
// 	},
// 	'amount': function (e, t) {
// 		return ittAPI.toPlaces(orders[i+1]);
// 	},
// 	'swap': function (e, t) {
// 		price.gt(ittDict["highestBid"].get()) ? "ask" : "bid";
// 	}

// })

Template.confirmCancel.events({
	'click button.cancel': function(e, t) {
		ittAPI.cancel(this.price);
	}
})

