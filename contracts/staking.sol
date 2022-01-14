//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./IExchange.sol";

contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor () internal { }

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}
    /* --------- Access Control --------- */
contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	* @dev Initializes the contract setting the deployer as the initial owner.
	*/
	constructor () internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	/**
	* @dev Returns the address of the current owner.
	*/
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	* @dev Leaves the contract without owner. It will not be possible to call
	* `onlyOwner` functions anymore. Can only be called by the current owner.
	*
	* NOTE: Renouncing ownership will leave the contract without an owner,
	* thereby removing any functionality that is only available to the owner.
	*/
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	* Can only be called by the current owner.
	*/
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	*/
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library SafeMath {
	function add(uint x, uint y) internal pure returns (uint z) {
		require((z = x + y) >= x, 'ds-math-add-overflow');
	}

	function sub(uint x, uint y) internal pure returns (uint z) {
		require((z = x - y) <= x, 'ds-math-sub-underflow');
	}

	function mul(uint x, uint y) internal pure returns (uint z) {
		require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
	}  
	
	function div(uint a, uint b) internal pure returns (uint c) {
		require(b > 0, "ds-math-mul-overflow");
		c = a / b;
	}

}

interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);
	function mint(uint amount) external returns (bool);
}

// each staking instance mapping to each pool
contract Staking is Ownable{
	using SafeMath for uint;
	event Stake(address staker, uint amount);
	event Reward(address staker, uint amount_1, uint amount_2);
	event Withdraw(address staker, uint amount);
    //staker inform
	struct Staker {
		address referal;
		uint stakingAmount;  // staking token amount
		uint lastUpdateTime;  // last amount updatetime
		uint lastStakeUpdateTime;  // last Stake updatetime
		uint stake;          // stake amount
		uint rewards_1;         // stake amount
		uint rewards_2;         // stake amount

	}
	//stakeToken is 
	address public rewardTokenAddress_1;
	address public rewardTokenAddress_2;
	address public stakeTokenAddress; //specify farming token when contract created

	uint public totalStakingAmount; // total staking token amount
	uint public lastUpdateTime; // total stake amount and reward update time
	uint public totalStake;   // total stake amount

	mapping(address=>Staker) public stakers;

	constructor (address _stakeTokenAddress, address _rewardTokenAddress_1, address _rewardTokenAddress_2) public {
		rewardTokenAddress_1 = _rewardTokenAddress_1;
		rewardTokenAddress_2 = _rewardTokenAddress_2;
		stakeTokenAddress = _stakeTokenAddress;
		lastUpdateTime = block.timestamp;
	}

	/* ----------------- total counts ----------------- */

	function countTotalStake() public view returns (uint _totalStake) {
		_totalStake = totalStake + totalStakingAmount.mul((block.timestamp).sub(lastUpdateTime));
	}

	function countTotalReward() public view returns (uint _totalReward_1, uint _totalReward_2) {
		_totalReward_1 = IERC20(rewardTokenAddress_1).balanceOf(address(this));
		_totalReward_2 = IERC20(rewardTokenAddress_2).balanceOf(address(this));
	}

	function updateTotalStake() internal {

		( uint _rewardableAmount_1 ,)  = getRewardableAmount();
		if( _rewardableAmount_1 > 1e4*1e18){
			swapTokenForReward();
		}

		totalStake = countTotalStake();
		lastUpdateTime = block.timestamp;
	}

	/* ----------------- personal counts ----------------- */

	function getStakeInfo(address stakerAddress) public view returns(uint _total, uint _staking, uint _rewardable_1, uint _rewardable_2, uint _rewards_1, uint _rewards_2) {
		_total = totalStakingAmount;
		_staking = stakers[stakerAddress].stakingAmount;
		(_rewardable_1, _rewardable_2) = countReward(stakerAddress); 
		_rewards_1 = stakers[stakerAddress].rewards_1;
		_rewards_2 = stakers[stakerAddress].rewards_2;

	}
	function countStake(address stakerAddress) public view returns(uint _stake) {
		if(totalStakingAmount == 0) return 0;
		Staker memory _staker = stakers[stakerAddress];
		_stake = _staker.stake + ((block.timestamp).sub(_staker.lastUpdateTime)).mul(_staker.stakingAmount);
	}
	
	function countReward(address stakerAddress) public view returns(uint _reward_1 , uint _reward_2) {
		uint _totalStake = countTotalStake();
		(uint _totalReward1 , uint  _totalReward2)= countTotalReward();
		uint stake = countStake(stakerAddress);
		_reward_1 = _totalStake==0 ? 0 : _totalReward1.mul(stake).div(_totalStake);
		_reward_2 = _totalStake==0 ? 0 : _totalReward2.mul(stake).div(_totalStake);
	}

	function countFee(address stakerAddress) public view returns (uint _fee) {
		if(block.timestamp.sub(stakers[stakerAddress].lastStakeUpdateTime) < 30 days){
			_fee = 10;
		}
		else _fee = 0;
	}

	/* ----------------- actions ----------------- */

	function stake(uint amount) external {
		address stakerAddress = msg.sender;
		IERC20(stakeTokenAddress).transferFrom(stakerAddress,address(this),amount);
		
		stakers[stakerAddress].stake = countStake(stakerAddress);
		stakers[stakerAddress].stakingAmount += amount;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		stakers[stakerAddress].lastStakeUpdateTime = block.timestamp;
		
		updateTotalStake();
		
		totalStakingAmount = totalStakingAmount + amount;
		emit Stake(stakerAddress,amount);
	}

	function unstaking() external {
		address stakerAddress = msg.sender;
		uint amount = stakers[stakerAddress].stakingAmount;
		require(0 <= amount,"staking : amount over stakeAmount");
		uint withdrawFee = countFee(stakerAddress);
		
		IERC20(stakeTokenAddress).transfer(owner(),amount.mul(withdrawFee).div(1000));
		IERC20(stakeTokenAddress).transfer(stakerAddress,amount.mul(1000-withdrawFee).div(1000));

		stakers[stakerAddress].stake = countStake(stakerAddress);
		stakers[stakerAddress].stakingAmount -= amount;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		stakers[stakerAddress].lastStakeUpdateTime = block.timestamp;

		updateTotalStake();
		totalStakingAmount = totalStakingAmount - amount;
		emit Withdraw(stakerAddress,amount);
	}

	function claimRewards() external {
		address stakerAddress = msg.sender;

		updateTotalStake();
		uint _stake = countStake(stakerAddress);
		(uint _reward_1, uint _reward_2) = countReward(stakerAddress);

		require(_reward_1>0,"staking : reward amount is 0");
		IERC20 rewardToken_1 = IERC20(rewardTokenAddress_1);
		IERC20 rewardToken_2 = IERC20(rewardTokenAddress_2);

		rewardToken_1.transfer(stakerAddress, _reward_1);
		rewardToken_2.transfer(stakerAddress, _reward_2);

		stakers[stakerAddress].rewards_1 += _reward_1;
		stakers[stakerAddress].rewards_2 += _reward_2;
		totalStake -= _stake;

		stakers[stakerAddress].stake = 0;
		stakers[stakerAddress].lastUpdateTime = block.timestamp;
		
		emit Reward(stakerAddress,_reward_1,_reward_2);
	}

	/* ----------------- swap for token ----------------- */
	
	IPancakeswapRouter public pancakeswapRouter;
	
	function setInitialAddresses(address _RouterAddress) external onlyOwner {
		IPancakeswapRouter _pancakeswapRouter = IPancakeswapRouter(_RouterAddress);
		pancakeswapRouter = _pancakeswapRouter;
	}

	function getRewardableAmount() public view returns (uint _rewardableAmount_1, uint _rewardableAmount_2){
		_rewardableAmount_1 = IERC20(stakeTokenAddress).balanceOf(address(this))/2;
		_rewardableAmount_2 = IERC20(stakeTokenAddress).balanceOf(address(this))/2;	
	}

	function swapTokenForReward() public {
		( uint _rewardableAmount_1 ,uint _rewardableAmount_2)  = getRewardableAmount();
		swapTokensForRewardToken(_rewardableAmount_1,_rewardableAmount_2);
	}

	function swapTokensForRewardToken(uint tokenAmount_1,uint tokenAmount_2) internal {
		address[] memory path_1 = new address[](2);
		address[] memory path_2 = new address[](2);
		path_1[0] = stakeTokenAddress;
		path_1[1] = rewardTokenAddress_1;
		path_2[0] = stakeTokenAddress;
		path_2[1] = rewardTokenAddress_2;

		IERC20(stakeTokenAddress).approve(address(pancakeswapRouter), tokenAmount_1+tokenAmount_2);

		// make the swap

		pancakeswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount_1,
			0, // accept any amount of usdt
			path_1,
			address(this),
			block.timestamp
		);

		
		pancakeswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount_2,
			0, // accept any amount of usdt
			path_2,
			address(this),
			block.timestamp
		);
	}
}  