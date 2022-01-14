
const fs = require('fs');
const colors = require('colors');
const { ethers } = require("hardhat");

const SHARKBABYToken = require("../artifacts/contracts/sharkbaby.sol/SHARKBABYOKEN.json");
const Staking = require("../artifacts/contracts/staking.sol/Staking.json");
const ERC20ABI = require("../artifacts/contracts/dexfactory.sol/IERC20.json").abi;


async function main() {
	
	// get network
	var [owner] = await ethers.getSigners();
	
	let network = await owner.provider._networkPromise;
	let chainId = network.chainId;

	console.log(chainId)

	var exchangeRouter;
	var exchangeFactory;
	var wETH;

	var sharkbabyToken;
	var sharkToken;
	var babyToken;

	var stakingTokenPool;

	var pancakeswapV2PairContract;

	// if it is fantom testnet, it use own exchange contract
	if(chainId === 4002||chainId === 1337) {
		/* ----------- factory -------------- */
		//deploy factory contract for test
		const Factory = await ethers.getContractFactory("PancakeswapFactory");
		exchangeFactory = await Factory.deploy(owner.address);
		await exchangeFactory.deployed();
		console.log(await exchangeFactory.INIT_CODE_PAIR_HASH());

		console.log("exchangeFactory",exchangeFactory.address.yellow)
		/* ----------- WETH -------------- */
		//deploy WETH contract for test
		const WETH = await ethers.getContractFactory("WETH9");
		wETH = await WETH.deploy();
		await wETH.deployed();

		console.log("WETH",wETH.address.yellow)

		/* ----------- Router -------------- */
		//deploy Router contract for test
		const Router = await ethers.getContractFactory("PancakeswapRouter");
		exchangeRouter = await Router.deploy(exchangeFactory.address,wETH.address);
		await exchangeRouter.deployed();

		console.log("exchangeRouter",exchangeRouter.address.yellow)
	}
	else {		
		// if it is binance smart chain, it use pancakeswap contract
		exchangeRouter = {address:"0x8e12fD09f7A761AABaD0C8E0e574d797FE27b8A6"}
		sharkToken = {address:process.env.SHARKADDRESS} 
		babyToken = {address:process.env.BABYADDRESS}
	}

		/* ----------- SharkbabyToken -------------- */
	{
		
		const SHARKBABYTOKEN = await ethers.getContractFactory("SHARKBABYOKEN");
		sharkbabyToken = await SHARKBABYTOKEN.deploy();
		await sharkbabyToken.deployed();
		console.log("sharkbabyToken",sharkbabyToken.address.yellow)

		var tx = await sharkbabyToken.setInitialAddresses(exchangeRouter.address);
		await tx.wait();

		//set paircontract 
		var pairAddress = await sharkbabyToken.pancakeswapV2Pair();
		pancakeswapV2PairContract = new ethers.Contract(pairAddress,ERC20ABI,owner);
		
		//shark and baby token 
		const ERC20TOKEN = await ethers.getContractFactory("ERC20");
		sharkToken = await ERC20TOKEN.deploy("AutoShark","SHARK");
		await sharkToken.deployed()
		console.log("sharkToken",sharkToken.address.yellow)

		babyToken = await ERC20TOKEN.deploy("Babyswap","BABY");
		await babyToken.deployed()
		console.log("babyToken",babyToken.address.yellow)
	}

		/* ----------- staking -------------- */
	{
		const Staking = await ethers.getContractFactory("Staking");
		stakingTokenPool = await Staking.deploy(sharkbabyToken.address, sharkToken.address, babyToken.address);
		await stakingTokenPool.deployed();
		console.log("stakingTokenPool",stakingTokenPool.address.yellow)


		//setFeeAddress
		tx = await sharkbabyToken.setFeeAddresses(
			process.env.MARKETINGADDRESS, 
			process.env.GAMINGADDRESS, 
			stakingTokenPool.address, 
			);

		await tx.wait();
	}

	if(chainId === 4002) {
		tx = await sharkbabyToken.approve(exchangeRouter.address,ethers.utils.parseUnits("100000000",18));
		await tx.wait();

		tx = await exchangeRouter.addLiquidityETH(
			sharkbabyToken.address,
			ethers.utils.parseUnits("5000",18),
			0,
			0,
			owner.address,
			"111111111111111111111",
			{value : ethers.utils.parseUnits("10",18)}
		);
		await tx.wait();
	}
	

	var SharkbabyTokenContract = {
		address:sharkbabyToken.address,
		abi:SHARKBABYToken.abi
	}

	// save cotracts object that deployed for using in web3
	var contractObject = {
		sharkbabyToken:SharkbabyTokenContract,
		stakingTokenPool : {address: stakingTokenPool.address, abi : Staking.abi}
	};
	fs.writeFileSync(`./build/${network.chainId}.json`,JSON.stringify(contractObject, undefined, 4));
	
}

main().then(() => {
	console.log('complete'.green);
})
.catch((error) => {
	console.error(error);
	process.exit(1);
});
