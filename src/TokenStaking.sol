// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenStaking is ReentrancyGuard, Ownable {
    IERC20 public stakingToken;
    
    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 unlockTime;
        bool claimed;
    }
    
    mapping(address => StakeInfo[]) public stakes;
    
    uint256 public constant MINIMUM_STAKING_AMOUNT = 100 * 10**18; // 100 tokens
    uint256 public constant STAKING_DURATION = 30 days;
    
    event Staked(address indexed user, uint256 amount, uint256 unlockTime);
    event Unstaked(address indexed user, uint256 amount);
    
    constructor(address _stakingToken) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Invalid token address");
        stakingToken = IERC20(_stakingToken);
    }
    
    function stake(uint256 _amount) external nonReentrant {
        require(_amount >= MINIMUM_STAKING_AMOUNT, "Amount below minimum");
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        uint256 unlockTime = block.timestamp + STAKING_DURATION;
        
        stakes[msg.sender].push(StakeInfo({
            amount: _amount,
            timestamp: block.timestamp,
            unlockTime: unlockTime,
            claimed: false
        }));
        
        emit Staked(msg.sender, _amount, unlockTime);
    }
    
    function unstake(uint256 _stakeIndex) external nonReentrant {
        require(_stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        StakeInfo storage stakeInfo = stakes[msg.sender][_stakeIndex];
        
        require(!stakeInfo.claimed, "Already claimed");
        require(block.timestamp >= stakeInfo.unlockTime, "Stake still locked");
        
        uint256 amount = stakeInfo.amount;
        stakeInfo.claimed = true;
        
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");
        
        emit Unstaked(msg.sender, amount);
    }
    
    function getStakeCount(address _user) external view returns (uint256) {
        return stakes[_user].length;
    }
    
    function getStakeInfo(address _user, uint256 _index) external view returns (
        uint256 amount,
        uint256 timestamp,
        uint256 unlockTime,
        bool claimed
    ) {
        require(_index < stakes[_user].length, "Invalid stake index");
        StakeInfo memory stakeInfo = stakes[_user][_index];
        return (stakeInfo.amount, stakeInfo.timestamp, stakeInfo.unlockTime, stakeInfo.claimed);
    }
}