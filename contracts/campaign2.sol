//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./crowdfunding2.sol";


contract Campaign2 {
    uint public deadline;
    uint public goal;
    uint public pledged;
    uint public voteForContinue;
    uint public voteAgainstContinue;    
    uint public id;
    uint public extraTime;
    address public organizer;
    CampaignStarter2 parent;
    bool withdrawn;
    bool public  offeredContinue;
    //enum offeredContinue{YES, NO, };
    mapping(address => uint) pledges;
    mapping(address => uint) votes;

    event Pledged(uint amount, address pledger);

    constructor(uint _deadline, uint _goal, address _organizer, uint _id) {
        deadline = _deadline;
        goal = _goal;
        organizer = _organizer;
        parent = CampaignStarter2(msg.sender);
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
        require(pledged >= goal, "goal was not achieved");
        require(!withdrawn, "funds have already been withdrawn");

        withdrawn = true;
        payable(organizer).transfer(pledged);
    }

    function fullRefund() external {
        require(block.timestamp > deadline, "fundraising is not over yet");
        require(pledged < goal, "goal has been achieved");
        require(offeredContinue == false, "voting for continue campaign is not over yet");

        uint refundAmount = pledges[msg.sender];
        pledges[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function continueCampaign(uint _extraTime) external {
        require(msg.sender == organizer, "you are not an organizer");
        require(block.timestamp > deadline, "fundraising is not over yet");
        require(pledged > goal, "goal already achieved");
        offeredContinue = true;
        extraTime = _extraTime;
    }

    function votingForContinue(bool _vote) external {
        require(offeredContinue == true, "voting has not started");
        require(pledges[msg.sender] > votes[msg.sender], "you have already voted");
        if (_vote == true){
            voteForContinue += (pledges[msg.sender] -votes[msg.sender]);
            votes[msg.sender] = pledges[msg.sender];
        }
        else{
            voteAgainstContinue += (pledges[msg.sender] -votes[msg.sender]);
            votes[msg.sender] = pledges[msg.sender];
        }
        if (voteForContinue >= pledged / 2){
            deadline += extraTime;
            offeredContinue = false;
        }
        if (voteAgainstContinue >= pledged / 2){
            offeredContinue = false;            
        }
        
    }
}