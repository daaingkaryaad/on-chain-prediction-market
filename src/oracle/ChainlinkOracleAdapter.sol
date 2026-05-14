// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPriceOracle} from "../interfaces/IPriceOracle.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function decimals() external view returns (uint8);
}

contract ChainlinkOracleAdapter is IPriceOracle {
    error InvalidOracle();
    error StalePrice();
    error InvalidPrice();
    error IncompleteRound();

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

    function latestPrice() external view override returns (int256 answer, uint256 updatedAt) {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updated,
            uint80 answeredInRound) = priceFeed.latestRoundData(

            );

        if (answeredInRound < roundId) {
            revert IncompleteRound();
        }

        if (startedAt == 0 || updated == 0 || updated > block.timestamp) {
            revert StalePrice();
            }

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
