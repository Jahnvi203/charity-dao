pragma solidity ^0.8.22;

import "./safeMath.sol";

contract Crowdfunding {

    //PART 0: DEFINING  VARIABLES -----------------------------------------------------------------------------------------
    address private charityOrg; //address of charity organisation who calls SC
    address public campaignAddress; //SC address
    uint256 private campaignStartTime; //UNIX Timestamp of start time for campaign
    uint256 private campaignDuration; //Block Numbers: to set duration of fundraising campaign
    uint256 private campaignEndTime; //UNIX Timestamp of end time for campaign
    uint256 private target; // monetary target of campaign 
    uint256 public totalAmountRaised; // total donated amount
    mapping(address => bool) private donorExists; // to get unique donors
    mapping(address => uint256) private donations; // to map donors => donationAmount
    mapping(string => uint256) private initiativeVotes; // to map initative => votes
    uint256 private neededVotes; //to see how many donors have yet to vote
    bool public votingStatus; // voting status
    string [] public initiatives; // to add donationType (in kind or in cash) to inputted initiative names 
    uint256 private votingDuration; // Block Numbers: to set duration of voting period 
    uint256 private votingEndTime; // UNIX Timestamp of end time for voting
    string public winningInitiative; // string which includes donationType (in kind or in cash) + initiative name

    constructor( uint256 _start, uint256 _campaignDuration, uint256 _target, string[] memory _inKindInitiatives, string[] memory _inCashInitiatives , uint256 _votingDuration) {
        //define variables
        charityOrg = msg.sender;
        campaignAddress = address(this);
        campaignStartTime = _start;
        campaignDuration = _campaignDuration;
        target = _target;
        votingStatus = false;
        votingDuration = _votingDuration;

        //calculate endTime of campaign 
        campaignEndTime = campaignStartTime + campaignDuration * 14; //time to mine a block is approximately 14s on ethereum

        //conmbine incash & inkind initiatives into variable initiative
        string memory inKind = "inKind_";
        for (uint256 i = 0; i < _inKindInitiatives.length; i++) {
            bytes memory concatenatedTerms = abi.encodePacked(inKind, _inKindInitiatives[i]);
            string memory initiativeWithCategory = string(concatenatedTerms);
            initiatives.push(initiativeWithCategory);
        } 

        string memory inCash = "inCash_";
        for (uint256 i = 0; i < _inCashInitiatives.length; i++) {
            bytes memory concatenatedTerms = abi.encodePacked(inCash, _inCashInitiatives[i]);
            string memory initiativeWithCategory = string(concatenatedTerms);
            initiatives.push(initiativeWithCategory);
        } 
    }
    // PART 1: FUNDRAISING STARTS ------------------------------------------------------------------------------------------
    // receive() function for SC to receive funds from donors' wallets
    receive() external payable fundraisingConditions {
        // calc totalAmountRaised
        uint256 donationAmount = msg.value;
        totalAmountRaised = SafeMath.add(donationAmount,totalAmountRaised);
        
        // add unique donor to number of voters
        if (!donorExists[msg.sender]){
            neededVotes +=1;
            donorExists[msg.sender] = true;
        }
        
        // add donation to an array
        donations[msg.sender] += donationAmount;
        emit DonationReceived(msg.sender, donationAmount);

        // if target is achieved
        if (totalAmountRaised >= target){
            emit campaignStatus("End of Fundraising.");
            votingStatus = true;
            emit campaignStatus("Start of Voting.");
            
            // calculate end time of voting
            votingEndTime = block.timestamp + votingDuration * 14;
            this.vote;
        }
    }
    
    event DonationReceived(address indexed donor, uint256 amount);
    event campaignStatus(string fundaraisingStage);

    modifier fundraisingConditions(){
        require(block.timestamp >= campaignStartTime, "Fundraising is not open.");
        require(block.timestamp < campaignEndTime, "Fundraising has ended.");
        require(totalAmountRaised < target, "Target for this fund has been achieved. Fundraising has ended.");
        require(msg.value > 0, "Donation amount must be greater than zero");
        require(msg.sender != charityOrg, "Charity Organisation cannot participate in fundraising campaign");
        _;
    }


    // PART 2: FUNDRAISING ENDS & VOTING STARTS -------------------------------------------------------------------------------
    function initiativesToVote() public view returns (string [] memory){
        return initiatives;
    }

    modifier votingConditions(){
        require(votingStatus == true, "Fundraising has not ended. Voting cannot open.");
        require(block.timestamp < votingEndTime, "Voting has ended.");
        require(donations[msg.sender] > 0, "Only donors can vote.");
        _;

        if (neededVotes == 0){
            votingStatus = false;
            emit campaignStatus("End of Voting.");
            emit campaignStatus("Start of Counting of Votes.");
            countVotes();
        }
    }

    function openVoting() public{
        require(block.timestamp > campaignEndTime, "Fundraising has not ended. Voting cannot open.");
        emit campaignStatus("End of Fundraising.");
        votingStatus = true;
        votingEndTime = block.timestamp + votingDuration * 14;
        emit campaignStatus("Start of Voting.");
    }

    function vote(string memory initiative) external votingConditions{
        initiativeVotes[initiative] = SafeMath.add(donations[msg.sender],initiativeVotes[initiative]);
        neededVotes -=1;
    }

    // PART 3: VOTING ENDS & COUNTING OF VOTES STARTS ------------------------------------------------------------------------------
    event topInitiative(string topInitiative, uint256 numVotes);

    modifier countingVotesConditions(){
        require(block.timestamp > votingEndTime || block.timestamp < campaignEndTime, "Voting is still in progress.");
        _;
    }

    function openCountingVotes() public{
        require(block.timestamp > votingEndTime, "Voting has not ended. Counting of votes process cannot start.");
        emit campaignStatus("End of Voting.");
        emit campaignStatus("Start of Counting of Votes.");
        this.countVotes();
    }

    function countVotes() public countingVotesConditions{
        //determining winningnInitiative
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < initiatives.length; i++) {
            if (initiativeVotes[initiatives[i]] > maxVotes) {
                maxVotes = initiativeVotes[initiatives[i]];
                winningInitiative = initiatives[i];
            }
        }
        // announcing initiaitive with highest votes
        emit campaignStatus("Votes are all accounted for.");
        emit topInitiative(winningInitiative,maxVotes);
    }

   // PART 4: DISTRIBUTING FUNDS TO BENEFICIARIES IF DONATION TYPE == IN CASH ---------------------------------------------------------
    function transferMoneyBeneficiaries(address payable [] memory  _beneficiaryList, uint256 numBeneficiaries) public payable {
        // pre-requisites
        require(_beneficiaryList.length == numBeneficiaries, "Number of beneficiaries to receive funds does not match number of wallet address received.");
        require(msg.sender == charityOrg, "Only Charity Organisation can count the votes.");
        
        // transfering the funds to the beneficiaries assuming funds are to be split equally
        uint256 amount = SafeMath.div(campaignAddress.balance, numBeneficiaries);
        for (uint256 i=0;i< numBeneficiaries; i++){
            require(_beneficiaryList[i] != charityOrg, "Charity Organisation cannot be a beneficiary.");
            _beneficiaryList[i].transfer(amount);
        }

        emit campaignStatus("Funds are distributed to beneficiaries.");
    }
}