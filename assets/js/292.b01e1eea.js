"use strict";
exports.id = 292;
exports.ids = [292];
exports.modules = {

/***/ 55292:
/***/ ((__unused_webpack___webpack_module__, __webpack_exports__, __webpack_require__) => {

// ESM COMPAT FLAG
__webpack_require__.r(__webpack_exports__);

// EXPORTS
__webpack_require__.d(__webpack_exports__, {
  NestedAppAuthController: () => (/* binding */ NestedAppAuthController)
});

// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/crypto/ICrypto.mjs
var ICrypto = __webpack_require__(49566);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/telemetry/performance/PerformanceEvent.mjs
var PerformanceEvent = __webpack_require__(90177);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/utils/TimeUtils.mjs
var TimeUtils = __webpack_require__(26516);
// EXTERNAL MODULE: ./node_modules/@azure/msal-browser/dist/utils/BrowserConstants.mjs
var BrowserConstants = __webpack_require__(2979);
// EXTERNAL MODULE: ./node_modules/@azure/msal-browser/dist/crypto/CryptoOps.mjs + 6 modules
var CryptoOps = __webpack_require__(69569);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/request/RequestParameterBuilder.mjs
var RequestParameterBuilder = __webpack_require__(16468);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/utils/StringUtils.mjs
var StringUtils = __webpack_require__(26159);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/utils/Constants.mjs
var Constants = __webpack_require__(49279);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/error/ClientAuthError.mjs
var ClientAuthError = __webpack_require__(24228);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/error/ClientAuthErrorCodes.mjs
var ClientAuthErrorCodes = __webpack_require__(47752);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/account/AuthToken.mjs
var AuthToken = __webpack_require__(76831);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/error/ServerError.mjs
var ServerError = __webpack_require__(32111);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/error/InteractionRequiredAuthError.mjs
var InteractionRequiredAuthError = __webpack_require__(85152);
// EXTERNAL MODULE: ./node_modules/@azure/msal-common/dist/error/AuthError.mjs
var AuthError = __webpack_require__(10536);
;// CONCATENATED MODULE: ./node_modules/@azure/msal-browser/dist/naa/BridgeError.mjs
/*! @azure/msal-browser v3.6.0 2023-12-01 */

/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */
function isBridgeError(error) {
    return error.status !== undefined;
}


//# sourceMappingURL=BridgeError.mjs.map

;// CONCATENATED MODULE: ./node_modules/@azure/msal-browser/dist/naa/BridgeStatusCode.mjs
/*! @azure/msal-browser v3.6.0 2023-12-01 */

/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */
var BridgeStatusCode;
(function (BridgeStatusCode) {
    BridgeStatusCode["USER_INTERACTION_REQUIRED"] = "USER_INTERACTION_REQUIRED";
    BridgeStatusCode["USER_CANCEL"] = "USER_CANCEL";
    BridgeStatusCode["NO_NETWORK"] = "NO_NETWORK";
    BridgeStatusCode["TRANSIENT_ERROR"] = "TRANSIENT_ERROR";
    BridgeStatusCode["PERSISTENT_ERROR"] = "PERSISTENT_ERROR";
    BridgeStatusCode["DISABLED"] = "DISABLED";
    BridgeStatusCode["ACCOUNT_UNAVAILABLE"] = "ACCOUNT_UNAVAILABLE";
    BridgeStatusCode["NESTED_APP_AUTH_UNAVAILABLE"] = "NESTED_APP_AUTH_UNAVAILABLE";
})(BridgeStatusCode || (BridgeStatusCode = {}));


//# sourceMappingURL=BridgeStatusCode.mjs.map

;// CONCATENATED MODULE: ./node_modules/@azure/msal-browser/dist/naa/mapping/NestedAppAuthAdapter.mjs
/*! @azure/msal-browser v3.6.0 2023-12-01 */





/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */
class NestedAppAuthAdapter {
    constructor(clientId, clientCapabilities, crypto, logger) {
        this.clientId = clientId;
        this.clientCapabilities = clientCapabilities;
        this.crypto = crypto;
        this.logger = logger;
    }
    toNaaTokenRequest(request) {
        let extraParams;
        if (request.extraQueryParameters === undefined) {
            extraParams = new Map();
        }
        else {
            extraParams = new Map(Object.entries(request.extraQueryParameters));
        }
        const requestBuilder = new RequestParameterBuilder/* RequestParameterBuilder */.H();
        const claims = requestBuilder.addClientCapabilitiesToClaims(request.claims, this.clientCapabilities);
        const tokenRequest = {
            userObjectId: request.account?.homeAccountId,
            clientId: this.clientId,
            authority: request.authority,
            scope: request.scopes.join(" "),
            correlationId: request.correlationId !== undefined
                ? request.correlationId
                : this.crypto.createNewGuid(),
            nonce: request.nonce,
            claims: !StringUtils/* StringUtils */.x.isEmptyObj(claims) ? claims : undefined,
            state: request.state,
            authenticationScheme: request.authenticationScheme || Constants/* AuthenticationScheme */.hO.BEARER,
            extraParameters: extraParams,
        };
        return tokenRequest;
    }
    fromNaaTokenResponse(request, response, reqTimestamp) {
        if (!response.id_token || !response.access_token) {
            throw (0,ClientAuthError/* createClientAuthError */.zP)(ClientAuthErrorCodes/* nullOrEmptyToken */.PM);
        }
        const expiresOn = new Date((reqTimestamp + (response.expires_in || 0)) * 1000);
        const idTokenClaims = AuthToken/* extractTokenClaims */.Z_(response.id_token, this.crypto.base64Decode);
        const account = this.fromNaaAccountInfo(response.account, idTokenClaims);
        const authenticationResult = {
            authority: response.authority || account.environment,
            uniqueId: account.localAccountId,
            tenantId: account.tenantId,
            scopes: response.scope.split(" "),
            account,
            idToken: response.id_token !== undefined ? response.id_token : "",
            idTokenClaims,
            accessToken: response.access_token,
            fromCache: true,
            expiresOn: expiresOn,
            tokenType: request.authenticationScheme || Constants/* AuthenticationScheme */.hO.BEARER,
            correlationId: request.correlationId,
            extExpiresOn: expiresOn,
            state: request.state,
        };
        return authenticationResult;
    }
    /*
     *  export type AccountInfo = {
     *     homeAccountId: string;
     *     environment: string;
     *     tenantId: string;
     *     username: string;
     *     localAccountId: string;
     *     name?: string;
     *     idToken?: string;
     *     idTokenClaims?: TokenClaims & {
     *         [key: string]:
     *             | string
     *             | number
     *             | string[]
     *             | object
     *             | undefined
     *             | unknown;
     *     };
     *     nativeAccountId?: string;
     *     authorityType?: string;
     * };
     */
    fromNaaAccountInfo(fromAccount, idTokenClaims) {
        const effectiveIdTokenClaims = idTokenClaims || fromAccount.idTokenClaims;
        const localAccountId = fromAccount.localAccountId ||
            effectiveIdTokenClaims?.oid ||
            effectiveIdTokenClaims?.sub ||
            "";
        const tenantId = fromAccount.tenantId || effectiveIdTokenClaims?.tid || "";
        const homeAccountId = fromAccount.homeAccountId || `${localAccountId}.${tenantId}`;
        const username = fromAccount.username ||
            effectiveIdTokenClaims?.preferred_username ||
            "";
        const name = fromAccount.name || effectiveIdTokenClaims?.name;
        const account = {
            homeAccountId,
            environment: fromAccount.environment,
            tenantId,
            username,
            localAccountId,
            name,
            idToken: fromAccount.idToken,
            idTokenClaims: effectiveIdTokenClaims,
        };
        return account;
    }
    /**
     *
     * @param error BridgeError
     * @returns AuthError, ClientAuthError, ClientConfigurationError, ServerError, InteractionRequiredError
     */
    fromBridgeError(error) {
        if (isBridgeError(error)) {
            switch (error.status) {
                case BridgeStatusCode.USER_CANCEL:
                    return new ClientAuthError/* ClientAuthError */.er(ClientAuthErrorCodes/* userCanceled */.$R);
                case BridgeStatusCode.NO_NETWORK:
                    return new ClientAuthError/* ClientAuthError */.er(ClientAuthErrorCodes/* noNetworkConnectivity */.Mq);
                case BridgeStatusCode.ACCOUNT_UNAVAILABLE:
                    return new ClientAuthError/* ClientAuthError */.er(ClientAuthErrorCodes/* noAccountFound */.cX);
                case BridgeStatusCode.DISABLED:
                    return new ClientAuthError/* ClientAuthError */.er(ClientAuthErrorCodes/* nestedAppAuthBridgeDisabled */.Ls);
                case BridgeStatusCode.NESTED_APP_AUTH_UNAVAILABLE:
                    return new ClientAuthError/* ClientAuthError */.er(error.code ||
                        ClientAuthErrorCodes/* nestedAppAuthBridgeDisabled */.Ls, error.description);
                case BridgeStatusCode.TRANSIENT_ERROR:
                case BridgeStatusCode.PERSISTENT_ERROR:
                    return new ServerError/* ServerError */.n(error.code, error.description);
                case BridgeStatusCode.USER_INTERACTION_REQUIRED:
                    return new InteractionRequiredAuthError/* InteractionRequiredAuthError */.Yo(error.code, error.description);
                default:
                    return new AuthError/* AuthError */.l4(error.code, error.description);
            }
        }
        else {
            return new AuthError/* AuthError */.l4("unknown_error", "An unknown error occurred");
        }
    }
}


//# sourceMappingURL=NestedAppAuthAdapter.mjs.map

;// CONCATENATED MODULE: ./node_modules/@azure/msal-browser/dist/error/NestedAppAuthError.mjs
/*! @azure/msal-browser v3.6.0 2023-12-01 */



/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */
/**
 * NestedAppAuthErrorMessage class containing string constants used by error codes and messages.
 */
const NestedAppAuthErrorMessage = {
    unsupportedMethod: {
        code: "unsupported_method",
        desc: "The PKCE code challenge and verifier could not be generated.",
    },
};
class NestedAppAuthError extends AuthError/* AuthError */.l4 {
    constructor(errorCode, errorMessage) {
        super(errorCode, errorMessage);
        Object.setPrototypeOf(this, NestedAppAuthError.prototype);
        this.name = "NestedAppAuthError";
    }
    static createUnsupportedError() {
        return new NestedAppAuthError(NestedAppAuthErrorMessage.unsupportedMethod.code, NestedAppAuthErrorMessage.unsupportedMethod.desc);
    }
}


//# sourceMappingURL=NestedAppAuthError.mjs.map

// EXTERNAL MODULE: ./node_modules/@azure/msal-browser/dist/event/EventHandler.mjs
var EventHandler = __webpack_require__(18896);
// EXTERNAL MODULE: ./node_modules/@azure/msal-browser/dist/event/EventType.mjs
var EventType = __webpack_require__(30882);
;// CONCATENATED MODULE: ./node_modules/@azure/msal-browser/dist/controllers/NestedAppAuthController.mjs
/*! @azure/msal-browser v3.6.0 2023-12-01 */









/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */
class NestedAppAuthController {
    constructor(operatingContext) {
        this.operatingContext = operatingContext;
        const proxy = this.operatingContext.getBridgeProxy();
        if (proxy !== undefined) {
            this.bridgeProxy = proxy;
        }
        else {
            throw new Error("unexpected: bridgeProxy is undefined");
        }
        // Set the configuration.
        this.config = operatingContext.getConfig();
        // Initialize logger
        this.logger = this.operatingContext.getLogger();
        // Initialize performance client
        this.performanceClient = this.config.telemetry.client;
        // Initialize the crypto class.
        this.browserCrypto = operatingContext.isBrowserEnvironment()
            ? new CryptoOps/* CryptoOps */.Q(this.logger, this.performanceClient)
            : ICrypto/* DEFAULT_CRYPTO_IMPLEMENTATION */.d;
        this.eventHandler = new EventHandler/* EventHandler */.b(this.logger, this.browserCrypto);
        this.nestedAppAuthAdapter = new NestedAppAuthAdapter(this.config.auth.clientId, this.config.auth.clientCapabilities, this.browserCrypto, this.logger);
    }
    getBrowserStorage() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    getEventHandler() {
        return this.eventHandler;
    }
    static async createController(operatingContext) {
        const controller = new NestedAppAuthController(operatingContext);
        return Promise.resolve(controller);
    }
    initialize() {
        // do nothing not required by this controller
        return Promise.resolve();
    }
    async acquireTokenInteractive(request) {
        this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_START, BrowserConstants/* InteractionType */.s_.Popup, request);
        const atPopupMeasurement = this.performanceClient.startMeasurement(PerformanceEvent/* PerformanceEvents */.Ak.AcquireTokenPopup, request.correlationId);
        atPopupMeasurement?.add({ nestedAppAuthRequest: true });
        try {
            const naaRequest = this.nestedAppAuthAdapter.toNaaTokenRequest(request);
            const reqTimestamp = TimeUtils/* TimeUtils */.I.nowSeconds();
            const response = await this.bridgeProxy.getTokenInteractive(naaRequest);
            const result = this.nestedAppAuthAdapter.fromNaaTokenResponse(naaRequest, response, reqTimestamp);
            this.operatingContext.setActiveAccount(result.account);
            this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_SUCCESS, BrowserConstants/* InteractionType */.s_.Popup, result);
            atPopupMeasurement.add({
                accessTokenSize: result.accessToken.length,
                idTokenSize: result.idToken.length,
            });
            atPopupMeasurement.end({
                success: true,
                requestId: result.requestId,
            });
            return result;
        }
        catch (e) {
            const error = this.nestedAppAuthAdapter.fromBridgeError(e);
            this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_FAILURE, BrowserConstants/* InteractionType */.s_.Popup, null, e);
            atPopupMeasurement.end({
                errorCode: error.errorCode,
                subErrorCode: error.subError,
                success: false,
            });
            throw error;
        }
    }
    async acquireTokenSilentInternal(request) {
        this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_START, BrowserConstants/* InteractionType */.s_.Silent, request);
        const ssoSilentMeasurement = this.performanceClient.startMeasurement(PerformanceEvent/* PerformanceEvents */.Ak.SsoSilent, request.correlationId);
        ssoSilentMeasurement?.increment({
            visibilityChangeCount: 0,
        });
        ssoSilentMeasurement?.add({
            nestedAppAuthRequest: true,
        });
        try {
            const naaRequest = this.nestedAppAuthAdapter.toNaaTokenRequest(request);
            const reqTimestamp = TimeUtils/* TimeUtils */.I.nowSeconds();
            const response = await this.bridgeProxy.getTokenSilent(naaRequest);
            const result = this.nestedAppAuthAdapter.fromNaaTokenResponse(naaRequest, response, reqTimestamp);
            this.operatingContext.setActiveAccount(result.account);
            this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_SUCCESS, BrowserConstants/* InteractionType */.s_.Silent, result);
            ssoSilentMeasurement?.add({
                accessTokenSize: result.accessToken.length,
                idTokenSize: result.idToken.length,
            });
            ssoSilentMeasurement?.end({
                success: true,
                requestId: result.requestId,
            });
            return result;
        }
        catch (e) {
            const error = this.nestedAppAuthAdapter.fromBridgeError(e);
            this.eventHandler.emitEvent(EventType/* EventType */.t.ACQUIRE_TOKEN_FAILURE, BrowserConstants/* InteractionType */.s_.Silent, null, e);
            ssoSilentMeasurement?.end({
                errorCode: error.errorCode,
                subErrorCode: error.subError,
                success: false,
            });
            throw error;
        }
    }
    async acquireTokenPopup(request) {
        return this.acquireTokenInteractive(request);
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    acquireTokenRedirect(request) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    async acquireTokenSilent(silentRequest) {
        return this.acquireTokenSilentInternal(silentRequest);
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    acquireTokenByCode(request // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    acquireTokenNative(request, apiId, // eslint-disable-line @typescript-eslint/no-unused-vars
    accountId // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    acquireTokenByRefreshToken(commonRequest, // eslint-disable-line @typescript-eslint/no-unused-vars
    silentRequest // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    /**
     * Adds event callbacks to array
     * @param callback
     */
    addEventCallback(callback) {
        return this.eventHandler.addEventCallback(callback);
    }
    /**
     * Removes callback with provided id from callback array
     * @param callbackId
     */
    removeEventCallback(callbackId) {
        this.eventHandler.removeEventCallback(callbackId);
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    addPerformanceCallback(callback) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    removePerformanceCallback(callbackId) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    enableAccountStorageEvents() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    disableAccountStorageEvents() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    getAccount(accountFilter) {
        throw NestedAppAuthError.createUnsupportedError();
        // TODO: Look at standard implementation
    }
    getAccountByHomeId(homeAccountId) {
        const currentAccount = this.operatingContext.getActiveAccount();
        if (currentAccount !== undefined) {
            if (currentAccount.homeAccountId === homeAccountId) {
                return this.nestedAppAuthAdapter.fromNaaAccountInfo(currentAccount);
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }
    getAccountByLocalId(localId) {
        const currentAccount = this.operatingContext.getActiveAccount();
        if (currentAccount !== undefined) {
            if (currentAccount.localAccountId === localId) {
                return this.nestedAppAuthAdapter.fromNaaAccountInfo(currentAccount);
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }
    getAccountByUsername(userName) {
        const currentAccount = this.operatingContext.getActiveAccount();
        if (currentAccount !== undefined) {
            if (currentAccount.username === userName) {
                return this.nestedAppAuthAdapter.fromNaaAccountInfo(currentAccount);
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }
    getAllAccounts() {
        const currentAccount = this.operatingContext.getActiveAccount();
        if (currentAccount !== undefined) {
            return [
                this.nestedAppAuthAdapter.fromNaaAccountInfo(currentAccount),
            ];
        }
        else {
            return [];
        }
    }
    handleRedirectPromise(hash // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    loginPopup(request // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        if (request !== undefined) {
            return this.acquireTokenInteractive(request);
        }
        else {
            throw NestedAppAuthError.createUnsupportedError();
        }
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    loginRedirect(request) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    logout(logoutRequest) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    logoutRedirect(logoutRequest // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    logoutPopup(logoutRequest // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    ssoSilent(
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    request) {
        return this.acquireTokenSilentInternal(request);
    }
    getTokenCache() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    /**
     * Returns the logger instance
     */
    getLogger() {
        return this.logger;
    }
    /**
     * Replaces the default logger set in configurations with new Logger with new configurations
     * @param logger Logger instance
     */
    setLogger(logger) {
        this.logger = logger;
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    setActiveAccount(account) {
        /*
         * StandardController uses this to allow the developer to set the active account
         * in the nested app auth scenario the active account is controlled by the app hosting the nested app
         */
        this.logger.warning("nestedAppAuth does not support setActiveAccount");
        return;
    }
    getActiveAccount() {
        const currentAccount = this.operatingContext.getActiveAccount();
        if (currentAccount !== undefined) {
            return this.nestedAppAuthAdapter.fromNaaAccountInfo(currentAccount);
        }
        else {
            return null;
        }
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    initializeWrapperLibrary(sku, version) {
        /*
         * Standard controller uses this to set the sku and version of the wrapper library in the storage
         * we do nothing here
         */
        return;
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    setNavigationClient(navigationClient) {
        this.logger.warning("setNavigationClient is not supported in nested app auth");
    }
    getConfiguration() {
        return this.config;
    }
    isBrowserEnv() {
        return this.operatingContext.isBrowserEnvironment();
    }
    getBrowserCrypto() {
        return this.browserCrypto;
    }
    getPerformanceClient() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    getRedirectResponse() {
        throw NestedAppAuthError.createUnsupportedError();
    }
    preflightBrowserEnvironmentCheck(interactionType, // eslint-disable-line @typescript-eslint/no-unused-vars
    setInteractionInProgress // eslint-disable-line @typescript-eslint/no-unused-vars
    ) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    async clearCache(logoutRequest) {
        throw NestedAppAuthError.createUnsupportedError();
    }
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    async hydrateCache(
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    result, 
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    request) {
        throw NestedAppAuthError.createUnsupportedError();
    }
}


//# sourceMappingURL=NestedAppAuthController.mjs.map


/***/ })

};
;