// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function decimals() external view returns (uint8);
}

contract ChainlinkOracleAdapter {
    error InvalidOracle();
    error StalePrice();
    error InvalidPrice();

    AggregatorV3Interface public immutable priceFeed;

    uint256 public immutable stalePriceDelay;

    constructor(address priceFeed_, uint256 stalePriceDelay_) {
        if (priceFeed_ == address(0)) {
            revert InvalidOracle();
        }

        if (stalePriceDelay_ == 0) {
            revert InvalidOracle();
        }

        priceFeed = AggregatorV3Interface(priceFeed_);
        stalePriceDelay = stalePriceDelay_;
    }

    function latestPrice() external view returns (int256 answer, uint256 updatedAt) {
        (, int256 price,, uint256 updated,) = priceFeed.latestRoundData();

        if (price <= 0) {
            revert InvalidPrice();
        }

        if (block.timestamp - updated > stalePriceDelay) {
            revert StalePrice();
        }

        return (price, updated);
    }

    function decimals() external view returns (uint8) {
        return priceFeed.decimals();
    }
}
