pragma solidity ^0.4.17;

contract Node
{
   address private sign;
   bytes32 private value;
   function Node(bytes32 _value) public
   {
        sign = msg.sender;
        value = _value;
   }

   function signedByMe() view public returns(bool)
   {
          return sign == msg.sender;
   }
   function getValue() view public returns(bytes32)
   {
          return value;
   }
   function del() payable public
   {
      require(msg.sender == sign);
      selfdestruct(sign);
   }
}


contract LostList
{
    address owner;
    address[]  list;
    function LostList(address[] memory _list,address _owner) public
    {
        list = _list;
        owner = _owner;
    }

    function getIndex(uint256 i) view public returns(address)
    {
        require(i < list.length);
        return list[i];
    }
    function getLength() view public returns(uint256)
    {
      return list.length;
    }
    function del() payable public
    {
       require(msg.sender == owner);
       selfdestruct(owner);
    }
}

interface ContractList
{
  function push(address n) payable public ;

  function erase(address n) payable public ;

  function top() view public returns(address);

  function isEnd(address n) view public returns(bool) ;

  function hasKey(address n) view public returns(bool) ;

  function getNext(address n) view public returns(address);

  function getPrev(address n) view public returns(address);
}

contract ControlAlertas
{
  address private owner;
  address private list;
  uint256 private length;
  mapping (bytes32 => bool) bytes32_to_bool;
  function ControlAlertas(address _list) payable public
  {
      owner = msg.sender;
      list = _list;
      length = 0;
  }


   function declareOwnerShip(address _owner) payable public
   {
     require(msg.sender == owner);
     owner = _owner;
   }

   function newAlert(bytes32 info) payable public
   {
        require(!bytes32_to_bool[info]);
        address a = new Node(info);
        ContractList(list).push(a);
        length++;
   }

   function verifyAlert(address a) payable public returns(bytes32)
   {
        require(ContractList(list).hasKey(a));
        require(Node(a).signedByMe());
        bytes32 ret = Node(a).getValue();
        ContractList(list).erase(a);
        Node(a).del();
        length--;
        return ret;

   }

   function getPendingList() payable public returns(address)
   {
        address act = ContractList(list).top();
        address [] memory ret = new address[](length);
        uint256 i = 0;
        while(ContractList(list).hasKey(act) && msg.gas > 10000000)
        {
           if(Node(act).signedByMe()){
               ret[i] = act;
               i++;
           }
           act = ContractList(list).getNext(act);
        }
        address a = new LostList(ret,msg.sender);
        return a;
   }
   function getValue(address a)view public returns(bytes32)
   {
          require(ContractList(list).hasKey(a));
          require(Node(a).signedByMe());
          return Node(a).getValue();
   }

   function kill() payable  public
   {
       require(msg.sender == owner);
       selfdestruct(owner);
   }


}
