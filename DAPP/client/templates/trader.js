import "./trader.html";

Template.traderAccount.onCreated (function (){
	this.autorun(setButtons);
})

Template.traderAccount.helpers({
	name: function () {
		return ittDict["account"].get().name;
	},
	account: function () {
		return ittDict["account"].get().address;
	},
	balance: function () {
		return ittDict["accountBalance"].get();
	},
})

Template.traderAccount.events({
	'click button.modal': function(){
		// show modal
		EthElements.Modal.show('accountList');
	},
})


Template.accountList.helpers({
	accounts: function () {
		return EthAccounts.find().fetch();
	}
})

Template.accountList.events({
	'click button.accButton': function(){
		EthElements.Modal.hide();
		ittAPI.setTradeAccount(this);
		ittAPI.updateDesk();
		console.log(this);
	},
})


//	'click button.question-modal': function(){
//		// show modal
//		EthElements.Modal.question({
//			text: 'Are you ok?',
//			ok: function(){
//				alert('Very nice!');
//			},
//			cancel: true
//		});
//	},
//	'click button.question-modal-template': function(){
//		// show modal
//		EthElements.Modal.question({
//			template: 'modal_demo',
//			ok: function(){
//				 alert('Lorem ipsum!');
//			},
//			cancel: function(){
//				alert('Ok Bye!');
//			}
//		});
//	}
