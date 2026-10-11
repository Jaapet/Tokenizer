# Token42 (T42)

**Token42** is a BEP-20 token deployed on the **BNB Smart Chain Testnet**, built for the 42 school **Tokenizer** project. It has a fixed initial supply of **1,000 T42**, all created at deployment, and **no owner or admin**: after deployment, nobody has special powers over it. Holders can send, approve, and burn their tokens.

As a bonus, a **2-of-2 multisig** contract, **MultiSig42**, holds a treasury of T42: it only moves tokens when both of its signers agree.

> T42 is a **test token**: it only exists on a test network and has **no monetary value**.

## Deployed contracts

| | |
| --- | --- |
| Token | **Token42**, ticker **T42**, 18 decimals |
| Network | BNB Smart Chain **Testnet** |
| Chain id | `97` |
| Contract address | `0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4` |
| Contract on BscScan | https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4 |
| Verified source code | https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4#code |
| Token page | https://testnet.bscscan.com/token/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4 |
| Deployer | `0xb46c1FACb64e462D26a84e84602aE4e09197Aa51` |
| Deployment transaction | [`0x6e22cd5f…6ea593`](https://testnet.bscscan.com/tx/0x6e22cd5f0a5258d217f13e72fe174fdca855a7b97975906975e9bb04846ea593) (block `135404847`) |
| Deployment date | 2026-10-07, 13:19:06 UTC |

### Bonus: MultiSig42 treasury

| | |
| --- | --- |
| Contract address | `0x79546751f76080964DD1FcA717190d530D5b9840` |
| Contract on BscScan (verified) | https://testnet.bscscan.com/address/0x79546751f76080964DD1FcA717190d530D5b9840#code |
| Signers | [Account 1] `0xb46c1FACb64e462D26a84e84602aE4e09197Aa51` (the deployer) and [Account 2] `0xbB7128213Ba52fa0AD3042BF7009033C714140a8` |
| Confirmations required | 2 of 2 |
| Treasury | 100 T42 sent in at the start |
| Deployment transaction | [`0x891a9209…15e18b`](https://testnet.bscscan.com/tx/0x891a920946350c26970acd93b10cb22f3d09d3775f2706eac9fd155b8f15e18b) (block `136166799`) |
| Deployment date | 2026-10-11, 12:33:57 UTC |

All deployment details are also in [`deployment/deployed.json`](deployment/deployed.json).

## Repository layout

```
README.md                           this file
code/
  Token42.sol                       the token's source code (commented)
  MultiSig42.sol                    bonus: the 2-of-2 multisig treasury (commented)
deployment/
  DEPLOY.md                         step-by-step deployment and BscScan verification guide
  COMPILER-SETTINGS.md              exact compiler settings (needed to verify)
  deployed.json                     addresses, transactions, blocks, settings (both contracts)
  Token42.abi.json                  the contract's interface (ABI), for apps and tools
  Token42_flattened.sol             single-file source, exactly as verified on BscScan
  MultiSig42.abi.json               the multisig's interface (ABI)
  MultiSig42_flattened.sol          the multisig's single-file source, as verified
documentation/
  WHITEPAPER.md                     what Token42 is and how it works
  USAGE.md                          how to use the token (MetaMask, BscScan) + test list
  SECURITY.md                       ownership, privileges, risks and trade-offs
  DEMO.md                           short live demo guide (one action per feature)
  MULTISIG.md                       bonus: how the multisig treasury works and how to use it
```

## Choices and why

| Topic | Choice | Why |
| --- | --- | --- |
| Blockchain | **BNB Smart Chain Testnet** (chain id 97) | The project is a BNB Chain partnership, and the subject requires a test network: test coins (tBNB) are free and have no value. BSC is compatible with Ethereum's tools (Solidity, MetaMask, Remix). |
| Token standard | **BEP-20** | The token standard of BNB Smart Chain, required by the subject. It has the same interface as Ethereum's ERC-20, so every wallet and explorer understands the token. |
| Language | **Solidity**, compiler **0.8.28** pinned exactly (`pragma solidity 0.8.28;`) | Solidity is the main language for BSC and Ethereum contracts. Since 0.8, it blocks arithmetic overflows automatically. An exact version (no `^`) means every compile gives the same result, which BscScan verification needs. |
| Library | **OpenZeppelin Contracts 5.6.1**: `ERC20` + `ERC20Burnable`, version pinned in the import paths (MultiSig42 only uses the `IERC20` interface) | The most used and audited implementation of the standard. Writing our own ERC-20 would add risk for no benefit; our own code is just a constant and the constructor. Pinning the version means the library can never change under us. |
| Burn | Holders can **burn** (destroy) their own tokens | Shows a supply that can only go down. It only acts on the caller's own tokens (or an allowance they were given), so it gives no one extra power. |
| Name and ticker | **Token42**, ticker **T42** | The subject requires "42" in the name. Short and clear. |
| Decimals | **18** | The standard value (same as BNB and most tokens); wallets display it correctly with no setup. |
| Supply | **1,000 T42**, fixed initial supply, all minted to the deployer at deployment | A small round number, easy to check in tests and the demo. Minting once in the constructor means the supply can never grow. |
| Admin | **None**: no owner, no `mint`, no `pause`, no blacklist | The simplest and safest answer to ownership and privileges: a privilege that does not exist cannot be abused, and an admin key that does not exist cannot be stolen. The trade-off is that the contract cannot be changed; see [SECURITY.md](documentation/SECURITY.md). |
| Development tool | **Remix IDE** (in the browser), not Hardhat or Foundry | Nothing to install: write, compile, test on the built-in Remix VM, deploy with MetaMask, and flatten for verification, all in one place. Enough for two small contracts. |
| Compiler settings | Optimizer **off**, EVM version **default** | The contract is small, so optimizing saves little gas; default settings keep the verification simple. Details in [COMPILER-SETTINGS.md](deployment/COMPILER-SETTINGS.md). |
| Wallet | **MetaMask**, with an account used only for this project | The most common wallet; it works with Remix and BscScan. A test-only account means no real funds are ever at risk. |
| Explorer and verification | **BscScan Testnet**, verified by hand with the **Verify and Publish** web form and a **flattened** source file | Verification publishes the source code, so anyone can check it matches the deployed contract. Remix's "Verify Contract on Explorers" switch did not verify on BscScan for us, so we used the web form: it needs no API key. It takes one file, so we flattened the contracts (OpenZeppelin code included) in Remix. |
| Faucet | **GHOST faucet** (https://ghostchain.io/faucet/bnb-testnet/) | The official BNB Chain faucet linked in the subject now requires holding 0.002 **real** BNB on the main network, so we used a faucet with no such requirement. Deployment cost about 0.001 tBNB. |
| Bonus: multisig | A separate contract, **MultiSig42**, that holds a **100 T42 treasury**; Token42 is unchanged | The subject asks to adapt the multisig to the token. Requiring several signatures for every T42 transfer would break the BEP-20 standard, so the multisig protects one holding instead: it can only move T42, and only with both signers. Like the token, it has no owner and its signers can never change. See [MULTISIG.md](documentation/MULTISIG.md). |
| Multisig signers | **2 of 2**: [Account 1] and [Account 2] | The simplest real multisig: one stolen key cannot move the treasury. The trade-off is that one lost key locks it forever (a 2-of-3 setup would avoid that); acceptable for a test token. |

## Quick start

- **Use the token** (see it in MetaMask, transfer, approve, burn): [documentation/USAGE.md](documentation/USAGE.md)
- **Understand the token**: [documentation/WHITEPAPER.md](documentation/WHITEPAPER.md)
- **Deploy and verify your own copy**: [deployment/DEPLOY.md](deployment/DEPLOY.md)
- **Read the code**: [code/Token42.sol](code/Token42.sol) and [code/MultiSig42.sol](code/MultiSig42.sol)
- **Use the multisig treasury (bonus)**: [documentation/MULTISIG.md](documentation/MULTISIG.md)

## Security in short

- **No owner, no admin functions.** Token42's 11 functions are the standard BEP-20 ones plus `burn` and `burnFrom`; each only acts on the caller's own tokens or on an allowance a holder gave. The ABI ([Token42.abi.json](deployment/Token42.abi.json)) proves there is nothing else.
- **Fixed initial supply.** No tokens can be created after deployment; burning can only lower the supply.
- **Audited, pinned code** (OpenZeppelin 5.6.1, Solidity 0.8.28) and **source verified on BscScan**.
- **Test-only keys.** No private key or secret is stored in this repository.
- **Bonus: multisig treasury.** 100 T42 are held by MultiSig42 and can only move when both signers confirm; its ABI ([MultiSig42.abi.json](deployment/MultiSig42.abi.json)) has no owner or admin function either.

Full details, including allowance risks and the trade-offs of having no admin: [documentation/SECURITY.md](documentation/SECURITY.md).
