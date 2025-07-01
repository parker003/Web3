// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract PoSVoting {
    address public owner;
    IERC20 public token;
    uint256 public proposalCount;

    struct Proposal {
        uint256 id;
        string description;
        uint256 createdAt;
        uint256 yesVotes;
        uint256 noVotes;
    }

    mapping(uint256 => Proposal) public proposals; // 매핑으로 안건 등록
    mapping(uint256 => mapping(address => bool)) public hasVoted; // 중복 투표방지를 위한 매핑

    modifier onlyOwner() {
    // 배포자만 안건 제안 가능
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address tokenAddress) {
    // 투표권에 사용할 토큰을 지정
        owner = msg.sender;
        token = IERC20(tokenAddress);
    }

    function addProposal(string calldata description) external onlyOwner {
    // 안건 제안 기능 배포자만 가능
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            createdAt: block.timestamp,
            yesVotes: 0,
            noVotes: 0
        });
    }

    function vote(uint256 proposalId, bool support) external {
    //투표 기능 유권자(토큰 보유자)만 투표 가능
        Proposal storage prop = proposals[proposalId]; // 다음 안건을 불러옴
        require(prop.id != 0, "Proposal does not exist"); // 안건이 존재하는지 확인
        require(!hasVoted[proposalId][msg.sender], "Already voted"); // 중복 투표 방지

        uint256 votingPower = token.balanceOf(msg.sender); // 투표권 보유량이 영향력임
        require(votingPower > 0, "No voting power"); // votingPower = 0 이면 토큰이 없다는 의미 즉 유권자가 아님

        if (support) {
            prop.yesVotes += votingPower; // 찬성에 내 영향력을 더함
        } else {
            prop.noVotes += votingPower; // 반대에 내 영향력을 더함
        }

        hasVoted[proposalId][msg.sender] = true; // 매핑을 통해 중복투표 방지 설정
    }

    function getResult(uint256 proposalId) external view returns (string memory result) {
    // 투표 결과 조회
        Proposal storage prop = proposals[proposalId]; // 해당 인덱스의 안건을 불러옴
        require(prop.id != 0, "Proposal does not exist"); // 해당 안건이 존재하는지 확인
        require(block.timestamp >= prop.createdAt + 5 minutes, "Voting still ongoing"); 
        // 해당 안건의 TimeStamp가 5분을 넘지 않았다면 아직 투표중

        if (prop.yesVotes > prop.noVotes) {
        // 찬성이 더 많을 때 Passed
            result = "Passed";
        } else if (prop.noVotes > prop.yesVotes) {
        // 반대가 더 많을 때 Rejected
            result = "Rejected";
        } else {
        // 만에 하나 동일할 때 Tie
            result = "Tie";
        }
    }

    function getProposal(uint256 proposalId) external view returns (
    // 안건 확인용 View
        uint256 id,
        string memory description,
        uint256 createdAt,
        uint256 yesVotes,
        uint256 noVotes
    ) {
        Proposal storage p = proposals[proposalId];
        require(p.id != 0, "Proposal does not exist");

        return (
            p.id,
            p.description,
            p.createdAt,
            p.yesVotes,
            p.noVotes
        );
    }
}
