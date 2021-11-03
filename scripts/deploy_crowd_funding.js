
async function deploy_contract(contractName, constructorArgs, account, value) {
    
    let artifactsPath = `browser/contracts/artifacts/${contractName}.json`
    
    console.log(`Deploying ${contractName} from "${artifactsPath}"`)
    
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
    let contract = new web3.eth.Contract(metadata.abi)
    
    contract = contract.deploy({
        data: metadata.data.bytecode.object,
        arguments: constructorArgs
    });
    
    return await contract.send({
            from: account,
            gas: 6721975,
            gasPrice: '15',
            value: value
    })
}

(async () => {
    try {
        console.log('Deploying crowd funding contracts');
        const accounts = await web3.eth.getAccounts();
    
        let cf_contract = await deploy_contract("CrowdFunding", ["100"], accounts[0], 0);
        console.log(`Contract deployed at address: ${cf_contract.options.address}`);
        
        let sf_contract = await deploy_contract("SponsorFunding", [cf_contract.options.address, "50"], accounts[0], 50);
        console.log(`Contract deployed at address: ${sf_contract.options.address}`);
        
    } catch (e) {
        console.log(e.message)
    }
  })()