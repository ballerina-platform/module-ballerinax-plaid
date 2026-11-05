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

import ballerina/http;

const string MOCK_ITEM_ID = "eVBnVMp7zdTJLkRNr33Rs6zr7KNJqBFL9DrE6";
const string MOCK_INSTITUTION_ID = "ins_109508";
const string MOCK_CHECKING_ACCOUNT_ID = "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp";
const string MOCK_SAVINGS_ACCOUNT_ID = "dVzbVMLjrxTnLjX4G66XUp5GLklm4oiZy88yK";
const string MOCK_INVESTMENT_ACCOUNT_ID = "k67E4xKvMlhmleEa4pg9hlwGGNnnEeixPolGm";
const string MOCK_CREDIT_ACCOUNT_ID = "3gE5gnRzNyfXpBK5wEEKcymJ5albGVUqg77gr";
const string MOCK_REQUEST_ID = "m8MDnv9okwxFNBV";

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Get FDX consent grant
    #
    # + consentId - Unique identifier of the consent grant
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get FDX consent grant)
    # http:DefaultStatusCodeResponse (Error response)
    resource function get fdx/consents/[string consentId]() returns FDXConsentGrant|FDXErrorDefault {
        FDXConsentGrant grant = {
            id: consentId,
            status: "ACTIVE",
            createdTime: "2026-03-02T15:04:05Z",
            updatedTime: "2026-03-02T15:04:05Z",
            parties: [
                {name: "Plaid", 'type: "DATA_ACCESS_PLATFORM"},
                {name: "First Platypus Bank", 'type: "DATA_PROVIDER"}
            ]
        };
        return grant;
    }

    # Retrieve real-time balance data
    #
    # + payload - Request to retrieve real-time balance data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve real-time balance data)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post accounts/balance/get(@http:Payload AccountsBalanceGetRequest payload) returns AccountsGetResponseOk|PlaidErrorDefault {
        return {body: {accounts: mockDepositoryAccounts(), item: mockItem(), request_id: MOCK_REQUEST_ID}};
    }

    # Retrieve accounts
    #
    # + payload - Request to retrieve accounts
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve accounts)
    # http:DefaultStatusCodeResponse (Error response.)
    resource function post accounts/get(@http:Payload AccountsGetRequest payload) returns AccountsGetResponseOk|PlaidErrorDefault {
        return {body: {accounts: mockDepositoryAccounts(), item: mockItem(), request_id: MOCK_REQUEST_ID}};
    }

    # Create an Asset Report
    #
    # + payload - Request to create an Asset Report
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create an Asset Report)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post asset_report/create(@http:Payload AssetReportCreateRequest payload) returns AssetReportCreateResponseOk|PlaidErrorDefault {
        return {
            body: {
                asset_report_token: "assets-sandbox-6f12f5bb-22dd-4855-b918-f47ec439198a",
                asset_report_id: "1f414183-220c-44f5-b0c8-bc0e6d4053bb",
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Retrieve an Asset Report
    #
    # + payload - Request to retrieve an Asset Report
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve an Asset Report)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post asset_report/get(@http:Payload AssetReportGetRequest payload) returns AssetReportGetResponseOk|PlaidErrorDefault {
        AssetReport report = {
            asset_report_id: "1f414183-220c-44f5-b0c8-bc0e6d4053bb",
            client_report_id: "client_report_id_1221",
            date_generated: "2026-03-02T15:04:05Z",
            days_requested: 30,
            user: {client_user_id: "user-7f3b2c", first_name: "Alberta", last_name: "Charleson"},
            items: [
                {
                    item_id: MOCK_ITEM_ID,
                    institution_name: "First Platypus Bank",
                    institution_id: MOCK_INSTITUTION_ID,
                    date_last_updated: "2026-03-02T15:04:05Z",
                    accounts: [
                        {
                            account_id: MOCK_CHECKING_ACCOUNT_ID,
                            balances: {
                                available: 100,
                                current: 110,
                                'limit: (),
                                margin_loan_amount: (),
                                iso_currency_code: "USD",
                                unofficial_currency_code: ()
                            },
                            mask: "0000",
                            name: "Plaid Checking",
                            official_name: "Plaid Gold Standard 0% Interest Checking",
                            'type: "depository",
                            subtype: "checking",
                            days_available: 30,
                            transactions: [
                                {
                                    account_id: MOCK_CHECKING_ACCOUNT_ID,
                                    amount: 6.33,
                                    iso_currency_code: "USD",
                                    unofficial_currency_code: (),
                                    original_description: "Uber 072515 SF**POOL**",
                                    date: "2026-02-24",
                                    pending: false,
                                    transaction_id: "lPNjeW1nR6CDn5okmGQ6hEpMo4lLNoSrzqDje"
                                }
                            ],
                            owners: [mockOwner()],
                            historical_balances: [
                                {date: "2026-03-01", current: 110, iso_currency_code: "USD", unofficial_currency_code: ()}
                            ]
                        }
                    ]
                }
            ]
        };
        return {body: {report, warnings: [], request_id: MOCK_REQUEST_ID}};
    }

    # Delete an Asset Report
    #
    # + payload - Request to delete an Asset Report
    # + return - returns can be any of following types
    # http:Ok (Response to a request to delete an Asset Report)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post asset_report/remove(@http:Payload AssetReportRemoveRequest payload) returns AssetReportRemoveResponseOk|PlaidErrorDefault {
        return {body: {removed: true, request_id: MOCK_REQUEST_ID}};
    }

    # Retrieve auth data
    #
    # + payload - Request to retrieve auth data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve auth data)
    # http:DefaultStatusCodeResponse (Default error)
    resource function post auth/get(@http:Payload AuthGetRequest payload) returns AuthGetResponseOk|PlaidErrorDefault {
        return {
            body: {
                accounts: mockDepositoryAccounts(),
                numbers: {
                    ach: [
                        {
                            account_id: MOCK_CHECKING_ACCOUNT_ID,
                            account: "1111222233330000",
                            routing: "011401533",
                            wire_routing: "021000021"
                        }
                    ],
                    eft: [],
                    international: [],
                    bacs: []
                },
                item: mockItem(),
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Retrieve identity data
    #
    # + payload - Request to retrieve identity data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve identity data)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post identity/get(@http:Payload IdentityGetRequest payload) returns IdentityGetResponseOk|PlaidErrorDefault {
        AccountIdentity account = {
            account_id: MOCK_CHECKING_ACCOUNT_ID,
            balances: {available: 100, current: 110, 'limit: (), iso_currency_code: "USD", unofficial_currency_code: ()},
            mask: "0000",
            name: "Plaid Checking",
            official_name: "Plaid Gold Standard 0% Interest Checking",
            'type: "depository",
            subtype: "checking",
            owners: [mockOwner()]
        };
        return {body: {accounts: [account], item: mockItem(), request_id: MOCK_REQUEST_ID}};
    }

    # Get details of all supported institutions
    #
    # + payload - Request to get details of all supported institutions
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get details of all supported institutions)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post institutions/get(@http:Payload InstitutionsGetRequest payload) returns InstitutionsGetResponseOk|PlaidErrorDefault {
        Institution[] institutions = [
            mockInstitution(MOCK_INSTITUTION_ID, "First Platypus Bank"),
            mockInstitution("ins_109509", "First Gingham Credit Union")
        ];
        return {body: {institutions, total: 11342, request_id: MOCK_REQUEST_ID}};
    }

    # Get details of an institution
    #
    # + payload - Request to get details of an institution
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get details of an institution)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post institutions/get_by_id(@http:Payload InstitutionsGetByIdRequest payload) returns InstitutionsGetByIdResponseOk|PlaidErrorDefault {
        return {body: {institution: mockInstitution(payload.institutionId, "First Platypus Bank"), request_id: MOCK_REQUEST_ID}};
    }

    # Search institutions
    #
    # + payload - Request to search institutions
    # + return - returns can be any of following types
    # http:Ok (Response to a request to search institutions)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post institutions/search(@http:Payload InstitutionsSearchRequest payload) returns InstitutionsSearchResponseOk|PlaidErrorDefault {
        return {body: {institutions: [mockInstitution(MOCK_INSTITUTION_ID, "First Platypus Bank")], request_id: MOCK_REQUEST_ID}};
    }

    # Get Investment holdings
    #
    # + payload - Request to get Investment holdings
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get Investment holdings)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post investments/holdings/get(@http:Payload InvestmentsHoldingsGetRequest payload) returns InvestmentsHoldingsGetResponseOk|PlaidErrorDefault {
        Holding holding = {
            account_id: MOCK_INVESTMENT_ACCOUNT_ID,
            security_id: "d6ePmbPxgWCWmMVv66q9iPV94n91vMtov5Are",
            institution_price: 10.42,
            institution_value: 20.84,
            cost_basis: 18.5,
            quantity: 2,
            iso_currency_code: "USD",
            unofficial_currency_code: ()
        };
        return {
            body: {
                accounts: [mockInvestmentAccount()],
                holdings: [holding],
                securities: [mockSecurity()],
                item: mockItem(),
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Get investment transactions
    #
    # + payload - Request to get investment transactions
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get investment transactions)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post investments/transactions/get(@http:Payload InvestmentsTransactionsGetRequest payload) returns InvestmentsTransactionsGetResponseOk|PlaidErrorDefault {
        InvestmentTransaction txn = {
            investment_transaction_id: "oq99Pz97joHQem4BNjXECev1E4B6L6sRzwANW",
            account_id: MOCK_INVESTMENT_ACCOUNT_ID,
            security_id: "d6ePmbPxgWCWmMVv66q9iPV94n91vMtov5Are",
            date: "2026-02-20",
            name: "BUY Achieve Life Sciences",
            quantity: 2,
            amount: 20.84,
            price: 10.42,
            fees: 0,
            'type: "buy",
            subtype: "buy",
            iso_currency_code: "USD",
            unofficial_currency_code: ()
        };
        return {
            body: {
                item: mockItem(),
                accounts: [mockInvestmentAccount()],
                securities: [mockSecurity()],
                investment_transactions: [txn],
                total_investment_transactions: 1,
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Retrieve an Item
    #
    # + payload - Request to retrieve an Item
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve an Item)
    # http:DefaultStatusCodeResponse (Error response.)
    resource function post item/get(@http:Payload ItemGetRequest payload) returns ItemGetResponseOk|PlaidErrorDefault {
        if !payload.accessToken.startsWith("access-") {
            return {
                status: new (400),
                body: {
                    error_type: "INVALID_INPUT",
                    error_code: "INVALID_ACCESS_TOKEN",
                    error_message: "provided access token is in an invalid format. expected format: access-<environment>-<identifier>",
                    display_message: ()
                }
            };
        }
        ItemWithConsentFields item = {...mockItem()};
        return {body: {item, request_id: MOCK_REQUEST_ID}};
    }

    # Exchange public token for an access token
    #
    # + payload - Request to exchange public token for an access token
    # + return - returns can be any of following types
    # http:Ok (Response to a request to exchange public token for an access token)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post item/public_token/exchange(@http:Payload ItemPublicTokenExchangeRequest payload) returns ItemPublicTokenExchangeResponseOk|PlaidErrorDefault {
        return {
            body: {
                access_token: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
                item_id: MOCK_ITEM_ID,
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Remove an Item
    #
    # + payload - Request to remove an Item
    # + return - returns can be any of following types
    # http:Ok (Response to a request to remove an Item)
    # http:DefaultStatusCodeResponse (Error response.)
    resource function post item/remove(@http:Payload ItemRemoveRequest payload) returns ItemRemoveResponseOk|PlaidErrorDefault {
        return {body: {request_id: MOCK_REQUEST_ID}};
    }

    # Update Webhook URL
    #
    # + payload - Request to update Webhook URL
    # + return - returns can be any of following types
    # http:Ok (Response to a request to update Webhook URL)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post item/webhook/update(@http:Payload ItemWebhookUpdateRequest payload) returns ItemWebhookUpdateResponseOk|PlaidErrorDefault {
        Item item = mockItem();
        item.webhook = payload?.webhook;
        return {body: {item, request_id: MOCK_REQUEST_ID}};
    }

    # Retrieve Liabilities data
    #
    # + payload - Request to retrieve Liabilities data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve Liabilities data)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post liabilities/get(@http:Payload LiabilitiesGetRequest payload) returns LiabilitiesGetResponseOk|PlaidErrorDefault {
        AccountBase creditCard = {
            account_id: MOCK_CREDIT_ACCOUNT_ID,
            balances: {available: (), current: 410, 'limit: 2000, iso_currency_code: "USD", unofficial_currency_code: ()},
            mask: "3333",
            name: "Plaid Credit Card",
            official_name: "Plaid Diamond 12.5% APR Interest Credit Card",
            'type: "credit",
            subtype: "credit card"
        };
        CreditCardLiability credit = {
            account_id: MOCK_CREDIT_ACCOUNT_ID,
            aprs: [
                {apr_percentage: 15.24, apr_type: "purchase_apr", balance_subject_to_apr: 410, interest_charge_amount: 5.46}
            ],
            is_overdue: false,
            last_payment_amount: 168.25,
            last_payment_date: "2026-02-16",
            last_statement_issue_date: "2026-02-28",
            last_statement_balance: 1708.77,
            minimum_payment_amount: 20,
            next_payment_due_date: "2026-03-18"
        };
        return {
            body: {
                accounts: [creditCard],
                item: mockItem(),
                liabilities: {credit: [credit], mortgage: (), student: ()},
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Create Link Token
    #
    # + payload - Request to create Link Token
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create Link Token)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post link/token/create(@http:Payload LinkTokenCreateRequest payload) returns LinkTokenCreateResponseOk|PlaidErrorDefault {
        return {
            body: {
                link_token: "link-sandbox-af1a0311-da53-4636-b754-dd15cc058176",
                expiration: "2026-03-02T19:04:05Z",
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Get Link Token
    #
    # + payload - Request to get Link Token
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get Link Token)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post link/token/get(@http:Payload LinkTokenGetRequest payload) returns LinkTokenGetResponseOk|PlaidErrorDefault {
        return {
            body: {
                link_token: payload.linkToken,
                created_at: "2026-03-02T15:04:05Z",
                expiration: "2026-03-02T19:04:05Z",
                metadata: {
                    initial_products: ["auth", "transactions"],
                    webhook: "https://www.genericwebhookurl.com/webhook",
                    country_codes: ["US"],
                    language: "en",
                    redirect_uri: (),
                    client_name: "Ballerina Plaid Connector"
                },
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Create processor token
    #
    # + payload - Request to create processor token
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create processor token)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post processor/token/create(@http:Payload ProcessorTokenCreateRequest payload) returns ProcessorTokenCreateResponseOk|PlaidErrorDefault {
        return {
            body: {
                processor_token: "processor-sandbox-0asd1-a92nc",
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Fire a test webhook
    #
    # + payload - Request to fire a test webhook
    # + return - returns can be any of following types
    # http:Ok (Response to a request to fire a test webhook)
    # http:DefaultStatusCodeResponse (Error response.)
    resource function post sandbox/item/fire_webhook(@http:Payload SandboxItemFireWebhookRequest payload) returns SandboxItemFireWebhookResponseOk|PlaidErrorDefault {
        return {body: {webhook_fired: true, request_id: MOCK_REQUEST_ID}};
    }

    # Create a test Item
    #
    # + payload - Request to create a test Item
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create a test Item)
    # http:DefaultStatusCodeResponse (Error response.)
    resource function post sandbox/public_token/create(@http:Payload SandboxPublicTokenCreateRequest payload) returns SandboxPublicTokenCreateResponseOk|PlaidErrorDefault {
        return {
            body: {
                public_token: "public-sandbox-b0e2c4ee-a763-4df5-bfe9-46a46bce993d",
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Get transaction data
    #
    # + payload - Request to get transaction data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get transaction data)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transactions/get(@http:Payload TransactionsGetRequest payload) returns TransactionsGetResponseOk|PlaidErrorDefault {
        Transaction[] transactions = [mockTransaction(payload.endDate)];
        return {
            body: {
                accounts: mockDepositoryAccounts(),
                transactions,
                total_transactions: transactions.length(),
                item: mockItem(),
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Refresh transaction data
    #
    # + payload - Request to refresh transaction data
    # + return - returns can be any of following types
    # http:Ok (Response to a request to refresh transaction data)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transactions/refresh(@http:Payload TransactionsRefreshRequest payload) returns TransactionsRefreshResponseOk|PlaidErrorDefault {
        return {body: {request_id: MOCK_REQUEST_ID}};
    }

    # Get incremental transaction updates on an Item
    #
    # + payload - Request to get incremental transaction updates on an Item
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get incremental transaction updates on an Item)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transactions/sync(@http:Payload TransactionsSyncRequest payload) returns TransactionsSyncResponseOk|PlaidErrorDefault {
        return {
            body: {
                transactions_update_status: "HISTORICAL_UPDATE_COMPLETE",
                accounts: mockDepositoryAccounts(),
                added: [mockTransaction("2026-02-24")],
                modified: [],
                removed: [{transaction_id: "CmdQTNgems8BT1B7ibkoUXVPyAeehT3Tmzk0l", account_id: MOCK_CHECKING_ACCOUNT_ID}],
                next_cursor: "tVUUL15lYQN5rBnfDIc1I8xudpGdIlw9nsgeXWvhOfkECvUeR663i3Dt1uf/94S8ASkitgLcIiOSqNwzzp+bh89kirazha5vuZHBb2ZA5NtCDkkV",
                has_more: false,
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Create a transfer authorization
    #
    # + payload - Request to create a transfer authorization
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create a transfer authorization)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transfer/authorization/create(@http:Payload TransferAuthorizationCreateRequest payload) returns TransferAuthorizationCreateResponseOk|PlaidErrorDefault {
        TransferAuthorization authorization = {
            id: "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
            created: "2026-03-02T15:04:05Z",
            decision: "approved",
            decision_rationale: (),
            guarantee_decision: (),
            guarantee_decision_rationale: (),
            payment_risk: (),
            proposed_transfer: {
                funding_account_id: "8945fedc-e703-463d-86b1-dc0607b55460",
                'type: payload.'type,
                user: {legal_name: payload.user.legalName, phone_number: (), email_address: (), address: ()},
                amount: payload.amount,
                requested_amount: payload.amount,
                network: payload.network,
                origination_account_id: "",
                iso_currency_code: "USD",
                originator_client_id: (),
                credit_funds_source: ()
            }
        };
        return {body: {authorization, request_id: MOCK_REQUEST_ID}};
    }

    # Create a transfer
    #
    # + payload - Request to create a transfer
    # + return - returns can be any of following types
    # http:Ok (Response to a request to create a transfer)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transfer/create(@http:Payload TransferCreateRequest payload) returns TransferCreateResponseOk|PlaidErrorDefault {
        return {body: {transfer: mockTransfer(payload.authorizationId, payload.description), request_id: MOCK_REQUEST_ID}};
    }

    # Retrieve a transfer
    #
    # + payload - Request to retrieve a transfer
    # + return - returns can be any of following types
    # http:Ok (Response to a request to retrieve a transfer)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post transfer/get(@http:Payload TransferGetRequest payload) returns TransferGetResponseOk|PlaidErrorDefault {
        return {
            body: {
                transfer: mockTransfer("460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9", "INV 1042"),
                request_id: MOCK_REQUEST_ID
            }
        };
    }

    # Get webhook verification key
    #
    # + payload - Request to get webhook verification key
    # + return - returns can be any of following types
    # http:Ok (Response to a request to get webhook verification key)
    # http:DefaultStatusCodeResponse (Error response)
    resource function post webhook_verification_key/get(@http:Payload WebhookVerificationKeyGetRequest payload) returns WebhookVerificationKeyGetResponseOk|PlaidErrorDefault {
        return {
            body: {
                'key: {
                    alg: "ES256",
                    crv: "P-256",
                    kid: payload.keyId,
                    kty: "EC",
                    use: "sig",
                    x: "hKXLGIjWvCBv-cP5euCTxl8g9GLG9zHo_3pO5NN1DwQ",
                    y: "shhexqPB7YffGn6fR6h2UhTSuCtPmfzQJ6ENVIoO4Ys",
                    created_at: 1560466143,
                    expired_at: ()
                },
                request_id: MOCK_REQUEST_ID
            }
        };
    }
}

isolated function mockItem() returns Item => {
    item_id: MOCK_ITEM_ID,
    institution_id: MOCK_INSTITUTION_ID,
    institution_name: "First Platypus Bank",
    webhook: "https://www.genericwebhookurl.com/webhook",
    'error: (),
    available_products: ["balance", "identity", "investments"],
    billed_products: ["auth", "transactions"],
    consent_expiration_time: (),
    update_type: "background"
};

isolated function mockDepositoryAccounts() returns AccountBase[] => [
    {
        account_id: MOCK_CHECKING_ACCOUNT_ID,
        balances: {available: 100, current: 110, 'limit: (), iso_currency_code: "USD", unofficial_currency_code: ()},
        mask: "0000",
        name: "Plaid Checking",
        official_name: "Plaid Gold Standard 0% Interest Checking",
        'type: "depository",
        subtype: "checking"
    },
    {
        account_id: MOCK_SAVINGS_ACCOUNT_ID,
        balances: {available: 200, current: 210, 'limit: (), iso_currency_code: "USD", unofficial_currency_code: ()},
        mask: "1111",
        name: "Plaid Saving",
        official_name: "Plaid Silver Standard 0.1% Interest Saving",
        'type: "depository",
        subtype: "savings"
    }
];

isolated function mockInvestmentAccount() returns InvestmentAccount => {
    account_id: MOCK_INVESTMENT_ACCOUNT_ID,
    balances: {
        available: 43200,
        current: 43200,
        'limit: (),
        iso_currency_code: "USD",
        unofficial_currency_code: (),
        margin_loan_amount: ()
    },
    mask: "5555",
    name: "Plaid IRA",
    official_name: (),
    'type: "investment",
    subtype: "ira"
};

isolated function mockSecurity() returns Security => {
    security_id: "d6ePmbPxgWCWmMVv66q9iPV94n91vMtov5Are",
    isin: "US0072141093",
    cusip: "007214109",
    sedol: (),
    institution_security_id: (),
    institution_id: (),
    proxy_security_id: (),
    name: "Achieve Life Sciences",
    ticker_symbol: "ACHV",
    is_cash_equivalent: false,
    'type: "equity",
    close_price: 10.42,
    close_price_as_of: "2026-02-27",
    iso_currency_code: "USD",
    unofficial_currency_code: (),
    market_identifier_code: "XNAS",
    sector: "Health Technology",
    industry: "Major Pharmaceuticals",
    cfi_code: (),
    figi: (),
    option_contract: (),
    fixed_income: ()
};

isolated function mockOwner() returns Owner => {
    names: ["Alberta Bobbeth Charleson"],
    phone_numbers: [{data: "+1 415-555-0123", primary: true, 'type: "mobile"}],
    emails: [{data: "accountholder0@plaid-sandbox.test", primary: true, 'type: "primary"}],
    addresses: [
        {
            data: {street: "2992 Cameron Road", city: "Malakoff", region: "NY", postal_code: "14236", country: "US"},
            primary: true
        }
    ]
};

isolated function mockInstitution(string institutionId, string name) returns Institution => {
    institution_id: institutionId,
    name,
    products: ["assets", "auth", "balance", "identity", "investments", "liabilities", "transactions"],
    country_codes: ["US"],
    url: "https://plaid.com",
    routing_numbers: ["011000138", "011200365"],
    oauth: false
};

isolated function mockTransaction(string date) returns Transaction => {
    account_id: MOCK_CHECKING_ACCOUNT_ID,
    amount: 72.1,
    iso_currency_code: "USD",
    unofficial_currency_code: (),
    date,
    pending: false,
    transaction_id: "lPNjeW1nR6CDn5okmGQ6hEpMo4lLNoSrzqDje",
    merchant_name: "Walgreens",
    authorized_date: date,
    authorized_datetime: (),
    datetime: (),
    payment_channel: "in store",
    transaction_code: (),
    account_owner: (),
    location: {
        address: "300 Post St",
        city: "San Francisco",
        region: "CA",
        postal_code: "94108",
        country: "US",
        lat: 40.740352,
        lon: -74.001761,
        store_number: "1235"
    },
    name: "Purchase WM SUPERCENTER #1700",
    payment_meta: {
        reference_number: (),
        ppd_id: (),
        payee: (),
        by_order_of: (),
        payer: (),
        payment_method: (),
        payment_processor: (),
        reason: ()
    },
    pending_transaction_id: ()
};

isolated function mockTransfer(string authorizationId, string description) returns Transfer => {
    id: "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
    authorization_id: authorizationId,
    funding_account_id: "8945fedc-e703-463d-86b1-dc0607b55460",
    'type: "debit",
    user: {legal_name: "Anne Charleston", phone_number: (), email_address: (), address: ()},
    amount: "12.34",
    description,
    created: "2026-03-02T15:04:05Z",
    status: "pending",
    network: "ach",
    cancellable: true,
    failure_reason: (),
    metadata: (),
    origination_account_id: "",
    guarantee_decision: (),
    guarantee_decision_rationale: (),
    iso_currency_code: "USD",
    standard_return_window: (),
    unauthorized_return_window: (),
    expected_settlement_date: (),
    originator_client_id: (),
    refunds: [],
    recurring_transfer_id: (),
    credit_funds_source: ()
};

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type AccountsGetResponseOk record {|
    *http:Ok;
    AccountsGetResponse body;
|};

public type AssetReportCreateResponseOk record {|
    *http:Ok;
    AssetReportCreateResponse body;
|};

public type AssetReportGetResponseOk record {|
    *http:Ok;
    AssetReportGetResponse body;
|};

public type AssetReportRemoveResponseOk record {|
    *http:Ok;
    AssetReportRemoveResponse body;
|};

public type AuthGetResponseOk record {|
    *http:Ok;
    AuthGetResponse body;
|};

public type FDXErrorDefault record {|
    *http:DefaultStatusCodeResponse;
    FDXError body;
|};

public type IdentityGetResponseOk record {|
    *http:Ok;
    IdentityGetResponse body;
|};

public type InstitutionsGetByIdResponseOk record {|
    *http:Ok;
    InstitutionsGetByIdResponse body;
|};

public type InstitutionsGetResponseOk record {|
    *http:Ok;
    InstitutionsGetResponse body;
|};

public type InstitutionsSearchResponseOk record {|
    *http:Ok;
    InstitutionsSearchResponse body;
|};

public type InvestmentsHoldingsGetResponseOk record {|
    *http:Ok;
    InvestmentsHoldingsGetResponse body;
|};

public type InvestmentsTransactionsGetResponseOk record {|
    *http:Ok;
    InvestmentsTransactionsGetResponse body;
|};

public type ItemGetResponseOk record {|
    *http:Ok;
    ItemGetResponse body;
|};

public type ItemPublicTokenExchangeResponseOk record {|
    *http:Ok;
    ItemPublicTokenExchangeResponse body;
|};

public type ItemRemoveResponseOk record {|
    *http:Ok;
    ItemRemoveResponse body;
|};

public type ItemWebhookUpdateResponseOk record {|
    *http:Ok;
    ItemWebhookUpdateResponse body;
|};

public type LiabilitiesGetResponseOk record {|
    *http:Ok;
    LiabilitiesGetResponse body;
|};

public type LinkTokenCreateResponseOk record {|
    *http:Ok;
    LinkTokenCreateResponse body;
|};

public type LinkTokenGetResponseOk record {|
    *http:Ok;
    LinkTokenGetResponse body;
|};

public type PlaidErrorDefault record {|
    *http:DefaultStatusCodeResponse;
    PlaidError body;
|};

public type ProcessorTokenCreateResponseOk record {|
    *http:Ok;
    ProcessorTokenCreateResponse body;
|};

public type SandboxItemFireWebhookResponseOk record {|
    *http:Ok;
    SandboxItemFireWebhookResponse body;
|};

public type SandboxPublicTokenCreateResponseOk record {|
    *http:Ok;
    SandboxPublicTokenCreateResponse body;
|};

public type TransactionsGetResponseOk record {|
    *http:Ok;
    TransactionsGetResponse body;
|};

public type TransactionsRefreshResponseOk record {|
    *http:Ok;
    TransactionsRefreshResponse body;
|};

public type TransactionsSyncResponseOk record {|
    *http:Ok;
    TransactionsSyncResponse body;
|};

public type TransferAuthorizationCreateResponseOk record {|
    *http:Ok;
    TransferAuthorizationCreateResponse body;
|};

public type TransferCreateResponseOk record {|
    *http:Ok;
    TransferCreateResponse body;
|};

public type TransferGetResponseOk record {|
    *http:Ok;
    TransferGetResponse body;
|};

public type WebhookVerificationKeyGetResponseOk record {|
    *http:Ok;
    WebhookVerificationKeyGetResponse body;
|};

# Error response for the FDX Consent API. These endpoints use the FDX error format rather than Plaid's standard error object
public type FDXError record {
    # Broad categorization of the error. Stable, and safe for programmatic use. Common values are `BAD_REQUEST`, `NOT_FOUND`, `CONFLICT`, and `INTERNAL_SERVER_ERROR`.
    string error_type;
    # The particular error code. Stable, and safe for programmatic use. For example `32` for a malformed request, `1107` when the consent grant is not found, `409` when the grant is already in a terminal state, and `01` for an internal error.
    string error_code;
    # A developer-friendly description of the error code. Subject to change, so it is not safe for programmatic use.
    string error_message;
};
