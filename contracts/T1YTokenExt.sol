//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
interface IToken{
    /// @notice 用户信息
    struct User {
        address superior;           // 上级地址
        uint8   nodeLevel;          // 节点等级 0=无，1=V1，2=V2，3=V3, 4=v4, 5=v5
        uint256 lpAmount;           // LP 代币数量
        uint256 usdtValue;          // USDT 面值
        uint256 depositCycle;       // 入场周期
        uint256 hashrateStatic;     // 静态算力
        uint256 hashrateDynamic;    // 动态算力
        uint256 staticReceived;     // 静态已领取（累计）
        uint256 dynamicReceived;    // 动态已领取（累计）
        uint256 nodeWBNBReceived;   // 节点WBNB已领取
        uint256 nodeT1YReceived;    // 节点T1Y已领取
        uint256 validReferralCount; // 有效下级数量（直推且已入金的用户）
        uint256 hashrateReward;
    }
    /// @notice 用户领奖周期记录
    struct UserLast {
        uint256 lastStaticCycle;    // 上次静态领奖周期
        uint256 lastDynamicCycle;   // 上次动态领奖周期
        uint256 lastNodeWBNBCycle;  // 上次节点WBNB领奖周期
        uint256 lastNodeT1YCycle;   // 上次节点T1Y领奖周期
    }
    function getHourlyCycle()external view returns(uint256);
    function hourlyCycleStaticHashrate(uint256 p)external view returns(uint256);
    function dailyCycleDynamicHashrate(uint256 p)external view returns(uint256);
    function hourlyCycleStaticReward(uint256 p)external view returns(uint256);
    function dailyCycleDynamicReward(uint256 p)external view returns(uint256);
    function usersCycleStaticHashrate(address u,uint256 p)external view returns(uint256);
    function usersCyclelDynamicHashrate(address u,uint256 p)external view returns(uint256);
    function getDailyCycle()external view returns(uint256);
    function pancakePair()external view returns(address);
    function users(address ur)external view returns(User memory);
    function userLasts(address ur)external view returns(UserLast memory);
    function balanceOf(address ur)external view returns(uint256);
    function wbnbReward(address ur)external view returns(uint256);
    function usersCyclelNodeLevel(address u,uint256 p)external view returns(uint256);
    function dailyCycleNodeCount(uint256 u,uint256 p)external view returns(uint256);
    function dailyCycleNodeRewards(uint256 u,uint256 p)external view returns(uint256);
    function pricePerHour(uint u)external view returns(uint256);
    function userReward(address u)external view returns(uint256);
    function swapSlippageBps() external view returns(uint256);
}
contract T1YTokenExt{
    /// @notice 用于计算用户队列排在第几天。
    uint256 [] public currentLimit = [100, 210, 331, 464, 610, 770, 946, 1139, 1339];
    /// @notice 基础比例分母
    uint256 private constant BASE = 100000;
    uint256 private constant BPS = 10000;
    uint256 private constant INITIAL_POOL_BALANCE = 130_000_000 ether;
    uint256 private constant MAX_DAILY_BURN_RATE = 3600; // 3.6%
    uint256 private constant MID_DAILY_BURN_RATE = 2400; // 2.4%
    uint256 private constant MIN_DAILY_BURN_RATE = 1200; // 1.2%
    uint256 private constant FLOOR_DAILY_BURN_RATE = 600; // 0.6%
    uint256 private constant MAX_DAILY_REWARD_LOOKBACK = 15;
    address public T1Y_TOKEN;
    address public pancakePair;
    /// @notice PancakeSwap Router V2 (BSC Mainnet)
    address public immutable ROUTER ;
    
    /// @notice USDT 代币地址 (BSC)
    address public immutable USDT ;
    
    /// @notice WBNB 代币地址 (BSC)
    address public immutable WBNB ;
    
    /// @notice 早期用户分红记账
    uint256 public earlierUserRewardPerShare;

    mapping(address =>uint256) public rewardOfuser;
    uint256 public userNumber;

    mapping(address =>bool) public isEarlierUser;
    mapping(uint256=>uint256) public numberOfDay;

    constructor(address _T1YToken){
        T1Y_TOKEN =  _T1YToken;
        pancakePair=IToken(T1Y_TOKEN).pancakePair();
        WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;  // BSC WBNB
        ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;      // PancakeSwap Router V2
        USDT=0x55d398326f99059fF775485246999027B3197955;
    }
    /**
     * @notice 24小时最高单价
     * @return highPrice 最高单价
     */
    function _gethighPrice(uint256 currentCycle)public view returns(uint256 highPrice){
        highPrice = IToken(T1Y_TOKEN).pricePerHour(currentCycle);
        if (currentCycle==0) return highPrice;
        for(uint256 cycle = currentCycle-1; cycle>0 ; cycle--){
            if (IToken(T1Y_TOKEN).pricePerHour(cycle)>highPrice) highPrice=IToken(T1Y_TOKEN).pricePerHour(cycle);
            if(currentCycle > 24) {
                if (cycle < currentCycle - 24) break;
            }
        }
    }
    function _limitAtDay(uint256 day) internal view returns (uint256) {
        uint256 lastLimit = currentLimit[8]; // 10626
        if (day <= 8) return currentLimit[day];
        return lastLimit + (day - 8) * 200;
    }
    
    function _approveWBNB(address spender, uint256 amount) internal {
        IERC20(WBNB).approve(spender, amount);
    }

    function _minAfterSlippage(uint256 amount, uint256 bps) internal pure returns(uint256) {
        if (bps >= 10000) return 0;
        return (amount * (10000 - bps)) / 10000;
    }

    function _buyT1Y(uint256 bnbAmount) public returns (uint256) {
        require(msg.sender == T1Y_TOKEN, "caller is not T1Y token");
        // 设置交易路径：WBNB → T1Y
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = T1Y_TOKEN;
        
        // 授权Router使用WBNB
        _approveWBNB(ROUTER, bnbAmount);

        uint256[] memory quoted = IPancakeRouter(ROUTER).getAmountsOut(bnbAmount, path);
        
        uint256[] memory amounts = IPancakeRouter(ROUTER).swapExactTokensForTokens(
            bnbAmount,
            _minAfterSlippage(quoted[1], IToken(T1Y_TOKEN).swapSlippageBps()),
            path,
            address(this),   
            block.timestamp + 300
        );
        return amounts[1];
    }
    function _buyWBNB(uint256 t1yAmount) public returns (uint256) {
        // 设置交易路径：WBNB → T1Y
        require(msg.sender == T1Y_TOKEN, "caller is not T1Y token");
        address[] memory path = new address[](2);
        path[1] = WBNB;
        path[0] = T1Y_TOKEN;
        
        // 授权Router使用T1Y
        IERC20(T1Y_TOKEN).approve(ROUTER, t1yAmount);
        // 先swap到中间地址，避免INVALID_TO错误
        // PancakeSwap不允许直接swap到代币合约自身，所以需要中间地址
        uint256[] memory quoted = IPancakeRouter(ROUTER).getAmountsOut(t1yAmount, path);
        uint256[] memory amounts = IPancakeRouter(ROUTER).swapExactTokensForTokens(
            t1yAmount,
            _minAfterSlippage(quoted[1], IToken(T1Y_TOKEN).swapSlippageBps()),
            path,
            address(this),    
            block.timestamp + 300
        );
        require(IERC20(WBNB).transfer(T1Y_TOKEN, amounts[1]), "WBNB transfer failed");

        return amounts[1];
    }

    event QueueDay(uint256 index, uint256 currentDay);
    function getDay(uint256 index, uint256 currentDay) public returns (uint256){
        require(msg.sender == T1Y_TOKEN, "caller is not T1Y token");
        require(currentDay > 0, "currentDay=0");
        // currentDay 是“今天+1”
        uint256 today = currentDay - 1;
        
        uint todaylimit = numberOfDay[today];
        
        if (today>1) todaylimit+=_limitAtDay(today-1);

        if(todaylimit<_limitAtDay(today)){
            //今天的人数加1
            numberOfDay[today]+=1;
            return today;
        }
        uint i = currentDay;
        while(true){
            if((numberOfDay[i] + _limitAtDay(i-1)) < _limitAtDay(i)){
                numberOfDay[i] += 1;
                emit QueueDay(index,i);
                return i;
            }
            i+=1;
            require(i<currentDay+20,"Only 20 days");
        }
        return 0;
    }
    
    function getUserInfo(address user) public view returns (
        address superior,
        uint256 lpAmount,
        uint256 usdtValue,
        uint256 hashrateStatic,
        uint256 hashrateDynamic,
        uint8 nodeLevel,
        uint256 validReferralCount,
        uint256 usdtValueOfHashRateReward
    ) {
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        return (
            u.superior,
            u.lpAmount,
            u.usdtValue,
            u.hashrateStatic,
            u.hashrateDynamic,
            u.nodeLevel,
            u.validReferralCount,
            u.hashrateReward
        );
    }
    function getPendingRewards(address user) public view returns (
        uint256 staticReward,
        uint256 dynamicReward,
        uint256 nodeWBNBReward,
        uint256 nodeT1YReward
    ) {
        // 使用统一的计算方法
        (staticReward,) = _calculateStaticReward(user);
        dynamicReward = _calculateDynamicReward(user);
        nodeWBNBReward = _calculateNodeWBNBReward(user);
        nodeT1YReward = _calculateNodeT1YReward(user);
    }
    function despositForEarlyUser(uint256 total,address user,uint8 control) public returns(uint256){
        require(msg.sender == T1Y_TOKEN,"caller is not T1Y token");
        //
        if(user!=address(0) && !isEarlierUser[user]) {
            // 首期建设者，最先达到C2的前100个用户。
            if(userNumber<100){
                isEarlierUser[user]=true;
                userNumber+=1;
                rewardOfuser[user] = earlierUserRewardPerShare;
            }
        }
        if(control==2 && isEarlierUser[user] ) rewardOfuser[user] = earlierUserRewardPerShare;
        // 将分配的资金 按人头均分
        if(total>0 && userNumber>0 ) earlierUserRewardPerShare += total/userNumber;
        return userNumber;
    }
    // ============ 核心功能：奖励计算 ============
    /**
     * @notice 计算节点 WBNB 奖励（周期）
     * @dev WBNB奖励来源：入金金额的5%，平均分配给L1/L2/L3/L4/L5五个等级
     * @dev 分配方式：按人数平分，每个节点用户获得相同数量的奖励
     * @dev 节点等级：
     * @dev 领取逻辑：只领取已完成燃烧的周期（currentDay - 1）
     * @param user 用户地址
     * @return 待领取的节点WBNB奖励数量
     */
    function _calculateNodeWBNBReward(address user) public view returns (uint256) {
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        if (u.nodeLevel == 0) return 0;
        
        uint256 currentDay = IToken(T1Y_TOKEN).getDailyCycle();
        IToken.UserLast memory info = IToken(T1Y_TOKEN).userLasts(user);
        uint256 lastDay = info.lastNodeWBNBCycle;//userLasts[user].lastNodeWBNBCycle;
        
        // 第0周期不计算奖励
        if (currentDay == 0) return 0;
        
        // 只计算到 currentDay - 1（已完成燃烧的周期）
        uint256 calculateUntilDay = currentDay;
        calculateUntilDay = _capDailyRewardWindow(lastDay, calculateUntilDay);
        if (lastDay >= calculateUntilDay) return 0; // 没有可计算的周期
        
        uint256 totalReward = 0;
        
        // 从上次领奖周期+1到当前周期-1
        for (uint256 day = lastDay; day < calculateUntilDay; day++) {
            // 获取用户在该周期的节点等级
            uint256 userNodeLevel = IToken(T1Y_TOKEN).usersCyclelNodeLevel(user,day);
            if (userNodeLevel == 0) continue; // 该周期不是节点，跳过
            
            uint256 nodeIdx = userNodeLevel - 1; // V1=0, V2=1, V3=2 V4=3, V5=4
            uint256 nodeCount = IToken(T1Y_TOKEN).dailyCycleNodeCount(day,nodeIdx);
            uint256 reward = IToken(T1Y_TOKEN).dailyCycleNodeRewards(day,nodeIdx);
            
            // 如果人数大于0且有奖励，则平分
            if (nodeCount > 0 && reward > 0) {
                totalReward += reward / nodeCount;
            }
        }
        
        return totalReward;
    }
    
    /**
     * @notice 计算节点 T1Y 奖励（周期）
     * @dev T1Y奖励来源：每小时底池燃烧量的0.5% × 5
     * @dev 分配方式：按人数平分，每个节点用户获得相同数量的奖励
     * @dev 节点等级：
     * @dev 领取逻辑：只领取已完成燃烧的周期（currentDay - 1）
     * @dev 如果周期未执行销毁，则累积模拟计算
     * @param user 用户地址
     * @return 待领取的节点T1Y奖励数量
     */
    function _calculateNodeT1YReward(address user) public view returns (uint256) {
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        if (u.nodeLevel == 0) return 0;
        
        uint256 currentDay = IToken(T1Y_TOKEN).getDailyCycle();
        IToken.UserLast memory info = IToken(T1Y_TOKEN).userLasts(user);
        uint256 lastDay = info.lastNodeT1YCycle;//userLasts[user].lastNodeT1YCycle;
        
        // 第0周期不计算奖励
        if (currentDay == 0) return 0;
        
        // 只计算到 currentDay - 1（已完成燃烧的周期）
        uint256 calculateUntilDay = currentDay;
        calculateUntilDay = _capDailyRewardWindow(lastDay, calculateUntilDay);
        if (lastDay >= calculateUntilDay) return 0; // 没有可计算的周期
        
        uint256 totalReward = 0;
        
        // 用于累积模拟的池子余额
        uint256 simulatedPoolBalance = IToken(T1Y_TOKEN).balanceOf(pancakePair);//super.balanceOf(pancakePair);
        
        // 从上次领奖周期到当前周期
        for (uint256 day = lastDay; day < calculateUntilDay; day++) {
            // 获取用户在该周期的节点等级
            uint256 userNodeLevel = IToken(T1Y_TOKEN).usersCyclelNodeLevel(user,day);
            if (userNodeLevel == 0) continue; // 该周期不是节点，跳过
            
            uint256 nodeIdx = userNodeLevel - 1; 
            uint256 rewardIdx = nodeIdx + 5; 
            uint256 nodeCount = IToken(T1Y_TOKEN).dailyCycleNodeCount(day,nodeIdx);
            uint256 reward = IToken(T1Y_TOKEN).dailyCycleNodeRewards(day,rewardIdx);
            
            // 如果奖励未记录，累积模拟计算（1天）
            if (reward == 0 && nodeCount > 0) {
                uint256[10] memory nodeRewards;
                (nodeRewards, simulatedPoolBalance) = _simulateNodeT1YRewardsWithBalance(day, simulatedPoolBalance);
                reward = nodeRewards[rewardIdx];
            }
            
            // 如果人数大于0且有奖励，则平分
            if (nodeCount > 0 && reward > 0) {
                totalReward += reward / nodeCount;
            }
        }
        
        return totalReward;
    }
    
    /**
     * @notice 计算动态奖励（周期）
     * @dev 动态奖励来源：每底池燃烧量的15%
     * @dev 分配方式：按用户动态算力占比分配
     * @dev 动态算力获取：通过推荐下级入金获得（直推16%，2-3代8%，4-20代4%）
     * @dev 领取逻辑：只领取已完成燃烧的周期（currentDay - 1）
     * @dev 如果周期未执行销毁，则累积模拟计算
     * @param user 用户地址
     * @return totalReward 待领取的动态奖励T1Y数量
     */
    function _calculateDynamicReward(address user) public view returns (uint256 totalReward) {
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        if (u.hashrateDynamic == 0||u.hashrateStatic == 0) return 0;
        
        uint256 currentDay = IToken(T1Y_TOKEN).getDailyCycle();
        IToken.UserLast memory info = IToken(T1Y_TOKEN).userLasts(user);
        uint256 lastDay = info.lastDynamicCycle;
        
        // 第0周期不计算奖励
        if (currentDay == 0) return 0;
        
        // 只计算到 currentDay - 1（已完成燃烧的周期）
        uint256 calculateUntilDay = currentDay;
        calculateUntilDay = _capDailyRewardWindow(lastDay, calculateUntilDay);
        if (lastDay >= calculateUntilDay) return 0; // 没有可计算的周期
        
        uint256 farstHashrate = IToken(T1Y_TOKEN).dailyCycleDynamicHashrate(lastDay);
        uint256 farstUserHashrate = IToken(T1Y_TOKEN).usersCyclelDynamicHashrate(user,lastDay);
        
        totalReward = __calculateDynamicReward(user,lastDay,calculateUntilDay,farstHashrate,farstUserHashrate);
        
        totalReward = _calculateValue(user,totalReward);

        return totalReward;
    }

    function _capDailyRewardWindow(uint256 lastDay, uint256 calculateUntilDay) internal pure returns (uint256) {
        uint256 maxUntilDay = lastDay + MAX_DAILY_REWARD_LOOKBACK;
        if (calculateUntilDay > maxUntilDay) return maxUntilDay;
        return calculateUntilDay;
    }

    function __calculateDynamicReward(address user,uint lastDay,uint calculateUntilDay,uint farstHashrate,uint farstUserHashrate)internal view returns(uint256 totalReward){
        // 用于累积模拟的池子余额
        uint256 simulatedPoolBalance = IToken(T1Y_TOKEN).balanceOf(pancakePair);
        
        for (uint256 day = lastDay; day < calculateUntilDay; day++) {
            uint256 hashrate = IToken(T1Y_TOKEN).dailyCycleDynamicHashrate(day);
            uint256 reward = IToken(T1Y_TOKEN).dailyCycleDynamicReward(day);
            uint256 userHashrate = IToken(T1Y_TOKEN).usersCyclelDynamicHashrate(user,day);
            
            // 如果算力未填充，使用历史算力
            if (hashrate == 0) {
                hashrate = farstHashrate;
            } else {
                farstHashrate = hashrate;
            }
            
            if (userHashrate == 0) {
                userHashrate = farstUserHashrate;
            } else {
                farstUserHashrate = userHashrate;
            }
            
            // 如果奖励未记录，累积模拟计算（1天）
            if (reward == 0 && hashrate > 0) {
                (reward, simulatedPoolBalance) = _simulateDailyBurnWithBalance(day, simulatedPoolBalance);
            }
            
            // 计算用户应得奖励
            if (hashrate > 0 && reward > 0 && userHashrate > 0) {
                totalReward += (userHashrate * reward) / hashrate;
            }
        }
    }
    function _calculateValue(address user,uint totalReward) public view returns(uint256){
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        uint256 maxReward = 3 * (u.hashrateStatic) + IToken(T1Y_TOKEN).userReward(user);

        if (maxReward <= IToken(T1Y_TOKEN).wbnbReward(user)) return 0;
        else maxReward -= IToken(T1Y_TOKEN).wbnbReward(user);
        
        uint value = _getT1YAmountOutOfUSDT(1e18);
        
        uint rewardGaiavalue = u.hashrateReward * value / 1e18;
        
        if(rewardGaiavalue >= maxReward) return 0;

        uint totalRewardValue = totalReward * value / 1e18;
        
        if(rewardGaiavalue + totalRewardValue > maxReward){
            totalRewardValue = maxReward - rewardGaiavalue;
            return totalRewardValue * 1e18 / value;
        }
        return totalReward;
    }
    /**
     * @notice 计算静态奖励（小时周期）
     * @dev 静态奖励来源：每小时底池燃烧量的30%
     * @dev 分配方式：按用户静态算力占比分配
     * @dev 领取逻辑：只领取已完成燃烧的周期（currentHour - 1）
     * @dev 如果周期未执行销毁，则累积模拟计算
     * @param user 用户地址
     * @return totalReward 待领取的静态奖励T1Y数量
     */
    function _calculateStaticReward(address user) public view returns (uint256 totalReward,uint256 nextHour) {
        IToken.User memory u = IToken(T1Y_TOKEN).users(user);
        if (u.hashrateStatic == 0) return (0,0);
        
        uint256 currentHour = IToken(T1Y_TOKEN).getHourlyCycle();
        IToken.UserLast memory info = IToken(T1Y_TOKEN).userLasts(user);
        uint256 lastHour = info.lastStaticCycle;//userLasts[user]
        
        // 第0周期不计算奖励
        if (currentHour == 0) return (0,0);
        
        // 只计算到 currentHour - 1（已完成燃烧的周期）
        uint256 calculateUntilHour = currentHour;
        if (lastHour >= calculateUntilHour) return (0,0); // 没有可计算的周期
        
        uint256 farstHashrate = IToken(T1Y_TOKEN).hourlyCycleStaticHashrate(lastHour);
        uint256 farstUserHashrate = IToken(T1Y_TOKEN).usersCycleStaticHashrate(user,lastHour);
        
        // 用于累积模拟的池子余额
        uint256 simulatedPoolBalance = IToken(T1Y_TOKEN).balanceOf(pancakePair);
        //
        (totalReward,nextHour) = _calculateStaticRewardHours(user, lastHour, calculateUntilHour, farstHashrate, farstUserHashrate, simulatedPoolBalance);
        nextHour = calculateUntilHour;
        totalReward = _calculateValue(user,totalReward);

        return (totalReward,nextHour);
    }
    
    function _calculateStaticRewardHours(address user,uint lastHour,uint calculateUntilHour,uint farstHashrate,uint farstUserHashrate,uint simulatedPoolBalance)
        internal view 
        returns (uint256 totalReward,uint nextHour){
        uint256 hour = lastHour;
        
        if (hour + 7*24 < calculateUntilHour){
            calculateUntilHour = hour + 7*24;
        }
        nextHour = calculateUntilHour;
        for (; hour < calculateUntilHour; hour++) {
            uint256 hashrate = IToken(T1Y_TOKEN).hourlyCycleStaticHashrate(hour);
            uint256 reward = IToken(T1Y_TOKEN).hourlyCycleStaticReward(hour);
            uint256 userHashrate = IToken(T1Y_TOKEN).usersCycleStaticHashrate(user,hour);
            // 如果算力未填充，使用历史算力
            if (hashrate == 0) {
                hashrate = farstHashrate;
            } else {
                farstHashrate = hashrate;
            }
            
            if (userHashrate == 0) {
                userHashrate = farstUserHashrate;
            } else {
                farstUserHashrate = userHashrate;
            }
            
            // 如果奖励未记录，累积模拟计算
            if (reward == 0 && hashrate > 0) {
                (reward, simulatedPoolBalance) = _simulateHourlyBurnWithBalance(
                    hour,
                    simulatedPoolBalance,
                    _priceDiscountBpsForHour(hour)
                );
            }
            
            // 计算用户应得奖励
            if (hashrate > 0 && reward > 0 && userHashrate > 0) {
                totalReward += (userHashrate * reward) / hashrate;
            }
        }
    }
    
    /**
     * @notice 模拟一天的销毁，返回节点T1Y奖励数组和新余额
     * @dev 测试环境下1小时=1天，返回累积的节点T1Y奖励
     * @param poolBalance 当前模拟的池子余额
     * @return nodeRewards 节点奖励数组 
     * @return newPoolBalance 所有销毁后的新余额
     */
    function _simulateNodeT1YRewardsWithBalance(
        uint256 day,
        uint256 poolBalance
    ) public view returns (uint256[10] memory nodeRewards, uint256 newPoolBalance) {
        // 生产环境：24小时 = 1天
        uint256 hoursPerDay = 24;
        
        // 初始化奖励数组
        nodeRewards = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];
        newPoolBalance = poolBalance;
        
        for (uint256 i = 0; i < hoursPerDay; i++) {
            if (newPoolBalance == 0) break;
            
            uint256 burnRate = _calculateBurnRateForPoolWithDiscount(
                day,
                newPoolBalance,
                _priceDiscountBpsForHour(day * 24 + i)
            );
            uint256 burnAmount = (newPoolBalance * burnRate) / BASE;
            if (burnAmount == 0) break;
            
            uint256 feePortion = burnAmount / 2;
            uint256 nodeT1YReward = (feePortion * 1000) / BASE;
            // 累积节点T1Y奖励（奖励半区各1%）
            nodeRewards[5] += nodeT1YReward; // L1 T1Y
            nodeRewards[6] += nodeT1YReward; // L2 T1Y
            nodeRewards[7] += nodeT1YReward; // L3 T1Y
            nodeRewards[8] += nodeT1YReward; // L4 T1Y
            nodeRewards[9] += nodeT1YReward; // L5 T1Y
            
            // 更新余额（防止溢出）
            if (newPoolBalance >= burnAmount) {
                newPoolBalance -= burnAmount;
            } else {
                newPoolBalance = 0;
            }
        }
        
        return (nodeRewards, newPoolBalance);
    }
    /**
     * @notice 计算当前真实池子的每小时燃烧比例
     */
    function _calculateBurnRate() public view returns (uint256) {
        return _calculateBurnRateForPool(
            IToken(T1Y_TOKEN).getDailyCycle(),
            IToken(T1Y_TOKEN).balanceOf(pancakePair),
            IToken(T1Y_TOKEN).getHourlyCycle()
        );
    }

    /**
     * @notice 按指定日周期和池子余额计算每小时燃烧比例
     */
    function _calculateBurnRateForPool(uint256 day, uint256 poolBalance, uint256 hour) public view returns (uint256) {
        return _calculateBurnRateForPoolWithDiscount(day, poolBalance, _priceDiscountBpsForHour(hour));
    }

    function _calculateBurnRateForPoolWithDiscount(
        uint256 day,
        uint256 poolBalance,
        uint256 priceDiscountBps
    ) internal pure returns (uint256) {
        uint256 dailyRate = _baseBurnRate(day);
        uint256 depthCap = _poolProtectionRate(poolBalance);
        if (depthCap < dailyRate) dailyRate = depthCap;

        dailyRate = (dailyRate * priceDiscountBps) / BPS;
        dailyRate = (dailyRate * _timeDiscountBps(day)) / BPS;
        if (dailyRate < FLOOR_DAILY_BURN_RATE) dailyRate = FLOOR_DAILY_BURN_RATE;
        return dailyRate / 24;
    }

    function _baseBurnRate(uint256 day) internal pure returns (uint256) {
        uint256 rate = 2400 + (day / 10 * 120);
        if (rate > MAX_DAILY_BURN_RATE) rate = MAX_DAILY_BURN_RATE;
        return rate;
    }

    function _poolProtectionRate(uint256 poolBalance) internal pure returns (uint256) {
        uint256 pool30 = (INITIAL_POOL_BALANCE * 30) / 100;
        uint256 pool20 = (INITIAL_POOL_BALANCE * 20) / 100;
        uint256 pool10 = (INITIAL_POOL_BALANCE * 10) / 100;

        if (poolBalance >= pool30) return MAX_DAILY_BURN_RATE;
        if (poolBalance >= pool20) {
            return MID_DAILY_BURN_RATE
                + ((poolBalance - pool20) * (MAX_DAILY_BURN_RATE - MID_DAILY_BURN_RATE))
                / (pool30 - pool20);
        }
        if (poolBalance >= pool10) {
            return MIN_DAILY_BURN_RATE
                + ((poolBalance - pool10) * (MID_DAILY_BURN_RATE - MIN_DAILY_BURN_RATE))
                / (pool20 - pool10);
        }
        return MIN_DAILY_BURN_RATE;
    }

    function _priceDiscountBpsForHour(uint256 hour) internal view returns (uint256) {
        uint256 currentPrice = IToken(T1Y_TOKEN).pricePerHour(hour);
        if (currentPrice == 0) return BPS;
        uint256 highPrice = _gethighPrice(hour);
        if (highPrice == 0 || currentPrice >= highPrice) return BPS;

        uint256 drawdownBps = ((highPrice - currentPrice) * BPS) / highPrice;
        if (drawdownBps >= 3000) return 7000;
        if (drawdownBps >= 2000) return 8500;
        return BPS;
    }

    function _timeDiscountBps(uint256 day) internal pure returns (uint256) {
        if (day < 180) return BPS;
        if (day < 360) return BPS - ((day - 180) * 1000) / 180;
        if (day < 540) return 9000 - ((day - 360) * 1500) / 180;
        if (day < 720) return 7500 - ((day - 540) * 1500) / 180;
        return 6000;
    }
    // ============ 辅助功能：累积模拟销毁 ============
    /**
     * @notice 模拟单个小时周期的销毁，并返回新的余额
     * @dev 用于在奖励计算时模拟未执行的销毁周期
     * @param poolBalance 当前模拟的池子余额
     * @return staticReward 该周期的静态奖励
     * @return newPoolBalance 销毁后的新余额
     */
    
    function _simulateHourlyBurnWithBalance(
        uint256 hour,
        uint256 poolBalance,
        uint256 priceDiscountBps
    ) internal pure returns (uint256 staticReward, uint256 newPoolBalance) {
        if (poolBalance == 0) return (0, 0);
        
        // 计算燃烧比例
        uint256 burnRate = _calculateBurnRateForPoolWithDiscount(hour / 24, poolBalance, priceDiscountBps);
        
        // 计算燃烧数量
        uint256 burnAmount = (poolBalance * burnRate) / BASE;
        if (burnAmount == 0) return (0, poolBalance);
        
        // 计算静态奖励（30%）
        staticReward = (burnAmount * 30000) / BASE;
        
        // 返回销毁后的新余额
        newPoolBalance = poolBalance - burnAmount;
        
        return (staticReward, newPoolBalance);
    }
    /**
     * @notice 模拟一天的销毁（累积所有小时），并返回新的余额
     * @dev 测试环境下1小时=1天，生产环境需要累积24小时
     * @param poolBalance 当前模拟的池子余额
     * @return dailyDynamicReward 该天的累积动态奖励
     * @return newPoolBalance 所有销毁后的新余额
     */
    function _simulateDailyBurnWithBalance(
        uint256 day,
        uint256 poolBalance
    ) public view returns (uint256 dailyDynamicReward, uint256 newPoolBalance) {
        // 测试环境：1小时 = 1天
        // 生产环境：需要累积24小时的销毁
        uint256 hoursPerDay = 24; // 生产环境：一天周期
        
        dailyDynamicReward = 0;
        newPoolBalance = poolBalance;
        
        for (uint256 i = 0; i < hoursPerDay; i++) {
            if (newPoolBalance == 0) break;
            
            uint256 burnRate = _calculateBurnRateForPoolWithDiscount(
                day,
                newPoolBalance,
                _priceDiscountBpsForHour(day * 24 + i)
            );
            uint256 burnAmount = (newPoolBalance * burnRate) / BASE;
            if (burnAmount == 0) break;
            
            // 累积动态奖励（15%）
            dailyDynamicReward += (burnAmount * 15000) / BASE;
            
            // 更新余额（防止溢出）
            if (newPoolBalance >= burnAmount) {
                newPoolBalance -= burnAmount;
            } else {
                newPoolBalance = 0;
            }
        }
        
        return (dailyDynamicReward, newPoolBalance);
    }
    
    /**
     * @notice 将查询T1Y对WBNB的价格
     */

    function _getT1YAmountOutOfUSDT(uint256 amountIn) public view returns(uint256){
        uint wbnbAmount = _getAmountOut(T1Y_TOKEN,WBNB,amountIn);
        return _getAmountOut(WBNB,USDT,wbnbAmount);
    }
    function _getUSDTAmountOustOfT1Y(uint256 amountIn) public view returns(uint256){
        uint wbnbAmount = _getAmountOut(USDT,WBNB,amountIn);
        return _getAmountOut(WBNB,T1Y_TOKEN,wbnbAmount);
    }
    function _getAmountOut(address token0,address token1,uint256 amountIn) internal view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amounts = IPancakeRouter(ROUTER).getAmountsOut(amountIn, path);
        return amounts[1];
    }
}
// ============ 接口定义 ============

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
