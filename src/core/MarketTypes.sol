// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MarketTypes
/// @notice Shared enums and structs for the prediction market protocol.
library MarketTypes {
    enum MarketState {
        Open,
        Locked,
        Resolved,
        Disputed,
        Cancelled
    }

    enum Outcome {
        Unresolved,
        Yes,
        No
    }

    struct MarketConfig {
        string question;
        address collateralToken;
        address oracle;
        uint256 resolutionTime;
        uint256 disputeWindow;
        uint256 initialYesReserve;
        uint256 initialNoReserve;
        uint256 feeBps;
    }

    struct MarketResolution {
        bool resolved;
        Outcome outcome;
        int256 oracleAnswer;
        uint256 updatedAt;
    }
}
