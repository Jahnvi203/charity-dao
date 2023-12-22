# Charity DAO: Fundraising and Voting Process Guide

This document explains the deployment and usage of `fundingOption.sol` and `donor.sol` to conduct a fundraising campaign within the Charity DAO.

## Stage 0: Campaign Deployment

1. **Deploy campaign.sol**
   - Parameters Required:
     - `_start`: UNIX timestamp for campaign start time (e.g., 1699182750)
     - `_campaignDuration`: duration of the campaign in block numbers (e.g., 10)
     - `_target`: monetary goal of the campaign in WEI (e.g., 20)
     - `_inKindInitiatives`: list of initiative names for in-kind donations (e.g., ["feedDogs"])
     - `_inCashInitiatives`: list of initiative names for cash donations (e.g., ["helpLife"])
     - `_votingDuration`: duration of the voting period in block numbers (e.g., 10)
   
2. **Deploy donor.sol**
   - Parameters Required:
     - `_campaignAddress`: smart contract (SC) address for the campaign
   **Note:** Avoid using the charity organization's wallet to deploy donor.sol

## Stage 1: Fundraising Starts

1. **Make Donations**
   - Enter donation amount under VALUE in the input box under DEPLOY & RUN TRANSACTIONS on the Remix environment.
   - Scroll down to DEPLOYED CONTRACTS and select the red "makePayment" button.
   - Successful invocation will show a green tick and a response in the logs indicating the donation received.

## Stage 2: Fundraising Ends and Voting Starts

- If fundraising ends due to the target being achieved or campaign end time, the voting process begins automatically.
- View potential initiatives to vote for using `getInitatives` and select a valid initiative name to vote for.

## Stage 3: Voting Ends and Vote Counting Begins

- Conditions for voting end: all donors voted or voting end time reached.
- Upon voting end, the counting of votes begins automatically.

## Stage 4: Distribution of Funds

- If the winning initiative is "in Cash":
  1. Charity organization inputs beneficiaries' wallet addresses.
  2. Click on the red "transferMoneyBeneficiaries" button to distribute funds evenly among the beneficiaries.

**Note:** All funds go directly from donors' wallets to the campaign's address and from the campaign's address to beneficiaries' wallets.
