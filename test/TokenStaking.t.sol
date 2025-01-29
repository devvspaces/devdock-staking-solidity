// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/TokenStaking.sol";

contract TokenStakingTest is Test {
    StakingToken public token;
    TokenStaking public staking;
    address public user1;
    address public user2;
    address public owner;

    event Staked(address indexed user, uint256 amount, uint256 unlockTime);
    event Unstaked(address indexed user, uint256 amount);

    function setUp() public {
        owner = address(this);
        token = new StakingToken();
        staking = new TokenStaking(address(token));

        user1 = address(0x1);
        user2 = address(0x2);

        // Fund users
        token.transfer(user1, 1000 * 10 ** 18);
        token.transfer(user2, 1000 * 10 ** 18);
    }

    function testInitialState() public view {
        assertEq(address(staking.stakingToken()), address(token));
        assertEq(staking.MINIMUM_STAKING_AMOUNT(), 100 * 10 ** 18);
        assertEq(staking.STAKING_DURATION(), 30 days);
    }

    function testStaking() public {
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);

        uint256 expectedUnlockTime = block.timestamp + 30 days;

        vm.expectEmit(true, false, false, true);
        emit Staked(user1, 500 * 10 ** 18, expectedUnlockTime);

        staking.stake(500 * 10 ** 18);

        assertEq(token.balanceOf(address(staking)), 500 * 10 ** 18);
        assertEq(staking.getStakeCount(user1), 1);

        (uint256 amount, , uint256 unlockTime, bool claimed) = staking
            .getStakeInfo(user1, 0);
        assertEq(amount, 500 * 10 ** 18);
        assertEq(unlockTime, expectedUnlockTime);
        assertFalse(claimed);

        vm.stopPrank();
    }

    function testMultipleStakes() public {
        vm.startPrank(user1);
        token.approve(address(staking), 1000 * 10 ** 18);

        staking.stake(200 * 10 ** 18);
        staking.stake(300 * 10 ** 18);

        assertEq(staking.getStakeCount(user1), 2);
        assertEq(token.balanceOf(address(staking)), 500 * 10 ** 18);
        vm.stopPrank();
    }

    function testUnstaking() public {
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);
        staking.stake(500 * 10 ** 18);

        uint256 initialBalance = token.balanceOf(user1);

        // Fast forward 31 days
        vm.warp(block.timestamp + 31 days);

        vm.expectEmit(true, false, false, true);
        emit Unstaked(user1, 500 * 10 ** 18);

        staking.unstake(0);
        assertEq(token.balanceOf(user1), initialBalance + 500 * 10 ** 18);

        // Verify stake is marked as claimed
        (, , , bool claimed) = staking.getStakeInfo(user1, 0);
        assertTrue(claimed);

        vm.stopPrank();
    }

    function test_RevertWhen_StakingBelowMinimum() public {
        vm.startPrank(user1);
        token.approve(address(staking), 50 * 10 ** 18);

        vm.expectRevert("Amount below minimum");
        staking.stake(50 * 10 ** 18);
        vm.stopPrank();
    }

    function test_RevertWhen_UnstakingTooEarly() public {
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);
        staking.stake(500 * 10 ** 18);

        vm.expectRevert("Stake still locked");
        staking.unstake(0);
        vm.stopPrank();
    }

    function test_RevertWhen_UnstakingInvalidIndex() public {
        vm.startPrank(user1);
        vm.expectRevert("Invalid stake index");
        staking.unstake(0);
        vm.stopPrank();
    }

    function test_RevertWhen_UnstakingAlreadyClaimed() public {
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);
        staking.stake(500 * 10 ** 18);

        // Fast forward 31 days
        vm.warp(block.timestamp + 31 days);

        // First unstake
        staking.unstake(0);

        // Try to unstake again
        vm.expectRevert("Already claimed");
        staking.unstake(0);
        vm.stopPrank();
    }

    function testStakingWithMultipleUsers() public {
        // User 1 stakes
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);
        staking.stake(500 * 10 ** 18);
        vm.stopPrank();

        // User 2 stakes
        vm.startPrank(user2);
        token.approve(address(staking), 300 * 10 ** 18);
        staking.stake(300 * 10 ** 18);
        vm.stopPrank();

        assertEq(token.balanceOf(address(staking)), 800 * 10 ** 18);
        assertEq(staking.getStakeCount(user1), 1);
        assertEq(staking.getStakeCount(user2), 1);
    }

    function testGetStakeInfo() public {
        vm.startPrank(user1);
        token.approve(address(staking), 500 * 10 ** 18);
        uint256 stakeTime = block.timestamp;
        staking.stake(500 * 10 ** 18);

        (
            uint256 amount,
            uint256 timestamp,
            uint256 unlockTime,
            bool claimed
        ) = staking.getStakeInfo(user1, 0);
        assertEq(amount, 500 * 10 ** 18);
        assertEq(timestamp, stakeTime);
        assertEq(unlockTime, stakeTime + 30 days);
        assertFalse(claimed);
        vm.stopPrank();
    }

    function test_RevertWhen_GetStakeInfoInvalidIndex() public {
        vm.expectRevert("Invalid stake index");
        staking.getStakeInfo(user1, 0);
    }
}
