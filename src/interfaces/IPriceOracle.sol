// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPriceOracle {
    function latestPrice() external view returns (int256 answer, uint256 updatedAt);
}
