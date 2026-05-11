// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AMMMath} from "../../src/libraries/AMMMath.sol";

contract AMMMathHarness {
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint256 feeBps)
        external
        pure
        returns (uint256)
    {
        return AMMMath.getAmountOut(amountIn, reserveIn, reserveOut, feeBps);
    }

    function validateSlippage(uint256 outputAmount, uint256 minOutput) external pure {
        AMMMath.validateSlippage(outputAmount, minOutput);
    }

    function calculateInvariant(uint256 reserveA, uint256 reserveB) external pure returns (uint256) {
        return AMMMath.calculateInvariant(reserveA, reserveB);
    }
}

contract AMMMathTest is Test {
    AMMMathHarness internal harness;

    function setUp() public {
        harness = new AMMMathHarness();
    }

    function testGetAmountOutReturnsExpectedValue() public view {
        uint256 amountOut = harness.getAmountOut(100 ether, 1_000 ether, 1_000 ether, 30);

        assertEq(amountOut, 90_661_089_388_014_913_158);
    }

    function testGetAmountOutRevertsWhenAmountInIsZero() public {
        vm.expectRevert(AMMMath.InvalidAmount.selector);

        harness.getAmountOut(0, 1_000 ether, 1_000 ether, 30);
    }

    function testGetAmountOutRevertsWhenReserveInIsZero() public {
        vm.expectRevert(AMMMath.InvalidReserves.selector);

        harness.getAmountOut(100 ether, 0, 1_000 ether, 30);
    }

    function testGetAmountOutRevertsWhenReserveOutIsZero() public {
        vm.expectRevert(AMMMath.InvalidReserves.selector);

        harness.getAmountOut(100 ether, 1_000 ether, 0, 30);
    }

    function testValidateSlippagePassesWhenOutputIsEnough() public view {
        harness.validateSlippage(100 ether, 90 ether);
    }

    function testValidateSlippageRevertsWhenOutputIsTooLow() public {
        vm.expectRevert();

        harness.validateSlippage(80 ether, 90 ether);
    }

    function testInvariantReturnsProduct() public view {
        assertEq(harness.calculateInvariant(12, 10), 120);
    }
}
