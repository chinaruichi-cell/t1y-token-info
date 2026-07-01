# T1Y Security and Transparency Report

Updated: 2026-06-30

This document is a public transparency report for T1Y. It is **not a formal third-party security audit**. It is intended to give users, explorers, wallets, and scanners a clear reference for deployed contracts, ownership status, source verification, and known non-standard token behavior.

## Official Public References

| Reference | URL |
| --- | --- |
| Official website | `https://chinaruichi-cell.github.io/t1y-token-info/` |
| Project information | `https://chinaruichi-cell.github.io/t1y-token-info/docs.html` |
| Whitepaper | `https://chinaruichi-cell.github.io/t1y-token-info/whitepaper.html` |
| Operation guide | `https://chinaruichi-cell.github.io/t1y-token-info/operation-guide.html` |
| Security status | `https://chinaruichi-cell.github.io/t1y-token-info/security.html` |
| GitHub repository | `https://github.com/chinaruichi-cell/t1y-token-info` |
| Official contact email | `chinaruichi@gmail.com` |

The official public representative for explorer and scanner communication is
`T1Y Team / CHINARUICHI BscScan account`. The Gmail address above is published
on the official website as the project contact address until a project-domain
mailbox is available.

## Contract Set

| Component | Address | Purpose |
| --- | --- | --- |
| T1YToken | `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f` | Main BEP-20 token and core participation logic |
| T1YTokenExt | `0x0379d39190e125b530e84254a132563e4eae37d2` | Reward and price-related extension logic |
| T1YFeeSwapper | `0x02a2060c730e009b4b2c2B9167f93e7af68D6Bbe` | Fee swapper and helper logic |
| T1Y/WBNB LP Pair | `0x9d3153f4d033a54fbc8199eaa195655cecc92262` | PancakeSwap V2 liquidity pair |
| Pancake Router V2 | `0x10ED43C718714eb63d5aA57B78B54704E256024E` | BSC PancakeSwap V2 router |
| WBNB | `0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c` | Wrapped BNB |
| BSC USDT | `0x55d398326f99059fF775485246999027B3197955` | USDT reference token |

## Current Read-Only Ownership Check

Read-only JSON-RPC check at BSC block `107286378`, timestamp `2026-06-30T16:39:11.388Z`:

| Check | Result | Interpretation |
| --- | --- | --- |
| `T1YToken.owner()` | `0x0000000000000000000000000000000000000000` | Main token ownership renounced |
| `T1YFeeSwapper.owner()` | `0x0000000000000000000000000000000000000000` | Fee swapper ownership renounced |
| `T1YTokenExt.owner()` | `execution reverted: 0x` | Extension is not an Ownable control contract in this deployment |
| `T1YToken.pancakePair()` | `0x9d3153f4d033a54fbc8199eaa195655cecc92262` | Matches the T1Y/WBNB pair |
| Pancake Factory `getPair(T1Y, WBNB)` | `0x9d3153f4d033a54fbc8199eaa195655cecc92262` | Factory pair matches token pair |
| `T1YToken.tokenExt()` | `0x0379d39190e125b530e84254a132563e4eae37d2` | Extension address is fixed after owner renounce |
| `T1YToken.feeSwapper()` | `0x02a2060c730e009b4b2c2b9167f93e7af68d6bbe` | Fee swapper address is fixed after owner renounce |

The latest JSON output is published at:

- `deployments/t1y-readonly-owner-check-latest.json`

Re-run the same check with:

```bash
node scripts/verify-t1y-readonly-state.cjs
```

## Deployment Transactions

| Action | Transaction |
| --- | --- |
| Deploy T1YToken | `0x50641f0f88123b368ed88d3a31d9a5a0ac5f9d6da882f3b1dc3a2443d2b459f4` |
| Deploy T1YTokenExt | `0x12dab37ab4a05d0c24d01fe14693443a013d832622b5932702ef4d5ace8aa429` |
| Deploy T1YFeeSwapper | `0xfdafdb6bb94db0507761304b33a4d690767f33028c6f0a2e025866c9121bdb74` |
| Set tokenExt | `0x6b413a6ff85a43c818802202538b0e574b92cf22e2ee9037f10ee980adc7e80f` |
| Set feeSwapper | `0x587674e5c59b8b005e30ac5839f83270691d26fb7d9984794dde647b627ef4e2` |
| Initial router approval | `0x5a5a3230b7a938ef0d8c63e12ee47e98d0641245c346d8c8a07ea22d36f59549` |
| Initial add liquidity | `0x677fff9752bc32166e43a3ddca46ce36e461f072fa007c8ca10b2c439cbe615f` |

## Initial Liquidity

Initial liquidity was seeded with:

- `5 BNB`
- `130,000,000 T1Y`

The LP pair is the PancakeSwap V2 T1Y/WBNB pair listed above.

## Source and Verification Materials

Local deployment records:

- `/Users/wong/Desktop/T1Y/deployments/bsc-mainnet-2026-06-26.json`
- `/Users/wong/Desktop/T1Y/deployments/bsc-mainnet-2026-06-26-verification.json`
- `/Users/wong/Desktop/T1Y/deployments/bsc-mainnet-2026-06-26-standard-input.json`

These files contain the deployment addresses, transaction hashes, and verification material used for BscScan source verification.

## Known Non-Standard Token Behavior

T1Y is not a plain transfer-only BEP-20 token. Wallets and scanners should account for the following behaviors:

- `transfer` and `transferFrom` are used as part of the protocol mechanics.
- `balanceOf` display semantics may include visible balance plus pending reward context, while transfer behavior follows actual transferable balance.
- Deposits, reward accounting, sell fees, burn logic, referral rewards, node rewards, and LP-related accounting are part of the protocol design.
- Sell impact and effective fees can vary based on protocol conditions.
- The contract performs external calls to PancakeSwap V2 router/pair and WBNB/USDT references for pricing, liquidity, and swap-related logic.

These behaviors should be disclosed, not hidden. The ownership-related scanner warning should be refreshed because owner-controlled replacement has been removed by ownership renounce.

## Practical Security Status

What can be publicly proven:

- Main token ownership is renounced.
- Fee swapper ownership is renounced.
- Extension contract does not expose an Ownable `owner()` control path.
- Main token references to `tokenExt` and `feeSwapper` are fixed after renounce.
- T1Y/WBNB pair address matches Pancake Factory.
- Source and deployment records are available.

What this document does not prove:

- It does not replace a professional third-party audit.
- It does not guarantee future price performance or liquidity depth.
- It does not remove the need for users to understand the non-standard token mechanics.

## Recommended Scanner Interpretation

Scanners should keep truthful warnings for:

- Non-standard ERC20/BEP-20 behavior.
- Dynamic fee/sell impact mechanics.
- External DEX dependency.
- Reward and accounting complexity.

Scanners should refresh or remove stale owner-control warnings where they are based on assumptions that `tokenExt`, `feeSwapper`, tax, or whitelist controls can still be changed by an owner.
