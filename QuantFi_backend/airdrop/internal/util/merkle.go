package util

import (
	"encoding/binary"
	"errors"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
)

// MerkleLeaf represents a leaf in the merkle tree
type MerkleLeaf struct {
	RoundID uint64
	Wallet  string
	Amount  int64
}

// LeafHash computes the keccak256 hash of abi.encodePacked(roundId, wallet, amount)
// This matches the Solidity contract's leaf calculation
func LeafHash(roundID uint64, wallet string, amount int64) []byte {
	// Normalize wallet address
	walletAddr := common.HexToAddress(wallet)
	
	// Encode: roundId (uint256) + wallet (address) + amount (uint256)
	// In Solidity: abi.encodePacked(roundId, msg.sender, amount)
	// abi.encodePacked concatenates without padding, but for uint256 we need 32 bytes
	data := make([]byte, 0, 32+20+32)
	
	// roundId as uint256 (32 bytes, big-endian)
	roundBytes := make([]byte, 32)
	binary.BigEndian.PutUint64(roundBytes[24:], roundID)
	data = append(data, roundBytes...)
	
	// wallet as address (20 bytes)
	data = append(data, walletAddr.Bytes()...)
	
	// amount as uint256 (32 bytes, big-endian)
	amountBytes := make([]byte, 32)
	binary.BigEndian.PutUint64(amountBytes[24:], uint64(amount))
	data = append(data, amountBytes...)
	
	hash := crypto.Keccak256(data)
	return hash
}

// BuildMerkleTree builds a merkle tree from leaves and returns the root and proofs
func BuildMerkleTree(leaves []MerkleLeaf) (root []byte, proofs map[string][][]byte, err error) {
	if len(leaves) == 0 {
		return nil, nil, errors.New("empty leaves")
	}
	
	// Compute leaf hashes
	leafHashes := make([][]byte, len(leaves))
	walletToIndex := make(map[string]int) // map[wallet]index
	for i, leaf := range leaves {
		leafHashes[i] = LeafHash(leaf.RoundID, leaf.Wallet, leaf.Amount)
		walletToIndex[leaf.Wallet] = i
	}
	
	// Build tree level by level, storing all levels for proof generation
	levels := make([][][]byte, 0)
	levels = append(levels, leafHashes)
	currentLevel := leafHashes
	
	for len(currentLevel) > 1 {
		nextLevel := make([][]byte, 0, (len(currentLevel)+1)/2)
		
		for i := 0; i < len(currentLevel); i += 2 {
			var hash []byte
			if i+1 < len(currentLevel) {
				// Pair of nodes: hash(left, right)
				left, right := currentLevel[i], currentLevel[i+1]
				// Ensure deterministic ordering (smaller first)
				if string(left) > string(right) {
					left, right = right, left
				}
				hash = crypto.Keccak256(append(left, right...))
			} else {
				// Odd node: hash with itself
				hash = crypto.Keccak256(append(currentLevel[i], currentLevel[i]...))
			}
			nextLevel = append(nextLevel, hash)
		}
		
		levels = append(levels, nextLevel)
		currentLevel = nextLevel
	}
	
	root = currentLevel[0]
	
	// Generate proofs for each wallet
	proofs = make(map[string][][]byte)
	for wallet, leafIdx := range walletToIndex {
		proof := make([][]byte, 0)
		idx := leafIdx
		
		// Traverse up the tree, collecting sibling hashes
		for level := 0; level < len(levels)-1; level++ {
			siblingIdx := idx ^ 1 // XOR to get sibling index
			if siblingIdx < len(levels[level]) {
				proof = append(proof, levels[level][siblingIdx])
			} else {
				// No sibling (odd number of nodes), use self
				proof = append(proof, levels[level][idx])
			}
			idx = idx / 2
		}
		
		proofs[wallet] = proof
	}
	
	return root, proofs, nil
}

// GenerateProof generates merkle proof for a specific wallet
func GenerateProof(roundID uint64, wallet string, amount int64, allLeaves []MerkleLeaf) ([]string, error) {
	_, proofs, err := BuildMerkleTree(allLeaves)
	if err != nil {
		return nil, err
	}
	
	proof, exists := proofs[wallet]
	if !exists {
		return nil, errors.New("wallet not found in leaves")
	}
	
	// Convert proof to hex strings
	proofStrs := make([]string, len(proof))
	for i, p := range proof {
		proofStrs[i] = common.BytesToHash(p).Hex()
	}
	
	return proofStrs, nil
}

