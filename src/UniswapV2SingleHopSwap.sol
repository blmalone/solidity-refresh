// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IUniswapV2Router.sol";

contract UniswapV2SingleHopSwap {
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IUniswapV2Router private constant router = IUniswapV2Router(UNISWAP_V2_ROUTER);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin) external {
        /**
        * This only works because msg.sender (the test contract) approved the funds to be moved by this contract.
        * This happened in the unit test.
        */
        weth.transferFrom(msg.sender, address(this), amountIn);

        /**
        * Once the weth was transferred to this contract it can approve the router to move the funds on it's behalf.
        */
        weth.approve(address(router), amountIn);

        address[] memory paths = new address[](2);
        paths[0] = WETH;
        paths[1] = DAI;

        /**
        * This swap ensures that all the 'amountIn' is consumed if it can reach the minimum threshold of the 'amountOutMin'.
        */
        router.swapExactTokensForTokens(amountIn, amountOutMin, paths, msg.sender, block.timestamp);
    }

    function swapSingleHopExactAmountOut(uint256 amountOutDesired, uint256 amountInMax) external {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        address[] memory paths = new address[](2);
        paths[0] = WETH;
        paths[1] = DAI;
        uint256[] memory amounts =
            router.swapTokensForExactTokens(amountOutDesired, amountInMax, paths, msg.sender, block.timestamp);

        uint256 refundAmount = amountInMax - amounts[0];
        weth.transfer(msg.sender, refundAmount);
    }
}
