contract Unsafe
{
  uint[] private a;
  function addInt(uint n) public
  {
  	 a.push(n);
  }
  function massOperation() public payable
  {
   	uint i = 0;
    	while(i < a.length && msg.gas > 100000)
    	{
        		a[i] = a[i]+1;
       		 i++;
    	}
  }
}
