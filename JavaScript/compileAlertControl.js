const path = require('path');
const fs = require('fs');
const solc = require('solc');

//nos proporciona el path a los archivos que necesitamos
const ControlAlertasPath = path.resolve(__dirname,'contracts','ControlAlertas.sol');
const source = fs.readFileSync(ControlAlertasPath,'utf8');

module.exports = solc.compile(source,1).contracts[':ControlAlertas'];
