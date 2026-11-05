# Sandbox account balance check

This example links a Plaid Sandbox test institution without the Link UI, exchanges the resulting public token for an access token, and prints each account's real-time balance next to the ACH account and routing numbers needed to move money into it.

It uses four operations in sequence:

1. `sandboxPublicTokenCreate` creates a test Item for the institution, standing in for a user completing Link.
2. `itemPublicTokenExchange` exchanges the public token for a permanent access token.
3. `accountsBalanceGet` fetches real-time balances, bypassing Plaid's balance cache.
4. `authGet` fetches the ACH numbers, which are matched to accounts by `account_id`.

`/sandbox/public_token/create` exists only in Plaid's Sandbox, so this example always runs against `https://sandbox.plaid.com`. In Production, the public token comes from Link instead of step 1.

## Prerequisites

1. Follow the [setup guide](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/README.md#setup-guide) to obtain your Plaid `client_id` and Sandbox secret.

2. Create a `Config.toml` file in this directory with your credentials. `institutionId` is optional and defaults to First Platypus Bank (`ins_109508`), a non-OAuth Sandbox institution:

    ```toml
    clientId = "<Your Plaid client ID>"
    secret = "<Your Plaid Sandbox secret>"
    institutionId = "ins_109508"
    ```

## Run the example

The example depends on the `ballerinax/plaid` version in this repository through the local repository. Pack the connector and push it there first:

```bash
cd ../../ballerina
bal pack && bal push --repository=local
cd ../examples/sandbox_account_balance_check
```

Then execute the following command to run the example:

```bash
bal run
```
