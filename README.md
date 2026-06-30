# T1Y Token Info Site

Static public token-info page for the T1Y BscScan token update request.

Intended GitHub Pages URL:

- Website: `https://chinaruichi-cell.github.io/t1y-token-info/`
- Project information: `https://chinaruichi-cell.github.io/t1y-token-info/docs.html`
- Security status: `https://chinaruichi-cell.github.io/t1y-token-info/security.html`
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
