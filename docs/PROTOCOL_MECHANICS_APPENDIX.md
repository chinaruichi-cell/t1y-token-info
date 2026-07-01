# T1Y Protocol Mechanics Appendix

Updated: 2026-07-02

This appendix provides a structured, reviewer-facing explanation of T1Y's
contract set, mechanics, non-standard BEP-20 behavior, evidence model, and risk
boundaries. It is not a third-party audit report.

## 1. Deployment Topology

| Component | Address | Reviewer purpose |
| --- | --- | --- |
| T1YToken | `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f` | Main token, user participation records, transfer behavior, reward accounting hooks, owner-renounced configuration |
| T1YTokenExt | `0x0379d39190E125b530E84254a132563E4EaE37d2` | Extended reward/accounting helper and read-path logic |
| T1YFeeSwapper | `0x02A2060c730e009b4b2c2B9167f93e7af68D6Bbe` | Fee conversion helper tied to the T1YToken deployment |
| PancakeSwap V2 T1Y/WBNB pair | `0x9d3153f4D033A54FbC8199eaA195655cecc92262` | Public AMM pair used for reserve and liquidity reference |
| PancakeSwap V2 router | `0x10ED43C718714eb63d5aA57B78B54704E256024E` | Standard BNB Smart Chain PancakeSwap V2 router |
| WBNB | `0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c` | Wrapped BNB used by the pair |
| Dead address | `0x000000000000000000000000000000000000dEaD` | Public burn receiver |

## 2. Participation and Accounting Model

T1Y is not presented as a simple fixed-tax token. The protocol includes
contract-defined user state and read paths for:

- participation status
- LP-related user accounting
- static hashrate
- dynamic hashrate
- referral-related accounting
- node-level accounting
- current claimable reward views
- burn and sell-impact related mechanics

Reviewers should distinguish ordinary token transfers from contract-defined
participation. Wallet token balance alone does not fully describe user status,
because the protocol also exposes user, reward, LP, and node-related read
paths.

## 3. Non-Standard BEP-20 Behavior

T1Y includes non-standard behavior that should be disclosed instead of hidden:

| Behavior | Why it exists | Review interpretation |
| --- | --- | --- |
| Reward-aware balance display | User-facing balance may include actual balance plus pending reward display logic. | This can confuse generic ERC-20 scanners; it is disclosed publicly. |
| Contract-defined participation | Users can have participation records separate from a normal spot buy. | Participation state should be checked through contract reads, not only token balance. |
| Burn transfers | Protocol mechanics can transfer T1Y to the standard dead address. | Burn evidence should be checked through BscScan token transfers. |
| Helper-contract reads | Reward and fee paths depend on deployed helper contracts. | Owner-renounce status and fixed wiring should be checked together. |
| Liquidity-pair interaction | T1Y/WBNB reserve state affects market-facing behavior. | Low-liquidity market risk should be disclosed. |

## 4. Ownership and Mutability Boundary

The current public owner evidence states:

- `T1YToken.owner()` is `0x0000000000000000000000000000000000000000`.
- `T1YFeeSwapper.owner()` is `0x0000000000000000000000000000000000000000`.
- `T1YTokenExt` does not expose an Ownable owner control path in this deployment.
- `T1YToken.tokenExt()` points to `0x0379d39190E125b530E84254a132563E4EaE37d2`.
- `T1YToken.feeSwapper()` points to `0x02A2060c730e009b4b2c2B9167f93e7af68D6Bbe`.
- The Pancake factory pair matches the published `T1Y/WBNB` LP address.

Evidence file:

```text
https://chinaruichi-cell.github.io/t1y-token-info/deployments/t1y-readonly-owner-check-latest.json
```

This owner evidence is important because scanners may still show historical or
heuristic warnings about configurable helper contracts, tax settings, or
whitelist-related behavior. The current owner status should be checked from the
live contract state and the public read-only owner/wiring output.

## 5. Burn Evidence Model

T1Y burn evidence should be reviewed through the token transfer table filtered
to the standard dead address:

```text
https://bscscan.com/token/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f?a=0x000000000000000000000000000000000000dEaD
```

The burn evidence notes also list representative transaction hashes:

```text
https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_SUBMISSION_PREP.md
```

Review note: recurring burn behavior may generate multiple transfer rows and
multiple transaction hashes over time. A token-update form should not describe
burns as a single one-time event unless BscScan specifically requests one
representative burn transaction.

## 6. Scanner Warning Interpretation

Some scanners may classify T1Y as non-standard because it contains:

- reward-aware balance logic
- helper-contract dependencies
- burn behavior
- referral and node accounting
- AMM reserve-based calculations
- contract-defined participation state

These scanner notices should be separated into two categories:

1. **Current permission/control state:** owner renounce and fixed wiring can be
   checked on-chain.
2. **Mechanism complexity:** non-standard reward, burn, and LP behavior remains
   part of the token design and should remain disclosed.

The project is not asking scanners or explorers to hide real mechanism
complexity. The request is to use current live owner state and public evidence
when displaying owner-control warnings.

## 7. Public Evidence Checklist

| Evidence | URL |
| --- | --- |
| Official website | `https://chinaruichi-cell.github.io/t1y-token-info/` |
| Whitepaper | `https://chinaruichi-cell.github.io/t1y-token-info/whitepaper.html` |
| Whitepaper PDF | `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-whitepaper.pdf` |
| Explorer review package | `https://chinaruichi-cell.github.io/t1y-token-info/explorer-review.html` |
| Due diligence FAQ | `https://chinaruichi-cell.github.io/t1y-token-info/docs/DUE_DILIGENCE_FAQ.md` |
| Official channels notice | `https://chinaruichi-cell.github.io/t1y-token-info/docs/OFFICIAL_CHANNELS_AND_IMPERSONATION_NOTICE.md` |
| Latest review gap analysis | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_LATEST_REVIEW_GAP_ANALYSIS.md` |
| Form payload | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_FORM_PAYLOAD.md` |
| Owner/wiring check | `https://chinaruichi-cell.github.io/t1y-token-info/deployments/t1y-readonly-owner-check-latest.json` |

## 8. Risk Boundary

T1Y does not guarantee:

- future price performance
- liquidity depth
- reward amount
- claim timing
- redemption value
- principal protection
- scanner or wallet display timing
- BscScan approval timing

This appendix is intended to improve transparency and reviewability, not to
remove the normal risks of smart contracts, AMM liquidity, digital assets, or
non-standard token mechanics.

