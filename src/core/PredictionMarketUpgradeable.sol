// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title PredictionMarketUpgradeable
/// @notice Minimal UUPS-upgradeable skeleton for future market upgrades.
contract PredictionMarketUpgradeable is Initializable, UUPSUpgradeable, AccessControlUpgradeable, ReentrancyGuard {
    error ZeroAddress();

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    string public marketQuestion;
    address public collateralToken;
    uint256 public versionNumber;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory question_, address collateralToken_, address admin_) public initializer {
        if (collateralToken_ == address(0) || admin_ == address(0)) {
            revert ZeroAddress();
        }

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(UPGRADER_ROLE, admin_);

        marketQuestion = question_;
        collateralToken = collateralToken_;
        versionNumber = 1;
    }

    function version() external view virtual returns (uint256) {
        return versionNumber;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert ZeroAddress();
        }
    }
}
