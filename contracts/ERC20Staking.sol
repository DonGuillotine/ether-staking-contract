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

    event Staked(address indexed user, uint256 amount);
}