pragma solidity ^0.4.17;

contract DataBase
{
    mapping(address => uint)  public addressType;/*0 => person, 1 => assistance*/
    mapping(address=>bytes32) public dataStore;
    mapping(address => bool)  public clean;
    address owner;
    bool deprecated;

    modifier OnlyOwner
    {
        require(msg.sender == owner);
        _;
    }
    function DataBase() public {
      owner = msg.sender;
      deprecated = false;
    }

//-----------------WORKING OPERATIONS---------------

    function isClean(address add) view  public returns (bool)
    {
        require(!deprecated);
        return clean[add];
    }
    function getData(address add) view  public returns (bytes32)
    {
        require(clean[add]);
        require(!deprecated);
        return dataStore[add];
    }
    function getType(address add)view  public returns(uint)
    {
        require(clean[add]);
        require(!deprecated);
        return addressType[add];
    }
    function deprecate() payable OnlyOwner public
    {
        require(msg.gas >= 10 wei);
        require(!deprecated);
        deprecated = true;
        assert(deprecated);
    }
    function addData(uint Type,address id, bytes32 data) payable OnlyOwner public
    {
      require(0<=Type && Type<=1);
      require(!clean[id]);
      require(!deprecated);
      addressType[id] = Type;
      clean[id] = true;
      dataStore[id] = data;
      assert(clean[id]);
    }
    function declareOwnerShip(address _owner) payable public
    {
      require(msg.sender == owner);
      require(!deprecated);
      owner = _owner;
    }

//-----------------DEPRECATE OPERATIONS---------------
    function kill() payable OnlyOwner public
    {
        require(msg.gas >= 100 wei);
        require(deprecated);
        selfdestruct(owner);
    }

}
