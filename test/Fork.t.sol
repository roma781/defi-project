// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external view returns (uint256[] memory amounts);
}

contract ForkTest is Test {
   
    address constant USDC         = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH         = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

   
    address constant USDC_WHALE   = 0x55FE002aefF02F77364de339a1292923A15844B8;

    uint256 mainnetFork;

    function setUp() public {
        string memory rpc = vm.envOr("MAINNET_RPC_URL", string(""));
        if (bytes(rpc).length == 0) {
            vm.skip(true);
            return;
        }
        mainnetFork = vm.createSelectFork(rpc);
    }

   

   function test_Fork_USDC_TotalSupply() public {
        uint256 supply = IERC20(USDC).totalSupply();
        // USDC supply is several billion (>20B at time of writing)
        assertGt(supply, 1_000_000e6, "USDC supply should be > 1M");
        console.log("USDC totalSupply:", supply);
    }

   
    function test_Fork_USDC_WhaleBalance() public {
        uint256 bal = IERC20(USDC).balanceOf(USDC_WHALE);
        console.log("Whale USDC balance:", bal);
        assertGt(bal, 0);
    }

    function test_Fork_UniswapV2_Swap_USDC_for_WETH() public {
        uint256 amountIn = 10_000e6; // 10,000 USDC

        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = WETH;

        uint256[] memory expected = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .getAmountsOut(amountIn, path);
        console.log("Expected WETH out:", expected[1]);

        vm.startPrank(USDC_WHALE);
        IERC20(USDC).approve(UNISWAP_V2_ROUTER, amountIn);
        uint256 wethBefore = IERC20(WETH).balanceOf(USDC_WHALE);

        uint256[] memory amounts = IUniswapV2Router02(UNISWAP_V2_ROUTER)
            .swapExactTokensForTokens(
                amountIn,
                0,           
                path,
                USDC_WHALE,
                block.timestamp + 300
            );
        vm.stopPrank();

        uint256 wethReceived = IERC20(WETH).balanceOf(USDC_WHALE) - wethBefore;
        console.log("WETH received:", wethReceived);

        assertGt(wethReceived, 0, "Should have received WETH");
        assertApproxEqRel(wethReceived, expected[1], 1e15); 
    }

    
    function test_Fork_RollFork_ChangesBlockNumber() public {
        uint256 currentBlock = block.number;
        vm.rollFork(currentBlock - 100);
        assertEq(block.number, currentBlock - 100);
        console.log("Rolled to block:", block.number);
    }
}
