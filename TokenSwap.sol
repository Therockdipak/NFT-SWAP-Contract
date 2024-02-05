// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {AToken} from "./TokenA.sol";
import {BToken} from "./TokenB.sol";

 contract TokenSwap is Ownable{
    using SafeERC20 for IERC20;

    AToken public tokenA;
    BToken public tokenB;

    uint256 public rate = 100;  // 1A = 100B
    uint256 public purchaseCount;
    uint256 public purchaseThreshold = 10000;
    uint256 public rateIncreasePercentage = 10;

    event TokensSwapped(address indexed buyer, uint256 amountA, uint256 amountB);

    constructor(AToken _tokenA, BToken _tokenB) Ownable(msg.sender) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function initializeTokenB(address _tokenBAddress) external onlyOwner {
        require(address(tokenB) == address(0), "TokenB address already set");
        tokenB = BToken(_tokenBAddress);
    }

    function tokenBTransfer(uint256 _amount) external onlyOwner{
        require(tokenB.balanceOf(msg.sender) >= _amount, "Insufficient TokenB balance");

        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), _amount);

        emit TokensSwapped(msg.sender, 0, _amount);

        // Check if the purchase threshold is crossed
        if (purchaseCount >= purchaseThreshold) {
            rate = rate + (rate * rateIncreasePercentage / 100);
            purchaseCount = 0;
        } else {
            purchaseCount += _amount;
        }
    }

    function swapTokens(uint256 amountA) external {
        require(tokenA.balanceOf(msg.sender) >= amountA, "Insufficient TokenA balance");

        uint256 amountB = amountA * rate;

        // Perform the token swap
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);
        console.log(msg.sender);
        emit TokensSwapped(msg.sender, amountA, amountB);

        // Check if the purchase threshold is crossed
        if (purchaseCount >= purchaseThreshold) {
            rate = rate + (rate * rateIncreasePercentage / 100);
            purchaseCount = 0;
        } else {
            purchaseCount += amountB;
        }
    }
}
