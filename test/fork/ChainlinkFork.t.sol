// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

interface AggregatorV3InterfaceFork {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);
}

contract ChainlinkForkTest is Test {
    AggregatorV3InterfaceFork internal ethUsdFeed;

    address internal constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    bool internal forkConfigured;

    function setUp() public {
        string memory rpcUrl = vm.envOr("MAINNET_RPC_URL", string(""));

        if (bytes(rpcUrl).length == 0) {
            return;
        }

        vm.createSelectFork(rpcUrl);

        forkConfigured = true;

        ethUsdFeed = AggregatorV3InterfaceFork(ETH_USD_FEED);
    }

    function testForkReadsChainlinkEthUsdFeed() public view {
        if (!forkConfigured) {
            return;
        }

        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            ethUsdFeed.latestRoundData();

        assertGt(roundId, 0);
        assertGt(answer, 0);
        assertGt(startedAt, 0);
        assertGt(updatedAt, 0);
        assertGe(answeredInRound, roundId);
    }

    function testForkChainlinkFeedDecimals() public view {
        if (!forkConfigured) {
            return;
        }

        assertEq(ethUsdFeed.decimals(), 8);
    }

    function testForkChainlinkFeedDescriptionExists() public view {
        if (!forkConfigured) {
            return;
        }

        string memory description = ethUsdFeed.description();

        assertGt(bytes(description).length, 0);
    }
}
