Please read the following document to understand how to deploy and use campaign.sol and donor.sol to run a fundraising campaign. 
The process stops after voting has ended and funds are distributed to the beneficiaries. For this project, the follow-up process for in kind donation has not been created. 

Stage 0: 
    1. Deploy campaign.sol
        Parameters Needed:
            - uint256 _start: UNIX time stamp for start time of campaign (e.g., 1699182750)
            - uint256 _campaignDuration: duration of campaign in block numbers (e.g., 10)
            - uint256 _target: monetary goal of campaign in WEI (e.g., 20)
            - string[] memory _inKindInitiatives: list of initiative names for donation type = in kind (e.g., ["feedDogs"])
            - string[] memory _inCashInitiatives: list of initiative names for donation type = in cash (e.g., ["helpLife"])
            - uint256 _votingDuration: duration of voting period in block numbers (e.g., 10)

        To get UNIX time stamp, you may refer to this link: https://www.unixtimestamp.com/
    
    2. Deploy donor.sol
        Parameters Needed:
            - address payable _campaignAddress: smart contract (SC) address for campaign
        
    * Note: Please do not use the charity organisation's wallet to deploy donor.sol


Stage 1: Fundraising Starts
    1. [donor.sol] Enter donation amount under VALUE in the input box under DEPLOY & RUN TRANSACTIONS on left of the Remix environment
    2. [donor.sol] Scroll down to DEPLOYED CONTRACTS and select the red "makePayment" button
        - Upon successful invocation, you should see a green tick and an e.g, of the following response in logs:
            
        logs    {
                    "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                    "topic": "0x264f630d9efa0d07053a31163641d9fcc0adafc9d9e76f1c37c2ce3a558d2c52",
                    "event": "DonationReceived",
                    "args": {
                        "0": "0x66Eac190681e453738d985195A9BDA502D0a8180",
                        "1": "10",
                        "donor": "0x66Eac190681e453738d985195A9BDA502D0a8180",
                        "amount": "10"
                    }
                }
    *Note: Funds from donors' wallet go directly to campaigns' address.

Stage 2: Fundraising ends and Voting starts
    - Conditions for end of fundraising: target is achieved or campaign end time has reached (whichever earlier)
    *Note: If fundraising ends due to target being achieved, the voting process will automatically start. No action is needed from the charity organisation.
    *Note: If fundraising ends due to campaign end time being reached, in campaign.sol, Charity Organisation can click on the orange "openVoting" button to start the voting process.
    - The following logs should be seen in the console:
        logs    [
                    {
                        "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                        "topic": "0x9df44ba242c25e722b754c19fc2be96e07d2aa706a492f4bc34cd9d42c2e5057",
                        "event": "campaignStatus",
                        "args": {
                            "0": "End of Fundraising.",
                            "fundaraisingStage": "End of Fundraising."
                        }
                    },
                    {
                        "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                        "topic": "0x9df44ba242c25e722b754c19fc2be96e07d2aa706a492f4bc34cd9d42c2e5057",
                        "event": "campaignStatus",
                        "args": {
                            "0": "Start of Voting.",
                            "fundaraisingStage": "Start of Voting."
                        }
                    }
                ]
    1. [donor.sol] Click on getInitatives to view a list of potential initiatives to vote for. You should see this in the console:
        decoded output	{
                            "0": "string[]: inKind_test,inCash_test"
                        }
    2. [donor.sol] Enter a valid initiative name from the response in getInitatives.


Stage 3: Voting ends and Counting of Votes starts
    - Conditions for end of voting: all donors have voted or voting end time has reached (whichever earlier)
    *Note: When voting ends due to all donors voting, the counting of votes is called. No action is needed from the charity organisation.
    *Note: If fundraising ends due to voting end time being reached, in campaign.sol, Charity Organisation can click on the orange "openCountingVote" button to start the counting process.
    - In the console, you should see the following after voting has ended:
        logs	[
                    {
                        "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                        "topic": "0x9df44ba242c25e722b754c19fc2be96e07d2aa706a492f4bc34cd9d42c2e5057",
                        "event": "campaignStatus",
                        "args": {
                            "0": "Voting has ended.",
                            "fundaraisingStage": "Voting has ended."
                        }
                    },
                    {
                        "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                        "topic": "0x9df44ba242c25e722b754c19fc2be96e07d2aa706a492f4bc34cd9d42c2e5057",
                        "event": "campaignStatus",
                        "args": {
                            "0": "Votes are all accounted for.",
                            "fundaraisingStage": "Votes are all accounted for."
                        }
                    },
                    {
                        "from": "0x3F4581a49F2d6CB00260e94a29Bb18E13f0fA7df",
                        "topic": "0xda4961a3d9f679c355832e1abe2feb231109f7ecf94b6241b30163f2d8dad90c",
                        "event": "topInitiative",
                        "args": {
                            "0": "inKindtest",
                            "1": "10",
                            "topInitiative": "inKindtest",
                            "numVotes": "10"
                        }
                    }
                ]


Stage 4: If donation type of winning initiative is "in Cash"
    1.[campaign.sol] Charity organisation will have to input beneficiaries wallet address to transfer the funds.
        Parameters:
            - address[] _beneficiaryList: list of beneficiaries wallet address
            - int numBeneficiaries: number of beneficiaries
    *Note: Funds are assumed to be distributed evenly among all the beneficiaries and charity organisation cannot be a beneficiary.
    *Note: Validity of beneficiaries address are to be done outside of smart contract (prior to this stage).
    2.[campaign.sol] Campaign Organisation will have to click on the red "transferMoneyBeneficiaries" button. The following should be seen in the console:
        logs    [
                    {
                        "from": "0xc256f2Cd270f9296C4f6c42A07639e581a5A23E7",
                        "topic": "0x9df44ba242c25e722b754c19fc2be96e07d2aa706a492f4bc34cd9d42c2e5057",
                        "event": "campaignStatus",
                        "args": {
                            "0": "Funds are distributed to beneficiaries.",
                            "fundaraisingStage": "Funds are distributed to beneficiaries."
                        }
                    }
                ]

    *Note: Funds from campaigns' address go directly to beneficiaries' wallet.