# T1Y Domain Email Readiness Plan

Updated: 2026-07-02

This document explains the current official contact email status and the planned
remediation path for a project-domain mailbox.

## Current Status

| Item | Status |
| --- | --- |
| Current official contact | `chinaruichi@gmail.com` |
| Published on official website | Yes |
| Used for BscScan communication | Yes |
| Project-domain mailbox | Not yet available |

The current Gmail contact is intentionally published on the official T1Y website
as the project's public contact address until a project-domain mailbox is
available.

## Why This Is Published

BscScan token information review commonly checks whether the sender email is the
same as the project website domain, or whether the email is clearly listed as
the official project contact on the website.

T1Y currently satisfies the second condition by publishing the Gmail contact on
the official website, team page, form payload, and reviewer response. A
project-domain mailbox would still be stronger and is recommended before or
after resubmission if operationally available.

## Recommended Target Setup

When a project domain is ready, use a simple role-based mailbox:

```text
contact@<project-domain>
```

Recommended public use:

| Purpose | Address |
| --- | --- |
| Token information and explorer review | `contact@<project-domain>` |
| Support and scanner review | `contact@<project-domain>` |
| Backup contact | `chinaruichi@gmail.com` |

## Update Checklist

After the mailbox is created and tested:

1. Update the official website contact email.
2. Update `team.html`.
3. Update `docs.html`.
4. Update `docs/BSCSCAN_FORM_PAYLOAD.md`.
5. Update `docs/BSCSCAN_REVIEW_RESPONSE.md`.
6. Update `docs/BSCSCAN_RESUBMISSION_COVER.md`.
7. Send BscScan submissions from the project-domain mailbox if possible.
8. Keep `chinaruichi@gmail.com` as a backup public contact only if desired.

## Reviewer Note

Until the project-domain mailbox is ready, reviewers should treat
`chinaruichi@gmail.com` as the official public contact because it is explicitly
published on the official T1Y website and public documentation.
