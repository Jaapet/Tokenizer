# Token42 security notes

This document explains the security choices behind **Token42 (T42)**: who controls what, what can go wrong, and why the design keeps the risks small.

## Contents

1. [Summary](#1-summary)
2. [Ownership and privileges](#2-ownership-and-privileges)
3. [Supply](#3-supply)
4. [Code safety](#4-code-safety)
5. [Allowances](#5-allowances)
6. [Keys and wallets](#6-keys-and-wallets)
7. [Transparency](#7-transparency)
8. [Trade-offs and limits](#8-trade-offs-and-limits)

---

## 1. Summary

| Question | Answer |
| --- | --- |
| Who owns the contract? | Nobody. There is no owner and no admin role. |
| Can anyone create new tokens? | No. There is no `mint` function. The 1,000 T42 were created once, at deployment. |
| Can anyone freeze, pause or block transfers? | No. There is no `pause` or blacklist function. |
| Can anyone take someone else's tokens? | No. Tokens only move with their holder's transaction, or with an allowance the holder gave. |
| Can the code be changed after deployment? | No. The contract is not upgradeable: the deployed code is final. |
| What special power does the deployer have? | None. The deployer only received the initial 1,000 T42, like a normal holder. |

The idea: **the safest privilege is the one that does not exist.** An admin function can be abused, and an admin key can be stolen or lost. Token42 has neither.

## 2. Ownership and privileges

Many tokens inherit OpenZeppelin's `Ownable`, which gives one address (the "owner") special functions, such as minting new tokens or pausing transfers. Token42 deliberately does **not**:

- **No `Ownable`, no roles.** The contract only inherits `ERC20` and `ERC20Burnable` (see [`code/Token42.sol`](../code/Token42.sol)).
- **No `mint`.** The supply cannot grow, so nobody can create tokens out of thin air and dilute the holders.
- **No `pause`, no blacklist.** Nobody can stop the token or block a specific holder.

**Proof:** the contract's ABI ([`deployment/Token42.abi.json`](../deployment/Token42.abi.json)) lists every function the contract has. There are 11 of them, and none is an admin function:

| Function | Who can call it | What it can affect |
| --- | --- | --- |
| `name`, `symbol`, `decimals`, `totalSupply`, `balanceOf`, `allowance` | Anyone (read-only) | Nothing: they only read data |
| `transfer`, `approve`, `burn` | Any holder | Only the **caller's own** tokens |
| `transferFrom`, `burnFrom` | Only a spender with an allowance | Only tokens the holder **allowed** them to move, up to that amount |

Every function is available to every account under the same rules. The deployer is no exception.

## 3. Supply

- **1,000 T42** (`1000 * 10**18` units, because of the 18 decimals) were created once, in the `constructor`, and sent to the deployer. A constructor runs only once, at deployment, and can never be called again.
- The constant `INITIAL_SUPPLY_IN_WHOLE_TOKENS` is `private` and `constant`: it is written into the code at compile time and nothing can change it.
- After deployment, the only way the supply changes is `burn` / `burnFrom`, which **lower** it. So the total supply can only go down, never up.

## 4. Code safety

- **Audited library instead of hand-written code.** The token logic is OpenZeppelin's `ERC20` and `ERC20Burnable`, the most widely used and audited ERC-20 code. Our own code is only one constant and the constructor (a few lines). Less custom code means fewer chances for a bug.
- **Pinned versions.** The import paths fix OpenZeppelin to version `5.6.1`, and the pragma fixes the compiler to exactly `0.8.28` (`pragma solidity 0.8.28;`, without `^`). Every compile uses the same code, and the result matches the verified contract on BscScan.
- **Overflow protection.** Since Solidity 0.8, arithmetic that goes past the limits of a number (overflow or underflow) makes the transaction fail instead of silently wrapping around. For example, sending more tokens than you have cannot turn a balance into a huge number. No extra library (like the old `SafeMath`) is needed.
- **Clear errors.** OpenZeppelin 5 uses named errors (`ERC20InsufficientBalance`, `ERC20InsufficientAllowance`, …). A failed transaction says exactly why, and changes nothing.
- **Small attack surface.** The contract never sends tBNB and never calls other contracts, so classic attacks like reentrancy (a malicious contract calling back in the middle of a function) do not apply. It has no `payable` function, so it cannot receive tBNB by mistake.

## 5. Allowances

`approve` lets someone else (a "spender") move your tokens with `transferFrom` or `burnFrom`, up to a limit. It is standard and useful, but it has two known risks.

### 5.1 The approve race

Example: Alice allowed Bob 5 T42 and now wants to lower it to 3, so she calls `approve(Bob, 3)`.

- Transactions are public **before** they are included in a block. Bob can see Alice's change waiting, quickly send a `transferFrom` for the 5 T42 with a higher gas fee so it goes first, and then, once the new allowance is set, spend 3 T42 more.
- Bob ends up spending **8** T42 instead of 3 or 5.

**How to avoid it:** to change an allowance that is not zero, first `approve(spender, 0)`, check with `allowance` that it was not used in between, and then `approve(spender, newValue)`.

This is a property of the ERC-20 standard itself, not a bug of Token42. (OpenZeppelin 5 removed the old `increaseAllowance` / `decreaseAllowance` helpers, so this contract does not have them.)

### 5.2 Unlimited allowances

Some apps ask for an "unlimited" allowance (the maximum number, `2^256 - 1`). With OpenZeppelin, such an allowance is **never** used up. If that spender is malicious or gets hacked, it can take all your tokens, at any time.

**Good practice:** only approve what is needed, only to addresses you trust, and set allowances you no longer need back to `0`.

## 6. Keys and wallets

- **Your private key is your account.** Whoever has it (or the recovery phrase) controls the tokens. There is no "forgot password" on a blockchain.
- **Test-only account.** The deployer is a MetaMask account created only for this project. It never holds real money, and is used only on the testnet.
- **The key never leaves MetaMask.** Remix and BscScan only ask MetaMask to sign; they never see the key. Each transaction must be confirmed in MetaMask by hand.
- **Nothing secret in the repository.** No private key, recovery phrase, API key or `.env` file is committed. Everything in the repo is public on purpose: the code, the ABI and the addresses.

## 7. Transparency

- **The source code is verified on BscScan.** BscScan recompiled our source with the same settings and checked that it produces exactly the bytecode deployed on the chain ("Successfully generated matching Bytecode and ABI"). Anyone can read the code on the contract's **Contract** tab and be sure that it is what runs.
  https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4#code
- **Every action is public.** Every transfer, approval and burn is recorded on the blockchain, with its `Transfer` or `Approval` event, and visible on BscScan.
- **Reproducible.** The exact compiler settings are in [`deployment/compiler-settings.md`](../deployment/compiler-settings.md), so anyone can recompile and compare.

## 8. Trade-offs and limits

Having no admin is the simplest and safest design for this token, but it has a cost:

| Limit | Consequence | Why it is acceptable here |
| --- | --- | --- |
| No admin, no upgrade | If a mistake were found, it could not be fixed. We would have to deploy a new contract. | The code is small and audited, and this is a fixed-supply test token. Redeploying on the testnet is free. |
| Lost keys mean lost tokens | If a holder loses their key, their T42 are stuck forever. Nobody can recover them. | The contract keeps working for every other holder, because nobody needs to administer it. |
| Transactions cannot be undone | T42 sent to a wrong address (including the token contract's own address) are lost. Nobody can send them back. | This is how every blockchain token works. Double-check addresses before sending. |
| All supply starts with the deployer | At first, one account holds all 1,000 T42. | This only concerns who holds tokens, not powers: the deployer cannot do anything a normal holder cannot. The tokens can then be distributed with `transfer`. |
| Testnet only | T42 has no value, and the testnet could be reset by its operators. | The subject requires a test network: no real money is involved. |
