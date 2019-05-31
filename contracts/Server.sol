pragma solidity ^0.4.17;//version de solidity para la que se ha creado el programa

interface DataBase
{
  function isClean(address add) view  public returns (bool);
  function getData(address add) view  public returns (bytes32);
  function getType(address add) view  public returns (uint);
  function deprecate() payable public ;
  function kill() payable  public ;
}



interface AlertManager
{
  function newAlert(bytes32 info) payable public ;
  function verifyAlert(address a) payable public returns(bytes32);
  function getPendingList() view public returns(address);
  function getValue(address a)view public returns(bytes32);
  function kill() payable  public ;
}

interface LostList
{
  function getIndex(uint256 i) view public returns(address) ;
  function getLength() view public returns(uint256) ;
  function del() payable public ;
}



contract Alert
{
  address _owner;
  address private _creator;
  uint256 private _price;
  bytes32 private _signature;

  function Alert(address creator,uint256 price,bytes32 signature) payable public
  {
    _owner = msg.sender;
    _creator = creator;
    _price = price;
    _signature = signature;
  }

  function getCreator() view public returns(address)
  {
    require(msg.sender == _owner);
    return _creator;
  }

  function getPrice() view public returns(uint256)
  {
    require(msg.sender == _owner);
    return _price;
  }
  function getSignature() view public returns(bytes32)
  {
    require(msg.sender == _owner);
    return _signature;
  }
  function kill() public{
    selfdestruct(_owner);
  }
}

contract Server
{
      event NewAccident(
        bytes32 _info
      );
      event DeletedAccident(
        uint256 _deleted
      );
      event NewLost
      (
        uint256 _idAc
      );
      event FoundLost
      (
        uint256 _idAc
      );
      event NewAssistance(
        uint256 _idAc,
        address _idAssitance
      );
      event DeleteAssistance(
        uint256 _idAc,
        address _addidAssitance
      );
      event ChangedAlerts();
      event SignedAccident(
        uint256 _idAc
      );

    struct Accident
    {
      /*removing and inserting are going to be used very often so is better if it uses a implementation that takes this into account*/
      address creator;
      address winner;
      uint256 price;
      bytes32 signature;
      bool signed;
      bytes32 info;
      address [] missing;
      mapping(address => bool) assistance;
      address[] assistance_to_refund;
      uint256 numAssitance;
    }



    address private Owner;

    /*the length of the array is not going to be long enough to be a problem, also removing and inserting are not going to be
    of often use.
      =>insert always at the end
      =>when removing from and index fill the gap with the higher index elements
    */
    Accident [] currentAccidents;
    address dataBase;
    address alertManager;
    mapping(address => bool)private registerExisting;
    mapping(bytes32 => bool)private registeredAccidents;

    mapping (bytes32=>bool) private alert_reg;
    mapping(bytes32=>address) private alert_location;

    address private alertList;
    uint256 private jackpot;

    uint256 private stateMiss;
    uint256 private stateAcc;
    bool private work;
    uint256 private currIdAC;

    function Server(address database,address _alertManager) payable public
    {
      Owner = msg.sender;
      dataBase = database;
      alertManager = _alertManager;
      alertList = AlertManager(alertManager).getPendingList();
      jackpot = 0;
      work = false;
    }

    modifier OnlyOwner(address id)
    {
      require(id == Owner);
      _;
    }
    modifier noReg(address id)
    {
      require(!registerExisting[id]);
      _;
    }
    modifier existingAc(uint256 id)
    {
      require(id < currentAccidents.length);
      _;
    }
    modifier existingLost(address id)
    {
      require(registerExisting[id]);
      _;
    }

    modifier newAccident(bytes32 desc)
    {
      require(!registeredAccidents[desc]);
      _;
    }

    function sendJackpot(address a) public
    {
        require(msg.sender == Owner);
        uint256 aux = jackpot;
        jackpot = 0;
        a.transfer(aux);
    }


    //  interaction with AlertManager //


    function newAlert(bytes32 info,bytes32 signature) payable public
    {
        require(DataBase(dataBase).isClean(msg.sender));
        require(DataBase(dataBase).getType(msg.sender) == 0);
        require(DataBase(dataBase).isClean(msg.sender));
        require(!registeredAccidents[info]);
        require(!alert_reg[info]);
        require(msg.value >= 0.10 ether);

        alert_reg[info] = true;
        alert_location[info] = new Alert(msg.sender,msg.value,signature);

        AlertManager(alertManager).newAlert(info);
        LostList(alertList).del();
        alertList = AlertManager(alertManager).getPendingList();
        ChangedAlerts();
    }

    function deleteAlert(uint256 a) payable public
    {
      require(DataBase(dataBase).isClean(msg.sender));
      require(DataBase(dataBase).getType(msg.sender) == 0);
      require(LostList(alertList).getLength() > a);

      address dir = LostList(alertList).getIndex(a);
      bytes32 info = AlertManager(alertManager).getValue(dir);

      require(alert_reg[info]);
      require(Alert(alert_location[info]).getCreator() == msg.sender);

      AlertManager(alertManager).verifyAlert(dir);

      alert_reg[info] = false;
      msg.sender.transfer(Alert(alert_location[info]).getPrice());
      Alert(alert_location[info]).kill();
      LostList(alertList).del();
      alertList = AlertManager(alertManager).getPendingList();
      ChangedAlerts();
    }

    function verifyAlert(uint256 a) payable public
    {
        require(DataBase(dataBase).isClean(msg.sender));
        require(DataBase(dataBase).getType(msg.sender) == 1);
        address dir = LostList(alertList).getIndex(a);
        bytes32 info = AlertManager(alertManager).verifyAlert(dir);
        require(alert_reg[info]);

        newAccidentProtocol(info);
        LostList(alertList).del();
        alertList = AlertManager(alertManager).getPendingList();
        ChangedAlerts();
    }

    function getAlertsNum() view public returns(uint256)
    {
      //require(DataBase(dataBase).isClean(msg.sender));
      uint256 ret = LostList(alertList).getLength();
      return ret;
    }

    function getAlert(uint256 a) view public returns (bytes32)
    {
      //require(DataBase(dataBase).isClean(msg.sender));
      uint256 n = LostList(alertList).getLength();
      require(a < n);
      address d = LostList(alertList).getIndex(a);
      return AlertManager(alertManager).getValue(d);
    }

    function getAlertCreator(uint256 a) view public returns (address)
    {
      //require(DataBase(dataBase).isClean(msg.sender));
      uint256 n = LostList(alertList).getLength();
      require(a < n);
      address d = LostList(alertList).getIndex(a);
      return Alert(alert_location[AlertManager(alertManager).getValue(d)]).getCreator();
    }

    function getAlertPrice(uint256 a) view public returns (uint256)
    {
      //require(DataBase(dataBase).isClean(msg.sender));
      uint256 n = LostList(alertList).getLength();
      require(a < n);
      address d = LostList(alertList).getIndex(a);
      return Alert(alert_location[AlertManager(alertManager).getValue(d)]).getPrice();
    }


    function newAccidentProtocol(bytes32 name) newAccident(name) private returns(uint id)
    {
      require(!work);
      require(DataBase(dataBase).isClean(msg.sender));
      require(DataBase(dataBase).getType(msg.sender) == 1);
      require(alert_reg[name]);
      require(msg.value == 0.10 ether);

      alert_reg[name] = false;


      Accident memory n;
      n.creator = Alert(alert_location[name]).getCreator();
      n.price = Alert(alert_location[name]).getPrice();
      n.signature = Alert(alert_location[name]).getSignature();
      n.info = name;
      n.numAssitance = 0;
      n.assistance_to_refund = new address [](0);
      n.signed = false;
      id = currentAccidents.push(n);

      currentAccidents[currentAccidents.length -1].assistance_to_refund.push(msg.sender);
      currentAccidents[currentAccidents.length -1].assistance[msg.sender] = true;
      currentAccidents[currentAccidents.length -1].numAssitance++;

      registeredAccidents[name] = true;
      Alert(alert_location[name]).kill();
      NewAccident(name);
    }


    function getAccidentCreator(uint256 idAc) existingAc(idAc) view public returns (address)
    {
      require(!work);
      return currentAccidents[idAc].creator;
    }

    function getAccidentPrice(uint256 idAc) existingAc(idAc) view public returns (uint256)
    {
      require(!work);
      return currentAccidents[idAc].price;
    }

    function isSigned(uint256 idAc) existingAc(idAc) view public returns(bool)
    {
      require(!work);
      return currentAccidents[idAc].signed;
    }



    function signAccident(uint256 idAc,bytes32 signature) existingAc(idAc) payable public
    {
      require(!work);
      require(currentAccidents[idAc].assistance[msg.sender]);
      require(currentAccidents[idAc].signature == signature);
      require(!currentAccidents[idAc].signed);
      currentAccidents[idAc].winner = msg.sender;
      currentAccidents[idAc].signed = true;
      SignedAccident(idAc);
    }

    function homework() public view returns(bool)
    {
      return work;
    }
    function giveWork(uint idAc) existingAc(idAc) payable public
    {
      require(!work);
      bytes32 info = currentAccidents[currIdAC].info;
      require(!registeredAccidents[info]);
      require(currentAccidents[idAc].signed);
      require(currentAccidents[idAc].creator == msg.sender);
      work = true;
      stateAcc = idAc;
      stateMiss = 0;
      currIdAC = idAc;
    }
    function rewardAccident() payable public returns(bool)
    {
      require(currentAccidents[currIdAC].creator == msg.sender);
      if(work){
        return false;
      }

      uint256 price = currentAccidents[currIdAC].price;
      currentAccidents[currIdAC].price = 0;

      if(currentAccidents[currIdAC].winner.send(currentAccidents[currIdAC].price)){
        bytes32 info = currentAccidents[currIdAC].info;
        registeredAccidents[info] = false;
        return true;
      }
      else{
        currentAccidents[currIdAC].price = price;
      }
    }


    function deleteAccidentProtocol() private
    {

        while(stateMiss < currentAccidents[currIdAC].missing.length && msg.gas > 10000000){
          registerExisting[currentAccidents[currIdAC].missing[stateMiss]] = false;
          stateMiss++;
        }
        while(stateAcc < currentAccidents.length-1 && msg.gas > 10000000)
        {
          currentAccidents[stateAcc] = currentAccidents[stateAcc+1];
          stateAcc++;
        }
        stateMiss = stateMiss % currentAccidents[currIdAC].missing.length;
        stateAcc = stateAcc % currentAccidents.length-1;
        if(stateMiss == 0 && stateAcc == 0){
          work = false;
          currentAccidents.length--;
          DeletedAccident(stateAcc);
        }
    }

    function getData(address idAddress) view public returns(bytes32)
    {
        require(DataBase(dataBase).isClean(idAddress));
        return DataBase(dataBase).getData(idAddress);
    }

    function getNumOfAccidents()  view public returns (uint256)
    {
        require(!work);
        return currentAccidents.length;
    }

    function getAccident(uint256 i) view public returns (bytes32)
    {
        require(!work);
        return currentAccidents[i].info;
    }

    //Lost operations

    function newLost(uint256 idAc,address idAddress) payable noReg(idAddress) existingAc(idAc) public
    {
      require(!work);
      require(currentAccidents[idAc].creator == msg.sender);
      require(!currentAccidents[idAc].signed);
      currentAccidents[idAc].missing.push(idAddress);
      registerExisting[idAddress] = true;
      NewLost(idAc);
    }

    /*function foundLost(address idAddress)payable existingLost(idAddress) public
    {

      CurrentPlace storage place = registerInfo[idAddress];
      Accident storage acc = currentAccidents[place.accident];

      require(DataBase(dataBase).isClean(msg.sender));
      require(DataBase(dataBase).getType(msg.sender) == 1);
      registerExisting[idAddress] = false;

      deleteValue(acc.missing,place.missingplace);
      FoundLost(place.accident);
    }*/

    function getLostList(uint256 idAc) view existingAc(idAc)  public returns(address[] memory)
    {
      require(!work);
      return currentAccidents[idAc].missing;
    }

    function givesAssistance(uint256 idAc) view existingAc(idAc) public returns(bool)
    {
        require(!work);
       return currentAccidents[idAc].assistance[msg.sender];
    }

    //assistance operations
    function addAssistance(uint256 idAc) payable existingAc(idAc)  public
    {
          require(!work);
          require(DataBase(dataBase).isClean(msg.sender));
          require(DataBase(dataBase).getType(msg.sender) == 1);
          require(!currentAccidents[idAc].assistance[msg.sender]);
          require(!currentAccidents[idAc].signed);
          require(msg.value == 0.10 ether);
          currentAccidents[idAc].assistance[msg.sender] = true;
          currentAccidents[idAc].numAssitance++;
          currentAccidents[idAc].assistance_to_refund.push(msg.sender);
          currentAccidents[idAc].price += msg.value;
          NewAssistance(idAc,msg.sender);
    }

    /*function deleteAssistance(uint256 idAc) payable existingAc(idAc)  public
    {
          require(currentAccidents[idAc].assistance[msg.sender]);
          require(currentAccidents[idAc].numAssitance > 0);
          currentAccidents[idAc].assistance[msg.sender] = false;
          currentAccidents[idAc].numAssitance--;
          uint256 ind = 0;

          while(!currentAccidents[idAc].assistance_values.reg_ocup[ind])ind++;
          while(currentAccidents[idAc].assistance_values.A[ind] != msg.sender)
          {
              ind++;
              while(!currentAccidents[idAc].assistance_values.reg_ocup[ind])ind++;
          }
          deleteValue(currentAccidents[idAc].assistance_values,ind);
          if(currentAccidents[idAc].numAssitance == 0)
            deleteAccidentProtocol(idAc);
          DeleteAssistance(idAc,msg.sender);

    }*/

    function getAssistanceList(uint256 idAc) view existingAc(idAc)  public returns(address[] memory)
    {
      require(!work);
      return currentAccidents[idAc].assistance_to_refund;
    }

    /*used in case the smartcontract is deprecated in favour of other one*/
    function kill() OnlyOwner(msg.sender) public
    {
      Owner.transfer(this.balance);
      AlertManager(alertManager).kill();
      DataBase(dataBase).deprecate();
      DataBase(dataBase).kill();
      selfdestruct(Owner);
    }
}
