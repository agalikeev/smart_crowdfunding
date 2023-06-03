//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./crowdfunding1.sol";
//import { onlyOrganizer } from "./crowdfunding.sol";

contract Campaign1 {
    uint public deadline;
    uint public goal;
    uint public pledged;
    uint public id;
    address public organizer;
    CampaignStarter1 parent;
    bool withdrawn;
    mapping(address => uint) pledges;

    event Pledged(uint amount, address pledger);

    constructor(uint _deadline, uint _goal, address _organizer, uint _id) {
        deadline = _deadline;
        goal = _goal;
        organizer = _organizer;
        parent = CampaignStarter1(msg.sender);
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
        uint refundAmount = pledges[msg.sender];
        pledges[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function beforeDeadline() view external returns(uint){
        require(deadline > block.timestamp, "fundraising ended");
        return deadline - block.timestamp;
    }
}