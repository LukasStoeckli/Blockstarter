// SPDX-License-Identifier: NO_MORE_WARNINGS

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {ProjectUtils} from "./ProjectUtils.sol";
import "./ProjectBase.sol";

contract ProjectWithMilestones is ProjectBase {
    
    using ProjectUtils for ProjectUtils.Milestone;
    ProjectUtils.Milestone[] public milestones;
    
    
    constructor(string memory _name, string memory _description, uint _requestedBudget, address payable _founder,
    ProjectUtils.Milestone[] memory _milestones) ProjectBase(_name, _description, _requestedBudget, _founder) {
        ProjectUtils.checkMilestonesValid(_milestones);
        // Copying of type struct memory[] memory to storage not yet supported
        for (uint i = 0; i < _milestones.length; i++){
            milestones.push(_milestones[i]);
        }
    }
    
    function completeMilestone(uint _mid) public virtual isFounder projectRunning {
        require(!milestones[_mid].completed, "Milestone already completed.");
        require(block.timestamp > milestones[_mid].deadline, "Milestone deadline not reached");
        uint transferAmount = requestedBudget * milestones[_mid].percentageOfBudget / 100;
        if(_mid == milestones.length - 1){
            //If it is the last milestone, transfer the full remaining amount.
            transferAmount = address(this).balance;
            completeProject();
        }
        founder.transfer(transferAmount);
        milestones[_mid].completed = true;
    }
    
    function releseableContributedFunds() override public view hasFunds returns (uint) {
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
    
}

