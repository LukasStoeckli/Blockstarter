pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {CryptoProjectUtils} from "./CryptoProjectUtils.sol";

contract CryptoProject {
    event EvAngelFunded(address project, address angel, uint amount);
    event EvProjectStarts(address project);
    event EvProjectResumes(address project);
    event EvProjectHalts(address project);
    event EvProjectCompleted(address project);
    
    uint public FUND_FACTOR_TO_BECOME_AN_ANGEL = 100;
    
    address payable public founder;
    string public name;
    string public description;
    uint public requestedBudget;
    uint public totalReceivedFunds;
    bool public projectStarted;
    bool public projectCompleted;
    
    using CryptoProjectUtils for CryptoProjectUtils.Milestone;
    CryptoProjectUtils.Milestone[] public milestones;
    
    mapping (address => bool) angels;
    mapping (address => uint) receivedFunds;
    
    uint public projectHalt;
    mapping (address => bool) angelRequestedHalt;
    
    
    constructor(string memory _name, string memory _description, uint _requestedBudget,
    address payable _founder, CryptoProjectUtils.Milestone[] memory _milestones) {
        name = _name;
        description = _description;
        requestedBudget = _requestedBudget;
        founder = _founder;
        
        if(_milestones.length > 1){
            uint totalPercentage = _milestones[0].percentageOfBudget;
            for (uint i = 1; i < _milestones.length; i++){
                require(_milestones[i-1].deadline < _milestones[i].deadline, "Milestones should be ordered (asc) by deadline.");
                totalPercentage += _milestones[i].percentageOfBudget;
            }
            require(totalPercentage == 100, "Error in milestones budget distribution.");
        }
        // Copying of type struct memory[] memory to storage not yet supported
        for (uint i = 1; i < _milestones.length; i++){
            milestones.push(_milestones[i]);
        }
    }
    
    modifier isFounder(){
        require(founder == msg.sender, "Only the founder can access this function.");
        _;
    }
    
    modifier isAngel(){
        require(angels[msg.sender], "Angel rank needed, to become an angel, one has to participate at least 1/FUND_FACTOR_TO_BECOME_AN_ANGEL of the total budget.");
        _;
    }
    
    modifier hasFunds(){
        require(receivedFunds[msg.sender] > 0, "You do not have any releseable funds left.");
        _;
    }
    
    modifier projectRunning(){
        require(projectStarted, "Project not started yet.");
        require(!isProjectHalted(), "Project halted.");
        require(!projectCompleted, "The project is already completed.");
        _;
    }
    
    function fundProject() public payable {
        require(!projectCompleted, "The project is already completed.");
        totalReceivedFunds += msg.value;
        receivedFunds[msg.sender] += msg.value;
        if(receivedFunds[msg.sender] * FUND_FACTOR_TO_BECOME_AN_ANGEL > requestedBudget){
            angels[msg.sender] = true;
            emit EvAngelFunded(address(this), msg.sender, msg.value);
        }
        if(!projectStarted && requestedBudget <= totalReceivedFunds){
            projectStarted = true;
            emit EvProjectStarts(address(this));
        }
    }
    
    function completeMilestone(uint _mid) public isFounder projectRunning {
        require(!milestones[_mid].completed, "Milestone already completed.");
        require(block.timestamp > milestones[_mid].deadline, "Milestone deadline not reached");
        uint transferAmount = requestedBudget * milestones[_mid].percentageOfBudget / 100;
        if(_mid == milestones.length - 1){
            //If it is the last milestone, transfer the full remaining amount.
            transferAmount = address(this).balance;
            emit EvProjectCompleted(address(this));
        }
        founder.transfer(transferAmount);
        milestones[_mid].completed = true;
        if(projectHalt > 0){
            updateHaltStatus(projectHalt * milestones[_mid].percentageOfBudget / 100, true);
        }
    }
    
    function releseableContributedFunds() public view hasFunds returns (uint) {
        uint rem = receivedFunds[msg.sender];
        if(!projectStarted){
            return rem;
        }
        uint totalPercentageBudgetDistributed = 0;
        for(uint i = 0; i < milestones.length; i++){
            if(milestones[i].completed){
                totalPercentageBudgetDistributed += milestones[i].percentageOfBudget;
            }
        }
        return rem - receivedFunds[msg.sender] * totalPercentageBudgetDistributed / 100;
    }
    
    function requestFundsBack() public hasFunds {
        uint rem = releseableContributedFunds();
        if(angelRequestedHalt[msg.sender]){
            angelRequestedHalt[msg.sender] = false;
            updateHaltStatus(rem, true);
        }
        msg.sender.transfer(rem);
        angels[msg.sender] = false;
        receivedFunds[msg.sender] = 0;
        totalReceivedFunds -= rem;
    }
    
    function isProjectHalted() public view returns (bool) {
        return projectHalt * 2 >= address(this).balance;
    }
    
    function updateHaltStatus(uint _rem, bool _sub) private {
        bool wasHalted = isProjectHalted();
        if(_sub){
            projectHalt -= _rem;
        } else {
            projectHalt += _rem;
        }
        bool isHalted = isProjectHalted();
        if(wasHalted && !isHalted){
            emit EvProjectResumes(address(this));
        } else if(!wasHalted && isHalted){
            emit EvProjectHalts(address(this));
        }
    }
    
    function requestHaltProject() public isAngel {
        require(!angelRequestedHalt[msg.sender], "Angel already requested to halt the project.");
        uint rem = releseableContributedFunds();
        angelRequestedHalt[msg.sender] = true;
        updateHaltStatus(rem, false);
    }
    
}
