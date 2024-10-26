// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { MockV3Aggregator } from "../mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    uint256 timesMintCalled;
    address[] userWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;


    constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
        dsce = _engine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weht)));
    }

    function depositCollateral(uint256 collateral, uint256 amountCollateral) public {
    amountCollateral = bound(amouontCollateral, 1, MAX_DEPOSIT_SIZE);
    ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

     // mint and approve!
    vm.startPrank(msg.sender);
    collateral.mint(msg.sender, amountCollateral);
    collateral.approve(address(engine), amountCollateral);

    dsce.depositCollateral(address(collateral), amountCollateral);
    vm.stopPrank();

    userWithCollateral.push(msg.sender);
}

// Helper Functions
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock){
        if(collateralSeed % 2 == 0){
        return weth;
        }
        return wbtc;
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);

    amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
    if(amountCollateral == 0){
        return;
    }

    dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    function mintDsc(uint256 amount) public {

        if(userWithCollateralDeposited.length == 0){
            return;
        }

    address sender = userWithCollateralDeposited[addressSeed % userWithCollateralDeposited.length];
    (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(msg.sender);

    uint256 maxDscToMint = (collateralValueInUsd / 2) - totalDscMinted;
    if(maxDscToMint < 0){
        return;
    }

    amount = bound(amount, 0, maxDscToMint);
    if(amount < 0){
        return;
    }

    vm.startPrank(msg.sender);
    dcse.mintDsc(amount);
    vm.stopPrank();

    timesMintIsCalled++;
    }

    function updateCollateralPrice(uint96 newPrice) public {
        int256 newPriceInt = int256(uint256(newPrice));
        ethUsdPriceFeed.updateAnswer(newPriceInt);
    }
     

    // THIS BREAKS OUR INVARIANT TEST SUITE!!!
    // function updateCollateralPrice(uint96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }
    
    

}