// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "./MerkleProof.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Merkle-based airdrop distributor with replay protection.
contract AirdropDistributor is Ownable {
    using SafeERC20 for IERC20;

    struct RoundConfig {
        bytes32 merkleRoot;
        uint64 claimDeadline;
        bool active;
    } 

    IERC20 public immutable TOKEN;
    mapping(uint256 => RoundConfig) public rounds;
    mapping(uint256 => mapping(address => bool)) public claimed;

    event RoundStarted(uint256 indexed roundId, bytes32 indexed merkleRoot, uint64 claimDeadline);
    event RoundClosed(uint256 indexed roundId);
    event Claimed(uint256 indexed roundId, address indexed account, uint256 amount, bytes32 leaf);

    constructor(address token_, address admin_) Ownable(admin_) {
        require(token_ != address(0), "token required");
        TOKEN = IERC20(token_);
    }

    function startRound(uint256 roundId, bytes32 merkleRoot, uint64 claimDeadline) external onlyOwner {
        require(roundId > 0, "round=0");
        require(merkleRoot != bytes32(0), "root required");
        require(claimDeadline > block.timestamp, "deadline invalid");
        rounds[roundId] = RoundConfig({merkleRoot: merkleRoot, claimDeadline: claimDeadline, active: true});
        emit RoundStarted(roundId, merkleRoot, claimDeadline);
    }

    function closeRound(uint256 roundId) external onlyOwner {
        RoundConfig storage config = rounds[roundId];
        require(config.active, "round not active");
        config.active = false;
        emit RoundClosed(roundId);
    }

    function claim(uint256 roundId, uint256 amount, bytes32[] calldata proof) external {
        RoundConfig memory config = rounds[roundId];
        require(config.active, "inactive");
        require(block.timestamp <= config.claimDeadline, "expired");
        require(!claimed[roundId][msg.sender], "claimed");
        require(amount > 0, "amount=0");

        bytes32 leaf;
        assembly {
            // abi.encodePacked(roundId, msg.sender, amount) tightly packs:
            // - roundId: 32 bytes (offset 0)
            // - msg.sender: 20 bytes (offset 32, no padding)
            // - amount: 32 bytes (offset 52)
            // Total: 84 bytes (0x54)
            let ptr := mload(0x40)
            // Store roundId at offset 0
            mstore(ptr, roundId)
            // Store msg.sender at offset 32 (0x20), left-shifted by 96 bits to align right
            // This puts the 20-byte address in bytes 32-51
            mstore(add(ptr, 0x20), shl(96, caller()))
            // Store amount starting at offset 52 (0x34)
            // We need to write it at the correct offset for tight packing
            // Since we stored 32 bytes at offset 0x20 (which includes address + 12 zero bytes),
            // we need to write amount starting at byte 52
            let amountPtr := add(ptr, 0x34) // 52 bytes = 0x34
            mstore(amountPtr, amount)
            // Hash exactly 84 bytes starting from ptr
            leaf := keccak256(ptr, 0x54)
            // Update free memory pointer
            mstore(0x40, add(ptr, 0x60))
        }
        require(MerkleProof.verify(proof, config.merkleRoot, leaf), "invalid proof");

        claimed[roundId][msg.sender] = true;
        TOKEN.safeTransfer(msg.sender, amount);
        emit Claimed(roundId, msg.sender, amount, leaf);
    }
}
