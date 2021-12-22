// var HDWalletProvider = require("@truffle/hdwallet-provider");
module.exports = 
{
    networks: 
    {
	    development: 
		  {
	   		host: "localhost",
	   		port: 7545,
	   		network_id: "*", // Match any network id
		  },
    	// rinkeby: {
    	//     provider: function() {
		  //     var mnemonic = "salon size apart blame rookie index valve peanut stable found symbol liar"; //put ETH wallet 12 mnemonic code	
		  //     return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/d9df5631b7264b23a2e5eabdd6d1da69");
		  //   },
		  //   network_id: '4',
		  //   from: '0x3946d07C22987351aB828da580c44562fB5A80cf', /*ETH wallet 12 mnemonic code wallet address*/
		  // }  
		
    },
	compilers: {
		solc: {
			version: "0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
			// docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
			// settings: {          // See the solidity docs for advice about optimization and evmVersion
			 optimizer: {
			   enabled: true,
			   runs: 200
			 },
			//  evmVersion: "byzantium"
			// }
		}
		}
};