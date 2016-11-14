Template.itt.helpers({
	symbol: function () {
		return ittDict["symbol"].get();
	},
	name: function () {
		return ittDict["name"].get();
	},
	decimalPlaces: function () {
		return ittDict["decimalPlaces"].get();
	},
	address: function () {
		return ittDict["ittAddress"].get();
	},
	supply: function () {
		return EthTools.formatNumber(ittDict["supply"].get(),ittDict["format"].get());
	},
	balanceOf: function () {
		return EthTools.formatNumber(ittDict["balanceOf"].get(),ittDict["format"].get());
	},
	etherBalanceOf: function () {
		return ittDict["etherBalanceOf"].get();
	},
	symbol: function () {
		return ittDict["symbol"].get();
	}
});


Template.itt.events({
	'click button.modal': function(){
		// show modal
		EthElements.Modal.show('ittList');
	},
	'click button.withdraw': function (){
		ittAPI.withdraw(ittDict["etherBalanceOf"].get());
	},
})

Template.ittList.helpers({
	ittsummary: function () {
		var ret = [];
		ittDict["itts"].get().forEach(function(e) {
			ret.push(ittAPI.summary(e));
		})
		return ret;
	},
})

Template.ittList.events({
	'click button.ittButton': function(){
		ittDict["ittAddress"].set(this.address);
		ittAPI.setITT();
		EthElements.Modal.hide();

		console.log(this);
	},
});
