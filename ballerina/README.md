## Overview

[Plaid](https://plaid.com/) is a financial data network that connects applications to their users' bank, card, investment and loan accounts. Its API covers linking accounts through Plaid Link, reading balances, transactions, identity and account numbers, verifying income and assets, screening users for compliance, and moving money with Plaid Transfer and Payment Initiation.

The Plaid connector lets Ballerina applications call the Plaid API from Sandbox or Production. It supports Plaid API version `2020-09-14`.

### Key features

- Create Link tokens, exchange public tokens and manage the lifecycle of linked Items
- Read accounts, real-time balances, ACH and international account numbers, and account-holder identity
- Sync and enrich transactions, detect recurring streams and refresh transaction data on demand
- Retrieve investment holdings and transactions, liabilities, statements, Asset Reports and Consumer Report (Plaid Check) data
- Authorize and create transfers, payments and processor tokens, and screen users with Identity Verification, Monitor and Beacon

## Setup guide

To use the Plaid connector, you need a Plaid account and its API keys. With API-key authentication, which every operation supports, each request carries a `client_id`, an environment-specific secret and the API version, sent as the `PLAID-CLIENT-ID`, `PLAID-SECRET` and `Plaid-Version` headers. A client configured with OAuth instead sends a bearer token and none of these headers.

### Step 1: Create a Plaid account

1. Sign up for a free account on the [Plaid Dashboard](https://dashboard.plaid.com/signup). A new account has immediate access to the Sandbox environment, which returns test data from simulated institutions.

2. To use real financial data, request Production access from the Dashboard. Plaid reviews the request and enables each product (Auth, Transactions, Identity and so on) for your team individually.

### Step 2: Get the API keys

1. In the Plaid Dashboard, open **Developers** → **Keys**.

2. Copy your `client_id`. It is the same for every environment.

3. Copy the secret for the environment you will call. Sandbox and Production have separate secrets, and a secret works only against its own environment's URL:

    | Environment | URL |
    |---|---|
    | Sandbox | `https://sandbox.plaid.com` |
    | Production | `https://production.plaid.com` (the connector's default) |

### Step 3 (optional): OAuth client credentials for Plaid Check

The Consumer Report (Plaid Check) endpoints that read `cra/check_report` data (`craCheckReportBaseReportGet`, `craCheckReportIncomeInsightsGet`, `craCheckReportNetworkInsightsGet`, `craCheckReportCashflowInsightsGet` and `craCheckReportLendScoreGet`) also accept an OAuth 2.0 client-credentials token with the `cra:read` scope, issued by `https://api.plaid.com/oauth2/apiv2/token`. Every other operation requires the API keys above, so use OAuth only for a client dedicated to those endpoints.

## Quickstart

To use the Plaid connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `plaid` module.

```ballerina
import ballerinax/plaid;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the credentials obtained in the setup guide:

    ```toml
    clientId = "<Your Plaid client ID>"
    secret = "<Your Plaid Sandbox secret>"
    ```

2. Create a `plaid:ConnectionConfig` with the API keys and initialize the connector with it. Pass the Sandbox URL while developing; omit it to call Production.

```ballerina
configurable string clientId = ?;
configurable string secret = ?;

final plaid:Client plaidClient = check new ({
    auth: {
        plaidClientId: clientId,
        plaidSecret: secret,
        plaidVersion: "2020-09-14"
    }
}, "https://sandbox.plaid.com");
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### List supported institutions

```ballerina
public function main() returns error? {
    plaid:InstitutionsGetResponse _ = check plaidClient->institutionsGet({
        count: 10,
        offset: 0,
        countryCodes: ["US"]
    });
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Plaid` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/examples/), covering the following use cases:

1. [Sandbox account balance check](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/examples/sandbox_account_balance_check) - Link a Sandbox test institution, then list each account's real-time balance with its ACH numbers.
2. [Category spending summary](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/examples/category_spending_summary) - Page through an Item's transactions with `/transactions/sync` and total the outflows by spending category.
