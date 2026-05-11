// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AMMMath
/// @notice Math utilities for CPMM-based prediction market pricing.
library AMMMath {
    error InvalidAmount();
    error InvalidReserves();
    error SlippageExceeded(uint256 outputAmount, uint256 minOutput);

    uint256 internal constant BPS_DENOMINATOR = 10_000;

    /// @notice Calculates output amount using x * y = k formula with fee.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint256 feeBps)
        internal
        pure
        returns (uint256 amountOut)
    {
        if (amountIn == 0) revert InvalidAmount();

        if (reserveIn == 0 || reserveOut == 0) {
            revert InvalidReserves();
        }

        uint256 amountInWithFee = amountIn * (BPS_DENOMINATOR - feeBps);

        uint256 numerator = amountInWithFee * reserveOut;

        uint256 denominator = (reserveIn * BPS_DENOMINATOR) + amountInWithFee;

        amountOut = numerator / denominator;
    }

    /// @notice Checks slippage bounds.
    function validateSlippage(uint256 outputAmount, uint256 minOutput) internal pure {
        if (outputAmount < minOutput) {
            revert SlippageExceeded(outputAmount, minOutput);
        }
    }

    /// @notice Returns current constant-product invariant.
    function calculateInvariant(uint256 reserveA, uint256 reserveB) internal pure returns (uint256) {
        return reserveA * reserveB;
    }
}
