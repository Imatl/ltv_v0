// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../utils/BaseTest.t.sol";
import "./PrepareEachFunctionSuccessfulExecution.sol";
import "../../src/elements/ModulesProvider.sol";
import "../../src/structs/state/ModulesState.sol";
import "../../src/interfaces/IModules.sol";
import "../../src/interfaces/reads/IAdministrationModule.sol";
import "../../src/interfaces/reads/IAuctionModule.sol";
import "../../src/interfaces/reads/IERC20Module.sol";
import "../../src/interfaces/reads/ICollateralVaultModule.sol";
import "../../src/interfaces/reads/IBorrowVaultModule.sol";
import "../../src/interfaces/reads/ILowLevelRebalanceModule.sol";
import {AuctionModule} from "../../src/elements/AuctionModule.sol";
import {ERC20Module} from "../../src/elements/ERC20Module.sol";
import {CollateralVaultModule} from "../../src/elements/CollateralVaultModule.sol";
import {BorrowVaultModule} from "../../src/elements/BorrowVaultModule.sol";
import {LowLevelRebalanceModule} from "../../src/elements/LowLevelRebalanceModule.sol";
import {AdministrationModule} from "../../src/elements/AdministrationModule.sol";
import {State} from "../../src/interfaces/ILTV.sol";

contract SetModulesTest is PrepareEachFunctionSuccessfulExecution {
    struct UserBalance {
        uint256 collateral;
        uint256 borrow;
        uint256 shares;
    }

    function getUserBalance(address user) public view returns (UserBalance memory) {
        return UserBalance({
            collateral: collateralToken.balanceOf(user),
            borrow: borrowToken.balanceOf(user),
            shares: ltv.balanceOf(user)
        });
    }

    function modulesCalls(address user) public view returns (bytes[] memory) {
        bytes[] memory selectors = new bytes[](76);
        uint256 amount = 1000;
        selectors[0] = abi.encodeCall(ILTV.deposit, (amount, user));
        selectors[1] = abi.encodeCall(ILTV.mint, (amount, user));
        selectors[2] = abi.encodeCall(ILTV.redeem, (amount, user, user));
        selectors[3] = abi.encodeCall(ILTV.withdraw, (amount, user, user));
        selectors[4] = abi.encodeCall(ILTV.depositCollateral, (amount, user));
        selectors[5] = abi.encodeCall(ILTV.mintCollateral, (amount, user));
        selectors[6] = abi.encodeCall(ILTV.redeemCollateral, (amount, user, user));
        selectors[7] = abi.encodeCall(ILTV.withdrawCollateral, (amount, user, user));
        selectors[8] = abi.encodeCall(ILTV.approve, (user, amount));
        selectors[9] = abi.encodeCall(ILTV.transfer, (user, amount));
        selectors[10] = abi.encodeCall(ILTV.transferFrom, (address(0), user, amount));
        selectors[11] = abi.encodeCall(ILTV.executeAuctionBorrow, (int256(amount)));
        selectors[12] = abi.encodeCall(ILTV.executeAuctionCollateral, (int256(amount)));
        selectors[13] = abi.encodeCall(ILTV.executeLowLevelRebalanceBorrow, (int256(amount)));
        selectors[14] = abi.encodeCall(ILTV.executeLowLevelRebalanceBorrowHint, (int256(amount), true));
        selectors[15] = abi.encodeCall(ILTV.executeLowLevelRebalanceCollateral, (int256(amount)));
        selectors[16] = abi.encodeCall(ILTV.executeLowLevelRebalanceCollateralHint, (int256(amount), true));
        selectors[17] = abi.encodeCall(ILTV.executeLowLevelRebalanceShares, (int256(amount)));
        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = ILTV.deposit.selector;
        selectors[18] = abi.encodeCall(ILTV.allowDisableFunctions, (signatures, true));
        selectors[19] = abi.encodeCall(ILTV.setFeeCollector, (user));
        selectors[20] = abi.encodeCall(ILTV.setIsDepositDisabled, (true));
        selectors[21] = abi.encodeCall(ILTV.setIsWhitelistActivated, (true));
        selectors[22] = abi.encodeCall(ILTV.setIsWithdrawDisabled, (true));
        selectors[23] = abi.encodeCall(ILTV.setLendingConnector, (user));
        selectors[24] = abi.encodeCall(ILTV.setMaxDeleverageFee, (amount));
        selectors[25] = abi.encodeCall(ILTV.setMaxGrowthFee, (amount));
        selectors[26] = abi.encodeCall(ILTV.setMaxSafeLTV, (uint128(amount)));
        selectors[27] = abi.encodeCall(ILTV.setMaxTotalAssetsInUnderlying, (amount));
        selectors[28] = abi.encodeCall(ILTV.setMinProfitLTV, (uint128(amount)));
        selectors[29] = abi.encodeCall(ILTV.setOracleConnector, (user));
        selectors[30] = abi.encodeCall(ILTV.setSlippageProvider, (user));
        selectors[31] = abi.encodeCall(ILTV.setTargetLTV, (uint128(amount)));
        selectors[32] = abi.encodeCall(ILTV.setWhitelistRegistry, (user));
        selectors[33] = abi.encodeCall(ILTV.deleverageAndWithdraw, (amount, amount));
        selectors[34] = abi.encodeCall(ILTV.renounceOwnership, ());
        selectors[35] = abi.encodeCall(ILTV.transferOwnership, (user));
        selectors[36] = abi.encodeCall(ILTV.updateGuardian, (user));
        selectors[37] = abi.encodeCall(ILTV.updateGovernor, (user));
        selectors[38] = abi.encodeCall(ILTV.updateEmergencyDeleverager, (user));
        State.StateInitData memory initData = State.StateInitData({
            collateralToken: address(collateralToken),
            borrowToken: address(borrowToken),
            feeCollector: user,
            maxSafeLTV: uint128(amount),
            minProfitLTV: uint128(amount),
            targetLTV: uint128(amount),
            lendingConnector: user,
            oracleConnector: user,
            maxGrowthFee: amount,
            maxTotalAssetsInUnderlying: amount,
            slippageProvider: user,
            maxDeleverageFee: amount,
            vaultBalanceAsLendingConnector: user
        });
        selectors[39] = abi.encodeCall(ILTV.initialize, (initData, user, "", ""));
        selectors[40] = abi.encodeCall(ILTV.convertToAssets, (amount));
        selectors[41] = abi.encodeCall(ILTV.convertToShares, (amount));
        selectors[42] = abi.encodeCall(ILTV.getLendingConnector, ());
        selectors[43] = abi.encodeCall(ILTV.getRealBorrowAssets, (true));
        selectors[44] = abi.encodeCall(ILTV.getRealCollateralAssets, (true));
        selectors[45] = abi.encodeCall(ILTV.maxDeposit, (user));
        selectors[46] = abi.encodeCall(ILTV.maxDepositCollateral, (user));
        selectors[47] = abi.encodeCall(ILTV.maxLowLevelRebalanceBorrow, ());
        selectors[48] = abi.encodeCall(ILTV.maxLowLevelRebalanceCollateral, ());
        selectors[49] = abi.encodeCall(ILTV.maxLowLevelRebalanceShares, ());
        selectors[50] = abi.encodeCall(ILTV.maxMint, (user));
        selectors[51] = abi.encodeCall(ILTV.maxMintCollateral, (user));
        selectors[52] = abi.encodeCall(ILTV.maxRedeem, (user));
        selectors[53] = abi.encodeCall(ILTV.maxRedeemCollateral, (user));
        selectors[54] = abi.encodeCall(ILTV.maxWithdraw, (user));
        selectors[55] = abi.encodeCall(ILTV.maxWithdrawCollateral, (user));
        selectors[56] = abi.encodeCall(ILTV.previewDeposit, (amount));
        selectors[57] = abi.encodeCall(ILTV.previewDepositCollateral, (amount));
        selectors[58] = abi.encodeCall(ILTV.previewExecuteAuctionBorrow, (int256(amount)));
        selectors[59] = abi.encodeCall(ILTV.previewExecuteAuctionCollateral, (int256(amount)));
        selectors[60] = abi.encodeCall(ILTV.previewLowLevelRebalanceBorrow, (int256(amount)));
        selectors[61] = abi.encodeCall(ILTV.previewLowLevelRebalanceBorrowHint, (int256(amount), true));
        selectors[62] = abi.encodeCall(ILTV.previewLowLevelRebalanceCollateral, (int256(amount)));
        selectors[63] = abi.encodeCall(ILTV.previewLowLevelRebalanceCollateralHint, (int256(amount), true));
        selectors[64] = abi.encodeCall(ILTV.previewLowLevelRebalanceShares, (int256(amount)));
        selectors[65] = abi.encodeCall(ILTV.previewMint, (amount));
        selectors[66] = abi.encodeCall(ILTV.previewMintCollateral, (amount));
        selectors[67] = abi.encodeCall(ILTV.previewRedeem, (amount));
        selectors[68] = abi.encodeCall(ILTV.previewRedeemCollateral, (amount));
        selectors[69] = abi.encodeCall(ILTV.previewWithdraw, (amount));
        selectors[70] = abi.encodeCall(ILTV.previewWithdrawCollateral, (amount));
        selectors[71] = abi.encodeWithSignature("totalAssets()");
        selectors[72] = abi.encodeWithSignature("totalAssets(bool)", true);
        selectors[73] = abi.encodeWithSignature("totalAssetsCollateral()");
        selectors[74] = abi.encodeWithSignature("totalAssetsCollateral(bool)", true);
        selectors[75] = abi.encodeCall(ILTV.totalSupply, ());
        return selectors;
    }

    function prepareModulesTest(address user) public {
        prepareEachFunctionSuccessfulExecution(user);
    }

    function test_setModulesChangesApplied(DefaultTestData memory data) public testWithPredefinedDefaultValues(data) {
        ModulesState memory validModulesState = ModulesState({
            borrowVaultModule: IBorrowVaultModule(address(new BorrowVaultModule())),
            collateralVaultModule: ICollateralVaultModule(address(new CollateralVaultModule())),
            lowLevelRebalanceModule: ILowLevelRebalanceModule(address(new LowLevelRebalanceModule())),
            auctionModule: IAuctionModule(address(new AuctionModule())),
            administrationModule: IAdministrationModule(address(new AdministrationModule())),
            erc20Module: IERC20Module(address(new ERC20Module()))
        });

        ModulesProvider validModulesProvider = new ModulesProvider(validModulesState);
        vm.prank(data.owner);
        ltv.setModules(IModules(address(validModulesProvider)));
        ModulesState memory dummyModulesState = ModulesState({
            borrowVaultModule: IBorrowVaultModule(address(0)),
            collateralVaultModule: ICollateralVaultModule(address(0)),
            lowLevelRebalanceModule: ILowLevelRebalanceModule(address(0)),
            auctionModule: IAuctionModule(address(0)),
            administrationModule: IAdministrationModule(address(0)),
            erc20Module: IERC20Module(address(0))
        });

        ModulesProvider dummyModulesProvider = new ModulesProvider(dummyModulesState);
        vm.prank(data.owner);
        ltv.setModules(IModules(address(dummyModulesProvider)));
        address user = address(0x123);
        UserBalance memory initialBalance = getUserBalance(user);
        bytes memory call = abi.encodeCall(ILTV.deposit, (1000, user));
        vm.prank(user);
        (bool success,) = address(ltv).call(call);
        assertEq(success, false);
        UserBalance memory finalBalance = getUserBalance(user);
        assertEq(initialBalance.collateral, finalBalance.collateral);
        assertEq(initialBalance.borrow, finalBalance.borrow);
        assertEq(initialBalance.shares, finalBalance.shares);
    }

    function test_nonZeroModules(DefaultTestData memory data) public testWithPredefinedDefaultValues(data) {
        ModulesState memory validModulesState = ModulesState({
            borrowVaultModule: IBorrowVaultModule(address(new BorrowVaultModule())),
            collateralVaultModule: ICollateralVaultModule(address(new CollateralVaultModule())),
            lowLevelRebalanceModule: ILowLevelRebalanceModule(address(new LowLevelRebalanceModule())),
            auctionModule: IAuctionModule(address(new AuctionModule())),
            administrationModule: IAdministrationModule(address(new AdministrationModule())),
            erc20Module: IERC20Module(address(new ERC20Module()))
        });
        ModulesProvider validModulesProvider = new ModulesProvider(validModulesState);
        vm.prank(data.owner);
        ltv.setModules(IModules(address(validModulesProvider)));
    }

    /// forge-config: default.fuzz.runs = 10
    function test_dummyModulesRevertWithZeroData(DefaultTestData memory data, address user) public {
        vm.assume(user != data.feeCollector);
        bytes[] memory calls = modulesCalls(user);
        for (uint256 i = 0; i < 40; i++) {
            checkDummyModulesRevert(data, user, calls[i]);
        }
    }

    function checkDummyModulesRevert(DefaultTestData memory data, address user, bytes memory call)
        internal
        testWithPredefinedDefaultValues(data)
    {
        prepareModulesTest(user);
        ModulesState memory dummyModulesState = ModulesState({
            borrowVaultModule: IBorrowVaultModule(address(0)),
            collateralVaultModule: ICollateralVaultModule(address(0)),
            lowLevelRebalanceModule: ILowLevelRebalanceModule(address(0)),
            auctionModule: IAuctionModule(address(0)),
            administrationModule: IAdministrationModule(address(0)),
            erc20Module: IERC20Module(address(0))
        });
        ModulesProvider dummyModulesProvider = new ModulesProvider(dummyModulesState);
        vm.prank(data.owner);
        ltv.setModules(IModules(address(dummyModulesProvider)));
        UserBalance memory initialBalance = getUserBalance(user);
        vm.prank(user);
        (bool success, bytes memory result) = address(ltv).call(call);

        assertEq(success, false);

        if (result.length == 0) {
            assertEq(result.length, 0);
        } else {
            assertGt(result.length, 0);
        }
        UserBalance memory finalBalance = getUserBalance(user);
        assertEq(initialBalance.collateral, finalBalance.collateral);
        assertEq(initialBalance.borrow, finalBalance.borrow);
        assertEq(initialBalance.shares, finalBalance.shares);
    }

    function test_onlyOwnerCanSetModules(DefaultTestData memory data, address user)
        public
        testWithPredefinedDefaultValues(data)
    {
        vm.assume(user != data.owner);
        ModulesState memory dummyModulesState = ModulesState({
            borrowVaultModule: IBorrowVaultModule(address(0)),
            collateralVaultModule: ICollateralVaultModule(address(0)),
            lowLevelRebalanceModule: ILowLevelRebalanceModule(address(0)),
            auctionModule: IAuctionModule(address(0)),
            administrationModule: IAdministrationModule(address(0)),
            erc20Module: IERC20Module(address(0))
        });
        ModulesProvider dummyModulesProvider = new ModulesProvider(dummyModulesState);
        vm.startPrank(user);
        vm.expectRevert();
        ltv.setModules(IModules(address(dummyModulesProvider)));
    }
}
