// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts@5.6.1/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts@5.6.1/token/ERC20/extensions/ERC20Burnable.sol";

/// @title Token42 (T42)
/// @author ndesprez
/// @notice A simple BEP-20 token for the 42 Tokenizer project, deployed on BNB Smart Chain Testnet.
/// @dev Fixed supply: all 1,000 T42 are created once, in the constructor, and sent to the deployer.
///      There is no owner, no admin, no mint function and no pause: nobody has special powers
///      after deployment. Holders can destroy (burn) their own tokens, which lowers the total supply.

contract Token42 is ERC20, ERC20Burnable {
    /// @notice Number of whole tokens created at deployment (before applying decimals).
    uint256 private constant INITIAL_SUPPLY_IN_WHOLE_TOKENS = 1_000;

    /// @notice Creates the token and gives the full supply to the account that deploys it.
    constructor() ERC20("Token42", "T42") {
        _mint(msg.sender, INITIAL_SUPPLY_IN_WHOLE_TOKENS * 10 ** decimals());
    }
}
