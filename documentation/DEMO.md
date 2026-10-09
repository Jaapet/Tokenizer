# Demo guide

- Contract: https://testnet.bscscan.com/address/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4
- Token page: https://testnet.bscscan.com/token/0x179C9a66f8ba033Eee37dA8953B192f981ff2bc4
- [Account 1] (deployer): `0xb46c1FACb64e462D26a84e84602aE4e09197Aa51`
- [Account 2]: `0xbB7128213Ba52fa0AD3042BF7009033C714140a8`
- 1 T42 = `1000000000000000000` (18 zeros)

Before: MetaMask on BSC Testnet. On BscScan, **Contract** tab, **Connect to Web3** before each write (reconnect after switching account).

| # | Who | Where | Action | Show |
| --- | --- | --- | --- | --- |
| 1 | - | Contract → Code | Green check "Source Code Verified" | Same code as `code/Token42.sol`; no owner, no mint |
| 2 | - | Read Contract | `name`, `symbol`, `decimals`, `totalSupply` | `Token42`, `T42`, `18`, supply |
| 3 | [Account 1] | MetaMask → T42 → Send | Send `1` T42 to [Account 2] | [Account 1] −1, [Account 2] +1 |
| 4 | [Account 1] | Write Contract → `approve` | spender = [Account 2], value = 1 T42 | Read `allowance([Account 1], [Account 2])` = 1 T42 |
| 5 | [Account 2] | Write Contract → `transferFrom` | from = [Account 1], to = [Account 2], value = 1 T42 | [Account 2] +1, allowance back to 0 |
| 6 | [Account 1] | Write Contract → `burn` | value = 1 T42 | [Account 1] −1 **and** `totalSupply` −1 |
| 7 | [Account 2] | Write Contract → `transferFrom` | Same as step 5 again | Confirm greyed out (allowance 0) → Reject |
| 8 | - | Token page | **Transfers** and **Holders** tabs | Every action above; a burn is a transfer to `0x000…000` |

Each write costs under 0.0001 tBNB; step 7 costs nothing.
