# T1Y Token Security Scanner Review Request

Project: T1Y

Network: BNB Smart Chain

Token contract: `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f`

Official website: `https://chinaruichi-cell.github.io/t1y-token-info/`

Security status page: `https://chinaruichi-cell.github.io/t1y-token-info/security.html`

Contact email: `chinaruichi@gmail.com`

## Request

Please review the current token-security scanner result for T1Y. Wallet scanner UI currently flags whitelist, tax mutability, and external-call items. The project would like these items reviewed with the current verified source and on-chain ownership status.

## Current On-Chain Ownership State

Read-only verification snapshot:

- Chain ID: `56`
- Block: `106713047`

- `T1YToken.owner()` returns `0x0000000000000000000000000000000000000000`
- `T1YFeeSwapper.owner()` returns `0x0000000000000000000000000000000000000000`
- `T1YTokenExt` does not expose an `owner()` function and does not inherit `Ownable`

## BscScan Evidence

- T1YToken Read Contract:
  `https://bscscan.com/address/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f#readContract`
- T1YFeeSwapper Read Contract:
  `https://bscscan.com/address/0x02A2060c730e009b4b2c2B9167f93e7af68D6Bbe#readContract`
- T1YTokenExt Read Contract:
  `https://bscscan.com/address/0x0379d39190E125b530E84254a132563E4EaE37d2#readContract`

## Explanation of Flagged Items

1. Whitelist-related code exists for protocol system addresses. New project-controlled whitelist updates are no longer possible because `T1YToken.owner()` is the zero address.

2. Sell protection, burn, and fee logic exists in the verified source. Owner-controlled parameter setters are no longer callable because ownership has been renounced.

3. External calls are part of the protocol mechanism and target PancakeSwap Router, WBNB, T1YTokenExt, and T1YFeeSwapper for liquidity, reward, redemption, and burn operations.

## Owner-Controlled Functions That Are No Longer Callable

- `T1YToken.settokenExt(address)`
- `T1YToken.setFeeSwapper(address)`
- `T1YToken.setLiquiditySlippageBps(uint256)`
- `T1YToken.setSwapSlippageBps(uint256)`
- `T1YFeeSwapper.toggleAutoSwap(bool)`
- `T1YFeeSwapper.setMinSwapAmount(uint256)`
- `T1YFeeSwapper.setSlippageBps(uint256)`
- `T1YFeeSwapper.addEarleirUser(address[])`
- `T1YFeeSwapper.emergencyWithdraw(address,uint256)`

Please refresh or correct the scanner result if it is currently presenting these owner-gated items as still project-modifiable.
