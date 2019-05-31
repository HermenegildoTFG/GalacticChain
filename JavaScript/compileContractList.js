const path = require('path');
const fs = require('fs');
const solc = require('solc');

//nos proporciona el path a los archivos que necesitamos
const ContractListPath = path.resolve(__dirname,'contracts','ContractList.sol');
const source = fs.readFileSync(ContractListPath,'utf8');

module.exports = solc.compile(source,1).contracts[':ContractList'];
