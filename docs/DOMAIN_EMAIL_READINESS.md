# T1Y Domain Email Readiness Status

Updated: 2026-07-02

This document explains the current official project-domain email status.

## Current Status

| Item | Status |
| --- | --- |
| Current official contact | `contact@t1y.org` |
| Published on official website | Yes |
| Used for BscScan communication | Yes |
| Project-domain mailbox | Active |
| Receive test | Passed |
| Send test | Passed |
| MX provider | Tencent Exmail |
| SPF | `v=spf1 include:spf.mail.qq.com ~all` |
| DMARC | `v=DMARC1; p=none; rua=mailto:contact@t1y.org` |
| DKIM | Published at `atmb2607._domainkey.t1y.org` |

The official T1Y contact email is now `contact@t1y.org`. The mailbox has been
created in Tencent Exmail and tested for both receiving and sending. DKIM is
also published for Tencent Exmail signing under the selector
`atmb2607._domainkey`.

## Why This Is Published

BscScan token information review commonly checks whether the sender email uses
the same domain as the project website, or whether the email is clearly listed
as the official project contact on the website.

T1Y now satisfies the stronger project-domain email condition by publishing
`contact@t1y.org` on the official website, team page, form payload, reviewer
response, and public transparency materials.

## Public Use

| Purpose | Address |
| --- | --- |
| Token information and explorer review | `contact@t1y.org` |
| Support and scanner review | `contact@t1y.org` |
| Public project contact | `contact@t1y.org` |

## DNS Checklist

1. MX records point to Tencent Exmail.
2. SPF authorizes Tencent Exmail.
3. DMARC is published in monitoring mode for domain-level mail policy visibility.
4. DKIM is published at `atmb2607._domainkey.t1y.org`.

Public DNS verification:

```text
dig +short @1.1.1.1 atmb2607._domainkey.t1y.org TXT
dig +short @8.8.8.8 atmb2607._domainkey.t1y.org TXT
```

Both resolvers return the Tencent Exmail DKIM TXT record.

## Reviewer Note

Reviewers should treat `contact@t1y.org` as the official public contact because
it is explicitly published on the official T1Y website and public documentation,
and it uses the same domain as `https://t1y.org/`.
