# Category spending summary

This example pages through every transaction of a linked Item with `/transactions/sync`, totals the posted outflows by Plaid's personal finance category, and prints the categories from the largest spend to the smallest.

It demonstrates:

1. Cursor pagination with `transactionsSync`: each call returns `next_cursor` and `has_more`, and the loop continues until `has_more` is `false`.
2. Handling a `NOT_READY` update status, which Plaid returns while it is still extracting a newly linked Item's history.
3. Optionally disconnecting the Item with `itemRemove` once the report is printed. Removal revokes the access token permanently, so it runs only when `removeItemAfterReport` is `true`.

Pending transactions and inflows (negative amounts in Plaid's sign convention) are left out of the totals.

## Prerequisites

1. Follow the [setup guide](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/README.md#setup-guide) to obtain your Plaid `client_id` and secret.

2. Obtain an access token for an Item initialised with the `transactions` product, either from your own Link integration or, in Sandbox, by calling `sandboxPublicTokenCreate` with `initialProducts: ["transactions"]` and then `itemPublicTokenExchange`, as the [sandbox account balance check](../sandbox_account_balance_check/sandbox_account_balance_check.md) example does.

3. Create a `Config.toml` file in this directory. Set `serviceUrl` to the Plaid environment the access token belongs to:

    ```toml
    clientId = "<Your Plaid client ID>"
    secret = "<Your Plaid secret for the environment>"
    accessToken = "<Access token of the Item>"
    serviceUrl = "https://sandbox.plaid.com"
    removeItemAfterReport = false
    ```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
