# Change Log

This file contains all the notable changes done to the Ballerina Plaid connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- 268 operations, taking the client from 90 to 351 remote methods. They cover, among others, Transactions Sync,
  Enrich and Recurring (`transactionsSync`, `transactionsEnrich`, `transactionsRecurringGet`), Statements, Investments
  Auth and Refresh, Identity Match and Identity Verification, Monitor (watchlist screening), Beacon, Signal, Protect,
  Plaid Check / Consumer Report (`craCheckReport*`, `craMonitoringInsights*`), Payroll and Bank Income
  (`creditPayrollIncome*`, `creditBankIncome*`), Plaid Transfer (authorizations, recurring transfers, refunds, sweeps,
  ledgers and originators), Payment Initiation consents, e-wallets, the User APIs (`user*`), FDX consent grants and
  reseller partner customers (`partnerCustomer*`).
- Every method accepts an optional `headers` map for additional request headers.
- `ConnectionConfig.auth` also accepts `OAuth2ClientCredentialsGrantConfig`. Only the five `craCheckReport*Get`
  operations that read Consumer Report data (base report, income, network and cash-flow insights, LendScore) accept an
  OAuth 2.0 token; every other operation requires the API keys.

### Changed

- The client is initialised with a single `ConnectionConfig` whose `auth` field carries the API keys, instead of a
  separate `ApiKeysConfig` argument. The `ApiKeysConfig` fields (`plaidClientId`, `plaidSecret`, `plaidVersion`) are
  unchanged.

  Before:

  ```ballerina
  plaid:Client plaidClient = check new ({plaidClientId, plaidSecret, plaidVersion}, {}, "https://sandbox.plaid.com");
  ```

  After:

  ```ballerina
  plaid:Client plaidClient = check new ({auth: {plaidClientId, plaidSecret, plaidVersion}}, "https://sandbox.plaid.com");
  ```

- Fields of closed records, which includes every request record, now use camelCase Ballerina names and map to Plaid's
  snake_case JSON names through `@jsondata:Name`, for example `AssetReportCreateRequest.access_tokens` is now
  `accessTokens` and `days_requested` is now `daysRequested`. Response records that Plaid defines as open
  (`additionalProperties: true`), such as `Item`, `AccountBase` and `Transaction`, keep their snake_case field names.
- `assetReportPdfGet` returns `http:Response` instead of `AssetReportPDFGetResponse`, and
  `incomeVerificationDocumentsDownload` returns `http:Response` instead of `string`. Read the PDF or ZIP bytes with
  `getBinaryPayload()`.
- The client is built from Plaid API `2020-09-14_1.740.1`, up from `2020-09-14_1.26.1`, so many request and response
  records gain fields and some are renamed or removed along with the operations below. The 83 operations kept from
  1.x keep their method names.
- The minimum Ballerina distribution is now **2201.13.4** (Swan Lake Update 13), up from 2201.4.1.
- The Development environment (`https://development.plaid.com`) is no longer one of the documented servers; Plaid has
  retired it. Use `https://sandbox.plaid.com` or `https://production.plaid.com` (the default) as the `serviceUrl`.

### Removed

These operations no longer exist in the Plaid API and are removed from the client:

- `incomeVerificationPaystubGet` (`POST /income/verification/paystub/get`). Use `incomeVerificationPaystubsGet`
  (`POST /income/verification/paystubs/get`) instead.
- `incomeVerificationSummaryGet` (`POST /income/verification/summary/get`).
- `incomeVerificationRefresh` (`POST /income/verification/refresh`). Use `creditPayrollIncomeRefresh`
  (`POST /credit/payroll_income/refresh`) instead.
- `depositSwitchCreate` (`POST /deposit_switch/create`), `depositSwitchAltCreate` (`POST /deposit_switch/alt/create`),
  `depositSwitchGet` (`POST /deposit_switch/get`) and `depositSwitchTokenCreate` (`POST /deposit_switch/token/create`).
  Plaid has discontinued the Deposit Switch product.
- The records used only by the removed operations, such as `DepositSwitchCreateRequest`,
  `IncomeVerificationSummaryGetResponse` and `IncomeVerificationRefreshResponse`.
