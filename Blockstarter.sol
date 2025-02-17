// SPDX-License-Identifier: NO_MORE_WARNINGS

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {ProjectUtils} from "./ProjectUtils.sol";
import "./ProjectWithAngels.sol";

contract Blockstarter {
    using ProjectUtils for ProjectUtils.Milestone;
    
    event NewProject(uint pid, string name, uint requestedBudget);
    
    ProjectWithAngels[] public projects;
    
    function createProject(string memory _name, string memory _description, uint _requestedBudget,
    address payable _founder, ProjectUtils.Milestone[] memory _milestones) public returns (uint id) {
        projects.push(new ProjectWithAngels(_name, _description, _requestedBudget, _founder, _milestones));
        emit NewProject(projects.length - 1, _name, _requestedBudget);
        return projects.length - 1;
    }

    function createProject(string memory _name, string memory _description, uint _requestedBudget,
    address payable _founder, string[] memory _descriptions, uint[] memory _deadlines, uint[] memory _percentages) public returns (uint id) {
        require(_descriptions.length == _deadlines.length, "Milestone arrays differ in length.");
        require(_descriptions.length == _percentages.length, "Milestone arrays differ in length.");
        uint len = _descriptions.length;
        ProjectUtils.Milestone[] memory milestones = new ProjectUtils.Milestone[](len);
        for (uint i = 0; i < len; i++) {
            milestones[i] = ProjectUtils.Milestone(false, _descriptions[i], _deadlines[i], _percentages[i]);
        }
        return createProject(_name, _description, _requestedBudget, _founder, milestones);
    }
    
    function defaultTestProject() public returns (uint id) {
        ProjectUtils.Milestone[] memory milestones = new ProjectUtils.Milestone[](3);
        milestones[0] = ProjectUtils.Milestone(false, "First milestone", block.timestamp + 3 minutes, 40);
        milestones[1] = ProjectUtils.Milestone(false, "Second milestone", block.timestamp + 6 minutes, 30);
        milestones[2] = ProjectUtils.Milestone(false, "Third milestone", block.timestamp + 9 minutes, 30);
        return createProject("The default project", "Test project description", 10 ether, msg.sender, milestones);
    }
}

