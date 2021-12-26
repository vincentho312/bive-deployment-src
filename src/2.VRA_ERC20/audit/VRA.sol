// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./BizverseWorldERC20.sol";
import "./AllowanceWhitelistable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract VRA is BizverseWorldERC20, AllowanceWhitelistable, EIP712 {
    uint256 private _nonce;
    struct TransferPermission {
        address from;
        address to;
        uint256 amount;
        uint256 nonce;
        bytes signature;
    }

    constructor(
        uint256 initialSupply,
        string memory signingDomain,
        string memory signatureVersion
    )
        BizverseWorldERC20("VIRTUAL REALITY ASSET", "VRA")
        EIP712(signingDomain, signatureVersion)
    {
        _mint(_msgSender(), initialSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 4;
    }

    function approve(address spender, uint256 amount)
        public
        override
        whenInWhitelist(spender)
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function addContractToWhitelist(address target)
        public
        onlyOwner
        returns (bool)
    {
        _addContractToWhitelist(target);
        return true;
    }

    function removeContractFromWhitelist(address target)
        public
        onlyOwner
        returns (bool)
    {
        _removeContractFromWhitelist(target);
        return true;
    }

    function ownerBurn(uint256 amount) external onlyOwner returns (bool) {
        _burn(owner(), amount);
        return true;
    }

    function transferWithPermit(TransferPermission calldata permission)
        external
        returns (bool)
    {
        // get signer address from
        address signer = _verify(permission);

        require(signer == permission.from, "Invalid Signature");
        require(_nonce == permission.nonce, "Invalid nonce");
        _nonce++;
        _transfer(permission.from, permission.to, permission.amount);
        return true;
    }

    function nonce() external view returns (uint256) {
        return _nonce;
    }

    function chainId() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function _verify(TransferPermission calldata permission)
        internal
        view
        returns (address)
    {
        bytes32 digest = _hash(permission);
        return ECDSA.recover(digest, permission.signature);
    }

    function _hash(TransferPermission calldata permission)
        internal
        view
        returns (bytes32)
    {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "TransferPermission(address from,address to,uint256 amount,uint256 nonce)"
                        ),
                        permission.from,
                        permission.to,
                        permission.amount,
                        permission.nonce
                    )
                )
            );
    }
}
