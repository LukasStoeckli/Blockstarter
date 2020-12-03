pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {ProjectUtils} from "./ProjectUtils.sol";
import "./ProjectWithMilestones.sol";

contract ProjectWithAngels is ProjectWithMilestones {
    event AngelFunded(address project, address angel, uint amount);
    event ProjectHalts(address project);
    event ProjectResumes(address project);
    
    uint public FUND_FACTOR_TO_BECOME_AN_ANGEL = 100;
    
    mapping (address => bool) angels;
    
    uint public projectHalt;
    mapping (address => bool) angelRequestedHalt;

    uint public haltedAt = 0;
    uint public delay = 0;
    
    
    constructor(string memory _name, string memory _description, uint _requestedBudget, address payable _founder,
    ProjectUtils.Milestone[] memory _milestones) ProjectWithMilestones(_name, _description, _requestedBudget, _founder, _milestones) {}
    
    modifier isAngel(){
        require(angels[msg.sender], "Angel rank needed, to become an angel, one has to participate at least 1/FUND_FACTOR_TO_BECOME_AN_ANGEL of the total budget.");
        _;
    }
    
    function isProjectRunning() internal override view {
        super.isProjectRunning();
        require(!isProjectHalted(), "Project halted.");
    }
    
    function fundProject() public override payable {
        super.fundProject();
        if(receivedFunds[msg.sender] * FUND_FACTOR_TO_BECOME_AN_ANGEL > requestedBudget){
            angels[msg.sender] = true;
            emit AngelFunded(address(this), msg.sender, msg.value);
        }
    }
    
    function completeMilestone(uint _mid) public override isFounder projectRunning {
        require(block.timestamp > milestones[_mid].deadline + delay, "Milestone deadline not reached");
        super.completeMilestone(_mid);
        if(projectHalt > 0){
            updateHaltStatus(projectHalt * milestones[_mid].percentageOfBudget / 100, true);
        }
    }
    
    function requestFundsBack() public override hasFunds {
        if(angelRequestedHalt[msg.sender]){
            angelRequestedHalt[msg.sender] = false;
            updateHaltStatus(releseableContributedFunds(), true);
            angels[msg.sender] = false;
        }
        super.requestFundsBack();
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
            delay += block.timestamp - haltedAt;
            emit ProjectResumes(address(this));
        } else if(!wasHalted && isHalted){
            haltedAt = block.timestamp;
            emit ProjectHalts(address(this));
        }
    }
    
    function requestHaltProject() public isAngel {
        require(!angelRequestedHalt[msg.sender], "Angel already requested to halt the project.");
        uint rem = releseableContributedFunds();
        angelRequestedHalt[msg.sender] = true;
        updateHaltStatus(rem, false);
    }
    
    function requestResumeProject() public isAngel {
        require(angelRequestedHalt[msg.sender], "Only if angel already requested project to halt can he requests project to resume.");
        uint rem = releseableContributedFunds();
        angelRequestedHalt[msg.sender] = false;
        updateHaltStatus(rem, true);
    }
    
}

