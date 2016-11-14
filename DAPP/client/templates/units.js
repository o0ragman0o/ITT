import "./units.html"

Template.unit.helpers({
	uintName: function() {
		return EthTools.getUnit();
	}
})

Template.unitList.helpers({
	units: function() {
		return ["wei", "Kwei", "Mwei", "Gwei", "szabo", "finney", "ether", "Kether", "Mether", "Gether", "Tether"];
	}
})

Template.unit.events({
	'click button.modal': function(){
	// show modal
	EthElements.Modal.show('unitList');
	},
})