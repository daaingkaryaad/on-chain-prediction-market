// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {ChainlinkOracleAdapter} from "../../src/oracle/ChainlinkOracleAdapter.sol";
import {MockChainlinkAggregator} from "../../src/mocks/MockChainlinkAggregator.sol";

contract ChainlinkOracleAdapterTest is Test {
    ChainlinkOracleAdapter internal adapter;
    MockChainlinkAggregator internal aggregator;

    function setUp() public {
        aggregator = new MockChainlinkAggregator(8);

        adapter = new ChainlinkOracleAdapter(address(aggregator), 1 days);
    }

    function testLatestPriceReturnsCorrectData() public {
        aggregator.setRoundData(3000e8, block.timestamp);

        (int256 answer, uint256 updatedAt) = adapter.latestPrice();

        assertEq(answer, 3000e8);
        assertEq(updatedAt, block.timestamp);
    }

    function testLatestPriceRevertsOnStalePrice() public {
        aggregator.setRoundData(3000e8, block.timestamp - 2 days);

        vm.expectRevert(ChainlinkOracleAdapter.StalePrice.selector);

        adapter.latestPrice();
    }

    function testLatestPriceRevertsOnInvalidPrice() public {
        aggregator.setRoundData(0, block.timestamp);

        vm.expectRevert(ChainlinkOracleAdapter.InvalidPrice.selector);

        adapter.latestPrice();
    }

    function testDecimalsReturnsFeedDecimals() public view {
        assertEq(adapter.decimals(), 8);
    }
}
