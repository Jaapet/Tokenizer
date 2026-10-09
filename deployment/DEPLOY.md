# How to deploy Token42

This guide explains, step by step, how `Token42` (T42) was deployed on the **BNB Smart Chain Testnet** and verified on **BscScan**. Anyone can follow it to deploy their own copy.

Everything happens in the browser: no installation other than the MetaMask extension.

> The official deployment is recorded in [deployed.json](deployed.json):
> contract `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4`
> ([see it on BscScan](https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4)).
> Deploying again creates a **new, separate** contract at a new address; it does not change the official one.

## Contents

1. [What you need](#1-what-you-need)
2. [Prepare MetaMask](#2-prepare-metamask)
3. [Get free test BNB (tBNB)](#3-get-free-test-bnb-tbnb)
4. [Open and compile the contract in Remix](#4-open-and-compile-the-contract-in-remix)
5. [Deploy on BSC Testnet](#5-deploy-on-bsc-testnet)
6. [Check the deployment on BscScan](#6-check-the-deployment-on-bscscan)
7. [Verify the source code on BscScan](#7-verify-the-source-code-on-bscscan)
8. [After deployment](#8-after-deployment)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. What you need

| Tool | What it is | Link |
| --- | --- | --- |
| A web browser | Chrome, Firefox, Brave… | |
| MetaMask | A wallet extension: it holds your account and signs transactions | https://metamask.io |
| Remix IDE | An online editor that compiles and deploys Solidity contracts | https://remix.ethereum.org |
| BscScan Testnet | The block explorer: a website to look at transactions and contracts | https://testnet.bscscan.com |
| The source code | [`code/Token42.sol`](../code/Token42.sol) | |

**Use a test-only account.** Never use a wallet that holds real money for this project.

## 2. Prepare MetaMask

1. Install the MetaMask extension and create a **new** wallet (or a new account) used only for testing. Write the recovery phrase down and keep it private.
2. Add the **BNB Smart Chain Testnet** network. In MetaMask, open the network list, then add a custom network with these values:

   | Field | Value |
   | --- | --- |
   | Network name | BNB Smart Chain Testnet |
   | RPC URL | `https://data-seed-prebsc-1-s1.bnbchain.org:8545` |
   | Chain ID | `97` |
   | Currency symbol | `tBNB` |
   | Block explorer URL | `https://testnet.bscscan.com` |

3. Select this network. Testnets are hidden by default in MetaMask's network list: in the network filter (the "All default networks" button), look under the **Custom** tab.

## 3. Get free test BNB (tBNB)

Every transaction costs a small fee ("gas"), paid in the chain's coin. On the testnet this coin, **tBNB**, is free and has no value.

- The official BNB Chain faucet now asks for at least 0.002 **real** BNB on the main network before it gives tBNB, so we did not use it.
- We used the **GHOST faucet**: https://ghostchain.io/faucet/bnb-testnet/ (0.01 tBNB per day, no balance needed). Paste your MetaMask address and request tBNB.

**How much you need:** our deployment cost **0.00101 tBNB**. A transfer costs about 0.0001 tBNB. 0.01 tBNB is plenty.

## 4. Open and compile the contract in Remix

1. Open https://remix.ethereum.org.
2. In the **File Explorer** (first icon on the left), create a file named `Token42.sol` and paste the content of [`code/Token42.sol`](../code/Token42.sol) into it.
   - The `import` lines point to OpenZeppelin version **5.6.1** (`@openzeppelin/contracts@5.6.1/...`). Remix downloads these files automatically when it compiles.
3. Open the **Solidity Compiler** tab (the "S" icon) and set:
   - **Compiler**: `0.8.28+commit.7893614a`. ⚠️ Remix selects its own latest version by default (0.8.34 at the time), so pick 0.8.28 by hand.
   - **Optimization**: off.
   - **EVM Version**: default.

   All settings and the reasons for them are in [compiler-settings.md](compiler-settings.md).
4. Click **Compile Token42.sol**. A green check must appear, with no warnings and no errors.

## 5. Deploy on BSC Testnet

This step sends a real transaction on the testnet and spends a little tBNB.

1. Open the **Deploy & Run Transactions** tab (the Ethereum icon, below the compiler).
2. **Environment**: choose **Browser Extension → MetaMask** (in older Remix versions this was called **Injected Provider - MetaMask**).
3. MetaMask opens and asks to connect to Remix: choose your test account and accept.
4. Check what Remix shows:
   - the network is **BNB Smart Chain Testnet** (chain id **97**). If another network shows, switch MetaMask to BSC Testnet for this site;
   - the **Account** is your test account, with its tBNB balance.
5. In the **Contract** list, choose **Token42** (not `ERC20` or `ERC20Burnable`, which are only building blocks).
6. Leave **Value** at `0` (we send no coins with the deployment) and **Gas limit** on `auto`.
7. The **Verify Contract on Explorers** switch may be on or off: for us it did **not** verify on BscScan, so we verified by hand (step 7).
8. Click **Deploy**.
9. MetaMask opens a confirmation window. Before you confirm, check:
   - network: BNB Smart Chain Testnet;
   - account: your test account;
   - network fee: a small amount of **tBNB** (around 0.001).

   Then click **Confirm**.
10. After a few seconds, the Remix terminal (the panel at the bottom) shows a line with a **green check**. Click it to see the details and write down:
    - the **contract address**;
    - the **transaction hash**;
    - the **block number**.

    The contract also appears in the **Transaction History** tab of Remix.

What happened: the constructor of `Token42` ran once, created **1,000 T42**, and gave all of them to the account that deployed (yours). Nobody can create more tokens later.

## 6. Check the deployment on BscScan

1. Open `https://testnet.bscscan.com/tx/<transaction hash>`.
   - **Status** must be **Success**.
   - **From** is your address; **To** says "Contract Creation" with the new contract address.
   - Note the **Timestamp** (date and time of the deployment).
2. Open `https://testnet.bscscan.com/address/<contract address>`.
   - The **Token Tracker** shows **Token42 (T42)**.
   - The **Contract** tab says **Verify and Publish**: BscScan only knows the compiled bytecode for now. The next step fixes that.

## 7. Verify the source code on BscScan

**Why:** verifying publishes the readable source code. BscScan compiles it again with the same settings and checks that the result is **exactly** the code stored on the blockchain. It proves to everyone that the code they read is the code that runs.

BscScan cannot download the OpenZeppelin imports by itself, so we give it a **flattened** file: one single file containing our contract and all the OpenZeppelin code it uses.

### 7.1 Flatten the contract in Remix

1. In the **File Explorer**, right-click `Token42.sol` and choose **Flatten**. Remix creates `Token42_flattened.sol`.
2. Remix's flattener removes all the license lines. Add this line back at the very top of the file:

   ```solidity
   // SPDX-License-Identifier: MIT
   ```

   (It is only a comment; it does not change the compiled code, and it avoids a compiler warning.)
3. Compile `Token42_flattened.sol` with the same settings (0.8.28, optimization off) to check that it has no errors.

Our flattened file is saved in [Token42_flattened.sol](Token42_flattened.sol): it is the exact file that BscScan verified.

### 7.2 Fill in the BscScan form

1. On the contract page, open the **Contract** tab and click **Verify and Publish**.
2. **Page 1:**

   | Field | Value |
   | --- | --- |
   | Contract Address | already filled in |
   | Compiler Type | **Solidity (Single file)** |
   | Compiler Version | **v0.8.28+commit.7893614a** |
   | Open Source License Type | **MIT License (MIT)** |

3. **Page 2:**

   | Field | Value |
   | --- | --- |
   | Optimization | **No** |
   | Source code | paste the **whole** content of `Token42_flattened.sol` |
   | Constructor Arguments | **leave empty** (our constructor takes no arguments) |
   | Advanced settings (if shown) | EVM version **default**, the rest unchanged |

4. Solve the captcha and click **Verify and Publish**.
5. Expected result: **"Successfully generated matching Bytecode and ABI"**. The **Contract** tab now shows a green check ✅, the source code, and the **Read Contract** / **Write Contract** buttons.

No BscScan account or API key is needed for this form.

## 8. After deployment

### Save the deployment details

Fill in [deployed.json](deployed.json): network, chain id, contract address, deployer, transaction hash, block number, timestamp, compiler settings, verification.

### Save the ABI

The ABI is the list of the contract's functions, events and errors, in a format that tools and websites use to talk to the contract.

- Easiest: on BscScan, **Contract** tab, scroll to **Contract ABI** and click copy.
- Or in Remix: **Solidity Compiler** tab, choose **Token42** in the **Contract** list, then click **ABI**.
  ⚠️ After flattening, this list contains many contracts. With another one selected (for example `Context`), the ABI is empty: `[]`.

Ours is in [Token42.abi.json](Token42.abi.json): 1 constructor, 11 functions, 2 events, 6 errors. It has no `mint`, `pause` or `owner` function: nobody has special powers over the token.

### See the tokens in MetaMask

1. In MetaMask, on BSC Testnet, open the **Tokens** tab and choose **Import tokens**.
2. Paste the contract address. The symbol **T42** and decimals **18** fill in by themselves (do not change them).
3. Confirm: the deployer account shows **1,000 T42**.

### Use the contract again from Remix

With MetaMask, the new contract may not appear in Remix's **Deployed Contracts** tab. To load it:

1. Compile `Token42.sol` and select **Token42** in the **Deploy** tab.
2. Paste the contract address in the **At Address** field and click **At Address**.
3. The contract appears in **Deployed Contracts** with all its buttons. Reading (`name`, `balanceOf`…) is free; actions (`transfer`, `approve`, `burn`…) are transactions and cost a little tBNB.

How to use the token (transfer, approve, burn) is explained in the `documentation/` folder.

## 9. Troubleshooting

| Problem | Cause and fix |
| --- | --- |
| The compiler shows a version error | The compiler is not on 0.8.28. Select `0.8.28+commit.7893614a` in the Solidity Compiler tab |
| Remix shows another chain id than 97 | MetaMask is on another network for remix.ethereum.org. Switch it to BNB Smart Chain Testnet |
| MetaMask says "insufficient funds" | Not enough tBNB for the fee. Use a faucet (step 3) |
| The contract is not in **Deployed Contracts** | Normal with MetaMask. Load it with **At Address** (step 8) |
| The "Verify Contract on Explorers" switch did not verify | Verify by hand with the BscScan form (step 7) |
| BscScan says the bytecode does not match | One setting differs: check compiler version (exact commit), optimization **No**, EVM default, and that the **whole** flattened file was pasted |
| The ABI copied from Remix is `[]` | The wrong contract is selected in the compiler's **Contract** list. Choose **Token42**, or copy the ABI from BscScan |
| MetaMask shows a wrong token amount | Wrong decimals when importing the token. Remove it and import again with decimals **18** |
