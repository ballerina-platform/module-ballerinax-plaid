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

type CategoryTotal record {|
    string category;
    string currency;
    decimal total;
|};

public function main() returns error? {
    plaid:Client plaidClient = check new ({
            auth: {plaidClientId: clientId, plaidSecret: secret, plaidVersion: "2020-09-14"}
        },
        serviceUrl
    );

    // Step 1: sync the whole transaction history, one page at a time. Later pages can modify
    // or remove transactions returned earlier, so keep the current state by transaction ID.
    map<plaid:Transaction> transactions = {};
    plaid:TransactionsUpdateStatus updateStatus = "TRANSACTIONS_UPDATE_STATUS_UNKNOWN";
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
        updateStatus = page.transactions_update_status;
        if updateStatus == "NOT_READY" {
            io:println("Plaid is still extracting this Item's transactions; run again after the INITIAL_UPDATE webhook.");
            return;
        }
        foreach plaid:Transaction txn in [...page.added, ...page.modified] {
            transactions[txn.transaction_id] = txn;
        }
        foreach plaid:RemovedTransaction txn in page.removed {
            _ = transactions.removeIfHasKey(txn.transaction_id);
        }
        cursor = page.next_cursor;
        hasMore = page.has_more;
    }

    // Step 2: total the posted outflows by category, keeping each currency separate
    map<CategoryTotal> totals = {};
    foreach plaid:Transaction txn in transactions {
        // Plaid reports money leaving the account as a positive amount
        if txn.pending || txn.amount <= 0d {
            continue;
        }
        plaid:PersonalFinanceCategory? category = txn?.personal_finance_category;
        string primary = category is plaid:PersonalFinanceCategory ? category.primary : "UNCATEGORIZED";
        string currency = txn.iso_currency_code ?: txn.unofficial_currency_code ?: "UNKNOWN";
        string key = string `${primary}|${currency}`;
        CategoryTotal? existing = totals[key];
        if existing is CategoryTotal {
            existing.total += txn.amount;
        } else {
            totals[key] = {category: primary, currency, total: txn.amount};
        }
    }

    // Step 3: print the categories, largest spend first
    // Only HISTORICAL_UPDATE_COMPLETE means the full history has been extracted
    boolean complete = updateStatus == "HISTORICAL_UPDATE_COMPLETE";
    io:println(string `Synced ${pages} page(s) of transactions`);
    if !complete {
        io:println("PARTIAL REPORT: Plaid has not finished extracting this Item's history; run again after the HISTORICAL_UPDATE webhook.");
    }
    CategoryTotal[] ranked = from CategoryTotal entry in totals
        order by entry.total descending
        select entry;
    foreach CategoryTotal entry in ranked {
        io:println(string `${entry.category}: ${entry.total.round(2).toString()} ${entry.currency}`);
    }

    // Step 4: disconnect the Item if asked to, but only once the report covers the full history
    if removeItemAfterReport && !complete {
        io:println("Keeping the Item until its historical update completes, so the report can be rerun in full.");
    } else if removeItemAfterReport {
        plaid:ItemRemoveResponse removed = check plaidClient->itemRemove({accessToken});
        io:println(string `Removed the Item (request ${removed.request_id})`);
    }
}
