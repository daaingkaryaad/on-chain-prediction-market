// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

import {IFeeVault} from "../interfaces/IFeeVault.sol";

contract FeeVault is ERC4626, AccessControl, IFeeVault {
    using SafeERC20 for IERC20;

    error ZeroAddress();
    error ZeroAmount();

    bytes32 public constant FEE_DEPOSITOR_ROLE = keccak256("FEE_DEPOSITOR_ROLE");

    constructor(IERC20 asset_, address admin) ERC20("PredictX Fee Vault Share", "pxFEE") ERC4626(asset_) {
        if (address(asset_) == address(0)) revert ZeroAddress();
        if (admin == address(0)) revert ZeroAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(FEE_DEPOSITOR_ROLE, admin);
    }

    function depositFees(uint256 amount) external onlyRole(FEE_DEPOSITOR_ROLE) {
        if (amount == 0) revert ZeroAmount();

        IERC20(asset()).safeTransferFrom(msg.sender, address(this), amount);

        emit FeesDeposited(msg.sender, amount);
    }

    function totalManagedAssets() external view returns (uint256) {
        return totalAssets();
    }
}
