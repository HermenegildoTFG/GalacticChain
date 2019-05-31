contract Unsafe
{
  	uint[] private a;
  	uint nextAccount;
  	function Unsafe() public
  	{
    		nextAccount = 0;
  	}
 	function addInt(uint n) public
  	{
      		a.push(n);
  	}
  	function massOperation() public payable
  	{
    		uint i = nextAccount;
    		while(i < a.length && msg.gas > 100000)
    		{
       			 a[i] = a[i]+1;
        			i++;
    		}
   		 nextAccount = i%a.length;
  	}
}
