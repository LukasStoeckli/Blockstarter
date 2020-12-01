pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

abstract contract A_CryptoProjectBase {
    event EvProjectStarts(address project);
    event EvProjectCompleted(address project);
    
    address payable public founder;
    string public name;
    string public description;
    uint public requestedBudget;
    uint public totalReceivedFunds;
    bool public projectStarted;
    bool public projectCompleted;
    
    mapping (address => uint) receivedFunds;
    
    
    constructor(string memory _name, string memory _description, uint _requestedBudget, address payable _founder) {
        name = _name;
        description = _description;
        requestedBudget = _requestedBudget;
        founder = _founder;
    }
    
    modifier isFounder(){
        require(founder == msg.sender, "Only the founder can access this function.");
        _;
    }
    
    modifier hasFunds(){
        require(receivedFunds[msg.sender] > 0, "You do not have any releseable funds left.");
        _;
    }
    
    modifier projectRunning(){
        isProjectRunning();
        _;
    }
    
    function isProjectRunning() internal virtual view {
        require(projectStarted, "Project not started yet.");
        require(!projectCompleted, "The project is already completed.");
    }
    
    function fundProject() public virtual payable {
        require(!projectCompleted, "The project is already completed.");
        totalReceivedFunds += msg.value;
        receivedFunds[msg.sender] += msg.value;
        if(!projectStarted && requestedBudget <= totalReceivedFunds){
            projectStarted = true;
            emit EvProjectStarts(address(this));
        }
    }
    
    function releseableContributedFunds() public virtual returns (uint);
    
    function requestFundsBack() public virtual hasFunds {
        uint rem = releseableContributedFunds();
        msg.sender.transfer(rem);
        receivedFunds[msg.sender] = 0;
        totalReceivedFunds -= rem;
    }
    
    function completeProject() internal isFounder {
        projectCompleted = true;
        emit EvProjectCompleted(address(this));
    }
    
}

