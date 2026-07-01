# T1Y Due Diligence FAQ

Updated: 2026-07-02

This FAQ is prepared for explorers, wallets, scanners, reviewers, and users who
need a concise due-diligence view of T1Y before relying on public metadata.

## 1. What is T1Y?

T1Y is a BNB Smart Chain token and protocol focused on on-chain liquidity,
LP-based hashrate accounting, referral rewards, node-level rewards,
contract-defined burn behavior, and transparent rules around the T1Y/WBNB
liquidity pool.

## 2. What is the official token contract?

```text
0x56b776483096c16a3eDD76156Eee47cdcbC05F7f
```

BscScan token page:

```text
https://bscscan.com/token/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f
```

## 3. Which contracts are part of the deployment?

| Contract | Address | Purpose |
| --- | --- | --- |
| T1YToken | `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f` | Main BEP-20 token and core participation logic |
| T1YTokenExt | `0x0379d39190E125b530E84254a132563E4EaE37d2` | Reward and extended accounting helper |
| T1YFeeSwapper | `0x02A2060c730e009b4b2c2B9167f93e7af68D6Bbe` | Fee conversion helper |
| T1Y/WBNB LP | `0x9d3153f4D033A54FbC8199eaA195655cecc92262` | PancakeSwap V2 T1Y/WBNB liquidity pair |

## 4. Is the source code verified?

Yes. The public site links the verified BscScan source pages, deployment JSON,
BscScan verification metadata, and compiler standard input.

Primary evidence:

```text
https://t1y.org/explorer-review.html
```

## 5. Has ownership been renounced?

The public owner-check evidence documents:

- `T1YToken.owner()` returns `0x0000000000000000000000000000000000000000`.
- `T1YFeeSwapper.owner()` returns `0x0000000000000000000000000000000000000000`.
- `T1YTokenExt` does not expose an Ownable owner control path in this deployment.

Read-only evidence:

```text
https://t1y.org/deployments/t1y-readonly-owner-check-latest.json
```

## 6. Does this replace a third-party audit?

No. The public materials are a transparency and technical-review evidence
package. They do not claim that a third-party contract security audit has been
completed or accepted by BscScan.

## 7. Does T1Y have ICO, IEO, presale, private sale, or premine claims?

T1Y does not publish an ICO, IEO, private sale, seed sale, presale, premine, or
guaranteed-return campaign in the BscScan submission materials.

## 8. Does the project guarantee returns?

No. T1Y does not guarantee price performance, profit, reward amount, liquidity
depth, or principal protection. On-chain participation and digital assets carry
risk.

## 9. Why do some wallets or scanners show warnings?

T1Y uses non-standard token mechanics, including reward accounting, burn logic,
liquidity interactions, and helper-contract reads. Some scanners may flag these
patterns automatically even after owner permissions have been renounced. The
public materials explain the difference between:

- actual current owner-control status
- non-standard token behavior
- scanner/wallet heuristic warnings

## 10. What is the official email?

The current official contact is:

```text
contact@t1y.org
```

It is the active project-domain mailbox and is intentionally published on the
official website as the public contact. The domain-email readiness status is
published separately:

```text
https://t1y.org/docs/DOMAIN_EMAIL_READINESS.md
```

## 11. Who publicly represents T1Y?

T1Y is publicly represented by:

```text
T1Y Team / CHINARUICHI
```

The public representative model is limited to project-controlled channels,
verified contract evidence, GitHub materials, BscScan records, and the official
contact email. It does not submit unsupported personal-profile claims.

## 12. What should reviewers use as the primary evidence package?

Use the explorer review package first:

```text
https://t1y.org/explorer-review.html
```

Then use the copy-ready form payload:

```text
https://t1y.org/docs/BSCSCAN_FORM_PAYLOAD.md
```

## 13. What should users avoid?

Users should avoid:

- trusting unofficial links or screenshots
- sending private keys or seed phrases to anyone
- relying on unofficial token addresses
- assuming wallet/scanner metadata is current before checking BscScan
- treating the public transparency package as a completed third-party audit

## 14. What is the safest way to verify the project?

1. Check the token contract address on BscScan.
2. Check verified source code on BscScan.
3. Check the official website and GitHub repository.
4. Check owner-renounce evidence.
5. Check the burn address and token-transfer evidence.
6. Check the whitepaper and risk disclosures.
7. Use only links published from the official site or BscScan.
