// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 eth;
        uint256 timestamp;
    }

    Wave[] waves;

    /*
     * "address => uint mapping"は、アドレスと数値を関連付ける
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * 初期シードの設定
         */
        seed = (block.timestamp + block.difficulty) % 100;
        totalWaves = 1;
    }

    function sqrt(uint256 x) public pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function isPrime(uint256 n) public pure returns (bool) {
        if (n <= 1) {
            return false;
        }
        if (2 == n) {
            return true;
        }
        if (0 == n % 2) {
            return false;
        }
        uint256 _sqrt = sqrt(n);
        for (uint256 i = 3; i <= _sqrt; i += 2) {
            if (0 == n % i) {
                return false;
            }
        }
        return true;
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 3 seconds < block.timestamp,
            "Wait 3 secconds"
        );

        /*
         * ユーザーの現在のタイムスタンプを更新する
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        /*
         *  ユーザーのために乱数を設定
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 80 && isPrime(totalWaves)) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0004126 ether;
            waves.push(
                Wave(msg.sender, _message, prizeAmount, block.timestamp)
            );

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
            console.log("lose!");
            waves.push(Wave(msg.sender, _message, 0 ether, block.timestamp));
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}
