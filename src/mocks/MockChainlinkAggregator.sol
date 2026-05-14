// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "../oracle/ChainlinkOracleAdapter.sol";

contract MockChainlinkAggregator is AggregatorV3Interface {
    int256 internal currentAnswer;
    uint256 internal currentUpdatedAt;
    uint80 internal currentRoundId;
    uint80 internal currentAnsweredInRound;
    uint8 internal immutable feedDecimals;

    constructor(uint8 decimals_) {
        feedDecimals = decimals_;
        currentRoundId = 1;
        currentAnsweredInRound = 1;
    }

    function setRoundData(int256 answer_, uint256 updatedAt_) external {
        currentAnswer = answer_;
        currentUpdatedAt = updatedAt_;
        currentRoundId = 1;
        currentAnsweredInRound = 1;
    }

    function setIncompleteRoundData(int256 answer_, uint256 updatedAt_) external {
        currentAnswer = answer_;
        currentUpdatedAt = updatedAt_;
        currentRoundId = 2;
        currentAnsweredInRound = 1;
    }

    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (currentRoundId, currentAnswer, currentUpdatedAt, currentUpdatedAt, currentAnsweredInRound);
    }

    function decimals() external view override returns (uint8) {
        return feedDecimals;
    }
}
