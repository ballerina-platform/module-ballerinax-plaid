# Running tests

The test suite exercises 30 of the connector's operations: Link token creation and lookup, Sandbox Item creation and public-token exchange, Item retrieval, webhook update and removal, accounts and real-time balances, Auth, Identity, transaction sync, retrieval and refresh, institution listing, lookup and search, investment holdings and transactions, liabilities, Asset Report creation, retrieval and removal, processor tokens, Transfer authorization, creation and retrieval, Sandbox webhooks, FDX consent grants and webhook verification keys. It also checks that a malformed access token is rejected.

Each test that removes something (an Item, an Asset Report) creates it first, so no test depends on another's fixture.

There are two test environments. The default is a mock server that runs locally on port 9090 (`tests/mock_service.bal`); the other is Plaid's Sandbox.

| Test group | Environment |
|---|---|
| `mock_tests` | Mock server (default) |
| `live_tests` | Plaid Sandbox (`https://sandbox.plaid.com`) |

Ten tests belong to `mock_tests` only, because a plain Sandbox account cannot serve them reliably: transactions, investment transactions and Asset Reports are prepared asynchronously after an Item is created; processor tokens, Plaid Transfer and FDX consent grants must be enabled for the Plaid account; firing a Sandbox webhook needs a reachable webhook URL; and a webhook verification key ID comes from a received webhook.

## Running tests against the mock server

```bash
bal test
```

Or, with Gradle from the repository root:

```bash
./gradlew clean test
```

## Running tests against Plaid Sandbox

Set the following environment variables. `PLAID_SECRET` must be your **Sandbox** secret; the live tests create and remove Sandbox Items only.

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to run against Plaid Sandbox |
| `PLAID_CLIENT_ID` | Your Plaid `client_id`, from **Developers** → **Keys** in the Plaid Dashboard |
| `PLAID_SECRET` | Your Plaid Sandbox secret |

```bash
export IS_LIVE_SERVER=true
export PLAID_CLIENT_ID="<Your Plaid client ID>"
export PLAID_SECRET="<Your Plaid Sandbox secret>"
bal test --groups live_tests
```

Or, with Gradle:

```bash
./gradlew clean test -Pgroups=live_tests
```
