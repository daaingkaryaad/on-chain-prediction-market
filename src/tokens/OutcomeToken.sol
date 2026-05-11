// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "../../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "../../lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {MarketTypes} from "../core/MarketTypes.sol";

/// @title OutcomeToken
/// @notice ERC1155 token representing YES and NO shares for prediction markets.
contract OutcomeToken is ERC1155, ERC1155Supply, AccessControl {
    error InvalidOutcome();
    error ZeroAddress();
    error ZeroAmount();

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address admin, string memory baseUri) ERC1155(baseUri) {
        if (admin == address(0)) revert ZeroAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    function tokenId(bytes32 marketId, MarketTypes.Outcome outcome) public pure returns (uint256) {
        if (outcome != MarketTypes.Outcome.Yes && outcome != MarketTypes.Outcome.No) {
            revert InvalidOutcome();
        }

        return uint256(keccak256(abi.encodePacked(marketId, outcome)));
    }

    function mint(address to, bytes32 marketId, MarketTypes.Outcome outcome, uint256 amount, bytes calldata data)
        external
        onlyRole(MINTER_ROLE)
    {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        _mint(to, tokenId(marketId, outcome), amount, data);
    }

    function burn(address from, bytes32 marketId, MarketTypes.Outcome outcome, uint256 amount) external {
        if (from == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        bool allowed = from == msg.sender || isApprovedForAll(from, msg.sender) || hasRole(MINTER_ROLE, msg.sender);
        if (!allowed) revert ERC1155MissingApprovalForAll(msg.sender, from);

        _burn(from, tokenId(marketId, outcome), amount);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
