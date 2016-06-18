contract ITT {
	
	bool constant BUY = false;
	bool constant SELL = true;
	uint256 constant MAXNUM = 2**255 - 1;
	uint256 constant MINNUM = 0;
	
	struct order {
		uint256 price;
		uint256 amount;
		address trader;
	}
	
	struct ordersFIFO {		
		uint256 up; // next higher price FIFO.
		uint256 down; // next lower price FIFO.
	    uint256 numOrders;
	    uint256 head; // first open order in orderID's array. 'orderIds.length - 1' is the last order;
	    uint256[] orderIds;
	}
	
    mapping (address => uint256) balances;
	mapping (address => bool) mutex;
	order[] orders; // Orders in order of creation
	mapping (uint256 => ordersFIFO) priceBook; // link list of live order prices
	mapping (address => uint256) locked; // Tokens comited to open sell orders.
	uint256 lowestAsk; // Lowest sell offer
	uint256 highestBid; // Highest buy offer
	uint256 lowestPrice; // Lowest buy price
	uint256 highestPrice; // Highest sell price
	
	function ITT() {
		balances[msg.sender] = 1000000;
		lowestAsk = MAXNUM;
		lowestPrice = MAXNUM;
		}
	
	function () { throw; }
	
	function getMetrics() constant returns (uint256 _balance,
											uint256 _locked,
											uint256 _highestPrice,
											uint256 _lowestAsk,
											uint256 _highestBid,
											uint256 _lowestPrice) {
		_balance = balances[msg.sender];
		_locked = locked[msg.sender];
		_highestPrice = highestPrice;
		_lowestAsk = lowestAsk;
		_highestBid = highestBid;
		_lowestPrice = lowestPrice;
		return;
	}
	
	function getFifo(uint256 _price) constant returns (uint256 _numOrders,
													   uint256 _head,
													   uint256 _tail) {
		_numOrders = priceBook[_price].numOrders;
		_head = priceBook[_price].head;
		_tail = priceBook[_price].orderIds.length;
		return;
	}
	
	function getFifoOrderId(uint _price, uint _ord) constant returns (uint){
		return priceBook[_price].orderIds[_ord];
	}
	
	function getVolumeAtPrice(uint256 _price) constant returns (uint256 _volume) {
		ordersFIFO fifo = priceBook[_price];
		uint256 len = fifo.orderIds.length;
		uint256 i = fifo.head;
		while(i < len) _volume += orders[fifo.orderIds[i++]].amount;
		return;
	}
	
	function getOrder(uint256 _orderId) constant returns (address _trader,
														  uint256 _price,
														  uint256 _vol) {
		order memory ord = orders[_orderId];
		_trader = ord.trader;
		_price = ord.price;
		_vol = ord.amount;
		return;
	}
	
	function consumeOrder(uint256 _price) returns (bool){
		ordersFIFO fifo = priceBook[_price];
		if (fifo.numOrders == 0) throw;
		uint256 next = fifo.head;
//		if (orders[fifo.orderIds[next]].amount > 0) return true;
		while (orders[fifo.orderIds[next]].amount == 0 && next < fifo.orderIds.length) next++;
		fifo.head = next;
		fifo.numOrders--;
		if (fifo.numOrders == 0) unstitchFifo(_price);
		return true;
	}
	
	function cancelOrder(uint256 _ordId) returns (bool){
		order ord = orders[_ordId];
		if (ord.trader != msg.sender) return false;
		if (ord.price <= highestBid) { msg.sender.send(ord.price * ord.amount); } 
		else { locked[msg.sender] -= ord.amount; }
		uint price = ord.price;
		delete orders[_ordId];
		consumeOrder(price);
		return true;
	}
	
	function swap(address _from, address _to, uint256 _price, uint256 _amount) internal {
		balances[_from] -= _amount;
		balances[_to] += _amount;
		if(!mutex[_from]) {
			mutex[_from]=true;
			_from.send(_price * _amount);
			delete mutex[_from];
		}
	}
	
	function unstitchFifo(uint256 _price) internal returns (bool) {
		ordersFIFO fifo = priceBook[_price];
		if (lowestPrice == highestPrice && highestPrice == _price){
			// no orders left;
			lowestPrice = 0;
			highestPrice = 0;
			return true;
		}
		if (_price == lowestPrice) {
			lowestPrice = fifo.up;
			priceBook[fifo.up].down = 0;
			return true;
		}
		if (_price == highestPrice) {
			highestPrice = fifo.down;
			priceBook[fifo.down].up = 0;
			return true;
		}
		priceBook[fifo.down].up = fifo.up;
		priceBook[fifo.up].down = fifo.down;
		return true;
	}
	
	function stitchFifo(ordersFIFO _fifo, uint256 _up, uint256 _down) internal returns (bool){
		_fifo.up = _up;
		_fifo.down = _down;
		return true;
	}
	
	function insertFifo(uint256 _price) internal returns (bool) {
		ordersFIFO fifo = priceBook[_price];
		if (_price < highestPrice && _price > lowestPrice && lowestPrice > 0) {
			uint256 seek = highestPrice;
			while (seek > _price) 
				if (seek > priceBook[seek].down) seek = priceBook[seek].down;
			stitchFifo(fifo, priceBook[seek].up, seek);
			priceBook[fifo.up].down = _price;
			priceBook[fifo.down].up = _price;
			return true;
		}
		if (_price < lowestPrice || lowestPrice == 0) {
			priceBook[lowestPrice].down = _price;
			lowestPrice = _price;
			stitchFifo(fifo, lowestPrice, 0);
		}
		if (_price > highestPrice) {
			stitchFifo(fifo, 0, highestPrice);
			priceBook[highestPrice].up = _price;
			highestPrice = _price;
		}
		return true;
	}		
	
	function insertOrder(uint256 _ordId) internal returns (bool) {
		ordersFIFO fifo = priceBook[orders[_ordId].price];
		if (fifo.numOrders == 0) insertFifo(orders[_ordId].price);
		fifo.orderIds.push(_ordId);
		fifo.numOrders++;
		return true;
	}

	function takeAsk(uint256 eth) returns (uint256 _remaining){
		ordersFIFO fifo = priceBook[lowestAsk];
		order ord = orders[fifo.orderIds[fifo.head]];
		uint256 amount = eth / ord.price;
		if (amount < ord.amount) {
			swap(ord.trader, msg.sender, ord.price, amount);
			_remaining = 0;
			ord.amount -= amount;
			return;
		}
		swap(ord.trader, msg.sender, ord.price, ord.amount);
		_remaining = eth - ord.price * ord.amount;
		delete orders[fifo.orderIds[fifo.head]];
		consumeOrder(lowestAsk);
		return;		
	}
	
	function takeBid(uint256 _price, uint256 _amount) returns (uint256 _remaining){
		ordersFIFO fifo = priceBook[highestBid];
		order ord = orders[fifo.orderIds[fifo.head]];
		if (_amount < ord.amount) {
			swap(msg.sender, ord.trader, ord.price, _amount);
			_remaining = 0;
			ord.amount -= _amount;
			return;
		}
		swap(msg.sender, ord.trader, ord.price, ord.amount);
		_remaining = _amount - ord.amount;
		consumeOrder(highestBid);
		delete orders[fifo.orderIds[fifo.head]];
		return ;		
	}
	
	function make(bool _swap, uint256 _price, uint256 _amount) returns (uint256 _ordId){
		order ord = orders[orders.length++];
		ord.trader = msg.sender;
		ord.price = _price;
		ord.amount = _amount;
		_ordId = orders.length - 1;
		insertOrder(_ordId);
		return _ordId;		
	}
	
	function buy (uint256 _price, bool _make) returns (uint256 _bought, uint256 _ordId) {
		if (msg.value == 0) throw;
		uint256 eth = msg.value;
		_bought = eth;
		while (_price >= lowestAsk && eth > 0) eth = takeAsk(eth);
		if (eth > 0 && _make) {
			_ordId =  make(BUY, _price, eth / _price);
			if(_price > highestBid) highestBid = _price;
		}
		_bought -= eth;
		if (eth > 0 && !_make) msg.sender.send(eth); // refund remaining ether
		return;
	}

	function sell (uint256 _price, uint256 _amount, bool _make) returns (uint256 _sold, uint256 _ordId) {
		if (_amount > balances[msg.sender] || _price == 0 || _amount == 0) throw;
		_sold = _amount;
		while (_price <= highestBid && _amount > 0)	_amount = takeBid(_price, _amount);
		if (_amount > 0 && _make) {
			_ordId = make(SELL, _price, _amount);
			if(_price < lowestAsk) lowestAsk = _price;
		}
		_sold -= _amount;
	}
}
