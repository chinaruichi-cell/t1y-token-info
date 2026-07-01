# BscScan Submission Prep

Prepared: 2026-07-01

This file prepares the next BscScan public-info submissions for T1Y. It is a
working checklist and should be reviewed before any BscScan form is submitted.

## Name Tag / Label

Submission URL:

- `https://bscscan.com/contactus?id=5&a=0x56b776483096c16a3eDD76156Eee47cdcbC05F7f`

Recommended labels:

| Address | Requested public name tag / label | Reason |
| --- | --- | --- |
| `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f` | `T1Y Token` | Main BEP-20 token and core participation logic |
| `0x0379d39190e125b530e84254a132563e4eae37d2` | `T1YTokenExt` | T1Y reward and price extension contract |
| `0x02a2060c730e009b4b2c2B9167f93e7af68D6Bbe` | `T1YFeeSwapper` | T1Y fee swapper/helper contract |
| `0x9d3153f4d033a54fbc8199eaa195655cecc92262` | `PancakeSwap V2: T1Y-WBNB` | T1Y/WBNB PancakeSwap V2 LP pair; BscScan may already display a PancakeSwap pair tag |

Suggested explanation:

```text
Please add public labels for the verified T1Y deployment contracts on BNB
Smart Chain. The token source is verified, the BscScan account has verified
ownership of the main token address, and public deployment/ownership materials
are available at:

https://github.com/chinaruichi-cell/t1y-token-info
https://chinaruichi-cell.github.io/t1y-token-info/security.html
https://chinaruichi-cell.github.io/t1y-token-info/explorer-review.html
```

## Token Information Resubmission Package

Use the verified-address token update form after logging in to BscScan:

- `https://BscScan.com/contactus?id=4`

Recommended field values:

| Field | Value |
| --- | --- |
| Contract Address | `0x56b776483096c16a3eDD76156Eee47cdcbC05F7f` |
| Project Name | `T1Y` |
| Project Website | `https://chinaruichi-cell.github.io/t1y-token-info/` |
| Project Email Address | `chinaruichi@gmail.com` |
| Logo SVG | `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-bscscan-logo-32.svg` |
| Whitepaper | `https://chinaruichi-cell.github.io/t1y-token-info/whitepaper.html` |
| Whitepaper PDF | `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-whitepaper.pdf` |
| GitHub | `https://github.com/chinaruichi-cell/t1y-token-info` |
| Team / Representative | `https://chinaruichi-cell.github.io/t1y-token-info/team.html` |
| Explorer Review Package | `https://chinaruichi-cell.github.io/t1y-token-info/explorer-review.html` |
| Review Summary | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_REVIEW_SUMMARY.md` |
| Copy-ready Form Payload | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_FORM_PAYLOAD.md` |
| Reviewer Response | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_REVIEW_RESPONSE.md` |
| Resubmission Cover | `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_RESUBMISSION_COVER.md` |
| Domain Email Readiness | `https://chinaruichi-cell.github.io/t1y-token-info/docs/DOMAIN_EMAIL_READINESS.md` |
| Project Sector | `DeFi` |

Neutral project description:

```text
T1Y is a BNB Smart Chain protocol focused on on-chain liquidity, LP-based
hashrate accounting, referral rewards, node-level rewards, contract-defined burn
behavior, and transparent rules around the T1Y/WBNB liquidity pool. The project
publishes verified contract addresses, source verification links, owner-renounce
evidence, logo files, operation notes, and risk disclosures at the official
website and GitHub repository.
```

Recommended comment:

```text
This resubmission adds a fuller public information package after the previous
review response. Public evidence now includes:

- expanded whitepaper
- downloadable whitepaper PDF
- operation guide
- team/public representative statement
- explorer review package
- BscScan review summary
- public logo SVG and PNG
- GitHub repository with deployment and verification JSON
- latest owner/wiring check JSON
- burn evidence and transparency report

The official contact email chinaruichi@gmail.com is intentionally published on
the official website as the project's primary contact email until a
project-domain mailbox is available.

If a personal professional profile is required, the project will provide only a
real profile controlled by the named person and updated to show T1Y involvement.
```

## Burn Details

Submission URL:

- `https://bscscan.com/contactus`

Relevant BscScan evidence page:

- `https://bscscan.com/token/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f?a=0x000000000000000000000000000000000000dEaD`

Filtered iframe used by BscScan for the transfer table:

- `https://bscscan.com/token/generic-tokentxns2?m=dark&contractAddress=0x56b776483096c16a3eDD76156Eee47cdcbC05F7f&a=0x000000000000000000000000000000000000dEaD&p=1`

Observed BscScan table state:

- BscScan displayed `112` T1Y transfers to `0x000000000000000000000000000000000000dEaD`.
- Latest page rows show the sender as `0x56b77648...dcbC05F7f` and receiver as `Null: 0x000...dEaD`.
- Multiple burn transfer rows can occur inside one transaction, so the number of table rows and number of unique transaction hashes are not the same.

Latest burn transaction samples verified by transaction receipt:

| Tx hash | Block | Burn log count in receipt | First burn amount shown on BscScan |
| --- | ---: | ---: | ---: |
| `0x7a3cf52f39ed354d9240d3a1f2c1d27600fa20e235e17482c17cebb226691788` | `107289790` | `1` | `58,167.788124615587281258` |
| `0x55fa08beed9561def29a0278d0031520ec9bc245dc204c341c7a6f34ab29015a` | `107288478` | `2` | `58,226.01413875434162288` |
| `0x401f328c11edd52e2c98c8b15c61253013e8ca5fba2912f656631f5c373ccb32` | `107265328` | `1` | `58,342.641078269802958995` |
| `0x4fefbcab0ce95c0558e7a1df0f9a507a6d354c470660604490c1a19ea52d7a4c` | `107263666` | `1` | `58,401.042120390193152148` |
| `0xdde3888f47180267f8092299d1c30d8bb3ac590e31be7acf91712e7e8f13f3a7` | `107249446` | `3` | `58,459.501622012205357505` |
| `0x757999d5240c73b2d42f4e4683b47376cfdb7484d8f520379718900b4345c609` | `107228253` | `1` | `58,635.231469361112079769` |
| `0x3ecfa80076738f7b16d6beff1e5af9763dc3642805af12e3a7448348b3f52ec4` | `107222197` | `1` | `58,693.925394755867947717` |
| `0x2aad78ac851f66ac6f1c3354eb2bf1d75c9735bf935b2e9167b005d195c72e8c` | `107212477` | `2` | `58,752.678072828696644361` |
| `0x3ff546c3725c1e85d5cc3332683ee5747a048d032a677a550d0291bbf960bf23` | `107193492` | `1` | `58,870.359922313401133227` |
| `0xcc1a75ddc22cfa294898d0bdaaabad30ca9ba3c84c4918b632757a00740a5005` | `107191332` | `1` | `58,929.289211524926059286` |

Suggested Burn Details text:

```text
T1Y has recurring protocol burn transfers from the verified T1Y token contract
to the standard dead address:

Token contract:
0x56b776483096c16a3eDD76156Eee47cdcbC05F7f

Burn address:
0x000000000000000000000000000000000000dEaD

BscScan filtered transfer page:
https://bscscan.com/token/0x56b776483096c16a3eDD76156Eee47cdcbC05F7f?a=0x000000000000000000000000000000000000dEaD

Latest verified burn transaction examples:
0x7a3cf52f39ed354d9240d3a1f2c1d27600fa20e235e17482c17cebb226691788
0x55fa08beed9561def29a0278d0031520ec9bc245dc204c341c7a6f34ab29015a
0x401f328c11edd52e2c98c8b15c61253013e8ca5fba2912f656631f5c373ccb32
0x4fefbcab0ce95c0558e7a1df0f9a507a6d354c470660604490c1a19ea52d7a4c
0xdde3888f47180267f8092299d1c30d8bb3ac590e31be7acf91712e7e8f13f3a7

The burn transfers are visible in BscScan's token transfer table filtered by
the dead address. Some transactions contain multiple burn transfer rows.
```

## Before Submitting

- Do not submit Burn Details unless the form allows a recurring/protocol burn
  explanation or enough transaction hashes.
- If the form requires an announcement URL, use the public transparency page:
  `https://chinaruichi-cell.github.io/t1y-token-info/security.html`.
- If BscScan asks for a single burn event, submit the latest successful burn
  transaction hash and mention that the contract performs recurring burns.
- Submit only after explicit approval.
- Submit token information through the verified-address/token-owner form, not by
  sending a separate Name Tag email without a verified address/signature context.
