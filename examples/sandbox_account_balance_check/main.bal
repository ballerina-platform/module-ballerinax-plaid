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

// Links a Plaid Sandbox test institution without the Link UI, exchanges the resulting
// public token for an access token, and prints each account's real-time balance next to
// the ACH account and routing numbers needed to move money into it.

import ballerina/io;
import ballerinax/plaid;

configurable string clientId = ?;
configurable string secret = ?;
configurable string institutionId = "ins_109508";

// `/sandbox/public_token/create` exists only in the Sandbox environment.
const string SANDBOX_URL = "https://sandbox.plaid.com";

public function main() returns error? {
    plaid:Client plaidClient = check new ({
            auth: {plaidClientId: clientId, plaidSecret: secret, plaidVersion: "2020-09-14"}
        },
        SANDBOX_URL
    );

    // Step 1: create a test Item for the institution, as if a user had completed Link
    plaid:SandboxPublicTokenCreateResponse publicToken = check plaidClient->sandboxPublicTokenCreate({
        institutionId,
        initialProducts: ["auth"]
    });

    // Step 2: exchange the short-lived public token for a permanent access token
    plaid:ItemPublicTokenExchangeResponse exchanged = check plaidClient->itemPublicTokenExchange({
        publicToken: publicToken.public_token
    });
    string accessToken = exchanged.access_token;
    io:println(string `Linked Item ${exchanged.item_id}`);

    // Step 3: fetch real-time balances; unlike /accounts/get this bypasses Plaid's cache
    plaid:AccountsGetResponse balances = check plaidClient->accountsBalanceGet({accessToken});

    // Step 4: fetch the ACH numbers and index them by account
    plaid:AuthGetResponse auth = check plaidClient->authGet({accessToken});
    map<plaid:NumbersACH> achByAccount = map from plaid:NumbersACH ach in auth.numbers.ach
        select [ach.account_id, ach];

    foreach plaid:AccountBase account in balances.accounts {
        string currency = account.balances.iso_currency_code ?: account.balances.unofficial_currency_code ?: "";
        decimal? current = account.balances.current;
        decimal? available = account.balances.available;
        io:println(string `${account.name} (****${account.mask ?: "----"}), ${account.'type}`);
        io:println(string `  current:   ${current is decimal ? current.toString() : "n/a"} ${currency}`);
        io:println(string `  available: ${available is decimal ? available.toString() : "n/a"} ${currency}`);
        plaid:NumbersACH? ach = achByAccount[account.account_id];
        if ach is plaid:NumbersACH {
            io:println(string `  ACH routing ${ach.routing}, account ${ach.account}`);
        }
    }
}
