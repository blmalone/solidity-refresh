// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IUniswapV3Router.sol";

contract UniswapV3SingleHopSwap {
    IUniswapV3Router private constant router = IUniswapV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapExactInputSingleHop(uint256 amountIn, uint256 amountOutMin) external {
        // swap weth for max amount of dai
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams(WETH, DAI, 3000, msg.sender, block.timestamp, amountIn, amountOutMin, 0);

        /**
         * This swap ensures that all the 'amountIn' is consumed if it can reach the minimum threshold of the 'amountOutMin'.
         */
        router.exactInputSingle(params);
    }

    function swapExactOutputSingleHop(uint256 amountOut, uint256 amountInMax) external {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams(WETH, DAI, 3000, msg.sender, block.timestamp, amountOut, amountInMax, 0);

        uint256 amountIn = router.exactOutputSingle(params);

        uint256 refundAmount = amountInMax - amountIn;
        weth.transfer(msg.sender, refundAmount);
        weth.approve(address(router), 0);
    }
}
