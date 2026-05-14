// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {MockOracleAdapter} from "../../src/oracle/MockOracleAdapter.sol";
import {MarketTypes} from "../../src/core/MarketTypes.sol";

contract MockOracleAdapterTest is Test {
    MockOracleAdapter internal oracle;

    address internal admin = address(this);
    address internal stranger = address(0xBAD);

    bytes32 internal marketId = keccak256("ETH_ABOVE_5000");

    function setUp() public {
        oracle = new MockOracleAdapter(admin, 1 days);
    }

    function testSetResolutionStoresResolution() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        MarketTypes.MarketResolution memory resolution = oracle.getResolution(marketId);

        assertTrue(resolution.resolved);
        assertEq(uint256(resolution.outcome), uint256(MarketTypes.Outcome.Yes));
        assertEq(resolution.oracleAnswer, 1);
        assertEq(resolution.updatedAt, block.timestamp);
    }

    function testIsResolvedReturnsTrueForFreshResolution() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.No, 0, block.timestamp);

        assertTrue(oracle.isResolved(marketId));
    }

    function testIsResolvedReturnsFalseForMissingResolution() public view {
        assertFalse(oracle.isResolved(marketId));
    }

    function testClearResolutionRemovesResolution() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        oracle.clearResolution(marketId);

        assertFalse(oracle.isResolved(marketId));

        vm.expectRevert();
        oracle.getResolution(marketId);
    }

    function testSetMaxStalenessUpdatesValue() public {
        oracle.setMaxStaleness(2 days);

        assertEq(oracle.maxStaleness(), 2 days);
    }

    function testSetMaxStalenessRevertsWithZero() public {
        vm.expectRevert(MockOracleAdapter.ZeroStaleness.selector);

        oracle.setMaxStaleness(0);
    }

    function testGetResolutionRevertsWhenMissing() public {
        vm.expectRevert();

        oracle.getResolution(marketId);
    }

    function testGetResolutionRevertsWhenStale() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert();

        oracle.getResolution(marketId);
    }

    function testIsResolvedReturnsFalseWhenStale() public {
        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);

        vm.warp(block.timestamp + 2 days);

        assertFalse(oracle.isResolved(marketId));
    }

    function testSetResolutionRevertsForInvalidOutcome() public {
        vm.expectRevert(MockOracleAdapter.InvalidOutcome.selector);

        oracle.setResolution(marketId, MarketTypes.Outcome.Unresolved, 0, block.timestamp);
    }

    function testNonAdminCannotSetResolution() public {
        vm.prank(stranger);
        vm.expectRevert();

        oracle.setResolution(marketId, MarketTypes.Outcome.Yes, 1, block.timestamp);
    }

    function testNonAdminCannotClearResolution() public {
        vm.prank(stranger);
        vm.expectRevert();

        oracle.clearResolution(marketId);
    }

    function testNonAdminCannotSetMaxStaleness() public {
        vm.prank(stranger);
        vm.expectRevert();

        oracle.setMaxStaleness(2 days);
    }
}
