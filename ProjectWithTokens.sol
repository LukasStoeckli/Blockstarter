pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {ProjectUtils} from "./ProjectUtils.sol";
import "./ProjectWithAngels.sol";

contract ProjectWithTokens is ProjectWithAngels {
    uint256 constant private MAXUINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 totalSupply;
    uint8 public decimals;
    string public symbol;
    
    event Transfer(
        address indexed _from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    constructor(
        string memory _name,
        string memory _description,
        uint _requestedBudget,
        address payable _founder,
        ProjectUtils.Milestone[] memory _milestones,
        string memory tokenSymbol
    )
    ProjectWithAngels
    (
        _name,
        _description,
        _requestedBudget,
        _founder,
        _milestones
    ) {
        balances[msg.sender] = _requestedBudget;
        totalSupply = _requestedBudget;
        name = _name;
        decimals = 0;
        symbol = tokenSymbol;
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address _from, address to, uint256 value) public returns (bool success) {
        uint256 allowe = allowed[_from][msg.sender];
        require(balances[_from] >= value && allowe >= value);
        balances[_from] -= value;
        balances[to] += value;
        if (allowe < MAXUINT256) {
            allowed[_from][msg.sender] -= value;
        }
        emit Transfer(_from, to, value);
        return true;
    }
    
    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }
    
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256 remaining) {
        return allowed[owner][spender];
    }

    /*
    function fundProject() public override payable {
        super.fundProject();
        if (totalReceivedFunds < requestedBudget) {
            uint tokens = msg.value;
            uint maxTokens = requestedBudget - totalReceivedFunds;
            if (maxTokens < tokens) {
                tokens = maxTokens;
            }
            //balances[msg.sender] += tokens;
        }
        
    }
    */
}


