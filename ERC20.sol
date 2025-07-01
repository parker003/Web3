// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
    // 불변 값들을 Constructor에서 초기화
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address recipient, uint256 amount) //송금
        external
        returns (bool)
    {
        balanceOf[msg.sender] -= amount; //보내는 양 만큼 요청자에게서 -
        balanceOf[recipient] += amount; //송신자에게 받은 양 만큼 +
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) { //위탁
    // 처음에는 위탁을 조회만 하고 실제 실행이 안되는 것이 아닌가 생각함
    // 하지만 위에서 mapping(address => mapping(address => uint256)) public allowance; 를 통해 2차원 매핑
    // allowance[Alice][Bob] = 100; 다음 정보를 통해 위탁을 받았는지 체크할 뿐 아니라 allowance도 참조하는 정보가 됨
    // approve는 허락만 해줌 실제 송금이나 권한 행사는 transferForm에서 수행

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) //실제 위임받은 사람이 권한을 행사
        external
        returns (bool)
    {
        //Alice가 Shop에게 50을 송금했지만 정작 이 트랜잭션의 호출자는 Bob인셈
        allowance[sender][msg.sender] -= amount; // 위탁 권한 차감
        balanceOf[sender] -= amount; // 실제 계좌에서도 차감
        balanceOf[recipient] += amount; // 목적 계좌에 +
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal { 
    // 로직과 권한 검증을 분리하여 다른 로직에서 _mint를 참조할때는 권한 검증 없이 빠르게 처리
    // internal로 선언될 시 후킹 X , Delegate Call X 따라서 이 로직 자체에서 문제가 생기지는 않음
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
    // 권한 검증만 맡게 되는 mint에서 문제가 생기거나 _mint를 불러오는 다른 로직에서 문제가 생긴다면 _mint도 같이 죽음
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
