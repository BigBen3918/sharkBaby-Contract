//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
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

    /* --------- safe math --------- */
library SafeMath {
	/**
	* @dev Returns the addition of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `+` operator.
	*
	* Requirements:
	* - Addition cannot overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	/**
	* @dev Returns the subtraction of two unsigned integers, reverting on
	* overflow (when the result is negative).
	*
	* Counterpart to Solidity's `-` operator.
	*
	* Requirements:
	* - Subtraction cannot overflow.
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	* @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	* overflow (when the result is negative).
	*
	* Counterpart to Solidity's `-` operator.
	*
	* Requirements:
	* - Subtraction cannot overflow.
	*/
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Returns the multiplication of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `*` operator.
	*
	* Requirements:
	* - Multiplication cannot overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
		return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	/**
	* @dev Returns the integer division of two unsigned integers. Reverts on
	* division by zero. The result is rounded towards zero.
	*
	* Counterpart to Solidity's `/` operator. Note: this function uses a
	* `revert` opcode (which leaves remaining gas untouched) while Solidity
	* uses an invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	/**
	* @dev Returns the integer division of two unsigned integers. Reverts with custom message on
	* division by zero. The result is rounded towards zero.
	*
	* Counterpart to Solidity's `/` operator. Note: this function uses a
	* `revert` opcode (which leaves remaining gas untouched) while Solidity
	* uses an invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts with custom message when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}



/* 
 _____ _   _   ___  ______ _   ________  ___  ________   _______ _   __ _____ _   _ 
/  ___| | | | / _ \ | ___ \ | / /| ___ \/ _ \ | ___ \ \ / /  _  | | / /|  ___| \ | |
\ `--.| |_| |/ /_\ \| |_/ / |/ / | |_/ / /_\ \| |_/ /\ V /| | | | |/ / | |__ |  \| |
 `--. \  _  ||  _  ||    /|    \ | ___ \  _  || ___ \ \ / | | | |    \ |  __|| . ` |
/\__/ / | | || | | || |\ \| |\  \| |_/ / | | || |_/ / | | \ \_/ / |\  \| |___| |\  |
\____/\_| |_/\_| |_/\_| \_\_| \_/\____/\_| |_/\____/  \_/  \___/\_| \_/\____/\_| \_/

*/

contract SHARKBABYOKEN is  Context, Ownable  {

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

	using SafeMath for uint256;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;
	uint8 private _decimals;
	string private _symbol;
	string private _name;


	function getOwner() external view returns (address) {
		return owner();
	}

	function decimals() external view returns (uint8) {
		return _decimals;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
		return true;
	}

	function burn(uint256 amount) external {
		_burn(msg.sender,amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: mint to the zero address");

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: burn from the zero address");

		_balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "BEP20: approve from the zero address");
		require(spender != address(0), "BEP20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
 
	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
	}

	//////////////////////////////////////////////
    /* ----------- special features ----------- */
	//////////////////////////////////////////////

    event ExcludeFromFee(address user, bool isExlcude);
    event SetSellFee(Fees sellFees);
    event SetBuyFee(Fees buyFees);

	struct Fees {
		uint256 marketing;
		uint256 gameWallet;
		uint256 liquidity;
		uint256 poolfee;
	}

    /* --------- special address info --------- */
	address public marketingAddress;
	address public gameAddress;
	address public poolAddress;
	address public babyPoolAddress;

    /* --------- exchange info --------- */
	IPancakeswapRouter public pancakeswapRouter;
	address public pancakeswapV2Pair;

	bool inSwapAndLiquify;
	modifier lockTheSwap {
		inSwapAndLiquify = true;
		_;
		inSwapAndLiquify = false;
	}

	bool public swapAndLiquifyEnabled = true;

    /* --------- buyFees info --------- */
    Fees public sellFees;
    Fees public buyFees;

    mapping(address=>bool) isExcludeFromFee;

    /* --------- max tx info --------- */
	uint public _maxTxAmount = 1e13 * 1e18;
	uint public numTokensSellToAddToLiquidity = 1e5 * 1e18;

    ////////////////////////////////////////////////
    /* --------- General Implementation --------- */
    ////////////////////////////////////////////////

    constructor () public {
        _name = "sharkbaby";
        _symbol = "SHBY";
        _decimals = 18;
        _totalSupply = 1e9*1e18; /// initial supply 1000,000,000,000,000
        _balances[msg.sender] = _totalSupply;

        buyFees.marketing = 20;
		buyFees.gameWallet = 20;
		buyFees.liquidity = 0;
		buyFees.poolfee = 0;

        sellFees.marketing = 20;
		sellFees.gameWallet = 0;
		sellFees.liquidity = 10;
		buyFees.poolfee = 80;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit SetBuyFee(buyFees);
        emit SetSellFee(sellFees);
    }

    /* --------- set token parameters--------- */

	function setInitialAddresses(address _RouterAddress) external onlyOwner {

		IPancakeswapRouter _pancakeswapRouter = IPancakeswapRouter(_RouterAddress);
		pancakeswapRouter = _pancakeswapRouter;
		pancakeswapV2Pair = IPancakeswapFactory(_pancakeswapRouter.factory()).createPair(address(this), _pancakeswapRouter.WETH()); //MD vs USDT pair
	}

	function setFeeAddresses( address _marketingAddress, address _gameAddress, address _poolAddress) external onlyOwner {
		marketingAddress = _marketingAddress;		
		gameAddress = _gameAddress;	
		poolAddress = _poolAddress;
	}

	function setMaxTxAmount(uint maxTxAmount) external onlyOwner {
		_maxTxAmount = maxTxAmount;
	}
    
    function setbuyFee(uint256 _marketingFee, uint256 _gameWalletFee, uint256 _liquidityFee, uint256 _poolfee) external onlyOwner {
        buyFees.marketing = _marketingFee;
		buyFees.gameWallet = _gameWalletFee;
		buyFees.liquidity = _liquidityFee;
		buyFees.poolfee = _poolfee;
        emit SetBuyFee(buyFees);
    }

	function setsellFee(uint256 _marketingFee, uint256 _gameWalletFee, uint256 _liquidityFee, uint256 _poolfee) external onlyOwner {
        sellFees.marketing = _marketingFee;
		sellFees.gameWallet = _gameWalletFee;
		sellFees.liquidity = _liquidityFee;
		sellFees.poolfee = _poolfee;
        emit SetSellFee(sellFees);
    }

	function getTotalSellFee() public view returns (uint) {
		return sellFees.marketing + sellFees.gameWallet + sellFees.liquidity + sellFees.poolfee ;
	}
	
	function getTotalBuyFee() public view returns (uint) {
		return buyFees.marketing + buyFees.gameWallet + buyFees.liquidity + buyFees.poolfee ;
	}

    /* --------- exclude address from buyFees--------- */
    function excludeAddressFromFee(address user,bool _isExclude) external onlyOwner {
        isExcludeFromFee[user] = _isExclude;
        emit ExcludeFromFee(user,_isExclude);
    }

    /* --------- transfer --------- */

	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "BEP20: transfer from the zero address");
		require(recipient != address(0), "BEP20: transfer to the zero address");

		// transfer 
		if((sender == pancakeswapV2Pair || recipient == pancakeswapV2Pair )&& !isExcludeFromFee[sender])
			require(_maxTxAmount>=amount,"BEP20: transfer amount exceeds max transfer amount");

		_balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

		uint recieveAmount = amount;

		uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

		if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != pancakeswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

		if(!isExcludeFromFee[sender]) {

			if(sender == pancakeswapV2Pair){
				// buy fee
				recieveAmount = recieveAmount.mul(1000-getTotalBuyFee()).div(1000);	
				_balances[marketingAddress] += amount.mul(buyFees.marketing).div(1000);
				_balances[gameAddress] += amount.mul(buyFees.gameWallet).div(1000);
				_balances[poolAddress] += amount.mul(buyFees.poolfee).div(1000);
				_balances[address(this)] += amount.mul(buyFees.liquidity).div(1000);
			}
			else if(recipient == pancakeswapV2Pair){
				// sell fee
				recieveAmount = recieveAmount.mul(1000-getTotalSellFee()).div(1000);	
				_balances[marketingAddress] += amount.mul(sellFees.marketing).div(1000);
				_balances[gameAddress] += amount.mul(sellFees.gameWallet).div(1000);
				_balances[poolAddress] += amount.mul(sellFees.poolfee).div(1000);
				_balances[address(this)] += amount.mul(sellFees.liquidity).div(1000);
			}
		}

		_balances[recipient] = _balances[recipient].add(recieveAmount);

		emit Transfer(sender, recipient, amount);
	}

	function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

	function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapRouter.WETH();

        _approve(address(this), address(pancakeswapRouter), tokenAmount);

        pancakeswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeswapRouter), tokenAmount);

        pancakeswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

	receive() external payable {
	}
}