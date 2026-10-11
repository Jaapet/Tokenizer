# Compiler settings

These are the exact settings used to compile, deploy and verify `Token42`, and the bonus contract `MultiSig42` (same settings).
Use them every time. BscScan verification only works if the source is compiled with the same settings as the deployed contract.

## Settings

| Setting | Value | Why |
| --- | --- | --- |
| Language | Solidity | The standard language for BNB Smart Chain and Ethereum contracts |
| Compiler version | `v0.8.28+commit.7893614a` | Matches the exact pragma in the source (`pragma solidity 0.8.28;`). Solidity 0.8.x checks for arithmetic overflow automatically |
| Optimizer | **Off** | The contracts are small and simple; turning the optimizer off keeps compilation and verification simple. Each deployment cost only about 0.001 tBNB anyway |
| EVM version | Compiler default (`cancun` for 0.8.28) | BNB Smart Chain supports these opcodes; nothing in the contract needs a specific older version |
| Other options | Remix defaults (no via-IR, no remappings) | Nothing special needed |
| License | MIT (`// SPDX-License-Identifier: MIT`) | Same license as OpenZeppelin, open and permissive |
| Library | OpenZeppelin Contracts **5.6.1** | Audited, widely used ERC-20/BEP-20 implementation. The version is pinned in the import paths (`@openzeppelin/contracts@5.6.1/...`), so the code never changes silently |
| Constructor arguments | Token42: none. MultiSig42: 3 addresses (token, signer 1, signer 2) | Token42's name, ticker and supply are fixed in the source code. MultiSig42 takes its addresses at deployment, so it can also be tested on the Remix VM, where addresses differ |

## Where to set them in Remix

In the **Solidity Compiler** tab (the "S" icon on the left):

1. **Compiler**: choose `0.8.28+commit.7893614a` in the list. Remix selects its own latest version by default, so check this every time.
2. **Advanced Configurations**:
   - **Optimization**: unchecked.
   - **EVM Version**: `default`.
3. Click **Compile Token42.sol** (or **Compile MultiSig42.sol**): you should get a green check, with no warnings and no errors.

## Same settings in the BscScan verification form

| BscScan field | Value |
| --- | --- |
| Compiler Type | Solidity (Single file) |
| Compiler Version | `v0.8.28+commit.7893614a` |
| Open Source License Type | MIT License (MIT) |
| Optimization | No |
| Source code | Full content of [`Token42_flattened.sol`](Token42_flattened.sol) (or [`MultiSig42_flattened.sol`](MultiSig42_flattened.sol)) |
| Constructor Arguments | Token42: empty. MultiSig42: the 3 ABI-encoded addresses, see [DEPLOY.md, section 10.4](DEPLOY.md#104-verify-on-bscscan) |
| EVM Version | default |

The full steps are in [DEPLOY.md](DEPLOY.md).
