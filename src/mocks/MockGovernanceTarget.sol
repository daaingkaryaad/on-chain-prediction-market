// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MockGovernanceTarget
/// @notice Simple target contract for testing Governor + Timelock execution.
contract MockGovernanceTarget {
    uint256 public value;

    event ValueChanged(uint256 oldValue, uint256 newValue);

    function setValue(uint256 newValue) external {
        uint256 oldValue = value;
        value = newValue;

        emit ValueChanged(oldValue, newValue);
    }
}
