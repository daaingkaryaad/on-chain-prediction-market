// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {FeeVault} from "../../src/vault/FeeVault.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";

contract FeeVaultFuzzTest is Test {
    MockERC20 internal collateral;
    FeeVault internal vault;

    address internal user = address(0xB0B);

    function setUp() public {
        collateral = new MockERC20("Mock USDC", "mUSDC", 18, address(this));
        vault = new FeeVault(IERC20(address(collateral)), address(this));
    }

    function testFuzzDepositAndWithdraw(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1, 1_000_000 ether);

        collateral.mint(user, amount);

        vm.startPrank(user);

        collateral.approve(address(vault), amount);

        uint256 sharesMinted = vault.deposit(amount, user);

        assertEq(vault.balanceOf(user), sharesMinted);
        assertEq(vault.totalManagedAssets(), amount);
        assertEq(collateral.balanceOf(address(vault)), amount);

        uint256 sharesBurned = vault.withdraw(amount, user, user);

        assertEq(sharesBurned, sharesMinted);
        assertEq(vault.balanceOf(user), 0);
        assertEq(vault.totalManagedAssets(), 0);
        assertEq(collateral.balanceOf(user), amount);

        vm.stopPrank();
    }

    function testFuzzDepositFeesIncreasesManagedAssets(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1, 1_000_000 ether);

        collateral.mint(address(this), amount);

        collateral.approve(address(vault), amount);

        vault.depositFees(amount);

        assertEq(vault.totalManagedAssets(), amount);
        assertEq(collateral.balanceOf(address(vault)), amount);
    }
}
