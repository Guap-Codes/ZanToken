// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployZanToken} from "../script/DeployZanToken.s.sol";
import {ZanToken} from "../src/ZanToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract ZanTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    ZanToken public zanToken;
    DeployZanToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;
    address charlie;

    function setUp() public {
        deployer = new DeployZanToken();
        zanToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");
        charlie = makeAddr("charlie");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        zanToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(zanToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(zanToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        zanToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        zanToken.transferFrom(bob, alice, transferAmount);
        assertEq(zanToken.balanceOf(alice), transferAmount);
        assertEq(zanToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);

        // Check remaining allowance
        assertEq(zanToken.allowance(bob, alice), initialAllowance - transferAmount);

        // Revert if trying to transfer more than remaining allowance
        vm.prank(alice);
        vm.expectRevert();
        zanToken.transferFrom(bob, alice, initialAllowance);
    }

    function testTransfers() public {
        uint256 transferAmount = 50 ether;

        // Bob transfers tokens to Alice
        vm.prank(bob);
        zanToken.transfer(alice, transferAmount);

        assertEq(zanToken.balanceOf(alice), transferAmount);
        assertEq(zanToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);

        // Alice transfers tokens to Charlie
        vm.prank(alice);
        zanToken.transfer(charlie, transferAmount / 2);

        assertEq(zanToken.balanceOf(charlie), transferAmount / 2);
        assertEq(zanToken.balanceOf(alice), transferAmount / 2);
    }

    function testInsufficientBalanceTransfers() public {
        uint256 transferAmount = 200 ether; // More than BOB_STARTING_AMOUNT

        // Bob tries to transfer more tokens than he has
        vm.prank(bob);
        vm.expectRevert();
        zanToken.transfer(alice, transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 allowance = 100 ether;
        uint256 transferAmount = 50 ether;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, allowance);

        // Alice transfers tokens from Bob's account to her own
        vm.prank(alice);
        zanToken.transferFrom(bob, alice, transferAmount);

        assertEq(zanToken.balanceOf(alice), transferAmount);
        assertEq(zanToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
        assertEq(zanToken.allowance(bob, alice), allowance - transferAmount);

        // Alice tries to transfer more than the remaining allowance
        vm.prank(alice);
        vm.expectRevert();
        zanToken.transferFrom(bob, alice, allowance); // Remaining allowance is only 50 ether
    }

    function testApproveZeroAllowance() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, initialAllowance);

        // Bob changes allowance to zero
        vm.prank(bob);
        zanToken.approve(alice, 0);

        // Check remaining allowance is zero
        assertEq(zanToken.allowance(bob, alice), 0);

        // Alice tries to transfer tokens from Bob's account
        vm.prank(alice);
        vm.expectRevert();
        zanToken.transferFrom(bob, alice, initialAllowance);
    }

    function testIncreaseAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 increaseAmount = 500;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, initialAllowance);

        // Bob increases Alice's allowance
        vm.prank(bob);
        zanToken.increaseAllowance(alice, increaseAmount);

        // Check new allowance
        assertEq(zanToken.allowance(bob, alice), initialAllowance + increaseAmount);
    }

    function testDecreaseAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 decreaseAmount = 500;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, initialAllowance);

        // Bob decreases Alice's allowance
        vm.prank(bob);
        zanToken.decreaseAllowance(alice, decreaseAmount);

        // Check new allowance
        assertEq(zanToken.allowance(bob, alice), initialAllowance - decreaseAmount);
    }

    function testTransferToZeroAddress() public {
        uint256 transferAmount = 50 ether;

        // Bob tries to transfer tokens to zero address
        vm.prank(bob);
        vm.expectRevert();
        zanToken.transfer(address(0), transferAmount);
    }

    function testTransferFromToZeroAddress() public {
        uint256 allowance = 100 ether;
        uint256 transferAmount = 50 ether;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, allowance);

        // Alice tries to transfer tokens from Bob's account to zero address
        vm.prank(alice);
        vm.expectRevert();
        zanToken.transferFrom(bob, address(0), transferAmount);
    }
}
