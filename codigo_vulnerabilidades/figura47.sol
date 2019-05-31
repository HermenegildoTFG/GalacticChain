contract Safer
{
 	mapping(address => uint) balance;
  	function Safe()payable public
  	{
    		addOwner();
 	 }

  	function addOwner() payable public
  	{
    		balance[msg.sender] += msg.value;
  	}

  	function getMoney(uint money) payable public
  	{
    		if(money >= balance[msg.sender]){
      			balance[msg.sender] -= money;
      			Investor(msg.sender).addMoney.value(money)();
    		}

 	 }
}
