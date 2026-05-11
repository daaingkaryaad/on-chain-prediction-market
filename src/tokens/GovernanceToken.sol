// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Nonces} from "../../lib/openzeppelin-contracts/contracts/utils/Nonces.sol";

/// @title GovernanceToken
/// @notice ERC20Votes + ERC20Permit governance token for protocol voting.
contract GovernanceToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    error ZeroAddress();
    error ZeroAmount();

    uint256 public constant MAX_SUPPLY = 100_000_000 ether;

    constructor(address initialOwner)
        ERC20("PredictX Governance Token", "PRED")
        ERC20Permit("PredictX Governance Token")
        Ownable(initialOwner)
    {
        if (initialOwner == address(0)) revert ZeroAddress();

        _mint(initialOwner, 1_000_000 ether);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (totalSupply() + amount > MAX_SUPPLY) revert ERC20ExceededCap(totalSupply() + amount, MAX_SUPPLY);

        _mint(to, amount);
    }

    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
