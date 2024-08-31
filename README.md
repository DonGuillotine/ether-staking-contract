# Solidity Staking Contracts

This repository contains two smart contracts for staking: one for ERC20 token staking and another for Ether staking. They are designed to allow users to stake their tokens or Ether in return for rewards, following a set of customizable rules defined within the contracts.

## Table of Contents

- [Overview](#overview)
- [Contracts](#contracts)
  - [ERC20Staking](#erc20staking)
  - [EtherStaking](#etherstaking)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Security Considerations](#security-considerations)
- [License](#license)

## Overview

The repository features two Solidity smart contracts built using the Hardhat environment:

1. **ERC20Staking**: A contract that allows users to stake ERC20 tokens and earn rewards based on the staking duration and reward rate.
2. **EtherStaking**: A contract that allows users to stake Ether and earn rewards, with a fixed minimum staking period and a reward rate.

## Contracts

### ERC20Staking

The `ERC20Staking` contract allows users to stake an ERC20 token and earn rewards over time. The contract supports the following features:

- **Staking**: Users can stake any amount of ERC20 tokens.
- **Reward Calculation**: Rewards are calculated based on the staking duration and a predefined reward rate.
- **Withdrawal**: Users can withdraw their staked tokens along with any rewards after the staking period ends.
- **Emergency Withdrawal**: Users can withdraw their staked tokens without any rewards in case of emergencies.
- **Owner Controls**: The contract owner can set the reward rate, staking duration, and recover any ERC20 tokens sent to the contract by mistake.

### EtherStaking

The `EtherStaking` contract allows users to stake Ether and earn rewards. Key features include:

- **Staking**: Users can stake Ether with a minimum staking period.
- **Reward Calculation**: Rewards are calculated daily based on the staked amount and a fixed reward rate.
- **Withdrawal**: Users can withdraw their staked Ether along with the rewards after the minimum staking period has passed.
- **Emergency Withdrawal**: The contract owner can withdraw all Ether in the contract in case of emergencies.
- **Non-Reentrancy**: The contract uses the `ReentrancyGuard` to prevent reentrancy attacks.

## Installation

To work with these contracts, follow the steps below:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DonGuillotine/ether-staking-contract.git
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Compile the contracts:**
   ```bash
   npx hardhat compile
   ```

## Usage

### Deploying Contracts

You can deploy the contracts using the Hardhat environment.

## Testing

To test the contracts, use the following command:

```bash
npx hardhat test
```

Ensure that you have written and configured the necessary test cases in the `test` folder.

## Security Considerations I implemented

- **Reentrancy**: The `EtherStaking` contract is protected against reentrancy attacks using the `ReentrancyGuard`.
- **Ownership Renouncement**: The `EtherStaking` contract has overridden the `renounceOwnership` function to prevent accidental loss of control.
- **Emergency Withdrawal**: Both contracts have emergency withdrawal functions to handle unforeseen circumstances.
- **Ensure Sufficient Balance**: Made sure that the contracts hold sufficient token or Ether balance to cover rewards before allowing users to withdraw.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
