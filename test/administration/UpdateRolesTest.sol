// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "../utils/BaseTest.t.sol";

contract UpdateRolesTest is BaseTest {
    function updateRoleCalls(address newAddress) public pure returns (bytes[] memory) {
        bytes[] memory selectors = new bytes[](3);
        selectors[0] = abi.encodeCall(ILTV.updateEmergencyDeleverager, (newAddress));
        selectors[1] = abi.encodeCall(ILTV.updateGovernor, (newAddress));
        selectors[2] = abi.encodeCall(ILTV.updateGuardian, (newAddress));
        return selectors;
    }

    function test_setAndCheckChangesAppliedBatch(DefaultTestData memory data, address newAddress) public {
        vm.assume(newAddress != address(0));
        vm.assume(newAddress != data.owner);
        vm.assume(newAddress != data.guardian);
        vm.assume(newAddress != data.governor);
        vm.assume(newAddress != data.emergencyDeleverager);
        vm.assume(newAddress != data.feeCollector);

        setAndCheckChangesAppliedEmergencyDeleverager(data, newAddress);
        setAndCheckChangesAppliedGovernor(data, newAddress);
        setAndCheckChangesAppliedGuardian(data, newAddress);
    }

    function setAndCheckChangesAppliedEmergencyDeleverager(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateEmergencyDeleverager(newAddress);
        vm.stopPrank();

        assertEq(ltv.emergencyDeleverager(), newAddress);
    }

    function setAndCheckChangesAppliedGovernor(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGovernor(newAddress);
        vm.stopPrank();

        assertEq(ltv.governor(), newAddress);
    }

    function setAndCheckChangesAppliedGuardian(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGuardian(newAddress);
        vm.stopPrank();

        assertEq(ltv.guardian(), newAddress);
    }

    function test_checkCanSetZeroAddressesBatch(DefaultTestData memory data) public {
        checkCanSetZeroAddressesEmergencyDeleverager(data);
        checkCanSetZeroAddressesGovernor(data);
        checkCanSetZeroAddressesGuardian(data);
    }

    function checkCanSetZeroAddressesEmergencyDeleverager(DefaultTestData memory data)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateEmergencyDeleverager(address(0));
        vm.stopPrank();

        assertEq(ltv.emergencyDeleverager(), address(0));
    }

    function checkCanSetZeroAddressesGovernor(DefaultTestData memory data)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGovernor(address(0));
        vm.stopPrank();

        assertEq(ltv.governor(), address(0));
    }

    function checkCanSetZeroAddressesGuardian(DefaultTestData memory data)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGuardian(address(0));
        vm.stopPrank();

        assertEq(ltv.guardian(), address(0));
    }

    function test_checkNewAdministratorCanExecuteItBatch(DefaultTestData memory data, address newAddress) public {
        vm.assume(newAddress != address(0));
        vm.assume(newAddress != data.owner);
        vm.assume(newAddress != data.guardian);
        vm.assume(newAddress != data.governor);
        vm.assume(newAddress != data.emergencyDeleverager);
        vm.assume(newAddress != data.feeCollector);

        checkNewEmergencyDeleveragerCanExecuteIt(data, newAddress);
        checkNewGovernorCanExecuteIt(data, newAddress);
        checkNewGuardianCanExecuteIt(data, newAddress);
    }

    function checkNewEmergencyDeleveragerCanExecuteIt(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateEmergencyDeleverager(newAddress);
        vm.stopPrank();

        uint256 realBorrowAssets = ltv.getRealBorrowAssets(false);
        deal(address(borrowToken), newAddress, realBorrowAssets);
        vm.startPrank(newAddress);
        borrowToken.approve(address(ltv), type(uint256).max);
        ltv.deleverageAndWithdraw(realBorrowAssets, 0);
        vm.stopPrank();
    }

    function checkNewGovernorCanExecuteIt(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGovernor(newAddress);
        vm.stopPrank();
        vm.startPrank(newAddress);
        ltv.setIsWhitelistActivated(false);
        vm.stopPrank();
    }

    function checkNewGuardianCanExecuteIt(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateGuardian(newAddress);
        vm.stopPrank();
        vm.startPrank(newAddress);
        ltv.setIsDepositDisabled(true);
        vm.stopPrank();
    }

    function test_checkOldAdministratorCantExecuteItAnymoreBatch(DefaultTestData memory data, address newAddress)
        public
    {
        vm.assume(newAddress != address(0));
        vm.assume(newAddress != data.owner);
        vm.assume(newAddress != data.guardian);
        vm.assume(newAddress != data.governor);
        vm.assume(newAddress != data.emergencyDeleverager);
        vm.assume(newAddress != data.feeCollector);

        checkOldEmergencyDeleveragerCantExecuteItAnymore(data, newAddress);
        checkOldGovernorCantExecuteItAnymore(data, newAddress);
        checkOldGuardianCantExecuteItAnymore(data, newAddress);
    }

    function checkOldEmergencyDeleveragerCantExecuteItAnymore(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        address oldEmergencyDeleverager = data.emergencyDeleverager;
        vm.startPrank(data.owner);
        ltv.updateEmergencyDeleverager(newAddress);
        vm.stopPrank();

        uint256 realBorrowAssets = ltv.getRealBorrowAssets(false);
        deal(address(borrowToken), oldEmergencyDeleverager, realBorrowAssets);
        vm.startPrank(oldEmergencyDeleverager);
        borrowToken.approve(address(ltv), type(uint256).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAdministrationErrors.OnlyEmergencyDeleveragerInvalidCaller.selector, oldEmergencyDeleverager
            )
        );
        ltv.deleverageAndWithdraw(realBorrowAssets, 0);
        vm.stopPrank();
    }

    function checkOldGovernorCantExecuteItAnymore(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        address oldGovernor = data.governor;
        vm.startPrank(data.owner);
        ltv.updateGovernor(newAddress);
        vm.stopPrank();
        vm.startPrank(oldGovernor);
        vm.expectRevert(abi.encodeWithSelector(IAdministrationErrors.OnlyGovernorInvalidCaller.selector, oldGovernor));
        ltv.setIsWhitelistActivated(false);
        vm.stopPrank();
    }

    function checkOldGuardianCantExecuteItAnymore(DefaultTestData memory data, address newAddress)
        internal
        testWithPredefinedDefaultValues(data)
    {
        address oldGuardian = data.guardian;
        vm.startPrank(data.owner);
        ltv.updateGuardian(newAddress);
        vm.stopPrank();
        vm.startPrank(oldGuardian);
        vm.expectRevert(abi.encodeWithSelector(IAdministrationErrors.OnlyGuardianInvalidCaller.selector, oldGuardian));
        ltv.setIsDepositDisabled(true);
        vm.stopPrank();
    }

    function test_failIfNotOwnerBatch(DefaultTestData memory data, address user) public {
        vm.assume(user != data.owner);
        vm.assume(user != address(0));

        failIfNotOwnerEmergencyDeleverager(data, user);
        failIfNotOwnerGovernor(data, user);
        failIfNotOwnerGuardian(data, user);
    }

    function failIfNotOwnerEmergencyDeleverager(DefaultTestData memory data, address user)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(user);
        vm.expectRevert();
        ltv.updateEmergencyDeleverager(makeAddr("newRole"));
        vm.stopPrank();
    }

    function failIfNotOwnerGovernor(DefaultTestData memory data, address user)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(user);
        vm.expectRevert();
        ltv.updateGovernor(makeAddr("newRole"));
        vm.stopPrank();
    }

    function failIfNotOwnerGuardian(DefaultTestData memory data, address user)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(user);
        vm.expectRevert();
        ltv.updateGuardian(makeAddr("newRole"));
        vm.stopPrank();
    }

    function test_checkSelfAssignmentBatch(DefaultTestData memory data) public {
        checkSelfAssignmentEmergencyDeleverager(data);
        checkSelfAssignmentGovernor(data);
        checkSelfAssignmentGuardian(data);
    }

    function checkSelfAssignmentEmergencyDeleverager(DefaultTestData memory data)
        internal
        testWithPredefinedDefaultValues(data)
    {
        vm.startPrank(data.owner);
        ltv.updateEmergencyDeleverager(data.emergencyDeleverager);
        assertEq(ltv.emergencyDeleverager(), data.emergencyDeleverager);
        vm.stopPrank();
    }

    function checkSelfAssignmentGovernor(DefaultTestData memory data) internal testWithPredefinedDefaultValues(data) {
        vm.startPrank(data.owner);
        ltv.updateGovernor(data.governor);
        assertEq(ltv.governor(), data.governor);
        vm.stopPrank();
    }

    function checkSelfAssignmentGuardian(DefaultTestData memory data) internal testWithPredefinedDefaultValues(data) {
        vm.startPrank(data.owner);
        ltv.updateGuardian(data.guardian);
        assertEq(ltv.guardian(), data.guardian);
        vm.stopPrank();
    }
}
