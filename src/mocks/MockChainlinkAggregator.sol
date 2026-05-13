// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockChainlinkAggregator {
    int256 internal currentAnswer;
    uint256 internal currentUpdatedAt;
    uint8 internal immutable feedDecimals;

    constructor(uint8 decimals_) {
        feedDecimals = decimals_;
    }

    function setRoundData(
        int256 answer_,
        uint256 updatedAt_
    )
        external
    {
        currentAnswer = answer_;
        currentUpdatedAt = updatedAt_;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return (
            1,
            currentAnswer,
            currentUpdatedAt,
            currentUpdatedAt,
            1
        );
    }

    function decimals()
        external
        view
        returns (uint8)
    {
        return feedDecimals;
    }
}