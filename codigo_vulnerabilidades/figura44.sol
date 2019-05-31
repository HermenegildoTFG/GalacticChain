contract Investor
{
  	uint balance;
  	Safe safe;
  	function Investor(address _safe) payable public
  	{
    		balance = msg.value;
    		safe = Safe(_safe);
  	}
  	function safeMoney(uint money) public
  	{
    		if(money <= balance){
      			balance -= money;
      			safe.addOwner.value(money)();
    		}
  	}
  	function takeBalance(uint money)public
  	{
    		safe.getMoney(money);
  	}
  	function addMoney() payable public
  	{
   		 balance += msg.value;
  	}
}
