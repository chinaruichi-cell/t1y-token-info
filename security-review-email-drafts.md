# T1Y Security Scanner Review Email Drafts

## Draft 0: BscScan Token Update Follow-Up

Subject: Re: Update Token Information [BscScan] - T1Y public verification materials added

Hello BscScan Team,

We have added additional public verification materials for the T1Y token update request.

Token information:

- Token name / symbol: T1Y
- Chain: BNB Smart Chain
- Token contract: `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f`
- Official website: `https://t1y.org/`
- Project information: `https://t1y.org/docs.html`
- Security and ownership status: `https://t1y.org/security.html`
- GitHub repository: `https://github.com/chinaruichi-cell/t1y-token-info`
- Official contact email: `contact@t1y.org`

New public verification materials in the GitHub repository:

- Contract source: `contracts/T1YToken.sol`, `contracts/T1YTokenExt.sol`, `contracts/T1YFeeSwapper.sol`
- Deployment record: `deployments/bsc-mainnet-2026-06-26-public.json`
- BscScan verification metadata: `deployments/bsc-mainnet-2026-06-26-verification.json`
- BscScan Standard JSON input: `deployments/bsc-mainnet-2026-06-26-standard-input.json`
- Latest read-only owner check: `deployments/t1y-readonly-owner-check-latest.json`
- Reproducible owner check script: `scripts/verify-t1y-readonly-state.cjs`
- Transparency report: `docs/T1Y_TRANSPARENCY_REPORT.md`

Current read-only ownership state:

- `T1YToken.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YFeeSwapper.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YTokenExt.owner()` reverts because this deployment does not expose an Ownable owner control path.

The BscScan account has also verified ownership of the submitted token contract address.

Please review the updated materials for the T1Y token information update request.

Thank you.

Best regards,

T1Y Team

## Draft 1: TokenPocket

Subject: T1Y token security scan review request - owner renounced and scanner notices need refresh

Hello TokenPocket team,

We are requesting a review of the T1Y token security scan display in TokenPocket.

Token: T1Y

Network: BNB Smart Chain

Token contract: `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f`

Official website: `https://t1y.org/`

Security status page: `https://t1y.org/security.html`

Public verification repository: `https://github.com/chinaruichi-cell/t1y-token-info`

Current TokenPocket scan displays whitelist, mutable-tax, and external-call notices. These notices appear to be based on static code patterns, but the current on-chain ownership state shows that the project can no longer modify the owner-gated controls.

Current on-chain state:

- `T1YToken.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YFeeSwapper.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YTokenExt` has no `owner()` function and does not inherit `Ownable`

BscScan evidence:

- T1YToken: `https://bscscan.com/address/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f#readContract`
- T1YFeeSwapper: `https://bscscan.com/address/0x02A2060c730e009b4b2c2B9167f93e7af68D6Bbe#readContract`
- T1YTokenExt: `https://bscscan.com/address/0x0379d39190E125b530E84254a132563E4EaE37d2#readContract`

The whitelist and parameter-setting functions are owner-gated and are no longer callable after ownership renounce. External calls are used for PancakeSwap Router, WBNB, T1YTokenExt, and T1YFeeSwapper as part of the protocol's liquidity, reward, redemption, and burn mechanics.

Please help refresh or review the displayed risk items so users are not misled into thinking these controls are still project-modifiable.

Thank you.

Contact: contact@t1y.org

## Draft 2: GoPlus / CertiK Scanner Data Source

Subject: T1Y token scanner false-positive review request - owner-gated controls are renounced

Hello team,

We are requesting a review of the token-security scanner result for T1Y on BNB Smart Chain.

Token contract: `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f`

Security status page: `https://t1y.org/security.html`

Public verification repository: `https://github.com/chinaruichi-cell/t1y-token-info`

The scanner currently flags whitelist, mutable-tax, or external-call risks. We understand these mechanisms exist in the verified source, but the owner-gated controls are no longer callable because ownership has been renounced.

Current on-chain ownership state:

- `T1YToken.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YFeeSwapper.owner()` = `0x0000000000000000000000000000000000000000`
- `T1YTokenExt` has no `owner()` function

Owner-gated functions that are no longer callable:

- `T1YToken.settokenExt(address)`
- `T1YToken.setFeeSwapper(address)`
- `T1YToken.setLiquiditySlippageBps(uint256)`
- `T1YToken.setSwapSlippageBps(uint256)`
- `T1YFeeSwapper.toggleAutoSwap(bool)`
- `T1YFeeSwapper.setMinSwapAmount(uint256)`
- `T1YFeeSwapper.setSlippageBps(uint256)`
- `T1YFeeSwapper.addEarleirUser(address[])`
- `T1YFeeSwapper.emergencyWithdraw(address,uint256)`

Please review whether these items can be displayed as static mechanism notices rather than active project-modifiable risks.

Thank you.

Contact: contact@t1y.org

## Customer-Facing Chinese Explanation

TP 安全检测显示的是静态扫描结果。它识别到合约代码中存在白名单、税费和外部调用机制，但这并不等于项目方现在还能修改。

太一 T1Y 当前链上权限状态：

- 主合约 `T1YToken.owner()` 已是零地址
- 手续费合约 `T1YFeeSwapper.owner()` 已是零地址
- 奖励扩展合约 `T1YTokenExt` 没有 owner 权限

因此，项目方已经无法再修改白名单、修改滑点参数、修改手续费兑换参数或转移 owner。TP 的提示属于静态检测提醒，不代表当前仍有项目方后台权限。

公开核查页面：

`https://t1y.org/security.html`
