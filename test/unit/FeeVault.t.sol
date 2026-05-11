// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {FeeVault} from "../../src/vault/FeeVault.sol";
import {MockERC20} from "../../src/mocks/MockERC20.sol";

contract FeeVaultTest is Test {
    FeeVault internal vault;
    MockERC20 internal asset;

    address internal admin = address(this);
    address internal user = address(0xB0B);
    address internal stranger = address(0xBAD);

    function setUp() public {
        asset = new MockERC20("Mock USDC", "mUSDC", 18, admin);
        vault = new FeeVault(asset, admin);

        asset.mint(user, 10_000 ether);
        asset.mint(admin, 10_000 ether);

        vm.prank(user);
        asset.approve(address(vault), type(uint256).max);

        asset.approve(address(vault), type(uint256).max);
    }

    function testConstructorStoresAsset() public view {
        assertEq(vault.asset(), address(asset));
    }

    function testAdminHasDefaultAdminRole() public view {
        assertTrue(vault.hasRole(vault.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testAdminHasFeeDepositorRole() public view {
        assertTrue(vault.hasRole(vault.FEE_DEPOSITOR_ROLE(), admin));
    }

    function testDepositWorks() public {
        vm.prank(user);
        uint256 shares = vault.deposit(100 ether, user);

        assertEq(shares, 100 ether);
        assertEq(vault.balanceOf(user), 100 ether);
        assertEq(vault.totalAssets(), 100 ether);
    }

    function testWithdrawWorks() public {
        vm.startPrank(user);
        vault.deposit(100 ether, user);

        uint256 balanceBefore = asset.balanceOf(user);

        uint256 sharesBurned = vault.withdraw(40 ether, user, user);

        vm.stopPrank();

        assertEq(sharesBurned, 40 ether);
        assertEq(vault.balanceOf(user), 60 ether);
        assertEq(asset.balanceOf(user), balanceBefore + 40 ether);
    }

    function testDepositFeesWorksForRole() public {
        vault.depositFees(100 ether);

        assertEq(vault.totalAssets(), 100 ether);
        assertEq(asset.balanceOf(address(vault)), 100 ether);
    }

    function testDepositFeesRevertsForNonRole() public {
        vm.prank(stranger);
        vm.expectRevert();

        vault.depositFees(100 ether);
    }

    function testDepositFeesRevertsWithZeroAmount() public {
        vm.expectRevert(FeeVault.ZeroAmount.selector);

        vault.depositFees(0);
    }

    function testTotalManagedAssetsReturnsTotalAssets() public {
        vm.prank(user);
        vault.deposit(250 ether, user);

        assertEq(vault.totalManagedAssets(), vault.totalAssets());
        assertEq(vault.totalManagedAssets(), 250 ether);
    }
}
