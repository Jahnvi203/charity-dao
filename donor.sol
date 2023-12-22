pragma solidity ^0.8.22;

import "./fundingOption.sol";

contract Donor {
    //PART 0: DEFINING  VARIABLES -----------------------------------------------------------------------------------------
    address payable public owner;
    Crowdfunding public campaign;
    address payable public campaignAddress;
    address payable public smartContractAdd;
    bool public voted;
    string [] public initiatives;
    uint256 public walletBalance; //to delete
    bool internal lockedFunds;

    constructor(address payable _campaignAddress) {
        owner = payable(msg.sender);
        voted = false;
        walletBalance = owner.balance;
        smartContractAdd = payable(address(this));
        campaignAddress = _campaignAddress;
        campaign = Crowdfunding(campaignAddress);
        lockedFunds = true;
    }

    //PART 1: DONATING TO CAMPAIGN -----------------------------------------------------------------------------------------
    event logInfo(string message);

    function makePayment() public payable returns(bool success, bytes memory data){
        
        // pre-requisites 
        require(owner.balance >= msg.value, "Insufficient balance."); // Check if the sender has enough balance
        require(msg.sender == owner, "Only wallet owner can donate.");
        require(lockedFunds);
        
        // lockedFunds to prevent re-entrancy attack by malicious actors
        lockedFunds = false;
        
        // transfer the amount to the recipient contract
        (success, data) = campaignAddress.call{value: msg.value}("");
        lockedFunds = true;
        return (success,data);
    }
    
    //PART 2: VOTING FOR INITIATIVES -----------------------------------------------------------------------------------------
    function getInitiatives() public returns(string [] memory){
        initiatives = campaign.initiativesToVote();
        return initiatives;
    }

    function isInitiativeValid( string memory _initative) public returns (bool) {
        getInitiatives();
        for (uint i = 0; i < initiatives.length; i++) {
            bytes32 initiativeInList = keccak256(abi.encodePacked(initiatives[i]));
            bytes32 enteredInitiative = keccak256(abi.encodePacked(_initative));
            if (initiativeInList == enteredInitiative){
                return true;
            }
        }
        return false;
    }

    function voteInitiative(string memory _initiative) public{
        require(!voted, "Donor has voted.");
        require(this.isInitiativeValid(_initiative),"Initiative does not exist");
        
        // vote for initiative to the recipient contract
        campaign.vote(_initiative);
        voted = true;
    }
}