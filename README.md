# T1Y Token Info Site

Static public token-info page for the T1Y BscScan token update request.

Intended GitHub Pages URL:

- Website: `https://chinaruichi-cell.github.io/t1y-token-info/`
- Project information: `https://chinaruichi-cell.github.io/t1y-token-info/docs.html`
- Whitepaper: `https://chinaruichi-cell.github.io/t1y-token-info/whitepaper.html`
- Whitepaper PDF: `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-whitepaper.pdf`
- Operation guide: `https://chinaruichi-cell.github.io/t1y-token-info/operation-guide.html`
- Security status: `https://chinaruichi-cell.github.io/t1y-token-info/security.html`
- Team & public representative: `https://chinaruichi-cell.github.io/t1y-token-info/team.html`
- Explorer review package: `https://chinaruichi-cell.github.io/t1y-token-info/explorer-review.html`
- BscScan review summary: `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_REVIEW_SUMMARY.md`
- BscScan reviewer response: `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_REVIEW_RESPONSE.md`
- BscScan form payload: `https://chinaruichi-cell.github.io/t1y-token-info/docs/BSCSCAN_FORM_PAYLOAD.md`
- BscScan logo SVG: `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-bscscan-logo-32.svg`
- Official logo PNG: `https://chinaruichi-cell.github.io/t1y-token-info/assets/t1y-official-logo-512.png`

No private key, mnemonic, RPC endpoint, signer data, or wallet balance is included.

## Public Verification Materials

This repository also publishes read-only materials for explorer, wallet, and
scanner review:

- Contract source:
  - `contracts/T1YToken.sol`
  - `contracts/T1YTokenExt.sol`
  - `contracts/T1YFeeSwapper.sol`
- Deployment record: `deployments/bsc-mainnet-2026-06-26-public.json`
- BscScan verification metadata: `deployments/bsc-mainnet-2026-06-26-verification.json`
- BscScan Standard JSON input: `deployments/bsc-mainnet-2026-06-26-standard-input.json`
- Latest read-only owner check: `deployments/t1y-readonly-owner-check-latest.json`
- Reproducible owner check script: `scripts/verify-t1y-readonly-state.cjs`
- Transparency report: `docs/T1Y_TRANSPARENCY_REPORT.md`

## Official Contact and Public Representative

- Official contact email: `chinaruichi@gmail.com`
- Public representative for explorer/scanner communications: `T1Y Team / CHINARUICHI BscScan account`

The Gmail address above is intentionally published on the official website as
the project contact address for BscScan/explorer verification until a
project-domain mailbox is available. The site does not publish private keys,
mnemonics, RPC endpoints, signer data, or wallet credentials.

The site publishes only verified project-controlled public channels and does not
add unsupported personal-profile claims. If an explorer requires an individual
public profile, it should be a real profile controlled by the named person and
updated to show T1Y involvement.

## Explorer Review Package

The page `explorer-review.html` maps BscScan-style review requirements to public
evidence links:

- official website and email
- whitepaper and operation guide
- logo SVG/PNG files
- verified contract links
- deployment and verification JSON
- latest owner/wiring check JSON
- burn evidence and transparency report
- representative and communication policy
- copy-ready BscScan token update form payload
- reviewer-note response mapped to BscScan's latest feedback

To reproduce the owner and wiring check:

```bash
node scripts/verify-t1y-readonly-state.cjs
```

Expected result:

- `T1YToken.owner()` is the zero address.
- `T1YFeeSwapper.owner()` is the zero address.
- `T1YTokenExt.owner()` reverts because this deployment does not expose an
  Ownable owner control path.
- `T1YToken.tokenExt()`, `T1YToken.feeSwapper()`, and the Pancake factory pair
  match the published deployment addresses.
