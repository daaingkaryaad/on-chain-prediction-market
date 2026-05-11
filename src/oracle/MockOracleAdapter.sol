// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {IOracleAdapter} from "../interfaces/IOracleAdapter.sol";
import {MarketTypes} from "../core/MarketTypes.sol";

/// @title MockOracleAdapter
/// @notice Mock oracle adapter used for deterministic tests and local demos.
contract MockOracleAdapter is IOracleAdapter, AccessControl {
    error InvalidOutcome();
    error ZeroStaleness();

    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    uint256 public maxStaleness;

    mapping(bytes32 marketId => MarketTypes.MarketResolution resolution) private _resolutions;

    constructor(address admin, uint256 maxStaleness_) {
        if (admin == address(0)) revert ZeroAddress();
        if (maxStaleness_ == 0) revert ZeroStaleness();

        maxStaleness = maxStaleness_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN_ROLE, admin);
    }

    error ZeroAddress();

    function setResolution(bytes32 marketId, MarketTypes.Outcome outcome, int256 oracleAnswer, uint256 updatedAt)
        external
        onlyRole(ORACLE_ADMIN_ROLE)
    {
        if (outcome != MarketTypes.Outcome.Yes && outcome != MarketTypes.Outcome.No) {
            revert InvalidOutcome();
        }

        _resolutions[marketId] = MarketTypes.MarketResolution({
            resolved: true, outcome: outcome, oracleAnswer: oracleAnswer, updatedAt: updatedAt
        });

        emit ResolutionSet(marketId, outcome, oracleAnswer, updatedAt);
    }

    function clearResolution(bytes32 marketId) external onlyRole(ORACLE_ADMIN_ROLE) {
        delete _resolutions[marketId];
    }

    function setMaxStaleness(uint256 newMaxStaleness) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (newMaxStaleness == 0) revert ZeroStaleness();

        maxStaleness = newMaxStaleness;
    }

    function getResolution(bytes32 marketId) external view returns (MarketTypes.MarketResolution memory resolution) {
        resolution = _resolutions[marketId];

        if (!resolution.resolved) revert MarketNotResolved(marketId);

        if (block.timestamp > resolution.updatedAt + maxStaleness) {
            revert OracleDataStale(resolution.updatedAt, block.timestamp, maxStaleness);
        }
    }

    function isResolved(bytes32 marketId) external view returns (bool) {
        MarketTypes.MarketResolution memory resolution = _resolutions[marketId];

        if (!resolution.resolved) {
            return false;
        }

        return block.timestamp <= resolution.updatedAt + maxStaleness;
    }
}
