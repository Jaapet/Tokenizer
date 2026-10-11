# MultiSig42: the T42 treasury (bonus)

**MultiSig42** is a second contract that holds a **treasury of T42** and only moves it when **both of its two signers agree**. This guide explains what it is, why it is built this way, and how to use it on BscScan.

It does not change Token42 at all: the token stays a plain BEP-20 token, and the multisig is simply a holder of T42 with stricter rules.

## Contents

1. [Facts](#1-facts)
2. [What is a multisig?](#2-what-is-a-multisig)
3. [How it is adapted to Token42](#3-how-it-is-adapted-to-token42)
4. [How a transfer works](#4-how-a-transfer-works)
5. [What the contract can do](#5-what-the-contract-can-do)
6. [Step-by-step on BscScan](#6-step-by-step-on-bscscan)
7. [Errors](#7-errors)
8. [Security and trade-offs](#8-security-and-trade-offs)
9. [Tests](#9-tests)

---

## 1. Facts

| Property | Value |
| --- | --- |
| Contract | `MultiSig42` ([code/MultiSig42.sol](../code/MultiSig42.sol)) |
| Network | BNB Smart Chain **Testnet**, chain id `97` |
| Contract address | `0x79546751f76080964DD1FcA717190d530D5b9840` |
| Contract on BscScan | https://testnet.bscscan.com/address/0x79546751f76080964DD1FcA717190d530D5b9840 |
| Verified source code | https://testnet.bscscan.com/address/0x79546751f76080964DD1FcA717190d530D5b9840#code |
| Token it holds | Token42 (T42), `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4` |
| Signer 1 | [Account 1] `0xb46c1FACb64e462D26a84e84602aE4e09197Aa51` (the token deployer) |
| Signer 2 | [Account 2] `0xbB7128213Ba52fa0AD3042BF7009033C714140a8` |
| Confirmations required | **2 of 2** (both signers) |
| Treasury | 100 T42 sent in at the start (10% of the initial supply) |
| Deployment | [`0x891a9209…15e18b`](https://testnet.bscscan.com/tx/0x891a920946350c26970acd93b10cb22f3d09d3775f2706eac9fd155b8f15e18b), block `136166799`, 2026-10-11 12:33:57 UTC |

All deployment details are also in [`deployment/deployed.json`](../deployment/deployed.json).

## 2. What is a multisig?

A normal account (like a MetaMask account) is controlled by **one** private key: whoever has that key can move all the funds, alone.

A **multisig** ("multi-signature") wallet is a **smart contract** that holds funds and only moves them when **several** chosen people agree. It is like a safe with two locks and two keyholders: it only opens when both turn their key.

- **One stolen key is not enough** to take the funds: the thief would still need the other signer.
- **No single person can act alone**, by mistake or on purpose.

Here, "signing" means sending a transaction to the multisig from a signer's account: MetaMask signs it with that account's key, and the contract records who agreed.

## 3. How it is adapted to Token42

The subject asks to adapt the multisig to the token. MultiSig42 is built **only for T42**:

- Its constructor takes the **Token42 address**, and it can only ever move T42 (it calls the token's standard `transfer`).
- It holds the **project treasury**: 100 T42, sent to it by [Account 1] like a normal transfer.
- It follows the **same "no admin" design** as Token42: no owner, the two signers and the threshold are fixed at deployment and can never be changed.

A proposal is therefore just "send this amount of T42 to this address", which keeps the BscScan fields simple (an address and an amount).

**Why not a multisig inside Token42 itself?** BEP-20 says a holder calls `transfer` once and the tokens move. Requiring several signatures for every T42 transfer would break the standard (and every wallet). Instead, the multisig protects one specific holding, the treasury, and Token42 stays standard.

## 4. How a transfer works

Every transfer out of the treasury goes through three steps. Each one is a transaction from a signer.

```
 1. submitTransfer(to, amount)   Signer A proposes "send <amount> T42 to <to>".
                                 A proposal with a new id (0, 1, 2...) is created,
                                 and it already counts as A's confirmation: 1 of 2.

 2. confirmTransfer(id)          Signer B agrees: 2 of 2.

 3. executeTransfer(id)          Either signer runs it: the multisig sends the T42.
                                 Before 2 confirmations, this fails and nothing moves.
```

Every proposal is kept forever in the contract (with its `executed` flag), so the history is public. A proposal can only be executed **once**.

## 5. What the contract can do

These are **all** the functions of the contract (see the ABI: [MultiSig42.abi.json](../deployment/MultiSig42.abi.json)).

**Read functions** (free, no transaction):

| Function | What it returns |
| --- | --- |
| `token()` | The address of Token42 |
| `signer1()`, `signer2()` | The two signers |
| `REQUIRED_CONFIRMATIONS()` | `2` |
| `isSigner(account)` | `true` if `account` is one of the two signers |
| `treasuryBalance()` | How many T42 units the multisig holds |
| `proposalCount()` | How many proposals were submitted (the next id) |
| `proposals(id)` | Proposal `id`: `to`, `amount`, `confirmationCount`, `executed` |
| `hasConfirmed(id, account)` | `true` if `account` has confirmed proposal `id` |

**Write functions** (transactions, cost gas):

| Function | What it does | Who can call it |
| --- | --- | --- |
| `submitTransfer(to, amount)` | Creates a proposal to send `amount` T42 units to `to`, and confirms it for the caller | Signers only |
| `confirmTransfer(id)` | Adds the caller's confirmation to proposal `id` | Signers only, once each |
| `executeTransfer(id)` | Sends the T42 of proposal `id` if it has 2 confirmations | Signers only, once per proposal |

**What does not exist:** no owner, no way to add or remove a signer, no way to change the threshold, no way to withdraw without both signers.

**Events** (shown in the contract's **Events** tab on BscScan): `TransferSubmitted`, `TransferConfirmed`, `TransferExecuted`. The executed transfer also appears on the T42 token page as a normal transfer from the multisig.

## 6. Step-by-step on BscScan

Amounts are in **units**, like in [USAGE.md, section 3](USAGE.md#3-understanding-amounts-decimals): 1 T42 = `1000000000000000000`. Both signers need a little tBNB for gas (about 0.00015 tBNB for a submit, 0.00006 for a confirm, 0.00008 for an execute).

Open the multisig on BscScan, tab **Contract**: **Read Contract** for reads, **Write Contract** for transactions (click **Connect to Web3** first, and reconnect after switching account in MetaMask).

1. **Check the treasury**: Read Contract → `treasuryBalance` and `proposalCount` (the id the next proposal will get).
2. **Propose** ([Account 1]): Write Contract → `submitTransfer`
   - `to`: the receiver's address
   - `amount`: for example `1000000000000000000` (1 T42)
   - **Write**, confirm in MetaMask.
3. **Check the proposal**: Read Contract → `proposals(id)` shows `confirmationCount` = `1`, `executed` = `false`.
4. **Try to execute too early** ([Account 1]): Write Contract → `executeTransfer(id)`. MetaMask simulates it, it fails (`NotEnoughConfirmations`), and **Confirm** is greyed out: reject it. Nothing moved.
5. **Confirm** ([Account 2]): switch MetaMask to [Account 2], reconnect, Write Contract → `confirmTransfer(id)`. Now `confirmationCount` = `2`.
6. **Execute** (either signer): Write Contract → `executeTransfer(id)`.
7. **Check**: `treasuryBalance` went down by the amount, the receiver's T42 balance went up, and `proposals(id)` shows `executed` = `true`.

## 7. Errors

As with the token, MetaMask simulates each transaction first and greys out **Confirm** when it would fail. The error names below come from the contract (they are in the ABI, so BscScan and Remix can show them).

| Error | Meaning |
| --- | --- |
| `NotASigner(caller)` | The caller is not one of the two signers |
| `NotEnoughConfirmations(id, confirmations, required)` | `executeTransfer` was called before both signers confirmed |
| `AlreadyConfirmed(id, signer)` | This signer already confirmed this proposal (submitting counts as confirming) |
| `AlreadyExecuted(id)` | The proposal was already executed: it cannot run twice |
| `ProposalDoesNotExist(id)` | No proposal has this id (ids go from 0 to `proposalCount() - 1`) |
| `ZeroAddress()` | The zero address was given as the receiver (or at deployment, as the token or a signer) |
| `DuplicateSigner(signer)` | At deployment only: the same address was given twice as a signer |
| `TokenTransferFailed()` | The token refused the transfer (not expected with Token42, which reverts with its own error instead, for example `ERC20InsufficientBalance` if the treasury is too small) |

## 8. Security and trade-offs

| Choice | Why | Trade-off |
| --- | --- | --- |
| **2 of 2** signers | The simplest real multisig: no single key can move the treasury | If **one key is lost**, the treasury is locked forever (nobody can reach 2 confirmations). A 2-of-3 setup would avoid this, at the cost of a third account. Acceptable for a test token |
| Signers and threshold **fixed at deployment** (`immutable`) | No owner and no admin function, like Token42: nobody can add themselves as a signer or lower the threshold | A signer cannot be replaced; a new multisig would have to be deployed |
| **T42 only** (not a generic multisig) | Simple, clear fields; it cannot be tricked into calling another contract | It cannot hold or move anything else: sending it tBNB fails (it has no function to receive coins), and other tokens sent to it would be stuck |
| Submitting counts as a confirmation | One transaction less; the proposer obviously agrees | None |
| `executed` is set **before** calling the token | Standard "checks, effects, interactions" order: even if the token called back into the multisig, the proposal could not be executed twice | None |
| Custom errors with names | Every refusal says exactly why | None |

**What if both signers agree to misuse the treasury?** They can: that is the chosen trust model. It is still safer than one key, since both must act.

More on the project's security: [SECURITY.md](SECURITY.md).

## 9. Tests

**Remix VM** (2026-10-11, before deployment): Token42 and MultiSig42 deployed on Remix's test chain, 100 T42 sent to the multisig, signers A and B, outsider C.

| # | Who | Action | Expected result | Result |
| --- | --- | --- | --- | --- |
| 1 | A | `submitTransfer(C, 10 T42)` | Proposal 0 created, 1 confirmation | Pass |
| 2 | A | `executeTransfer(0)` | Fails: `NotEnoughConfirmations` | Pass |
| 3 | A | `confirmTransfer(0)` | Fails: `AlreadyConfirmed` | Pass |
| 4 | C | `confirmTransfer(0)` | Fails: `NotASigner` | Pass |
| 5 | B | `confirmTransfer(5)` | Fails: `ProposalDoesNotExist` | Pass |
| 6 | B | `confirmTransfer(0)` | 2 confirmations | Pass |
| 7 | B | `executeTransfer(0)` | C receives 10 T42, treasury 90 T42, executed = true | Pass |
| 8 | A | `executeTransfer(0)` again | Fails: `AlreadyExecuted` | Pass |

**Live testnet** (2026-10-11), click to see each transaction on BscScan:

| Step | Transaction | Result after it |
| --- | --- | --- |
| Fund the treasury | [[Account 1] sends 100 T42 to the multisig](https://testnet.bscscan.com/tx/0x1d8703054636b24c6d8065d50a87839a80b2099adf60fdb155cd42f4a61380b5) | Treasury 100 T42 |
| Propose | [`submitTransfer([Account 2], 10 T42)` by [Account 1]](https://testnet.bscscan.com/tx/0x61f83721d1a2076fd5ff0470f6c04c12d77904ece8cb4e81fcf573f69ec0c55c) | Proposal 0, 1 of 2 |
| Execute too early | `executeTransfer(0)` by [Account 1]: Confirm greyed out in MetaMask, rejected | Fails with `NotEnoughConfirmations(0, 1, 2)` (simulated on a node) |
| Confirm | [`confirmTransfer(0)` by [Account 2]](https://testnet.bscscan.com/tx/0x03b801f532ec0a5ed835d31e016003456135658fd00edbd3510384b59dc7d005) | 2 of 2 |
| Execute | [`executeTransfer(0)` by [Account 2]](https://testnet.bscscan.com/tx/0x6592d2c02d8732df65055a2b0d32060d9ab57401d71e766562358d9ed61b8bac) | Treasury 90 T42, [Account 2] +10 T42 |
