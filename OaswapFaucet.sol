// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OaswapFaucet is Ownable {
    mapping(address => bool) public sent;
    uint256 private _lastTxn;

    event Withdrawal(address indexed to);
    event Deposit(address indexed from, uint256 amount);

    constructor() {}

    /**
        @notice Sends 0.01 ROSE to a wallet if the faucet has enough funds
     */
    function faucetWithdraw(address _requestWallet) external onlyOwner {
        require(address(this).balance >= 0.01 ether, "Faucet is empty.");
        require(sent[_requestWallet] != true, "Already sent.");
        require(_lastTxn <= block.timestamp - 3 minutes, "Before time limit.");

        payable(_requestWallet).transfer(0.01 ether);
        sent[_requestWallet] = true;
        _lastTxn = block.timestamp;

        emit Withdrawal(msg.sender);
    }

    /**
        @notice Function to receive ROSE
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
        @notice Withdraw all ROSE with owner
     */
    function ownerWithdraw() external onlyOwner {
        uint256 totalBalance = address(this).balance;
        payable(owner()).transfer(totalBalance);
    }

    /**
        @notice Destroys this smart contract and sends all remaining funds to the owner
     */
    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}
