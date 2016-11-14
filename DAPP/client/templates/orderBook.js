import './orderBook.html';

Template.orderBook.helpers({
	orderBook: function () {
		var j, i = 0;
		var ret = [];
		var volume = new BigNumber(0);
		var total = new BigNumber(0);
		book = ittDict["orderBook"].get();
		while (!book[i].isZero()) i+=2;
		j = i;
		bids = book.slice(0,j--);
		while (j > 0){
			// Tally bid volumes and totals in decending order
			price = ittAPI.fromPlaces(web3.fromWei(bids[j-1], "ether"));
			volume = volume.plus(ittAPI.toPlaces(bids[j]));
			total = total.plus(price.mul(ittAPI.toPlaces(bids[j])));
			ret.push({
				price: price,
				volume: volume,
				total: total,
				swap: "bid",
			});
			j -=2;
		}
		ret = ret.reverse();
		volume = new BigNumber(0);
		total = new BigNumber(0);
		while (i < book.length - 2){
			// Tally volumes and totals in ascending order
			i +=2;
			price = ittAPI.fromPlaces(web3.fromWei(book[i], "ether"));
			volume = volume.plus(ittAPI.toPlaces(book[i+1]));
			total = total.plus(price.mul(ittAPI.toPlaces(book[i+1])));
			ret.push({
				price: price,
				volume: volume,
				total: total,
				swap: "ask"
			});
		}
		return ret;
	},
})

Template.orderBook.events({
	'click li.priceQuote': function() {
		console.log(this);
		ittDict["orderFormPrice"].set(this.price);
		ittDict["orderFormAmount"].set(this.volume);
		ittDict["orderFormTotal"].set(this.total);
	}
})