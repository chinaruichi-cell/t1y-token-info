# T1Y Token Info Site

Static public token-info page for the T1Y BscScan token update request.

Intended GitHub Pages URL:

- Website: `https://t1y.org/`
- Project information: `https://t1y.org/docs.html`
- Whitepaper: `https://t1y.org/whitepaper.html`
- Whitepaper PDF: `https://t1y.org/assets/t1y-whitepaper.pdf`
- Protocol mechanics appendix: `https://t1y.org/docs/PROTOCOL_MECHANICS_APPENDIX.md`
- Operation guide: `https://t1y.org/operation-guide.html`
- Security status: `https://t1y.org/security.html`
- Team & public representative: `https://t1y.org/team.html`
- Explorer review package: `https://t1y.org/explorer-review.html`
- BscScan review summary: `https://t1y.org/docs/BSCSCAN_REVIEW_SUMMARY.md`
- BscScan reviewer response: `https://t1y.org/docs/BSCSCAN_REVIEW_RESPONSE.md`
- BscScan latest review gap analysis: `https://t1y.org/docs/BSCSCAN_LATEST_REVIEW_GAP_ANALYSIS.md`
- BscScan form payload: `https://t1y.org/docs/BSCSCAN_FORM_PAYLOAD.md`
- BscScan resubmission cover: `https://t1y.org/docs/BSCSCAN_RESUBMISSION_COVER.md`
- Domain email readiness: `https://t1y.org/docs/DOMAIN_EMAIL_READINESS.md`
- Due diligence FAQ: `https://t1y.org/docs/DUE_DILIGENCE_FAQ.md`
- Official channels notice: `https://t1y.org/docs/OFFICIAL_CHANNELS_AND_IMPERSONATION_NOTICE.md`
- BscScan logo SVG: `https://t1y.org/assets/t1y-bscscan-logo-32.svg`
- Official logo PNG: `https://t1y.org/assets/t1y-official-logo-512.png`

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

- Official contact email: `contact@t1y.org`
- Public representative for explorer/scanner communications: `T1Y Team / CHINARUICHI BscScan account`

The email address above is the active project-domain contact address for
BscScan/explorer verification. The site does not publish private keys,
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
- protocol mechanics appendix
- logo SVG/PNG files
- verified contract links
- deployment and verification JSON
- latest owner/wiring check JSON
- burn evidence and transparency report
- representative and communication policy
- copy-ready BscScan token update form payload
- reviewer-note response mapped to BscScan's latest feedback
- latest review gap analysis mapped to BscScan's newest feedback categories
- resubmission cover note and domain-email readiness status
- due diligence FAQ and official channels notice

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
