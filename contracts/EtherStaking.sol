// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EtherStaking is ReentrancyGuard, Ownable {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        bool claimed;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public totalRewards;

    uint256 public constant REWARD_RATE = 1; 
    uint256 public constant REWARD_PERIOD = 1 days;
    uint256 public constant MINIMUM_STAKING_PERIOD = 7 days;

    constructor() Ownable(msg.sender) {

    }

    event Staked(address indexed user, uint256 amount);

    function stakeEther() external payable nonReentrant {
        require(msg.value > 0, "Must stake some Ether");
        require(stakes[msg.sender].amount == 0, "Already staking");

        stakes[msg.sender] = Stake({
            amount: msg.value,
            timestamp: block.timestamp,
            claimed: false
        });

        emit Staked(msg.sender, msg.value);
    }

    function calculateReward(address _user) public view returns (uint256) {
        Stake memory stake = stakes[_user];
        if (stake.amount == 0 || stake.claimed) {
            return 0;
        }

        uint256 stakingDuration = block.timestamp - stake.timestamp;
        if (stakingDuration < MINIMUM_STAKING_PERIOD) {
            return 0;
        }

        uint256 rewardPeriods = stakingDuration / REWARD_PERIOD;
        uint256 reward = (stake.amount * REWARD_RATE * rewardPeriods) / 1000;

        return reward;
    }
}