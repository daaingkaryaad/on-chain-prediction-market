// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PredictionMarketUpgradeable} from "../core/PredictionMarketUpgradeable.sol";

contract PredictionMarketUpgradeableV2 is PredictionMarketUpgradeable {
    function version() external pure override returns (uint256) {
        return 2;
    }

    function newFunction() external pure returns (string memory) {
        return "upgraded";
    }
}
