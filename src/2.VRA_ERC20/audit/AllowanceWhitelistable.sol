// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

abstract contract AllowanceWhitelistable {
    using Address for address;

    mapping(address => bool) private _whitelistApprovals;

    event AddContractToWhitelist(address indexed target);
    event RemoveContractFromWhitelist(address indexed target);
    modifier whenInWhitelist(address target) {
        if (target.isContract())
            require(
                _whitelistApprovals[target],
                "AllowanceWhitelistable: Contract must be in whitelist for approvals"
            );
        _;
    }

    modifier whenNotInWhitelist(address target) {
        if (target.isContract())
            require(
                !_whitelistApprovals[target],
                "AllowanceWhitelistable: Contract must not be in whitelist for approvals"
            );
        _;
    }

    modifier onlyContract(address target) {
        require(
            target.isContract(),
            "AllowanceWhitelistable: Target is not a contract"
        );
        _;
    }

    function isWhitelisted(address target) public view returns (bool) {
        if (target.isContract()) return _whitelistApprovals[target];
        else return true;
    }

    function _addContractToWhitelist(address target)
        internal
        virtual
        onlyContract(target)
        whenNotInWhitelist(target)
    {
        _whitelistApprovals[target] = true;
    }

    function _removeContractFromWhitelist(address target)
        internal
        virtual
        onlyContract(target)
        whenInWhitelist(target)
    {
        _whitelistApprovals[target] = false;
    }
}
