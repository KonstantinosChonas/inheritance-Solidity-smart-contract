# Inheritance Smart Contract

This repository contains a Solidity smart contract that implements an inheritance mechanism. The contract allows the owner to withdraw ETH, and if the owner does not perform a withdrawal for more than 30 days, a designated heir can take control of the contract and assign a new heir.

## Features

- **Owner Withdrawal**: The owner can withdraw any amount of ETH from the contract, including 0 ETH to reset the inactivity timer.
- **Heir Takeover**: If the owner does not withdraw for more than 30 days, the heir can claim ownership and designate a new heir.
- **ETH Deposits**: The contract can receive ETH, and the balance can be checked via a public function.
- **Event Logging**: Key actions (withdrawals, heir designations, ownership transfers, and ETH receipts) are logged via events for transparency.

## Contract Details

- **Solidity Version**: `>=0.7.0 <0.9.0`
- **License**: GPL-3.0
- **State Variables**:
  - `owner`: The current owner of the contract.
  - `heir`: The designated heir who can take over after inactivity.
  - `lastWithdrawal`: Timestamp of the last withdrawal or ownership transfer.
  - `INACTIVITY_PERIOD`: Constant set to 30 days (in seconds).
- **Events**:
  - `Withdrawal`: Emitted when the owner withdraws ETH.
  - `HeirDesignated`: Emitted when the owner designates a new heir.
  - `OwnershipTransferred`: Emitted when the heir claims ownership.
  - `BalanceReceived`: Emitted when the contract receives ETH.

## Design Choices

The following design decisions were made to ensure the contract operates securely and aligns with the intended inheritance mechanism:

- **Heir Cannot Be the Owner**: The contract enforces that the `heir` cannot be the same address as the `owner` during initialization and when designating a new heir. This prevents the owner from accidentally or intentionally locking the contract into an invalid state where no transfer of ownership could occur, ensuring the inheritance feature remains functional.
  
- **New Heir Cannot Be the Current Heir in Ownership Claim**: When the heir claims ownership via `claimOwnership`, the new heir they designate cannot be themselves (the current heir who is becoming the owner). This avoids a situation where the new owner could immediately become their own heir, which would defeat the purpose of having a separate successor and could lead to a dead-end scenario.

- **Zero Address Restriction**: The `heir` cannot be the zero address (`address(0)`). This ensures that there is always a valid Ethereum address designated as the heir, preventing funds from becoming permanently inaccessible due to an unclaimable state.

These choices prioritize security, simplicity, and the core intent of enabling a reliable transfer of control over the contract’s funds.
