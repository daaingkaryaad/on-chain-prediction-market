// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TimelockController} from "../../lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

/// @title ProtocolTimelock
/// @notice Timelock controller for PredictX governance execution.
contract ProtocolTimelock is TimelockController {
    uint256 public constant MIN_DELAY = 2 days;

    constructor(address[] memory proposers, address[] memory executors, address admin)
        TimelockController(MIN_DELAY, proposers, executors, admin)
    {}
}
