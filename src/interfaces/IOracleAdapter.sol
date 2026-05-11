// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MarketTypes} from "../core/MarketTypes.sol";

interface IOracleAdapter {
    error OracleDataStale(uint256 updatedAt, uint256 currentTime, uint256 maxStaleness);
    error MarketNotResolved(bytes32 marketId);

    event ResolutionSet(
        bytes32 indexed marketId, MarketTypes.Outcome indexed outcome, int256 oracleAnswer, uint256 updatedAt
    );

    function getResolution(bytes32 marketId) external view returns (MarketTypes.MarketResolution memory resolution);

    function isResolved(bytes32 marketId) external view returns (bool);
}
