const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');



const provider = new HDWalletProvider(

  /*surtituir por la semilla de tus cuentas Metamask*/,
  /*URL proporcionada por Infura*/
);

const web3 = new Web3(provider);


const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  var resultList;
  var resultAlertControl;
  var resultDatabase;

  {
    console.log('Attempting to deploy database from',accounts[0]);
    const {interface, bytecode} = require('./compileDatabase');
    resultDatabase = await new web3.eth.Contract(JSON.parse(interface))
      .deploy({ data:'0x'+ bytecode})
      .send({ from: accounts[0]});

    const path = require('path');
    const fs = require('fs');

    const DataPath = path.resolve(__dirname,'datos','data.txt');
    var row = fs.readFileSync(DataPath,'utf8').split("\n");

    console.log("initializing database...");
    for(var i = 1; i < row.length -1;i++)
    {

      var params = row[i].split(",");

      var type = parseInt(params[2],10);
      var hex = params[0];
      var byt = web3.utils.asciiToHex(params[1]);

      await resultDatabase.methods
               .addData(type,hex,byt)
               .send({ from: accounts[0]});
    }
    console.log("database initialize");
    console.log();
    console.log();
    //console.log(interface);
    console.log('Contract database deployed to', resultDatabase.options.address);
    console.log();
    console.log();
  }



  {
  const {interface, bytecode} = require('./compileContractList');

  console.log('Attempting to deploy ContractList from account',accounts[0]);
  resultList = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data:'0x'+ bytecode})
    .send({ from: accounts[0]});
  console.log('Contract ContractList deployed to', resultList.options.address);
  }

  {
  const {interface, bytecode} = require('./compileAlertControl');
  console.log('Attempting to deploy AlertControl from account',accounts[0]);
  resultAlertControl = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data:'0x'+ bytecode,
              arguments: [resultList.options.address]})
    .send({ from: accounts[0]});
  console.log('Contract AlertControl deployed to', resultAlertControl.options.address);
  }

  console.log('changing ownership');
  await resultList.methods.declareOwnerShip(resultAlertControl.options.address).send({ from: accounts[0]});
  console.log('ownership changed');

  {
  console.log('Attempting to deploy from account',accounts[0]);
  const {interface, bytecode} = require('./compileServer');
  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data:'0x'+ bytecode ,
              arguments: [resultDatabase.options.address,resultAlertControl.options.address]})
    .send({ from: accounts[0] ,value: 1});

  console.log('declaring server as alert control owner');
  await resultAlertControl.methods.declareOwnerShip(result.options.address).send({ from: accounts[0]});
  console.log('ownership declared');

  console.log('declaring server as dataBase owner');
  await resultDatabase.methods.declareOwnerShip(result.options.address).send({ from: accounts[0]});
  console.log('ownership declared');

  console.log('adding accidents');
  console.log("adding first lost spaceship");

  await result.methods.newAlert(
    web3.utils.asciiToHex("nave22 direccion 34:21"),
    web3.utils.asciiToHex("12345")
  )
    .send({ from: accounts[0], value: web3.utils.toWei('0.2','ether')});

  console.log("adding second lost spaceship");
  await result.methods.newAlert(
    web3.utils.asciiToHex("nave45 direccion 34:30"),
    web3.utils.asciiToHex("12345")
  )
    .send({ from: accounts[0], value: web3.utils.toWei('0.15','ether')});

  console.log("adding third lost spaceship");
  await result.methods.newAlert(
    web3.utils.asciiToHex("nave55 direccion 55:30"),
    web3.utils.asciiToHex("12345")
  )
    .send({ from: accounts[0], value: web3.utils.toWei('0.11','ether')});


  console.log("adding fourth lost spaceship");
  await result.methods.newAlert(
    web3.utils.asciiToHex("nave66 direccion 55:44"),
    web3.utils.asciiToHex("12345")
  )
    .send({ from: accounts[0], value: web3.utils.toWei('0.2','ether')});

  console.log();
  console.log();

  console.log('Contract Server deployed to', result.options.address);
  console.log('project successfully upload to the Rinkeby blockchain');
  console.log('Server ABI:')
  console.log(interface);

  }
};
deploy();
