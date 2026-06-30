// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: FeeSwapper.sol

// FeeSwapper.sol

pragma solidity ^0.8.20;


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


/**
 * @title T1YFeeSwapper
 * @notice 专门用于处理 T1Y 手续费兑换的中间合约
 * @dev 将 T1Y 手续费兑换为 USDT 并自动分配到节点奖池
 */
contract T1YFeeSwapper is Ownable {
    address public T1Y_TOKEN;
    address public immutable WBNB;
    address public immutable USDT;
    address public immutable ROUTER;
    
    // 自动兑换开关
    bool public autoSwapEnabled = true;
    
    // 最小兑换数量（极低阈值，确保每笔都兑换）
    uint256 public minSwapAmount = 0.001 ether;  // 0.001 T1Y

    uint256 public slippageBps = 1000;

    mapping(address=>bool) public earleirUser;
    
    event FeeSwapped(uint256 t1yAmount, uint256 usdtAmount);
    event AutoSwapToggled(bool enabled);
    event MinSwapAmountUpdated(uint256 newAmount);
    event AddEarleirUser(address user);
    
    /**
     * @notice 构造函数
     * @param _t1yToken T1Y代币地址（即主合约地址）
     */
    constructor(
        address _t1yToken
    ) Ownable(msg.sender) {
        require(_t1yToken != address(0), "Invalid T1Y token");
        require(_t1yToken.code.length > 0, "Nc");
        T1Y_TOKEN = _t1yToken;
        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;  // BSC WBNB
        ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;      // PancakeSwap Router V2
        USDT=0x55d398326f99059fF775485246999027B3197955;
    }
    
    /**
     * @notice 兑换指定数量的 T1Y 为 WBNB 并自动分配
     * @dev 由主合约在卖出时自动调用
     * @param t1yAmount 要兑换的 T1Y 数量
     * @return wbnbAmount 获得的 WBNB 数量
     */
    function swapT1YForWBNB(uint256 t1yAmount) external returns (uint256) {
        require(msg.sender == T1Y_TOKEN, "Only main contract");
        
        if (!autoSwapEnabled || t1yAmount < minSwapAmount) {
            return 0;  // 不兑换，累积到下次
        }
        
        uint256 t1yBalance = IERC20(T1Y_TOKEN).balanceOf(address(this));
        require(t1yBalance >= t1yAmount, "Insufficient T1Y balance");
        
        // 授权 Router
        IERC20(T1Y_TOKEN).approve(ROUTER, t1yAmount);
        
        // 设置交易路径：T1Y → WBNB
        address[] memory path = new address[](2);
        path[0] = T1Y_TOKEN;
        path[1] = WBNB;

        uint256[] memory quoted = IPancakeRouter(ROUTER).getAmountsOut(t1yAmount, path);
        
        // 执行 swap
        uint256[] memory amounts = IPancakeRouter(ROUTER).swapExactTokensForTokens(
            t1yAmount,
            _minAfterSlippage(quoted[1], slippageBps),
            path,
            address(this),  // 先接收到本合约
            block.timestamp + 300
        );
        
        uint256 wbnbAmount = amounts[1];
        
        // 将 WBNB 转回主合约并触发分配
        require(IERC20(WBNB).transfer(T1Y_TOKEN, wbnbAmount), "WBNB transfer failed");
        
        emit FeeSwapped(t1yAmount, wbnbAmount);
        
        return wbnbAmount;
    }
    
    /**
     * @notice 切换自动兑换开关
     */
    function toggleAutoSwap(bool _enabled) external onlyOwner {
        autoSwapEnabled = _enabled;
        emit AutoSwapToggled(_enabled);
    }
    
    /**
     * @notice 设置最小兑换数量
     */
    function setMinSwapAmount(uint256 _amount) external onlyOwner {
        minSwapAmount = _amount;
        emit MinSwapAmountUpdated(_amount);
    }

    function setSlippageBps(uint256 _bps) external onlyOwner {
        require(_bps <= 5000, "max 50%");
        slippageBps = _bps;
    }

    /**
     * @notice 添加优先用户
     */
    function addEarleirUser(address[] memory users) external onlyOwner {
        for(uint i = 0;i<users.length;i++){
            earleirUser[users[i]]=true;
            emit AddEarleirUser(users[i]);
        }
    }
    
    /**
     * @notice 查看当前累积的 T1Y 余额
     */
    function getT1YBalance() external view returns (uint256) {
        return IERC20(T1Y_TOKEN).balanceOf(address(this));
    }
    
    /**
     * @notice 转移代币到指定地址
     * @dev 只允许 T1Y 主合约调用，用于赎回等操作
     * @param token 代币地址
     * @param to 接收地址
     * @param amount 转移数量
     */
    function transferToken(address token, address to, uint256 amount) external returns (bool) {
        require(msg.sender == T1Y_TOKEN, "Only main contract");
        require(to != address(0), "Invalid recipient");
        
        return IERC20(token).transfer(to, amount);
    }
    
    /**
     * @notice 紧急提取函数
     */
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Token transfer failed");
    }
    /**
     * @notice 将查询WBNB对U的价格
     */
    function _getWBNBAmountOut(uint256 amountIn) external view returns(uint256){
        return _getAmountOut(WBNB,USDT,amountIn);
    }
    /**
     * @notice 将查询T1Y对WBNB的价格
     */
    function _getT1YAmountOut(uint256 amountIn) external view returns(uint256){
        return _getAmountOut(T1Y_TOKEN,WBNB,amountIn);
    }
    /**
     * @notice 将查询T1Y对WBNB的价格
     */
    function _getT1YAmountOutOfUSDT(uint256 amountIn) external view returns(uint256){
        uint wbnbAmount = _getAmountOut(T1Y_TOKEN,WBNB,amountIn);
        return _getAmountOut(WBNB,USDT,wbnbAmount);
    }
    function _getAmountOut(address token0,address token1,uint256 amountIn) internal view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amounts = IPancakeRouter(ROUTER).getAmountsOut(amountIn, path);
        return amounts[1];
    }

    function _minAfterSlippage(uint256 amount, uint256 bps) internal pure returns (uint256) {
        if (bps >= 10000) return 0;
        return (amount * (10000 - bps)) / 10000;
    }
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}
