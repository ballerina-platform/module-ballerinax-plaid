// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Pages through every transaction of a linked Item with `/transactions/sync`, totals the
// posted outflows by Plaid's personal finance category, and optionally disconnects the
// Item once the report is printed.

import ballerina/io;
import ballerinax/plaid;

configurable string clientId = ?;
configurable string secret = ?;
configurable string accessToken = ?;
configurable string serviceUrl = "https://sandbox.plaid.com";
// Removing an Item revokes the access token for good, so it is opt-in.
configurable boolean removeItemAfterReport = false;

public function main() returns error? {
    plaid:Client plaidClient = check new ({
            auth: {plaidClientId: clientId, plaidSecret: secret, plaidVersion: "2020-09-14"}
        },
        serviceUrl
    );

    // Step 1: sync the whole transaction history, one page at a time
    map<decimal> spendByCategory = {};
    string currency = "";
    string? cursor = ();
    boolean hasMore = true;
    int pages = 0;
    while hasMore {
        plaid:TransactionsSyncRequest request = {accessToken, count: 500};
        if cursor is string {
            request.cursor = cursor;
        }
        plaid:TransactionsSyncResponse page = check plaidClient->transactionsSync(request);
        pages += 1;
        if page.transactions_update_status == "NOT_READY" {
            io:println("Plaid is still extracting this Item's transactions; run again after the INITIAL_UPDATE webhook.");
            return;
        }
        foreach plaid:Transaction txn in page.added {
            // Plaid reports money leaving the account as a positive amount
            if txn.pending || txn.amount <= 0d {
                continue;
            }
            plaid:PersonalFinanceCategory? category = txn?.personal_finance_category;
            string primary = category is plaid:PersonalFinanceCategory ? category.primary : "UNCATEGORIZED";
            spendByCategory[primary] = (spendByCategory[primary] ?: 0d) + txn.amount;
            currency = txn.iso_currency_code ?: currency;
        }
        cursor = page.next_cursor;
        hasMore = page.has_more;
    }

    // Step 2: print the categories, largest spend first
    io:println(string `Synced ${pages} page(s) of transactions`);
    string[] ranked = from [string, decimal] [name, total] in spendByCategory.entries()
        order by total descending
        select name;
    foreach string name in ranked {
        io:println(string `${name}: ${spendByCategory.get(name).round(2).toString()} ${currency}`);
    }

    // Step 3: disconnect the Item if asked to
    if removeItemAfterReport {
        plaid:ItemRemoveResponse removed = check plaidClient->itemRemove({accessToken});
        io:println(string `Removed the Item (request ${removed.request_id})`);
    }
}
