# Examples

The `ballerinax/plaid` connector provides practical examples illustrating usage in various scenarios.

| Example | Description |
|---------|-------------|
| [`sandbox_account_balance_check`](./sandbox_account_balance_check/sandbox_account_balance_check.md) | Link a Sandbox test institution, then list each account's real-time balance with its ACH numbers. |
| [`category_spending_summary`](./category_spending_summary/category_spending_summary.md) | Page through an Item's transactions with `/transactions/sync` and total the outflows by spending category. |

## Prerequisites

1. Follow the [setup guide](https://github.com/ballerina-platform/module-ballerinax-plaid/tree/main/README.md#setup-guide) to obtain your Plaid `client_id` and secret.

2. For each example, create a `Config.toml` file in the example directory with the values that example's document lists. Both need your API keys:

    ```toml
    clientId = "<Your Plaid client ID>"
    secret = "<Your Plaid secret>"
    ```

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
