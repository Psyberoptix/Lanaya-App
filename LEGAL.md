# LanaYa Legal Documents

## LanaYa Exchange Policy (2026)
"Exchange rates are provided in real-time and include a 1.5% operational spread. Once a quote is accepted, the rate is locked for 60 seconds. LanaYa is not responsible for 4x1000 taxes incurred on non-exempt accounts. All local transfers are powered by the Bre-B national rail."

---

## DIAN Compliance: Foreigner Transaction Rules (2026)

### 4x1000 (GMF) Tax
- The GMF is a Colombian **domestic banking transaction tax**. It applies to movements through Colombian bank accounts.
- **Colombian users** (identified by Cédula): The 4x1000 tax is **automatically applied** to all COP transfers. No user toggle is needed — exemptions are managed at the account's bank, not by LanaYa.
- **Foreign users** (no Cédula): The 4x1000 does **not** apply to USD wallet-to-wallet operations. If a foreigner holds a Colombian bank account, the bank handles GMF independently.

### DIAN Reporting Threshold for Non-Residents
Per DIAN regulations (2026, UVT = $52,374 COP):
- If a **non-resident's** gross income, credit card consumption, or **bank transactions exceed 1,400 UVT** (approximately **$73,323,600 COP**) in a calendar year, a Colombian **income tax filing obligation** is triggered.
- LanaYa will display a compliance notification if a foreign user approaches this threshold.

### Tax Residency
- An individual becomes a **Colombian tax resident** after spending **183+ calendar days** in Colombia within any 365-day period.
- Residents are taxed on **worldwide income**; non-residents only on **Colombian-source income** at a flat 35% rate.

### Wealth Tax (Impuesto al Patrimonio)
- Applies to individuals (including non-residents) with net assets in Colombia ≥ **40,000 UVT** (~$2.095 billion COP / ~$497,000 USD).

---

## Open Finance Security: Circular Externa 001 de 2026

### Architecture Requirements
- All Open Finance API connections (bank account linking) must use **OAuth 2.0** with PKCE flow.
- Access tokens expire after **5 minutes**; refresh tokens expire after **30 days**.
- All data in transit uses **TLS 1.3** minimum.

### Data Protection
- **Consent-based access only**: Users must explicitly authorize each data category (balances, transactions, identity).
- **Right to revoke**: Users can disconnect linked accounts at any time; all cached financial data must be purged within **72 hours** of revocation.
- **Data minimization**: LanaYa only requests the minimum data required: account balance, last 5 transactions, and account holder name.

### Audit Requirements
- All API calls to financial institutions must be logged in the `audit_logs` collection with timestamp, endpoint, user_id, and success/failure status.
- Logs must be retained for **5 years** per Superintendencia Financiera guidelines.

### LanaYa Implementation
- Our `MockBankService` simulates the OAuth 2.0 flow. In production, this connects to Bancolombia's Open Finance API via their sandbox environment.
- The `AuditLogService` records all transaction events for compliance.

> **Disclaimer**: This document is for informational purposes only and does not constitute legal or tax advice. Users should consult a qualified Colombian tax professional for their specific circumstances.
