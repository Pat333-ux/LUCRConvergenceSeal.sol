// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LUCRConvergenceSeal {
    address public governance;

    struct CycleSeal {
        uint256 blockNum;
        uint256 timestamp;
        bytes32 convergenceHash;
        bytes32 sealHash;
    }

    mapping(uint256 => CycleSeal) public seals;

    event CycleSealed(
        uint256 indexed blockNum,
        bytes32 sealHash,
        uint256 timestamp
    );

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not governance");
        _;
    }

    constructor() {
        governance = msg.sender;
    }

    function seal(bytes32 convergenceHash) external onlyGovernance returns (bytes32) {
        bytes32 sealHash = keccak256(
            abi.encodePacked(
                convergenceHash,
                block.number,
                block.timestamp,
                blockhash(block.number - 1)
            )
        );

        seals[block.number] = CycleSeal({
            blockNum: block.number,
            timestamp: block.timestamp,
            convergenceHash: convergenceHash,
            sealHash: sealHash
        });

        emit CycleSealed(block.number, sealHash, block.timestamp);
        return sealHash;
    }
}
