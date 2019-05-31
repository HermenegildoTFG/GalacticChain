contract Count
{
	uint256 total;
	uint256 [] nums;
	function Count() public
	{
		total = 0;
    }

    function getTotal() returns(uint256)
    {
	   return total;
    }
    function add(uint256 a )
    {
	       nums.push(a);
           total += a;
    }
}
