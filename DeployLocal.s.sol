// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/SimpleWallet.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        SimpleWallet wallet = new SimpleWallet(); // 지갑 배포

        wallet.deployToken("Hunma", "HM", 18); // 지갑에서 토큰 생성

        uint256 tokenBalance = wallet.getTokenBalance(); // 생성된 잔액 출력
        console.log("Token balance in wallet:", tokenBalance);

        vm.stopBroadcast();
    }
}

