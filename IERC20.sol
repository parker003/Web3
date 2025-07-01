// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function name() external view returns (string memory); // Coin의 이름
    function symbol() external view returns (string memory); // Coin의 별명? 아무튼 이름은 아님
    function decimals() external view returns (uint8); // 1ETH를 10**decimals wei 로 표현 가능 (일반적으로 18)
    function totalSupply() external view returns (uint256); // 이제까지 발행된 총 토큰량
    function balanceOf(address account) external view returns (uint256); // 잔액을 가리킴 ETH, Token의 양을 반환함
    function transfer(address recipient, uint256 amount) // 송금
        external
        returns (bool);
    function allowance(address owner, address spender) // 위탁된 자금의 양을 확인
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool); // 자금 위탁?
    function transferFrom(address sender, address recipient, uint256 amount) // 위임받은 사람이 권한을 행사할 때
        external
        returns (bool);
}
