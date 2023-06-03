//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./campaign3.sol";


contract CampaignStarter3 {
    mapping(uint => address) public campaigns;
    uint private campaignId;
    address owner;

    event CampaignStarted3(uint id, uint deadline, uint goal, address organizer);

    function start(uint _goal, uint _deadline) external {
        require(_goal > 0, "incorrect goal");
        require(_deadline > 0, "incorrect deadline");
        campaignId = campaignId + 1;
        Campaign3 newCampaign = new Campaign3(block.timestamp+_deadline, _goal, msg.sender, campaignId);
        campaigns[campaignId] = address(newCampaign);
        emit CampaignStarted3(campaignId, block.timestamp+_deadline, _goal, msg.sender);
    }
}
