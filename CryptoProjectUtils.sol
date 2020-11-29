pragma solidity ^0.7.0;

library CryptoProjectUtils {
    struct Milestone {
        bool completed;
        string description;
        uint deadline;
        uint percentageOfBudget;
    }
}
