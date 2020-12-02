pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

library ProjectUtils {
    struct Milestone {
        bool completed;
        string description;
        uint deadline;
        uint percentageOfBudget;
    }
    
    function checkMilestonesValid(Milestone[] memory _milestones) public pure {
        require(_milestones.length > 0, "Milestones array empty.");
        uint totalPercentage = _milestones[0].percentageOfBudget;
        if(_milestones.length > 1){
            for (uint i = 1; i < _milestones.length; i++){
                require(_milestones[i-1].deadline < _milestones[i].deadline, "Milestones should be ordered (asc) by deadline.");
                totalPercentage += _milestones[i].percentageOfBudget;
            }
        }
        require(totalPercentage == 100, "Error in milestones budget distribution.");
    }
}
