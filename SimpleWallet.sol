// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./CreateToken.sol";

contract SimpleWallet {
    address public owner;
    MyToken public token;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function deployToken(string memory name, string memory symbol, uint8 decimals) external {
        require(msg.sender == owner, "Not owner");

        // 여기서 자기 주소를 넘김 (지갑이 토큰 받음)
        token = new MyToken(name, symbol, decimals, address(this));
    }

    function sendEther(address payable to, uint256 amount) external {
    // 지갑에서 출금 혹은 송금에 대한 로직
    require(msg.sender == owner, "Not owner"); // 지갑의 주인만 출금/송금 가능
    require(address(this).balance >= amount, "Insufficient ETH balance"); // 내 자산이 출금/송금하려는 양과 같거나 작아야 함
    to.transfer(amount);
    }


    function sendToken(address to, uint256 amount) external {
    // 지갑에서 토큰 전송
    require(msg.sender == owner, "Not owner"); // 지갑의 주인만 전송 가능
    require(token.balanceOf(address(this)) >= amount, "Insufficient token balance"); // 내 토큰 보유량 보다 많은 양을 전송할 수 없음
    require(token.transfer(to, amount), "Token transfer failed"); 
    // 토큰을 전송할 때 에러가 발생하면 롤백하기 위한 로직 다음과 같은 로직이 없다면 토큰이 증발하거나 Fork같은 상태에 빠질 수 있음
    }


    function getEtherBalance() external view returns (uint256) {
    // 지갑 내의 ETH의 양을 조회하는 View
        return address(this).balance;
    }

    function getTokenBalance() external view returns (uint256) {
    // 지갑 내의 Token 양을 조회하는 View
        return token.balanceOf(address(this));
    }

    function getTokenAddress() external view returns (address) {
    // 이 지갑이 관리하는 토큰 컨트랙트의 주소 View
        return address(token);
    }
}

