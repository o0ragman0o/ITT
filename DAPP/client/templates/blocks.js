import "./blocks.html";

Template.blocks.helpers ({
	'block': function () { return ittDict["latestBlock"].get(); },
	'bestBlock': function () {},
	'chainId': function () { return web3.version.network}
})