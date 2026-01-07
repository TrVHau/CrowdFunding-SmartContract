// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {PriceConverter} from "./PriceConverter.sol";
contract CrowdFunding {
    using PriceConverter for uint256;
    /*ERRORS*/
    error NotOwner();
    error InsufficientAmount();

    /*CONSTANTS*/
    uint256 public constant MINIMUM_USD = 5e18; // 5 USD (18 decimals)

    /* VARIABLES*/
    address public immutable i_owner;

    mapping(address => uint256) public fundedAmount;

    /*CONSTRUCTOR*/
    constructor() {
        i_owner = msg.sender;
    }

    /*RECEIVE / FALLBACK*/
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /*MODIFIERS*/
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    /*FUNCTIONS*/
    function fund() public payable {
        if (msg.value.getConversionRate() < MINIMUM_USD)
            revert InsufficientAmount();
    }

    function withdraw() external onlyOwner {
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "ETH_TRANSFER_FAILED");
    }
}
