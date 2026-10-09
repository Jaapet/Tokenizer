# Token42 (T42) whitepaper

*Version 1.0, October 2026. Author: ndesprez (42 school, Tokenizer project).*

## Contents

1. [Abstract](#1-abstract)
2. [Background](#2-background)
3. [Token specification](#3-token-specification)
4. [How it works](#4-how-it-works)
5. [Token distribution](#5-token-distribution)
6. [Governance and security](#6-governance-and-security)
7. [Lifecycle](#7-lifecycle)
8. [Limitations and disclaimer](#8-limitations-and-disclaimer)

---

## 1. Abstract

**Token42 (T42)** is a BEP-20 token deployed on the **BNB Smart Chain Testnet**. It has a fixed initial supply of 1,000 tokens, all created once at deployment, and no owner or administrator: after deployment, nobody has special powers over it. Holders can send, approve, and burn (destroy) their tokens.

It was built for the 42 school **Tokenizer** project, to learn how a token is written, tested, deployed, and published on a public blockchain. It has no monetary value and is not for sale.

## 2. Background

This section explains the basic ideas behind the project, for readers new to blockchain.

**Blockchain.** A blockchain is a shared database copied on many computers around the world. Nobody controls it alone. New data is added in **blocks**, and once added, it cannot be changed or deleted. Anyone can read it.

**Account and wallet.** An account is identified by an **address** (like `0xb46c…7Aa51`) and controlled by a secret **private key**. A **wallet** such as MetaMask stores the key and uses it to sign transactions. Whoever has the key controls the account.

**Transaction and gas.** Any change to the blockchain (sending tokens, deploying a contract) is a **transaction**, signed by an account. The sender pays a small fee, called **gas**, in the chain's coin: BNB on BNB Smart Chain, and the free test coin **tBNB** on its testnet.

**Smart contract.** A smart contract is a program stored on the blockchain. Once deployed, its code cannot be changed, and it runs exactly as written for everyone. It has its own address. Token42 is a smart contract written in **Solidity**, the main language for this kind of chain.

**Token.** A token is a smart contract that keeps a list of **balances** (how many tokens each address holds) and lets holders move them. The token does not "live" in the wallets: the wallets only read the balances in the contract.

**BNB Smart Chain (BSC).** BSC is the blockchain of the BNB Chain ecosystem. It is compatible with Ethereum's virtual machine (the EVM), so Solidity contracts and tools like MetaMask and Remix work on it unchanged. Its **testnet** (chain id 97) is a copy for testing, where coins are free and worthless.

**BEP-20 and ERC-20.** For wallets and apps to handle any token the same way, tokens follow a **standard**: a fixed list of functions and events. On Ethereum, this standard is **ERC-20**. On BSC, it is **BEP-20**, which has the same interface: the [official BEP-20 specification](https://github.com/bnb-chain/BEPs/blob/master/BEPs/BEP20.md) requires the same 9 functions and 2 events as ERC-20. So an ERC-20 contract deployed on BSC is a BEP-20 token. Token42 implements all of them. (Some older BEP-20 tutorials add a `getOwner()` function; it is not part of the current specification, and Token42 has no owner.)

## 3. Token specification

| Property | Value |
| --- | --- |
| Name | Token42 |
| Ticker | T42 |
| Decimals | 18 (1 T42 = 10^18 units) |
| Initial supply | 1,000 T42 (`1000000000000000000000` units) |
| Maximum supply | 1,000 T42: no tokens can be created after deployment |
| Standard | BEP-20 (ERC-20 interface) + burn extension |
| Network | BNB Smart Chain Testnet, chain id `97` |
| Contract address | [`0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4`](https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4) |
| Source code | [`code/Token42.sol`](../code/Token42.sol), verified on BscScan |
| Language and compiler | Solidity `0.8.28` (exact), optimizer off |
| Library | OpenZeppelin Contracts `5.6.1`: `ERC20` and `ERC20Burnable` |
| License | MIT |
| Owner / admin | None |

**Why 18 decimals?** It is the standard value, used by BNB and most tokens. Wallets display it correctly without any setup.

**Why 1,000 tokens?** A small, round number that is easy to read and check during tests and the demo.

## 4. How it works

The contract stores two tables:

- **Balances**: for each address, how many T42 it holds.
- **Allowances**: for each pair (owner, spender), how many of the owner's T42 the spender may still move.

It offers five actions that change them:

| Action | Effect |
| --- | --- |
| `transfer(to, value)` | Moves `value` T42 from the caller to `to` |
| `approve(spender, value)` | Sets the caller's allowance for `spender` to `value` |
| `transferFrom(from, to, value)` | The caller (a spender) moves `value` T42 from `from` to `to`, and the allowance goes down |
| `burn(value)` | Destroys `value` of the caller's T42; the total supply goes down |
| `burnFrom(account, value)` | The caller (a spender) destroys `value` of `account`'s T42, using the allowance |

The six read functions (`name`, `symbol`, `decimals`, `totalSupply`, `balanceOf`, `allowance`) are free and change nothing.

Every action that does not respect the rules (not enough tokens, not enough allowance, sending to the zero address) fails as a whole, with a named error, and nothing changes. Every successful transfer or burn emits a **`Transfer`** event, and every approval an **`Approval`** event. Wallets and BscScan read these events to show the token's history.

Each action is a transaction, so the caller pays gas in tBNB (about 0.0001 tBNB per action).

A step-by-step guide for each action, with MetaMask and BscScan, is in [USAGE.md](USAGE.md).

## 5. Token distribution

- At deployment, on 2026-10-07, the **constructor** created all 1,000 T42 and sent them to the deployer account `0xb46c1FACb64e462D26a84e84602aE4e09197Aa51`.
- There is no sale, no mining, no reward, and no later creation of tokens. The deployer distributes T42 with ordinary transfers (for example, to a second account for the demo).
- The total supply can only **go down**, when holders burn tokens. The current supply can always be read with `totalSupply()` on BscScan.

## 6. Governance and security

Token42 has **no governance**: there is no owner, no admin, no vote, and no upgrade mechanism. The rules are fixed in the code and are the same for every holder, including the deployer.

This is a deliberate security choice: a privilege that does not exist cannot be abused, and an admin key that does not exist cannot be stolen. The token's logic comes from OpenZeppelin, an audited library, and the deployed code is verified on BscScan.

The full analysis (privileges, supply, allowance risks, keys, trade-offs) is in [SECURITY.md](SECURITY.md).

## 7. Lifecycle

| Date | Step |
| --- | --- |
| 2026-10-06 | Contract written ([`code/Token42.sol`](../code/Token42.sol)) and compiled in Remix IDE with no warnings |
| 2026-10-06 | Every action tested on the Remix VM, Remix's built-in test chain (see [USAGE.md, section 8](USAGE.md#8-manual-test-list)) |
| 2026-10-07 | Deployed on BSC Testnet from Remix and MetaMask, in block `135404847` ([transaction](https://testnet.bscscan.com/tx/0x6e22cd5f0a5258d217f13e72fe174fdca855a7b97975906975e9bb04846ea593)) |
| 2026-10-07 | Source code verified on BscScan ([Contract tab](https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4#code)) |

How to deploy and verify a copy is explained in [`deployment/DEPLOY.md`](../deployment/DEPLOY.md). Since the contract cannot be changed, any new version would be a new contract at a new address.

## 8. Limitations and disclaimer

- Token42 is an **educational** project. It exists only on a **test network**, has **no monetary value**, and is not an investment.
- The contract cannot be changed or stopped. Tokens sent to a wrong address, or held by a lost key, cannot be recovered.
- The testnet is run for developers and may be reset or changed by its operators.
- This document describes the contract deployed at `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4`. The deployed code, verified on BscScan, is the final reference.
