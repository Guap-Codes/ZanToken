// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployZanToken} from "../script/DeployZanToken.s.sol";
import {ZanToken} from "../src/ZanToken.sol";
import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract ZanTokenFuzzTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether; // Initial amount of tokens allocated to Bob

    ZanToken public zanToken; // Instance of the ZanToken contract
    DeployZanToken public deployer; // Instance of the deployer contract
    address public deployerAddress; // Address of the deployer
    address bob; // Address for Bob
    address alice; // Address for Alice

    function setUp() public {
        // Deploy the ZanToken contract
        deployer = new DeployZanToken();
        zanToken = deployer.run();

        // Create Bob and Alice addresses
        bob = makeAddr("bob");
        alice = makeAddr("alice");

        // Get the deployer's address
        deployerAddress = vm.addr(deployer.deployerKey());

        // Transfer initial tokens to Bob from the deployer's address
        vm.prank(deployerAddress);
        zanToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testFuzzTransfer(uint256 transferAmount) public {
        // Ensure the transfer amount is within the range of Bob's starting amount
        vm.assume(transferAmount <= BOB_STARTING_AMOUNT);

        uint256 initialBobBalance = zanToken.balanceOf(bob); // Get Bob's initial balance
        uint256 initialAliceBalance = zanToken.balanceOf(alice); // Get Alice's initial balance

        // Bob attempts to transfer tokens to Alice
        vm.prank(bob);
        bool success = zanToken.transfer(alice, transferAmount);

        if (transferAmount <= initialBobBalance) {
            // If the transfer amount is within Bob's balance, the transfer should succeed
            assert(success);
            assertEq(zanToken.balanceOf(bob), initialBobBalance - transferAmount);
            assertEq(zanToken.balanceOf(alice), initialAliceBalance + transferAmount);
        } else {
            // If the transfer amount exceeds Bob's balance, the transfer should fail
            assert(!success);
            assertEq(zanToken.balanceOf(bob), initialBobBalance);
            assertEq(zanToken.balanceOf(alice), initialAliceBalance);
        }
    }

    function testFuzzApproveAndTransferFrom(uint256 approveAmount, uint256 transferAmount) public {
        // Ensure the approve amount is within the range of Bob's starting amount
        vm.assume(approveAmount <= BOB_STARTING_AMOUNT);
        // Ensure the transfer amount is within the approve amount
        vm.assume(transferAmount <= approveAmount);

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, approveAmount);

        uint256 initialBobBalance = zanToken.balanceOf(bob); // Get Bob's initial balance
        uint256 initialAliceBalance = zanToken.balanceOf(alice); // Get Alice's initial balance

        // Alice attempts to transfer tokens from Bob's account to her own
        vm.prank(alice);
        bool success = zanToken.transferFrom(bob, alice, transferAmount);

        if (transferAmount <= initialBobBalance && transferAmount <= approveAmount) {
            // If the transfer amount is within Bob's balance and the approved amount, the transfer should succeed
            assert(success);
            assertEq(zanToken.balanceOf(bob), initialBobBalance - transferAmount);
            assertEq(zanToken.balanceOf(alice), initialAliceBalance + transferAmount);
            assertEq(zanToken.allowance(bob, alice), approveAmount - transferAmount);
        } else {
            // If the transfer amount exceeds Bob's balance or the approved amount, the transfer should fail
            assert(!success);
            assertEq(zanToken.balanceOf(bob), initialBobBalance);
            assertEq(zanToken.balanceOf(alice), initialAliceBalance);
            assertEq(zanToken.allowance(bob, alice), approveAmount);
        }
    }

    function testFuzzTransferToZeroAddress(uint256 transferAmount) public {
        // Ensure the transfer amount is within the range of Bob's starting amount
        vm.assume(transferAmount <= BOB_STARTING_AMOUNT);

        // Bob attempts to transfer tokens to the zero address, which should fail
        vm.prank(bob);
        vm.expectRevert();
        zanToken.transfer(address(0), transferAmount);
    }

    function testFuzzTransferFromToZeroAddress(uint256 approveAmount, uint256 transferAmount) public {
        // Ensure the approve amount is within the range of Bob's starting amount
        vm.assume(approveAmount <= BOB_STARTING_AMOUNT);
        // Ensure the transfer amount is within the approve amount
        vm.assume(transferAmount <= approveAmount);

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        zanToken.approve(alice, approveAmount);

        // Alice attempts to transfer tokens from Bob's account to the zero address, which should fail
        vm.prank(alice);
        vm.expectRevert();
        zanToken.transferFrom(bob, address(0), transferAmount);
    }
}
