// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console2 as console} from "forge-std/Test.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {UniswapV2SingleHopSwap} from "../src/UniswapV2SingleHopSwap.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

contract UniswapV2SingleHopSwapTest is Test {
    UniswapV2SingleHopSwap private swap;
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    uint256 private constant AMOUNT_IN = 1e18;
    uint256 private constant AMOUNT_OUT = 3 * 1e18;
    uint256 private constant MAX_AMOUNT_IN = 1e18;

    function setUp() public {
        swap = new UniswapV2SingleHopSwap();
        weth.deposit{value: AMOUNT_IN + MAX_AMOUNT_IN}();
        weth.approve(address(swap), type(uint256).max);
    }

    function test_swapSingleHopExactAmountIn() public {
        swap.swapSingleHopExactAmountIn(AMOUNT_IN, 1);
        uint256 d1 = dai.balanceOf(address(this));
        assertGt(d1, 0, "DAI balance = 0");
    }

    // function test_swapSingleHopExactAmountOut() public {
    //     uint256 w0 = weth.balanceOf(address(this));
    //     uint256 d0 = dai.balanceOf(address(this));
    //     swap.swapSingleHopExactAmountOut(AMOUNT_OUT, MAX_AMOUNT_IN);
    //     uint256 w1 = weth.balanceOf(address(this));
    //     uint256 d1 = dai.balanceOf(address(this));

    //     assertLt(w1, w0, "WETH balance didn't decrease");
    //     assertGt(d1, d0, "DAI balance didn't increase");
    //     assertEq(weth.balanceOf(address(swap)), 0, "WETH balance of swap != 0");
    //     assertEq(dai.balanceOf(address(swap)), 0, "DAI balance of swap != 0");
    // }
}
