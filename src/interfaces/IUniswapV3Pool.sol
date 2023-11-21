// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IUniswapV3Pool {
    function liquidity() external returns (uint128 amount);
}
