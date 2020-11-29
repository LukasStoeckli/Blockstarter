pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {CryptoProjectUtils} from "./CryptoProjectUtils.sol";
import "./CryptoProject.sol";

contract CryptoProjectFactory {
    using CryptoProjectUtils for CryptoProjectUtils.Milestone;
    
    event NewCryptoProject(uint pid, string name, uint requestedBudget);
    
    CryptoProject[] public projects;
    
    function createProject(string memory _name, string memory _description, uint _requestedBudget,
    address payable _founder, CryptoProjectUtils.Milestone[] memory _milestones) public {
        projects.push(new CryptoProject(_name, _description, _requestedBudget, _founder, _milestones));
        emit NewCryptoProject(projects.length - 1, _name, _requestedBudget);
    }
    
    function defaultTestProject() public {
        CryptoProjectUtils.Milestone[] memory milestones = new CryptoProjectUtils.Milestone[](3);
        milestones[0] = CryptoProjectUtils.Milestone(false, "First milestone", block.timestamp + 1 days, 40);
        milestones[1] = CryptoProjectUtils.Milestone(false, "Second milestone", block.timestamp + 2 days, 30);
        milestones[2] = CryptoProjectUtils.Milestone(false, "Third milestone", block.timestamp + 3 days, 30);
        createProject("The default project", "Test project description", 10 ether, msg.sender, milestones);
    }
}
