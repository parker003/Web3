// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract MultiSigWalletWithVoting {
    address public owner;

    struct Proposal {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 createdAt;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals; // 안건
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 중복 투표 방지
    mapping(address => bool) public isVoter; // 유권자인지 확인

    event ProposalCreated(uint256 id, address to, uint256 value); // 안건 생성 이벤트
    event Voted(uint256 id, address voter, bool support); // 투표 이벤트
    event Executed(uint256 id); // 투표 결과에 따른 실행
    event Received(address from, uint256 amount); // 

    modifier onlyOwner() {
    // 오너만 안건 제안 가능
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address[] memory voters) {
        owner = msg.sender;
        for (uint i = 0; i < voters.length; i++) {
            isVoter[voters[i]] = true;
        }
    }

    
    function createProposal(uint256 id, address to, uint256 value, bytes calldata data) external onlyOwner {
        require(proposals[id].id == 0, "Proposal already exists"); // 안건 id 중복 방지

        proposals[id] = Proposal({
            id: id,
            to: to,
            value: value,
            data: data,
            yesVotes: 0,
            noVotes: 0,
            createdAt: block.timestamp,
            executed: false
        }); // 안건 생성

        emit ProposalCreated(id, to, value);
    }

    function voteWithSignature(uint256 id, bool support, bytes calldata signature) external {
    // 서명 기반 투표
        Proposal storage p = proposals[id]; // 안건 불러오기
        require(p.id != 0, "No such proposal"); // 존재하는 안건인지 확인

        bytes32 digest = keccak256(abi.encodePacked(id, p.to, p.value, p.data)); // 32바이트의 다이제스트 생성
        address signer = recover(digest, signature); // 서명 생성을 통해 유권자 확인 가능

        require(isVoter[signer], "Not voter"); // 유권자 확인
        require(!hasVoted[id][signer], "Already voted"); // 중복 투표 방지

        if (support) {
            p.yesVotes++; // 찬성
        } else {
            p.noVotes++; // 반대
        }

        hasVoted[id][signer] = true; // 안간에 투표했다는 매핑 중복 투표 방지
        emit Voted(id, signer, support);
    }

    function executeProposal(uint256 id) external {
    // 투표 종료 후 결과에 따른 실행
        Proposal storage p = proposals[id]; // 안건 불러오기
        require(p.id != 0, "No such proposal"); // 안건 존재여부 확인
        require(!p.executed, "Already executed"); // 안건이 실행되었는지 확인
        require(block.timestamp >= p.createdAt + 5 minutes, "Too early"); // 투표가 끝났는지 확인
        require(p.yesVotes > p.noVotes, "Not enough support"); // 안건이 통과 되었을 때만 실행

        p.executed = true; // 플래그 설정을 통해 중복 실행 방지

        (bool success, ) = p.to.call{value: p.value}(p.data); // 안건 실행
        require(success, "Execution failed"); // 실패 시 revert

        emit Executed(id);
    }

    function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
    // 서명한 사람이 유권자인지 확인
        require(sig.length == 65, "Invalid signature length"); // 시그니처의 길이
        bytes32 r; bytes32 s; uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return ecrecover(toEthSignedMessageHash(hash), v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    //서명자가 오프체인에서 서명하였기 때문에 스마트 컨트랙트에서 검증하기 위해 반드시 같은 방식으로 해싱해야 함
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getEthBalance() external view returns (uint256) {
    // 지갑의 ETH 양 View
        return address(this).balance;
    }

    function getTokenBalance(address token) external view returns (uint256) {
    // 지갑의 Token 양 View
        return IERC20(token).balanceOf(address(this));
    }

    receive() external payable {
    //ETH 거래를 하기 위함
        emit Received(msg.sender, msg.value);
    }
}
