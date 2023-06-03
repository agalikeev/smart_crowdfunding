//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./crowdfunding3.sol";


contract Campaign3 {
    uint public deadline;
    uint public goal;
    uint public pledged;
    uint public withdrawnPledged;
    uint public voteForWithdraw;
    uint public voteAgainstWithdraw;    
    uint public id;
    uint public withdrawValue;
    address public organizer;
    CampaignStarter3 parent;
    bool withdrawn;
    bool public offeredWithdraw;
    //enum offeredContinue{YES, NO, };
    mapping(address => uint) pledges;
    mapping(address => uint) votes;

    event Pledged(uint amount, address pledger);

    constructor(uint _deadline, uint _goal, address _organizer, uint _id) {
        deadline = _deadline;
        goal = _goal;
        organizer = _organizer;
        parent = CampaignStarter3(msg.sender);
        id = _id;
    }

    function pledge() external payable {
        require(block.timestamp <= deadline, "fundraising ended");
        require(msg.value > 0, "incorrect value");

        pledged += msg.value;
        pledges[msg.sender] += msg.value;

        emit Pledged(msg.value, msg.sender);
    }

    function withdraw() external {
        require(block.timestamp > deadline, "fundraising is not over yet");
        require(msg.sender == organizer, "you are not an organizer");
        require(pledged + withdrawnPledged >= goal, "goal was not achieved");
        require(!withdrawn, "funds have already been withdrawn");

        withdrawn = true;
        payable(organizer).transfer(pledged);
    }

    function fullRefund() external {
        require(block.timestamp > deadline, "fundraising is not over yet");
        require(pledged + withdrawnPledged < goal, "goal has been achieved");
        //require(offeredContinue == false, "voting for continue campaign is not over yet");

        uint refundAmount = pledges[msg.sender];
        pledges[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function doWithdrawValue(uint _withdrawvalue) external {
        require(msg.sender == organizer, "you are not an organizer");
        require(block.timestamp < deadline, "fundraising ended");
        require(pledged + withdrawnPledged>= goal, "goal was not achieved");
        offeredWithdraw = true;
        withdrawValue = _withdrawvalue;
    }

    function votingForWithdraw(bool _vote) external {
        require(offeredWithdraw == true, "voting has not started");
        require(pledges[msg.sender] > votes[msg.sender], "you have already voted");
        if (_vote == true){
            voteForWithdraw += (pledges[msg.sender] -votes[msg.sender]);
            votes[msg.sender] = pledges[msg.sender];
        }
        else{
            voteAgainstWithdraw += (pledges[msg.sender] -votes[msg.sender]);
            votes[msg.sender] = pledges[msg.sender];
        }
        if (voteForWithdraw >= pledged / 2){
            payable(organizer).transfer(withdrawValue);
            withdrawnPledged += withdrawValue;
            pledged -= withdrawValue;
            offeredWithdraw = false;
        }
        if (voteAgainstWithdraw >= pledged / 2){
            offeredWithdraw = false;            
        }
    }
}