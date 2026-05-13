// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {YulMath} from "../../src/libraries/YulMath.sol";

contract SolidityMathHarness {
    function min(uint256 a, uint256 b)
        external
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        external
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    )
        external
        pure
        returns (uint256)
    {
        return (x * y) / denominator;
    }
}

contract YulMathHarness {
    function min(uint256 a, uint256 b)
        external
        pure
        returns (uint256)
    {
        return YulMath.min(a, b);
    }

    function max(uint256 a, uint256 b)
        external
        pure
        returns (uint256)
    {
        return YulMath.max(a, b);
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    )
        external
        pure
        returns (uint256)
    {
        return YulMath.mulDiv(x, y, denominator);
    }
}

contract YulMathGasTest is Test {
    SolidityMathHarness internal solidityMath;
    YulMathHarness internal yulMath;

    function setUp() public {
        solidityMath = new SolidityMathHarness();
        yulMath = new YulMathHarness();
    }

    function testGasMinSolidity() public view {
        uint256 result = solidityMath.min(100, 200);

        assertEq(result, 100);
    }

    function testGasMinYul() public view {
        uint256 result = yulMath.min(100, 200);

        assertEq(result, 100);
    }

    function testGasMaxSolidity() public view {
        uint256 result = solidityMath.max(100, 200);

        assertEq(result, 200);
    }

    function testGasMaxYul() public view {
        uint256 result = yulMath.max(100, 200);

        assertEq(result, 200);
    }

    function testGasMulDivSolidity() public view {
        uint256 result = solidityMath.mulDiv(
            1_000 ether,
            500 ether,
            100 ether
        );

        assertEq(result, 5_000 ether);
    }

    function testGasMulDivYul() public view {
        uint256 result = yulMath.mulDiv(
            1_000 ether,
            500 ether,
            100 ether
        );

        assertEq(result, 5_000 ether);
    }
}