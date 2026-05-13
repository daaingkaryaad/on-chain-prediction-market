// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title YulMath
/// @notice Gas-optimized math helpers using inline assembly.
library YulMath {
    error DivisionByZero();

    function min(uint256 a, uint256 b) internal pure returns (uint256 result) {
        assembly {
            result := xor(a, mul(xor(a, b), lt(b, a)))
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256 result) {
        assembly {
            result := xor(b, mul(xor(a, b), lt(b, a)))
        }
    }

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        if (denominator == 0) {
            revert DivisionByZero();
        }

        assembly {
            result := div(mul(x, y), denominator)
        }
    }
}
