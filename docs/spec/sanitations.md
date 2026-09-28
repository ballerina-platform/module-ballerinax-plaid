_Author_:  @DimuthuMadushan \
_Created_: 2026/09/28 \
_Updated_: 2026/09/28 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Plaid. 
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/plaid/plaid/2020-09-14_1.740.1/openapi.yaml) (The Plaid API, `info.version` `2020-09-14_1.740.1`).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

Item 1 is applied to `docs/spec/openapi.json`. Items 2-8 are applied to `docs/spec/aligned_ballerina_openapi.json` after `bal openapi flatten` and `bal openapi align`; a regeneration that re-runs flatten and align from `openapi.json` must re-apply them. Operation-ID and schema-name decisions are persisted in `docs/spec/ai-mappings.json` and re-apply automatically.

1. Check in the specification as JSON instead of YAML
- **Original**: Plaid publishes the specification as YAML (`openapi.yaml`, 3,163,761 code points).
- **Updated**: `docs/spec/openapi.json` holds the same document converted to JSON, with dates and timestamps kept as strings (a data comparison of the two documents is equal). No YAML copy is kept in `docs/spec/`.
- **Reason**: `bal openapi`'s YAML parser (snakeyaml) rejects documents over 3,145,728 code points ("The incoming YAML document exceeds the limit"), so every subcommand fails on the YAML with only "malformed or unreadable swagger supplied". JSON input has no such limit.

2. Collapse `AmountWithCurrencyWithMonthlyAverage` to a single base schema
- **Original**: `AmountWithCurrencyWithMonthlyAverage` was `allOf: [AmountWithCurrency, MonthlyAverage]`, and both members declare the same three properties (`amount`, `iso_currency_code`, `unofficial_currency_code`) with identical types.
- **Updated**: `allOf: [AmountWithCurrency]`, keeping the schema's description, `nullable` and `additionalProperties`.
- **Reason**: The generated record included both members and failed to compile with `redeclared symbol 'amount'` (and the two currency fields). The wire shape is unchanged, since both members describe the same fields.

3. Collapse string-typed `allOf` properties to a single reference
- **Original**: `SessionTokenCreateRequestUser.user_id` was `allOf: [UserId, {type: string, description}]` and `PaymentInitiationConsentPaymentExecuteRequest.scope` was `allOf: [PaymentInitiationConsentScope, {type: string, description, nullable: true}]`.
- **Updated**: `allOf: [<reference>]`, with the second member's `description` (and `nullable`) moved onto the property.
- **Reason**: The generator turned each into `record {*UserId;}` and `record {*PaymentInitiationConsentScope;}`, which do not compile because the referenced types are strings (`'UserId' is not a record`).

4. Name the API-key fields after the published connector
- **Original**: `align` named the `clientId` and `secret` API-key schemes `pLAIDCLIENTID` and `pLAIDSECRET` (from the `PLAID-CLIENT-ID` and `PLAID-SECRET` header names).
- **Updated**: `x-ballerina-name` is `plaidClientId`, `plaidSecret` and `plaidVersion` on the `clientId`, `secret` and `plaidVersion` security schemes, and each scheme has a description of the credential and its header.
- **Reason**: These are the `ApiKeysConfig` field names of the published 1.x connector, and the aligned names are unreadable.

5. Describe fields that have no description
- **Original**: 1,053 schema properties had no description or one under 10 characters. 898 of them are `$ref` properties that `align` wraps as `allOf: [$ref]` with an `x-ballerina-name`, which leaves them without a description of their own.
- **Updated**: Each `allOf: [$ref]` property takes the description of the schema it references (898); a multi-member `allOf` takes the description its non-reference member carries (7); arrays read `List of <items>` (73); the rest were written from the property and its parent schema (75), for example `PartnerEndCustomerAddress.city` → "The city of the end customer's address".
- **Reason**: Undescribed fields produce undocumented record fields in `types.bal`.

6. Describe request bodies and typed responses
- **Original**: None of the 344 request bodies had a description, and 344 typed 2xx responses were described only as `OK`, `success` or `Created`.
- **Updated**: Request bodies read `Request to <summary>` and typed responses read `Response to a request to <summary>`, derived from each operation's summary (for example `assetReportCreate`: "Request to create an Asset Report" / "Response to a request to create an Asset Report"). Responses without a body keep their original descriptions.
- **Reason**: These become the `payload` and `return` doc comments of every client method.

7. Disambiguate duplicate operation summaries
- **Original**: 12 pairs of operations shared a summary, for example `transactionsGet` and `processorTransactionsGet` ("Get transaction data").
- **Updated**: 13 summaries rewritten: the `/processor/...` variants add "using a processor token"; `/beta/partner/customer/v1/create` and `/enable` add "(beta v1)"; `/profile/network_status/get` adds "by profile"; `/cashflow_report/get` and `/cashflow_report/transactions/get` read "Get the transaction data in a cash flow report" and "Get the transactions of a cash flow report".
- **Reason**: The summary is each client method's doc comment, so duplicates make the methods indistinguishable in the API docs.

8. Keep Plaid's operation IDs and schema names
- **Original**: The specification's operation IDs (for example `itemGet`, `assetReportCreate`) and schema names.
- **Updated**: Unchanged. All 351 operation IDs and 2,274 schema names are recorded as identity decisions in `ai-mappings.json`. Ten operation IDs exceed 37 characters (for example `watchlistScreeningIndividualHistoryList`) and are kept, so that each operation family keeps one naming pattern. `align` itself renamed ten schemas to remove double underscores (for example `DocumentImage__Front` → `DocumentImageFront`).
- **Reason**: The 83 operations carried over from 1.x keep their published method names, and every name matches Plaid's API reference.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --license docs/license.txt --client-methods remote
```

Note: The license year is hardcoded to 2026, change if necessary.
