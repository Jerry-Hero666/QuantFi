// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {MockERC20} from "../../src/mock/MockERC20.sol";
import {AirdropDistributor} from "../../src/airdrop/AirdropDistributor.sol";

contract AirdropDistributorTest is Test {
    MockERC20 internal token;
    AirdropDistributor internal distributor;
    address internal admin = address(0xA11CE);
    address internal alice = address(0xBEEF1);
    address internal bob = address(0xBEEF2);
    uint256 internal constant ROUND_ID = 1;

    function setUp() public {
        // 开始以 admin 身份执行后续所有操作
        vm.startPrank(admin);
        token = new MockERC20("AirdropToken", "ADPT", 18);
        distributor = new AirdropDistributor(address(token), admin);
        token.mint(address(distributor), 1_000_000 ether);
        // 停止 prank，恢复为默认调用者
        vm.stopPrank();

        bytes32 leafAlice = _leaf(ROUND_ID, alice, 100 ether);
        bytes32 leafBob = _leaf(ROUND_ID, bob, 200 ether);
        bytes32 root = _parent(leafAlice, leafBob);
        // 以下一个调用以 admin 身份执行
        vm.prank(admin);
        distributor.startRound(ROUND_ID, root, uint64(block.timestamp + 1 days));
    }

    function testClaimTransfersTokens() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = _leaf(ROUND_ID, bob, 200 ether);
        // 以下一个调用以 alice 身份执行
        vm.prank(alice);
        distributor.claim(ROUND_ID, 100 ether, proof);
        assertEq(token.balanceOf(alice), 100 ether);
        assertTrue(distributor.claimed(ROUND_ID, alice));
    }

    function testCannotClaimTwice() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = _leaf(ROUND_ID, bob, 200 ether);
        // 以下一个调用以 alice 身份执行
        vm.prank(alice);
        distributor.claim(ROUND_ID, 100 ether, proof);

        // 以下一个调用以 alice 身份执行
        vm.prank(alice);
        // 期望下一个调用会回退并包含 "claimed" 错误消息
        vm.expectRevert("claimed");
        distributor.claim(ROUND_ID, 100 ether, proof);
    }

    function testInvalidProofReverts() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bytes32(uint256(123));
        // 以下一个调用以 bob 身份执行
        vm.prank(bob);
        // 期望下一个调用会回退并包含 "invalid proof" 错误消息
        vm.expectRevert("invalid proof");
        distributor.claim(ROUND_ID, 200 ether, proof);
    }

    function testExpiredRoundReverts() public {
        bytes32 leafAlice = _leaf(2, alice, 1 ether);
        // 以下一个调用以 admin 身份执行
        vm.prank(admin);
        distributor.startRound(2, leafAlice, uint64(block.timestamp + 1));
        // 将区块时间戳向前推进 2 秒，使轮次过期
        vm.warp(block.timestamp + 2);

        bytes32[] memory proof = new bytes32[](0);
        // 以下一个调用以 alice 身份执行
        vm.prank(alice);
        // 期望下一个调用会回退并包含 "expired" 错误消息
        vm.expectRevert("expired");
        distributor.claim(2, 1 ether, proof);
    }

    function _leaf(uint256 roundId, address account, uint256 amount) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(roundId, account, amount));
    }

    function _parent(bytes32 left, bytes32 right) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(left, right));
    }
}
