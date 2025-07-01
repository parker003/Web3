// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/CreateToken.sol";
import "../src/SimpleWallet.sol";
import "../src/MultiSigWallet.sol";
import "../src/Vote.sol";

contract DeployAll is Script {
    function run() external {
        vm.startBroadcast();

        // 1. 토큰 배포 토큰 정보들은 유일해야함
        CreateToken token = new CreateToken("Hunma", "HM", 18);
        token.mint(msg.sender, 1_000_000 ether);

        // 2. 심플 지갑
        SimpleWallet wallet = new SimpleWallet();
        wallet.deployToken("Hunma", "HM", 18);

        // 3. 다중서명 + 서명 기반 투표 지갑
        address ;
        voters[0] = msg.sender;
        voters[1] = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        MultiSigWalletWithVoting multi = new MultiSigWalletWithVoting(voters, 2, address(token));

        // 4. 토큰 기반 투표 컨트랙트
        PoSVoting weighted = new PoSVoting(address(token));

        vm.stopBroadcast();
    }
}

