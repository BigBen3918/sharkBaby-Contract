const { expect } = require("chai");
const { ethers } = require("hardhat");
const ERC20ABI = require("../artifacts/contracts/dexfactory.sol/IERC20.json").abi;

const {delay, fromBigNum, toBigNum} = require("./utils.js")

var exchangeRouter;
var exchangeFactory;
var wETH;

var sharkbabyToken;
var sharkToken;
var babyToken;

var stakingPool;

var owner;
var userWallet;

var pancakeswapV2PairContract;
var LPBalance1;

describe("Create UserWallet", function () {
  it("Create account", async function () {
	[owner] = await ethers.getSigners();

	userWallet = ethers.Wallet.createRandom();
	userWallet = userWallet.connect(ethers.provider);
	var tx = await owner.sendTransaction({
		to: userWallet.address, 
		value:ethers.utils.parseUnits("100",18)
	});
	await tx.wait();	
	});
});

describe("Exchange deploy and deploy", function () {

  it("Factory deploy", async function () {
    const Factory = await ethers.getContractFactory("PancakeswapFactory");
    exchangeFactory = await Factory.deploy(owner.address);
    await exchangeFactory.deployed();
	console.log(await exchangeFactory.INIT_CODE_PAIR_HASH())
  });

  it("WETH deploy", async function () {
    const WETH = await ethers.getContractFactory("WETH9");
    wETH = await WETH.deploy();
    await wETH.deployed();
  });
  
  it("Router deploy", async function () {
    const Router = await ethers.getContractFactory("PancakeswapRouter");
    exchangeRouter = await Router.deploy(exchangeFactory.address,wETH.address);
    await exchangeRouter.deployed();
  });

});

describe("Token contract deploy", function () {
	
	it("SHBY Deploy and Initial", async function () {
		const SHARKBABYTOKEN = await ethers.getContractFactory("SHARKBABYOKEN");
		sharkbabyToken = await SHARKBABYTOKEN.deploy();
		await sharkbabyToken.deployed();

		var tx = await sharkbabyToken.setInitialAddresses(exchangeRouter.address);
		await tx.wait();

		//set paircontract 
		var pairAddress = await sharkbabyToken.pancakeswapV2Pair();
		pancakeswapV2PairContract = new ethers.Contract(pairAddress,ERC20ABI,owner);
		
		//shark and baby token 
		const ERC20TOKEN = await ethers.getContractFactory("ERC20");
		sharkToken = await ERC20TOKEN.deploy("AutoShark","SHARK");
		await sharkToken.deployed()

		babyToken = await ERC20TOKEN.deploy("Babyswap","BABY");
		await babyToken.deployed()
	
	});

	it("autoSharktoken and babytoken staking pool deploy and setFeeaddress", async function(){
		//shark pool
		
		const Staking = await ethers.getContractFactory("Staking");
		stakingPool = await Staking.deploy(sharkbabyToken.address, sharkToken.address,babyToken.address);
		await stakingPool.deployed();

		//setFeeAddress
		var tx = await sharkbabyToken.setFeeAddresses(
			process.env.MARKETINGADDRESS, 
			process.env.GAMINGADDRESS, 
			stakingPool.address, 
			);

		await tx.wait();
	})

  	it("SHBY Add Liquidity", async function () {
		var tx = await sharkbabyToken.approve(exchangeRouter.address,ethers.utils.parseUnits("100000000",18));
		await tx.wait();

		tx = await exchangeRouter.addLiquidityETH(
			sharkbabyToken.address,
			ethers.utils.parseUnits("500000",18),
			0,
			0,
			owner.address,
			"111111111111111111111",
			{value : ethers.utils.parseUnits("5000",18)}
		);
		await tx.wait();

		// set LP balance1
		LPBalance1 = await pancakeswapV2PairContract.balanceOf(owner.address);
	});

});

describe("sharkbabyToken General  test", function () {
	it("name, symbol, totalSupply (BEP20) test", async function () {
		var name = await sharkbabyToken.name();
		var symbol = await sharkbabyToken.symbol();
		var totalSupply = await sharkbabyToken.totalSupply();

		// name is PLEDGE
		expect(name).to.equal("sharkbaby");
		
		// symbol is SHBY
		expect(symbol).to.equal("SHBY");

	})

	it("sharkbabyToken-eth test", async function () {
		
		var swapAmount = ethers.utils.parseUnits("100000",18);
		
		var initsharkbabyBalance = await sharkbabyToken.balanceOf(owner.address);
		var initETHTokenBalance = await owner.getBalance();
		var exceptSwapBalance = (await exchangeRouter.getAmountsOut(swapAmount,[sharkbabyToken.address,wETH.address]))[1];

		var tx = await sharkbabyToken.approve(exchangeRouter.address,swapAmount);
		await tx.wait();

		tx = await exchangeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
			swapAmount,
			0,
			[sharkbabyToken.address,wETH.address],
			owner.address,
			"99000000000000000"
		)
		await tx.wait()

		let  buySharkTokenAmount = await sharkbabyToken.balanceOf(owner.address);
		let  buyETHAmount = await owner.getBalance();

		console.log(
			"shark-eth ",
			ethers.utils.formatUnits(initsharkbabyBalance.sub(buySharkTokenAmount),18),
			ethers.utils.formatUnits(buyETHAmount.sub(initETHTokenBalance),18),
			ethers.utils.formatUnits(exceptSwapBalance,18)
		);
	});

	// it("USDT-DM test", async function () {

	// 	var swapAmount = ethers.utils.parseUnits("50000000",6);
		
	// 	var initUsdtBalance = await usdt.balanceOf(owner.address);
	// 	var initDMTokenBalance = await dMToken.balanceOf(owner.address);
	// 	var exceptSwapBalance = (await exchangeRouter.getAmountsOut(swapAmount,[usdt.address,dMToken.address]))[1];

	// 	var tx = await usdt.approve(exchangeRouter.address,swapAmount);
	// 	await tx.wait();

	// 	tx = await exchangeRouter.swapExactTokensForTokens(
	// 		swapAmount,
	// 		0,
	// 		[usdt.address, dMToken.address],
	// 		owner.address,
	// 		"99000000000000000"
	// 	)
	// 	await tx.wait(); 

	// 	let  buyUsdtAmount= await usdt.balanceOf(owner.address);
	// 	let  buyDMTokenAmount= await dMToken.balanceOf(owner.address);

	// });

	it("marketing, game fee test", async function () {
		var marketingAddress = await sharkbabyToken.marketingAddress();
		var gameAddress = await sharkbabyToken.gameAddress();

		var marketingAddressBalance  = await sharkbabyToken.balanceOf(marketingAddress);
		var gameAddressBalance  = await sharkbabyToken.balanceOf(gameAddress);

		console.log(fromBigNum(marketingAddressBalance,18), fromBigNum(gameAddressBalance,18))
		
		// //fee count
		// // marketing fee = 5000000*0.01
		// expect(marketingAddressBalance).to.equal(toBigNum("50000",18))

		// // charity fee = 5000000*0.05 + 10000 * 0.05 + 10000 * 0.05
		// expect(charityAddressBalance).to.equal(toBigNum("250000",18))

		// // charity fee = 5000000*0.025 + 10000 * 0.025 + 10000 * 0.025
		// expect(lotteryAddressBalance).to.equal(toBigNum("125000",18))	
	});
	
	// it("allowance, increaseAllownance transferFrom test", async function () {

	// 	//allowance, transferFrom test
	// 	var tx = await sharkbabyToken.approve(userWallet.address,toBigNum("10000",18));
	// 	await tx.wait();

	// 	var testPledgeToken = sharkbabyToken.connect(userWallet);
	// 	tx = await testPledgeToken.transferFrom(owner.address,userWallet.address,toBigNum("10000",18));
	// 	await tx.wait();
		
	// 	var balance = await sharkbabyToken.balanceOf(userWallet.address);
	// 	var allowance = await sharkbabyToken.allowance(owner.address,userWallet.address);

	// 	// expect user balance is 8000 (fee 20%)
	// 	expect(balance).to.equal(toBigNum("8000",18));
	// 	expect(allowance).to.equal(toBigNum("0",18));

	// 	//increaseAllownance test
	// 	tx = await sharkbabyToken.increaseAllowance(userWallet.address,toBigNum("10000",18));
	// 	await tx.wait();

	// 	allowance = await sharkbabyToken.allowance(owner.address,userWallet.address);
	// 	expect(allowance).to.equal(toBigNum("10000",18));

	// });

	// it("swapAndLiquify,swapTokensForEth,addLiquidity test", async function () {
	// 	var LPBalance2 = await pancakeswapV2PairContract.balanceOf(owner.address);
	// 	expect(Number(LPBalance2.sub(LPBalance1))).to.be.at.above(0);
	// });

	// it("exclude from fee", async function () {
	// 	var tx = await sharkbabyToken.excludeAddressFromFee(owner.address, true);
	// 	await tx.wait();
		
	// 	var balance_1 = await sharkbabyToken.balanceOf(owner.address);
	// 	tx = await sharkbabyToken.transfer(owner.address,toBigNum("10000",18));
	// 	await tx.wait();
		
	// 	var balance_2 = await sharkbabyToken.balanceOf(owner.address);

	// 	// fee is 0%
	// 	expect(balance_1.sub(balance_2)).to.equal(toBigNum("0",18));

	// 	tx = await sharkbabyToken.excludeAddressFromFee(owner.address, false);
	// 	await tx.wait();
	// });
});


