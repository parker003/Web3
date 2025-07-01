// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        address initialOwner
    ) ERC20(name, symbol, decimals) {
        // 지갑에게 발행
        _mint(initialOwner, 10 * 10 ** uint256(decimals));
    }
}

