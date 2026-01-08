// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {PriceConverter} from "./PriceConverter.sol";

contract CrowFunding {
    using PriceConverter for uint256;
    /*ERRORS*/
    error NotOwner();
    error InsufficientAmount();

    /*CONSTANTS*/
    uint256 public constant MINIMUM_USD = 5e18; // 5 USD (18 decimals)

    /* VARIABLES*/
    address public immutable i_owner;

    mapping(address funder => bool isFunded) public isFunders;
    mapping(address funder => uint256 value) public fundedAmount;
    address[] public funders;

    event Funded(address indexed funder, uint256 value);
    event Withdraw(address indexed owner, uint256 value);

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
        fundedAmount[msg.sender] += msg.value;
        if (!isFunders[msg.sender]) {
            isFunders[msg.sender] = true;
            funders.push(msg.sender);
        }
        emit Funded(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "ETH_TRANSFER_FAILED");
        emit Withdraw(i_owner, address(this).balance);
    }

    function getFundersLength() public view returns (uint256) {
        return funders.length;
    }
}
