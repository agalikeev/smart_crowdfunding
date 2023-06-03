//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./campaign4.sol";


contract CampaignStarter4 {
    mapping(uint => address) public campaigns;
    uint private campaignId;
    address owner;

    event CampaignStarted4(uint id, uint deadline, uint goal, address organizer);

    function start(uint _goal, uint _deadline) external {
        require(_goal > 0, "incorrect goal");
        require(_deadline > 0, "incorrect deadline");
        campaignId = campaignId + 1;
        Campaign4 newCampaign = new Campaign4(block.timestamp+_deadline, _goal, msg.sender, campaignId);
        campaigns[campaignId] = address(newCampaign);
        emit CampaignStarted4(campaignId, block.timestamp+_deadline, _goal, msg.sender);
    }
}
