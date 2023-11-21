// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IERC721Receiver.sol";
import "../src/interfaces/INonfungiblePositionManager.sol";

contract UniswapV3Liquidity is IERC721Receiver {
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant weth = IERC20(WETH);

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = -MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    INonfungiblePositionManager public manager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    event Mint(uint256 tokenId);

    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256, /* tokenId */
        bytes calldata /* data */
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function mint(uint256 amount0ToAdd, uint256 amount1ToAdd) external returns (uint256) {
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);
        dai.approve(address(manager), amount0ToAdd);
        weth.approve(address(manager), amount1ToAdd);

        int24 tickLower = (MIN_TICK / TICK_SPACING) * TICK_SPACING;
        int24 tickUpper = (MAX_TICK / TICK_SPACING) * TICK_SPACING;

        INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams(
            DAI, WETH, 3000, tickLower, tickUpper, amount0ToAdd, amount1ToAdd, 0, 0, address(this), block.timestamp
        );
        (uint256 tokenId, , uint256 amount0, uint256 amount1) = manager.mint(mintParams);
        uint256 daiRefundAmount = amount0ToAdd - amount0;
        uint256 wethRefundAmount = amount1ToAdd - amount1;

        if (daiRefundAmount > 0) {
            dai.transfer(msg.sender, daiRefundAmount);
        }
        if (wethRefundAmount > 0) {
            weth.transfer(msg.sender, wethRefundAmount);
        }

        dai.approve(address(manager), 0);
        weth.approve(address(manager), 0);

        emit Mint(tokenId);

        return tokenId;
    }

    function increaseLiquidity(uint256 tokenId, uint256 amount0ToAdd, uint256 amount1ToAdd) external {
        // Code
    }

    function decreaseLiquidity(uint256 tokenId, uint128 liquidity) external {
        // Code
    }

    function collect(uint256 tokenId) external {
        // Code
    }
}
