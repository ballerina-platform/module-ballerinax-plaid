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
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://sandbox.plaid.com" : "http://localhost:9090";
final string clientId = isLiveServer ? os:getEnv("PLAID_CLIENT_ID") : "mock-client-id";
final string secret = isLiveServer ? os:getEnv("PLAID_SECRET") : "mock-sandbox-secret";

const string PLAID_VERSION = "2020-09-14";
// First Platypus Bank, the non-OAuth sandbox institution
const string SANDBOX_INSTITUTION_ID = "ins_109508";

// The mock is plain HTTP, so the HTTP/2 client would negotiate an h2c upgrade against it.
final Client plaid = check new ({
        auth: {plaidClientId: clientId, plaidSecret: secret, plaidVersion: PLAID_VERSION},
        httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
    },
    serviceUrl
);

# Creates a sandbox Item for the given products and exchanges its public token.
#
# + products - The products to initialise the Item with
# + return - The access token of the new Item
isolated function newSandboxAccessToken(Products[] products) returns string|error {
    SandboxPublicTokenCreateResponse created = check plaid->sandboxPublicTokenCreate({
        institutionId: SANDBOX_INSTITUTION_ID,
        initialProducts: products
    });
    ItemPublicTokenExchangeResponse exchanged = check plaid->itemPublicTokenExchange({
        publicToken: created.public_token
    });
    return exchanged.access_token;
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testLinkTokenCreate() returns error? {
    LinkTokenCreateResponse response = check plaid->linkTokenCreate({
        clientName: "Ballerina Plaid Connector",
        language: "en",
        countryCodes: ["US"],
        user: {clientUserId: "ballerina-test-user"},
        products: ["auth"]
    });
    test:assertTrue(response.link_token.startsWith("link-"));
    test:assertNotEquals(response.expiration, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testLinkTokenGet() returns error? {
    LinkTokenCreateResponse created = check plaid->linkTokenCreate({
        clientName: "Ballerina Plaid Connector",
        language: "en",
        countryCodes: ["US"],
        user: {clientUserId: "ballerina-test-user"},
        products: ["auth"]
    });
    LinkTokenGetResponse response = check plaid->linkTokenGet({linkToken: created.link_token});
    test:assertEquals(response.link_token, created.link_token);
    CountryCode us = "US";
    test:assertTrue(response.metadata.country_codes.indexOf(us) !is ());
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testSandboxPublicTokenCreate() returns error? {
    SandboxPublicTokenCreateResponse response = check plaid->sandboxPublicTokenCreate({
        institutionId: SANDBOX_INSTITUTION_ID,
        initialProducts: ["auth"]
    });
    test:assertTrue(response.public_token.startsWith("public-"));
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testItemPublicTokenExchange() returns error? {
    SandboxPublicTokenCreateResponse created = check plaid->sandboxPublicTokenCreate({
        institutionId: SANDBOX_INSTITUTION_ID,
        initialProducts: ["auth"]
    });
    ItemPublicTokenExchangeResponse response = check plaid->itemPublicTokenExchange({
        publicToken: created.public_token
    });
    test:assertTrue(response.access_token.startsWith("access-"));
    test:assertNotEquals(response.item_id, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testItemGet() returns error? {
    string accessToken = check newSandboxAccessToken(["auth"]);
    ItemGetResponse response = check plaid->itemGet({accessToken});
    test:assertNotEquals(response.item.item_id, "");
    test:assertEquals(response.item?.institution_id, SANDBOX_INSTITUTION_ID);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testItemGetWithInvalidAccessToken() {
    ItemGetResponse|error response = plaid->itemGet({accessToken: "not-an-access-token"});
    test:assertTrue(response is error, "an invalid access token must be rejected");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testItemWebhookUpdate() returns error? {
    string accessToken = check newSandboxAccessToken(["auth"]);
    string webhook = "https://www.genericwebhookurl.com/webhook";
    ItemWebhookUpdateResponse response = check plaid->itemWebhookUpdate({accessToken, webhook});
    test:assertEquals(response.item.webhook, webhook);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testItemRemove() returns error? {
    // create the Item this test removes, so no other test loses its fixture
    SandboxPublicTokenCreateResponse created = check plaid->sandboxPublicTokenCreate({
        institutionId: SANDBOX_INSTITUTION_ID,
        initialProducts: ["auth"]
    });
    ItemPublicTokenExchangeResponse exchanged = check plaid->itemPublicTokenExchange({
        publicToken: created.public_token
    });
    ItemRemoveResponse response = check plaid->itemRemove({accessToken: exchanged.access_token});
    test:assertNotEquals(response.request_id, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testAccountsGet() returns error? {
    string accessToken = check newSandboxAccessToken(["auth"]);
    AccountsGetResponse response = check plaid->accountsGet({accessToken});
    test:assertTrue(response.accounts.length() > 0);
    test:assertNotEquals(response.accounts[0].account_id, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testAccountsBalanceGet() returns error? {
    string accessToken = check newSandboxAccessToken(["auth"]);
    AccountsGetResponse response = check plaid->accountsBalanceGet({accessToken});
    test:assertTrue(response.accounts.length() > 0);
    test:assertTrue(response.accounts[0].balances.current is decimal);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testAuthGet() returns error? {
    string accessToken = check newSandboxAccessToken(["auth"]);
    AuthGetResponse response = check plaid->authGet({accessToken});
    test:assertTrue(response.numbers.ach.length() > 0);
    test:assertNotEquals(response.numbers.ach[0].routing, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testIdentityGet() returns error? {
    string accessToken = check newSandboxAccessToken(["identity"]);
    IdentityGetResponse response = check plaid->identityGet({accessToken});
    test:assertTrue(response.accounts.length() > 0);
    test:assertTrue(response.accounts[0].owners.length() > 0);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testTransactionsSync() returns error? {
    string accessToken = check newSandboxAccessToken(["transactions"]);
    TransactionsSyncResponse response = check plaid->transactionsSync({accessToken, count: 50});
    test:assertNotEquals(response.request_id, "");
    test:assertTrue(response.added.length() + response.modified.length() + response.removed.length() >= 0);
}

// Transactions are prepared asynchronously after an Item is created, so a fresh sandbox
// Item answers PRODUCT_NOT_READY; this runs against the mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testTransactionsGet() returns error? {
    TransactionsGetResponse response = check plaid->transactionsGet({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        startDate: "2026-02-01",
        endDate: "2026-02-28"
    });
    test:assertTrue(response.transactions.length() > 0);
    test:assertEquals(response.total_transactions, response.transactions.length());
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testTransactionsRefresh() returns error? {
    string accessToken = check newSandboxAccessToken(["transactions"]);
    TransactionsRefreshResponse response = check plaid->transactionsRefresh({accessToken});
    test:assertNotEquals(response.request_id, "");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testInstitutionsGet() returns error? {
    InstitutionsGetResponse response = check plaid->institutionsGet({count: 2, offset: 0, countryCodes: ["US"]});
    test:assertTrue(response.institutions.length() > 0);
    test:assertTrue(response.total > 0);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testInstitutionsGetById() returns error? {
    InstitutionsGetByIdResponse response = check plaid->institutionsGetById({
        institutionId: SANDBOX_INSTITUTION_ID,
        countryCodes: ["US"]
    });
    test:assertEquals(response.institution.institution_id, SANDBOX_INSTITUTION_ID);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testInstitutionsSearch() returns error? {
    InstitutionsSearchResponse response = check plaid->institutionsSearch({
        query: "Platypus",
        countryCodes: ["US"]
    });
    test:assertTrue(response.institutions.length() > 0);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testInvestmentsHoldingsGet() returns error? {
    string accessToken = check newSandboxAccessToken(["investments"]);
    InvestmentsHoldingsGetResponse response = check plaid->investmentsHoldingsGet({accessToken});
    test:assertTrue(response.holdings.length() > 0);
    test:assertTrue(response.securities.length() > 0);
}

// Investment transactions are also prepared asynchronously; mock only, as for transactions.
@test:Config {
    groups: ["mock_tests"]
}
function testInvestmentsTransactionsGet() returns error? {
    InvestmentsTransactionsGetResponse response = check plaid->investmentsTransactionsGet({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        startDate: "2026-01-01",
        endDate: "2026-02-28"
    });
    test:assertTrue(response.investment_transactions.length() > 0);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testLiabilitiesGet() returns error? {
    string accessToken = check newSandboxAccessToken(["liabilities"]);
    LiabilitiesGetResponse response = check plaid->liabilitiesGet({accessToken});
    test:assertTrue(response.accounts.length() > 0);
    CreditCardLiability[]? credit = response.liabilities.credit;
    test:assertTrue(credit is CreditCardLiability[] && credit.length() > 0);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testAssetReportCreate() returns error? {
    string accessToken = check newSandboxAccessToken(["assets"]);
    AssetReportCreateResponse response = check plaid->assetReportCreate({
        accessTokens: [accessToken],
        daysRequested: 30
    });
    test:assertTrue(response.asset_report_token.startsWith("assets-"));
}

// Asset Reports are generated asynchronously and signalled by webhook; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testAssetReportGet() returns error? {
    AssetReportGetResponse response = check plaid->assetReportGet({
        assetReportToken: "assets-sandbox-6f12f5bb-22dd-4855-b918-f47ec439198a"
    });
    test:assertTrue(response.report.items.length() > 0);
    test:assertEquals(response.report.days_requested, 30d);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
function testAssetReportRemove() returns error? {
    // create the report this test removes
    string accessToken = check newSandboxAccessToken(["assets"]);
    AssetReportCreateResponse created = check plaid->assetReportCreate({
        accessTokens: [accessToken],
        daysRequested: 30
    });
    AssetReportRemoveResponse response = check plaid->assetReportRemove({
        assetReportToken: created.asset_report_token
    });
    test:assertTrue(response.removed);
}

// Processor tokens need a processor partnership enabled on the Plaid account; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testProcessorTokenCreate() returns error? {
    ProcessorTokenCreateResponse response = check plaid->processorTokenCreate({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        accountId: "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp",
        processor: "dwolla"
    });
    test:assertTrue(response.processor_token.startsWith("processor-"));
}

// Plaid Transfer must be enabled for the account before these can run live; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testTransferAuthorizationCreate() returns error? {
    TransferAuthorizationCreateResponse response = check plaid->transferAuthorizationCreate({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        accountId: "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp",
        'type: "debit",
        network: "ach",
        amount: "12.34",
        user: {legalName: "Anne Charleston"}
    });
    test:assertEquals(response.authorization.decision, "approved");
    test:assertEquals(response.authorization.proposed_transfer.amount, "12.34");
}

@test:Config {
    groups: ["mock_tests"]
}
function testTransferCreate() returns error? {
    TransferCreateResponse response = check plaid->transferCreate({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        accountId: "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp",
        authorizationId: "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
        description: "INV 1042"
    });
    test:assertEquals(response.transfer.authorization_id, "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9");
    test:assertEquals(response.transfer.description, "INV 1042");
}

@test:Config {
    groups: ["mock_tests"]
}
function testTransferGet() returns error? {
    TransferGetResponse response = check plaid->transferGet({transferId: "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9"});
    test:assertEquals(response.transfer.id, "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9");
    test:assertEquals(response.transfer.status, "pending");
}

// Firing a webhook live needs an Item created with a webhook URL that is reachable; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testSandboxItemFireWebhook() returns error? {
    SandboxItemFireWebhookResponse response = check plaid->sandboxItemFireWebhook({
        accessToken: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
        webhookCode: "DEFAULT_UPDATE"
    });
    test:assertTrue(response.webhook_fired);
}

// FDX consent grants exist only for accounts enrolled in Plaid's FDX programme; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testFdxConsentsGet() returns error? {
    FDXConsentGrant response = check plaid->fdxConsentsGet("9cf1a5c2-6c4b-4f0d-8d5e-0b1f2e3a4b5c");
    test:assertEquals(response.id, "9cf1a5c2-6c4b-4f0d-8d5e-0b1f2e3a4b5c");
    test:assertEquals(response.status, "ACTIVE");
}

// A verification key id comes from the JWT header of a received webhook; mock only.
@test:Config {
    groups: ["mock_tests"]
}
function testWebhookVerificationKeyGet() returns error? {
    WebhookVerificationKeyGetResponse response = check plaid->webhookVerificationKeyGet({
        keyId: "6c5516e1-92dc-479e-a8ff-5a51992e0001"
    });
    test:assertEquals(response.'key.kid, "6c5516e1-92dc-479e-a8ff-5a51992e0001");
    test:assertEquals(response.'key.alg, "ES256");
}
