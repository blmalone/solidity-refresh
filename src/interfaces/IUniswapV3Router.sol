// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }
}

interface IUniswapV3Router {
    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
    function exactOutputSingle(ISwapRouter.ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);
    function exactInput(ISwapRouter.ExactInputParams calldata params) external payable returns (uint256 amountOut);
    function exactOutput(ISwapRouter.ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
