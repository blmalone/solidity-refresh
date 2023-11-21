// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console2 as console} from "forge-std/Test.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IUniswapV3Pool} from "../src/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "../src/interfaces/INonfungiblePositionManager.sol";
import {UniswapV3Liquidity} from "../src/UniswapV3Liquidity.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant DAI_WETH_POOL = 0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8;
address constant MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

contract UniswapV3LiquidityTest is Test {
    UniswapV3Liquidity private liq;
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IUniswapV3Pool private constant pool = IUniswapV3Pool(DAI_WETH_POOL);
    INonfungiblePositionManager private constant manager = INonfungiblePositionManager(MANAGER);

    // Mint
    uint256 private constant WETH_AMOUNT = 1e18;
    uint256 private constant DAI_AMOUNT = 100 * 1e18;
    // Increase liquidity
    uint256 private constant WETH_INC_AMOUNT = 1e18;
    uint256 private constant DAI_INC_AMOUNT = 200 * 1e18;

    function setUp() public {
        liq = new UniswapV3Liquidity();

        weth.deposit{value: WETH_AMOUNT + WETH_INC_AMOUNT}();
        weth.approve(address(liq), type(uint256).max);

        deal(DAI, address(this), DAI_AMOUNT + DAI_INC_AMOUNT);
        dai.approve(address(liq), type(uint256).max);
    }

    function test_mint() public {
        uint128 l0 = pool.liquidity();
        uint256 tokenId = liq.mint(DAI_AMOUNT, WETH_AMOUNT);
        uint128 l1 = pool.liquidity();

        assertGt(l1, l0, "liquidity didn't increase");
        assertEq(manager.ownerOf(tokenId), address(liq), "not owner of token id");
        assertEq(weth.balanceOf(address(liq)), 0, "WETH balance != 0");
        assertEq(dai.balanceOf(address(liq)), 0, "DAI balance != 0");
        assertEq(weth.allowance(address(liq), MANAGER), 0, "WETH allowance != 0");
        assertEq(dai.allowance(address(liq), MANAGER), 0, "DAI allowance != 0");
    }

    function test_increaseLiquidity() public {
        uint256 tokenId = liq.mint(DAI_AMOUNT, WETH_AMOUNT);

        uint256 l0 = pool.liquidity();
        liq.increaseLiquidity(tokenId, DAI_INC_AMOUNT, WETH_INC_AMOUNT);
        uint256 l1 = pool.liquidity();

        assertGt(l1, l0, "liquidity didn't increase");
        assertEq(weth.balanceOf(address(liq)), 0, "WETH balance != 0");
        assertEq(dai.balanceOf(address(liq)), 0, "DAI balance != 0");
        assertEq(weth.allowance(address(liq), MANAGER), 0, "WETH allowance != 0");
        assertEq(dai.allowance(address(liq), MANAGER), 0, "DAI allowance != 0");
    }

    function test_decreaseLiquidity() public {
        uint256 tokenId = liq.mint(DAI_AMOUNT, WETH_AMOUNT);

        INonfungiblePositionManager.Position memory p0 = manager.positions(tokenId);
        liq.decreaseLiquidity(tokenId, p0.liquidity);
        INonfungiblePositionManager.Position memory p1 = manager.positions(tokenId);

        assertEq(p1.liquidity, 0, "liquidity != 0");
    }

    function test_collect() public {
        uint256 tokenId = liq.mint(DAI_AMOUNT, WETH_AMOUNT);
        INonfungiblePositionManager.Position memory p0 = manager.positions(tokenId);
        liq.decreaseLiquidity(tokenId, p0.liquidity);

        uint256 d0 = dai.balanceOf(address(this));
        uint256 w0 = weth.balanceOf(address(this));
        liq.collect(tokenId);
        uint256 d1 = dai.balanceOf(address(this));
        uint256 w1 = weth.balanceOf(address(this));

        assertGt(d1, d0, "DAI balance didn't increase");
        assertGt(w1, w0, "WETH balance didn't increase");
    }
}
