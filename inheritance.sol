// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Inheritance {

    address public owner; // The owner of the contract
    address public heir; // The designated heir who can take over
    uint256 public lastWithdrawal; // Timestamp of the last withdrawal 
    uint256 public constant INACTIVITY_PERIOD = 30 days ; // 1 month in seconds (30 days * 24 hours * 60 minutes * 60 seconds)

    // Events for important actions
    event Withdrawal(address indexed owner, uint256 amount, uint256 timestamp);
    event HeirDesignated(address indexed owner, address indexed newHeir);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner, address newHeir);
    event BalanceReceived(address indexed sender, uint256 amount, uint256 newBalance);

    

    // Constructor to set the initial owner and heir
    constructor(address newHeir) payable {
        owner = msg.sender; // The deployer becomes the owner

        // check if heir is valid
        require(newHeir != owner, "Owner cannot be the heir");
        require(newHeir != address(0), "Heir cannot be the zero address");
        // if it is you can set the heir
        heir = newHeir; // Set the initial heir
        lastWithdrawal = block.timestamp; // Initialize the last withdrawal timestamp
    }

    // Function to allow the owner to withdraw ETH (including 0 ETH to reset the timer)
    function withdraw(uint256 _amount) external  {
        require(msg.sender == owner, "Only the owner can call this function"); // Give access only to the owner
        require(address(this).balance >= _amount, "Insufficient balance in contract");
        
        // Update the last withdrawal timestamp (resets the INACTIVITY_PERIOD counter)
        lastWithdrawal = block.timestamp;

        // If the amount is greater than 0, transfer ETH to the owner
        if (_amount > 0) {
            (bool success, ) = owner.call{value: _amount}("");
            require(success, "ETH transfer failed");
        }

        emit Withdrawal(owner, _amount, block.timestamp);
    }

    // Function for the owner to designate a new heir
    function designateHeir(address newHeir) external  {
        //check if heir is valid
        require(newHeir != owner, "Owner cannot be the heir");
        require(newHeir != address(0), "Heir cannot be the zero address");

        require(msg.sender == owner, "Only the owner can call this function");  // Give access only to the owner
        heir = newHeir;
        emit HeirDesignated(owner, newHeir);
    }

    // Function for the heir to take control after 1 month of inactivity
    function claimOwnership(address newHeir) external {
        require(msg.sender == heir, "Only the heir can claim ownership");
        require(block.timestamp >= lastWithdrawal + INACTIVITY_PERIOD, "Owner is still active");
        //check if heir is valid
        require(newHeir != heir, "New heir cannot be the new owner");
        require(newHeir != address(0), "Heir cannot be the zero address");
        // Transfer ownership to the heir
        address oldOwner = owner;
        owner = heir;
        heir = newHeir;
        lastWithdrawal = block.timestamp; // Reset the timer for the new owner

        emit OwnershipTransferred(oldOwner, owner, newHeir);
    }

    // Function to allow the contract to receive ETH
    receive() external payable {
        emit BalanceReceived(msg.sender, msg.value, address(this).balance);
    }

    // Function to check the contract's balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}