# How to use Token42

This guide explains how to hold, send, approve and burn **Token42 (T42)**, and how to check everything on the block explorer. It does not require any knowledge of the code.

Everything happens in the browser, with **MetaMask** (your wallet) and **BscScan** (the block explorer).

## Contents

1. [Token facts](#1-token-facts)
2. [What you need](#2-what-you-need)
3. [Understanding amounts (decimals)](#3-understanding-amounts-decimals)
4. [See your T42 in MetaMask](#4-see-your-t42-in-metamask)
5. [What the token can do](#5-what-the-token-can-do)
6. [Step-by-step actions](#6-step-by-step-actions)
7. [Common errors](#7-common-errors)
8. [Manual test list](#8-manual-test-list)

---

## 1. Token facts

| Property | Value |
| --- | --- |
| Name | Token42 |
| Ticker (symbol) | T42 |
| Decimals | 18 |
| Initial and maximum supply | 1,000 T42 (can only go down, through burns) |
| Standard | BEP-20 (same interface as ERC-20) |
| Network | BNB Smart Chain **Testnet**, chain id `97` |
| Contract address | `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4` |
| Contract on BscScan | https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4 |
| Token page on BscScan | https://testnet.bscscan.com/token/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4 |

T42 is a **test token**: it lives on a test network and has no monetary value.

## 2. What you need

- **MetaMask** with the **BNB Smart Chain Testnet** network added. See [DEPLOY.md, section 2](../deployment/DEPLOY.md#2-prepare-metamask).
- A little **tBNB** (the testnet coin) to pay for gas. See [DEPLOY.md, section 3](../deployment/DEPLOY.md#3-get-free-test-bnb-tbnb).

**What is gas?** Every action that *changes* the blockchain (sending, approving, burning) is a **transaction**, and the account that sends it pays a small fee in tBNB. About 0.0001 tBNB is enough for one T42 transaction. *Reading* data (a balance, the total supply) is free.

So every account that sends a transaction needs some tBNB, not only T42. For example, in the `approve` + `transferFrom` example below, the second account ([Account 2]) needs tBNB too.

## 3. Understanding amounts (decimals)

A blockchain contract cannot store fractional numbers like `0.5`. So the token counts in very small units, and **18 decimals** means:

> 1 T42 = 1 followed by 18 zeros units = `1000000000000000000`

- **MetaMask** does the conversion for you: you type `10`, it sends 10 T42.
- **BscScan's Write Contract tab** (and Remix) does **not** convert: you must type the amount in units.

| You want | Type this in BscScan |
| --- | --- |
| 1 T42 | `1000000000000000000` |
| 10 T42 | `10000000000000000000` |
| 0.5 T42 | `500000000000000000` |
| 1,000 T42 (the whole supply) | `1000000000000000000000` |

Tip: on BscScan, the small **"+"** button next to an amount field can add the 18 zeros for you.

The same goes for reading: `balanceOf` returns `1000000000000000000000`, which means 1,000 T42.

## 4. See your T42 in MetaMask

MetaMask does not show every token automatically. To add T42:

1. Open MetaMask and select the **BNB Smart Chain Testnet** network.
2. In the **Tokens** tab, choose **Import tokens** (in the `⋮` menu or at the bottom of the token list, depending on the MetaMask version).
3. Select the BNB Smart Chain Testnet network if MetaMask asks, and paste the contract address:
   `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4`
4. The symbol (`T42`) and decimals (`18`) fill in automatically. Click **Next**, then **Import**.

Your T42 balance now appears in the token list. Do this on every account you use.

## 5. What the token can do

These are **all** the functions of the contract. They come from the BEP-20 / ERC-20 standard (OpenZeppelin `ERC20`) plus the burn extension (OpenZeppelin `ERC20Burnable`).

**Read functions** (free, no transaction):

| Function | What it returns |
| --- | --- |
| `name()` | `Token42` |
| `symbol()` | `T42` |
| `decimals()` | `18` |
| `totalSupply()` | The number of T42 that exist right now, in units |
| `balanceOf(account)` | How many T42 an address holds, in units |
| `allowance(owner, spender)` | How many of `owner`'s T42 `spender` is still allowed to move |

**Write functions** (transactions, cost gas):

| Function | What it does | Who can call it |
| --- | --- | --- |
| `transfer(to, value)` | Sends `value` of **your** T42 to `to` | Any holder, for their own tokens |
| `approve(spender, value)` | Allows `spender` to move up to `value` of **your** T42. It sets the allowance (it replaces the old one, it does not add) | Any holder, for their own tokens |
| `transferFrom(from, to, value)` | Moves `value` T42 from `from` to `to`, using the allowance `from` gave you | Only a spender with a large enough allowance |
| `burn(value)` | Destroys `value` of **your** T42. The total supply goes down | Any holder, for their own tokens |
| `burnFrom(account, value)` | Destroys `value` of `account`'s T42, using the allowance `account` gave you | Only a spender with a large enough allowance |

**What does not exist:** there is no owner, no `mint` (nobody can create new tokens), no `pause`, and no blacklist. Nobody has special powers over the contract, not even the deployer. See [security.md](security.md).

Every transfer and burn emits a `Transfer` event, and every approval emits an `Approval` event. BscScan uses them to show the token's history. A burn appears as a transfer **to** the zero address `0x0000000000000000000000000000000000000000`.

## 6. Step-by-step actions

There are two simple ways to act on the token:

- **MetaMask**: easiest for sending T42 (it only supports sending).
- **BscScan**, on the contract page: the **Contract** tab has **Read Contract** (free reads) and **Write Contract** (transactions). Before writing, click **Connect to Web3** and connect MetaMask. Make sure MetaMask is on BSC Testnet with the right account selected.

(Remix's "At Address" button also works with the contract address, but BscScan is simpler.)

The examples use two accounts:

- **[Account 1]**: holds T42 (for example the deployer account).
- **[Account 2]**: a second account, with a little tBNB for gas.

### 6.1 Read the token info and a balance

1. Open the contract on BscScan, tab **Contract** → **Read Contract**.
2. Click `name`, `symbol`, `decimals`, `totalSupply`: the values appear immediately.
3. In `balanceOf`, paste an address and click **Query**. Divide the result by 10^18 to get T42.

In MetaMask, the balance is shown directly in the Tokens tab.

### 6.2 Send T42 (`transfer`)

**With MetaMask:**

1. Select [Account 1], click **T42** in the token list, then **Send**.
2. Paste [Account 2]'s address, type the amount (for example `10`), click **Continue**, then **Confirm**.

**With BscScan:**

1. **Write Contract** → `transfer`.
2. `to`: [Account 2]'s address. `value`: `10000000000000000000` (10 T42).
3. Click **Write**, then confirm in MetaMask.

Result: [Account 1] has 10 T42 less, [Account 2] has 10 T42 more. The total supply does not change.

### 6.3 Let someone spend for you (`approve`, then `transferFrom`)

This is how apps and exchanges move tokens on your behalf: you give a **permission** (an allowance) first, then they use it.

Example: [Account 1] allows [Account 2] to spend up to 5 T42 of its tokens, and [Account 2] uses it to send 5 T42 to itself.

1. **[Account 1]** (connected on BscScan) → **Write Contract** → `approve`:
   - `spender`: [Account 2]'s address
   - `value`: `5000000000000000000` (5 T42)
   - **Write**, confirm in MetaMask.
2. Check it: **Read Contract** → `allowance(owner = [Account 1], spender = [Account 2])` returns `5000000000000000000`.
3. Switch MetaMask to **[Account 2]** (and reconnect on BscScan if needed). **Write Contract** → `transferFrom`:
   - `from`: [Account 1]'s address
   - `to`: [Account 2]'s address (or any other address)
   - `value`: `5000000000000000000`
   - **Write**, confirm in MetaMask. [Account 2] pays the gas.
4. Result: [Account 1] has 5 T42 less, the receiver has 5 T42 more, and the allowance is back to `0`.

Notes:

- `approve` **replaces** the allowance; it does not add to it. To cancel a permission, approve `0`.
- If [Account 2] tries to move more than its allowance, the transaction fails (`ERC20InsufficientAllowance`).

### 6.4 Destroy tokens (`burn` and `burnFrom`)

Burning destroys tokens forever: they leave your balance **and** the total supply goes down. Nobody can create them again.

**`burn`** (your own tokens):

1. **Write Contract** → `burn`, `value`: `1000000000000000000` (1 T42).
2. **Write**, confirm in MetaMask.
3. Check: your balance and `totalSupply` are both 1 T42 lower.

**`burnFrom`** (someone else's tokens, with their permission):

- It works like `transferFrom`: it needs an allowance first. [Account 1] approves [Account 2], then [Account 2] calls `burnFrom([Account 1], value)`, and the allowance goes down.
- It **always** needs an allowance, even on your own account: calling `burnFrom` with your own address without approving yourself first fails with `ERC20InsufficientAllowance`. To burn your own tokens, use `burn`.

### 6.5 Check the result on BscScan

- After each transaction, MetaMask shows a link to it. On BscScan, the transaction page shows the **Status** (Success or Fail), the sender, the fee paid, and the **ERC-20 Tokens Transferred** line.
- The **token page** (https://testnet.bscscan.com/token/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4) lists every transfer and burn in the **Transfers** tab, and every holder in the **Holders** tab.
- BscScan can take a few seconds to show a new transaction.

## 7. Common errors

Before sending, MetaMask simulates the transaction for free. When the simulation fails, MetaMask greys out **Confirm** (often without naming the error), so the only option is to reject it. If a failing transaction is sent anyway (for example from another tool), it fails on chain and the sender still pays the gas.

To see the exact error name, simulate the same call with a node (an `eth_call`) or in Remix; the table below lists what each error means.

| Error | Meaning | Fix |
| --- | --- | --- |
| `ERC20InsufficientBalance` | You try to send or burn more T42 than you have | Lower the amount; check your balance and the decimals |
| `ERC20InsufficientAllowance` | `transferFrom` or `burnFrom` asks for more than the allowance | The owner must `approve` you first, for a large enough amount |
| `ERC20InvalidReceiver` | You send to the zero address `0x000…000` | Use a real address. To destroy tokens, use `burn` |
| `ERC20InvalidSpender` | You `approve` the zero address | Use a real address |
| `ERC20InvalidSender` / `ERC20InvalidApprover` | The zero address is used as the sender or approver | Cannot happen from a normal account |
| "Insufficient funds for gas" | The account has no tBNB to pay the fee | Get tBNB from a faucet, or send some from another account |
| Amount is 10^18 times too small | You typed `10` in BscScan instead of `10000000000000000000` | BscScan uses units: see [section 3](#3-understanding-amounts-decimals) |

## 8. Manual test list

These tests check every action of the token by hand.

- **Remix VM**: Remix's built-in test chain (free and instant), run on 2026-10-06 before the real deployment.
- **Live testnet**: the deployed contract on BSC Testnet, run on 2026-10-09 with two accounts ([Account 1] = the deployer, [Account 2] = `0xbB7128213Ba52fa0AD3042BF7009033C714140a8`). Tests 7 to 9 were stopped by MetaMask before sending (Confirm greyed out); the error names come from simulating the same calls on a node.

| # | Action | Expected result | Remix VM | Live testnet |
| --- | --- | --- | --- | --- |
| 1 | Read `name`, `symbol`, `decimals` | `Token42`, `T42`, `18` | Pass | Pass |
| 2 | Read `totalSupply` and the deployer's `balanceOf` | Both `1000000000000000000000` (1,000 T42) | Pass | Pass |
| 3 | `transfer` T42 to a second account | Sender balance goes down, receiver balance goes up by the same amount | Pass | Pass |
| 4 | `approve` the second account, then read `allowance` | The allowance equals the approved amount | Pass | Pass |
| 5 | Second account calls `transferFrom` within the allowance | Tokens move, the allowance goes down by the amount | Pass | Pass |
| 6 | `burn` some T42 | Balance and `totalSupply` both go down by the amount | Pass | Pass |
| 7 | `transfer` more than the balance | Fails with `ERC20InsufficientBalance`, no balance changes | Pass | Pass |
| 8 | `transferFrom` with no allowance | Fails with `ERC20InsufficientAllowance` | Pass | Pass |
| 9 | `burnFrom` on your own account with no allowance | Fails with `ERC20InsufficientAllowance` | Pass | Pass |

Live transactions (click to see them on BscScan):

| Test | Transaction | Result after it |
| --- | --- | --- |
| Gas for [Account 2] | [send 0.001 tBNB to [Account 2]](https://testnet.bscscan.com/tx/0x7b8e54860964102c2e0383cdf6cf7b95ce36994d4dcf7885cb9d4fe7ebca646b) | [Account 2] can pay fees |
| 3 | [`transfer` 10 T42 to [Account 2]](https://testnet.bscscan.com/tx/0x815af8aa8d432de613e42c9b380f171c55bb58fb8e5e41cc7232ae3c19b10531) | [Account 1] 990, [Account 2] 10 |
| 4 | [`approve` [Account 2] for 5 T42](https://testnet.bscscan.com/tx/0xef2b5112111f4e9c34d0c9a8aa96f2adcacf8429af6820f093c6f14d2ea7e1ad) | Allowance 5 |
| 5 | [`transferFrom` 5 T42, sent by [Account 2]](https://testnet.bscscan.com/tx/0x844aa26780d3865f0916a9059010ae7bcde5540d4c038c4839059182e854a631) | [Account 1] 985, [Account 2] 15, allowance 0 |
| 6 | [`burn` 1 T42](https://testnet.bscscan.com/tx/0x6118fc77188019cb49ef394a17492cfd9d2614d463af48c440021452abfb0b25) | [Account 1] 984, total supply 999 |
