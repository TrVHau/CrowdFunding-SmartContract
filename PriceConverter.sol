// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getEthPrice() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return uint256(price) * 1e8;
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getEthPrice(); // 36 decimals
        return (ethAmount * ethPrice) / 1e18;
    }
}
