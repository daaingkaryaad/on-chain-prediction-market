// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {LPToken} from "../../src/tokens/LPToken.sol";

contract LPTokenTest is Test {
    LPToken internal token;

    address internal admin = address(this);
    address internal user = address(0xB0B);
    address internal stranger = address(0xBAD);

    function setUp() public {
        token = new LPToken(admin);
    }

    function testAdminHasDefaultAdminRole() public view {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testAdminHasMinterRole() public view {
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
    }

    function testMinterCanMint() public {
        token.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
        assertEq(token.totalSupply(), 100 ether);
    }

    function testNonMinterCannotMint() public {
        vm.prank(stranger);
        vm.expectRevert();

        token.mint(user, 100 ether);
    }

    function testMintRevertsToZeroAddress() public {
        vm.expectRevert(LPToken.ZeroAddress.selector);

        token.mint(address(0), 100 ether);
    }

    function testMintRevertsWithZeroAmount() public {
        vm.expectRevert(LPToken.ZeroAmount.selector);

        token.mint(user, 0);
    }

    function testMinterCanBurn() public {
        token.mint(user, 100 ether);
        token.burn(user, 40 ether);

        assertEq(token.balanceOf(user), 60 ether);
        assertEq(token.totalSupply(), 60 ether);
    }

    function testNonMinterCannotBurn() public {
        token.mint(user, 100 ether);

        vm.prank(stranger);
        vm.expectRevert();

        token.burn(user, 40 ether);
    }

    function testBurnRevertsFromZeroAddress() public {
        vm.expectRevert(LPToken.ZeroAddress.selector);

        token.burn(address(0), 40 ether);
    }

    function testBurnRevertsWithZeroAmount() public {
        token.mint(user, 100 ether);

        vm.expectRevert(LPToken.ZeroAmount.selector);

        token.burn(user, 0);
    }
}
