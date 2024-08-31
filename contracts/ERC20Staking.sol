// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Staking is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingStart;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 stakedAmount, uint256 rewardAmount);
    event EmergencyWithdrawn(address indexed user, uint256 stakedAmount);
    event RewardRateUpdated(uint256 newRate);
    event StakingDurationUpdated(uint256 newDuration);
    event ERC20Recovered(address token, uint256 amount);
    
    uint256 public rewardRate;
    uint256 public stakingDuration;

    constructor(address _stakingToken, uint256 _rewardRate, uint256 _stakingDuration) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Invalid staking token address");
        require(_rewardRate > 0, "Reward rate must be greater than 0");
        require(_stakingDuration > 0, "Staking duration must be greater than 0");

        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
        stakingDuration = _stakingDuration;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        
        uint256 currentReward = _calculateRewards(msg.sender);
        rewards[msg.sender] += currentReward;
        
        stakedBalance[msg.sender] += _amount;
        stakingStart[msg.sender] = block.timestamp;
        
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        
        emit Staked(msg.sender, _amount);
    }

    function _calculateRewards(address _user) internal view returns (uint256) {
        if (stakedBalance[_user] == 0) {
            return 0;
        }
        
        uint256 stakingEndTime = stakingStart[_user] + stakingDuration;
        uint256 timeStaked = block.timestamp > stakingEndTime ? stakingDuration : block.timestamp - stakingStart[_user];
        
        return (stakedBalance[_user] * rewardRate * timeStaked) / (365 days * 100);
    }

    function withdraw() external {
        require(stakedBalance[msg.sender] > 0, "No tokens staked");
        
        uint256 currentStakedAmount = stakedBalance[msg.sender];
        uint256 currentReward = _calculateRewards(msg.sender);
        
        stakedBalance[msg.sender] = 0;
        stakingStart[msg.sender] = 0;
        
        uint256 totalRewards = rewards[msg.sender] + currentReward;
        rewards[msg.sender] = 0;
        
        stakingToken.safeTransfer(msg.sender, currentStakedAmount);
        if (totalRewards > 0) {
            require(stakingToken.balanceOf(address(this)) >= totalRewards, "Insufficient reward tokens");
            stakingToken.safeTransfer(msg.sender, totalRewards);
        }
        
        emit Withdrawn(msg.sender, currentStakedAmount, totalRewards);
    }

    function emergencyWithdraw() external {
        require(stakedBalance[msg.sender] > 0, "No tokens staked");
        
        uint256 currentStakedAmount = stakedBalance[msg.sender];
        
        stakedBalance[msg.sender] = 0;
        stakingStart[msg.sender] = 0;
        rewards[msg.sender] = 0;
        
        stakingToken.safeTransfer(msg.sender, currentStakedAmount);
        
        emit EmergencyWithdrawn(msg.sender, currentStakedAmount);
    }

    function getStakedBalance(address _user) external view returns (uint256) {
        return stakedBalance[_user];
    }

    function getRewards(address _user) external view returns (uint256) {
        return rewards[_user] + _calculateRewards(_user);
    }

    function setRewardRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "Reward rate must be greater than 0");
        rewardRate = _newRate;
        emit RewardRateUpdated(_newRate);
    }

    function setStakingDuration(uint256 _newDuration) external onlyOwner {
        require(_newDuration > 0, "Staking duration must be greater than 0");
        stakingDuration = _newDuration;
        emit StakingDurationUpdated(_newDuration);
    }

    function recoverERC20(address _tokenAddress, uint256 _amount) external onlyOwner {
        require(_tokenAddress != address(stakingToken), "Cannot recover staking token");
        IERC20(_tokenAddress).safeTransfer(owner(), _amount);
        emit ERC20Recovered(_tokenAddress, _amount);
    }
}