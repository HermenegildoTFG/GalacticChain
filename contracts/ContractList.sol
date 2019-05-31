pragma solidity ^0.4.17;

/*
    we have 2 posibilities:
      1 =>
          left the contract ownerless so the list can be use by everyone, this will let in signed contracts so is known the address that push that value in the list.
      2=>
          declare ownership in the list when created
    in this case, since is going to be use inside a damage control contract that needs as much efficiency as possible is going to be implemented possibilitie number 2

*/
contract ContractList
{
    address private ini;
    address private end;
    address private owner;
    mapping(address => bool) private isInTheStack;
    mapping(address => address) private nodeTonext;
    mapping(address => address)  private nodeToprev;

    modifier OnlyOwner
    {
      require(msg.sender == owner);
      _;
    }

    function ContractList() public
    {
        ini = address(0);
        end = address(0);
        owner = msg.sender;
        isInTheStack[address(0)] = false;
        nodeTonext[ini] = address(0);
        nodeToprev[ini] = address(0);

    }


    function declareOwnerShip(address _owner) OnlyOwner payable public
    {
          owner = _owner;
    }

    function push(address n) OnlyOwner payable public
    {
        isInTheStack[n] = true;
        nodeTonext[n] = ini;
        nodeToprev[n] = address(0);
        nodeToprev[ini] = n;
        ini = n;
    }

    function erase(address n) OnlyOwner payable public
    {
        require(isInTheStack[n]);
        if(ini == n)
        {
          ini = nodeTonext[ini];
          nodeToprev[ini] = address(0);
        }
        else{
        address aux = nodeToprev[n];
        nodeTonext[aux] = nodeTonext[n];
        nodeToprev[nodeTonext[n]] = aux;
        }
        isInTheStack[n] = false;
    }

    function top() view public returns(address)
    {
          return ini;
    }

    function isEnd(address n) view public returns(bool)
    {
         return n == end;
    }

    function hasKey(address n) view public returns(bool)
    {
         return isInTheStack[n];
    }

    function getNext(address n) view public returns(address)
    {
         require(isInTheStack[n]);
         return nodeTonext[n];
    }

    function getPrev(address n) view public returns(address)
    {
         require(isInTheStack[n]);
         return nodeToprev[n];
    }
    function kill() payable  public
    {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
}
