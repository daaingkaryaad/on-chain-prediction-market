// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFeeVault {
    event FeesDeposited(address indexed depositor, uint256 amount);

    function depositFees(uint256 amount) external;

    function totalManagedAssets() external view returns (uint256);
}
