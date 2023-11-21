// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IUniswapV3Router.sol";

// Swap WETH for USDC and then USDC for DAI.
contract UniswapV3MultiHopSwap {
    IUniswapV3Router private constant router = IUniswapV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapExactInputMultiHop(uint256 amountIn, uint256 amountOutMin) external {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        /**
         * So, in summary, the swap starts with a certain amount of WETH, swaps it for USDC in a pool with a 0.3% fee,
         * then swaps the USDC for DAI in a pool with a 0.05% fee (assuming that the uint24(100) was intended to be uint24(500)).
         * The swap is executed in the order that the addresses are listed in the path.
         */
        bytes memory path = abi.encodePacked(WETH, uint24(3000), USDC, uint24(100), DAI);

        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams(path, msg.sender, block.timestamp, amountIn, amountOutMin);
        router.exactInput(params);
    }

    function swapExactOutputMultiHop(uint256 amountOut, uint256 amountInMax) external {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        /**
         * The reason for the reversal in the path is that this is intended for an exact output swap.
         * For exact output swaps, the path is followed from end to start, meaning the swap is executed in reverse order.
         */
        bytes memory path = abi.encodePacked(DAI, uint24(100), USDC, uint24(3000), WETH); // Trade is done in the reverse order
        ISwapRouter.ExactOutputParams memory params =
            ISwapRouter.ExactOutputParams(path, msg.sender, block.timestamp, amountOut, amountInMax);
        uint256 amountIn = router.exactOutput(params);

        uint256 refundAmount = amountInMax - amountIn;
        weth.transfer(msg.sender, refundAmount);
        weth.approve(address(router), 0);
    }
}
