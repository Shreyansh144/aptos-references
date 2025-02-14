"use strict";
/* eslint-disable no-console */
/* eslint-disable max-len */
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Example to demonstrate creating and adding to liquidity pools, swapping between two fungible asset.
 *
 * Steps:
 * 1. Create two accounts (Alice and Bob)
 * 2. Fund Alice and Bob
 * 3. Create a FA with Alice as the owner
 * 4. Create another FA with Bob as the owner
 * 5. Create a liquidity pool with Alice's FA and Bob's FA
 * 6. Swap between Alice's FA and Bob's FA
 */
// import "dotenv";
var ts_sdk_1 = require("@aptos-labs/ts-sdk");
var readline_1 = require("readline");
// Default to devnet, but allow for overriding
var APTOS_NETWORK = ts_sdk_1.NetworkToNetworkName[ts_sdk_1.Network.DEVNET];
var readline = (0, readline_1.createInterface)({
    input: process.stdin,
    output: process.stdout,
});
var getOptimalLpAmount = function (aptos, swap, token1Addr, token2Addr) { return __awaiter(void 0, void 0, void 0, function () {
    var payload, result;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                payload = {
                    function: "".concat(swap.toString(), "::router::optimal_liquidity_amounts"),
                    functionArguments: [token1Addr, token2Addr, false, "200000", "300000", "200", "300"],
                };
                return [4 /*yield*/, aptos.view({ payload: payload })];
            case 1:
                result = _a.sent();
                console.log("Optimal LP amount: ", result);
                return [2 /*return*/];
        }
    });
}); };
var addLiquidity = function (aptos, swap, deployer, token1Addr, token2Addr) { return __awaiter(void 0, void 0, void 0, function () {
    var rawTxn, pendingTxn, response;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.transaction.build.simple({
                    sender: deployer.accountAddress,
                    data: {
                        function: "".concat(swap.toString(), "::router::add_liquidity_entry"),
                        functionArguments: [token1Addr, token2Addr, false, 200000, 300000, 200, 300],
                    },
                })];
            case 1:
                rawTxn = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: deployer, transaction: rawTxn })];
            case 2:
                pendingTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTxn.hash })];
            case 3:
                response = _a.sent();
                console.log("Add liquidity succeed. - ", response.hash);
                return [2 /*return*/, response.hash];
        }
    });
}); };
var swapAssets = function (aptos, swap, deployer, fromToken, toToken, amountIn, amountOutMin, recipient) { return __awaiter(void 0, void 0, void 0, function () {
    var rawTxn, pendingTxn, response;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.transaction.build.simple({
                    sender: deployer.accountAddress.toString(),
                    data: {
                        function: "".concat(swap.toString(), "::router::swap_entry"),
                        functionArguments: [amountIn, amountOutMin, fromToken, toToken, false, recipient],
                    },
                })];
            case 1:
                rawTxn = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: deployer, transaction: rawTxn })];
            case 2:
                pendingTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTxn.hash })];
            case 3:
                response = _a.sent();
                console.log("Swap succeed. - ", response.hash);
                return [2 /*return*/, response.hash];
        }
    });
}); };
var getAssetType = function (aptos, owner) { return __awaiter(void 0, void 0, void 0, function () {
    var data;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.getFungibleAssetMetadata({
                    options: {
                        where: {
                            creator_address: { _eq: owner.accountAddress.toStringLong() },
                        },
                    },
                })];
            case 1:
                data = _a.sent();
                if (data.length !== 2)
                    throw new Error("Expected two Fungible Assets.");
                console.log("Fungible Asset: ", data);
                return [2 /*return*/, {
                        cat: data[0].asset_type,
                        dog: data[1].asset_type,
                    }];
        }
    });
}); };
var getFaBalance = function (aptos, owner, assetType) { return __awaiter(void 0, void 0, void 0, function () {
    var data;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.getCurrentFungibleAssetBalances({
                    options: {
                        where: {
                            owner_address: { _eq: owner.accountAddress.toStringLong() },
                            asset_type: { _eq: assetType },
                        },
                    },
                })];
            case 1:
                data = _a.sent();
                return [2 /*return*/, data[0].amount];
        }
    });
}); };
var createLiquidityPool = function (aptos, swap, deployer, dogCoinAddr, catCoinAddr) { return __awaiter(void 0, void 0, void 0, function () {
    var rawTxn, pendingTxn, response;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.transaction.build.simple({
                    sender: deployer.accountAddress,
                    data: {
                        function: "".concat(swap.toString(), "::router::create_pool"),
                        functionArguments: [dogCoinAddr, catCoinAddr, false],
                    },
                })];
            case 1:
                rawTxn = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: deployer, transaction: rawTxn })];
            case 2:
                pendingTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTxn.hash })];
            case 3:
                response = _a.sent();
                console.log("Creating liquidity pool successful. - ", response.hash);
                return [2 /*return*/, response.hash];
        }
    });
}); };
var initLiquidityPool = function (aptos, swap, deployer) { return __awaiter(void 0, void 0, void 0, function () {
    var rawTxn, pendingTxn, response;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.transaction.build.simple({
                    sender: deployer.accountAddress,
                    data: {
                        function: "".concat(swap.toString(), "::liquidity_pool::initialize"),
                        functionArguments: [],
                    },
                })];
            case 1:
                rawTxn = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: deployer, transaction: rawTxn })];
            case 2:
                pendingTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTxn.hash })];
            case 3:
                response = _a.sent();
                console.log("Init LP Pool success. - ", response.hash);
                return [2 /*return*/, response.hash];
        }
    });
}); };
// eslint-disable-next-line @typescript-eslint/no-unused-vars
var createFungibleAsset = function (aptos, admin) { return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, new Promise(function (resolve) {
                    readline.question("Follow the steps to publish the Dog and Cat Coin module with Admin's address, and press enter. \n" +
                        "1. cd to /aptos-ts-sdk/examples/typescript/move/facoin folder \n" +
                        "2. run 'aptos move publish --named-address FACoin=[admin] --profile=[admin] \n" +
                        "   Note: [admin] is the same profile you used to publish your 'swap' package", function () {
                        resolve();
                    });
                })];
            case 1:
                _a.sent();
                return [2 /*return*/];
        }
    });
}); };
/**
 *  Admin mint the coin
 */
var mintCoin = function (aptos, admin, amount, coinName) { return __awaiter(void 0, void 0, void 0, function () {
    var rawTxn, pendingTxn, response;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, aptos.transaction.build.simple({
                    sender: admin.accountAddress,
                    data: {
                        function: "".concat(admin.accountAddress.toString(), "::").concat(coinName, "::mint"),
                        functionArguments: [admin.accountAddress, amount],
                    },
                })];
            case 1:
                rawTxn = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: admin, transaction: rawTxn })];
            case 2:
                pendingTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTxn.hash })];
            case 3:
                response = _a.sent();
                console.log("Minting ".concat(coinName, " coin successful. - "), response.hash);
                return [2 /*return*/, response.hash];
        }
    });
}); };
var example = function () { return __awaiter(void 0, void 0, void 0, function () {
    var aptosConfig, aptos, swapAddress, admin, assetTypes, dogCoinAddr, catCoinAddr, _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m;
    return __generator(this, function (_o) {
        switch (_o.label) {
            case 0:
                console.log("This example will create a main user account called 'Admin', it will be used to deploy Liquidity pool and two new fungible assets. \n" +
                    "After creating the Dog and Cat coin, and the liquidity pool, it will swap one token for another. \n" +
                    "Note: This example requires you to have the 'swap' module published before running. \n" +
                    "If you haven't published the 'swap' module, please publish the package using \n" +
                    "'aptos move create-resource-account-and-publish-package --seed 0 --address-name=swap --named-addresses deployer=[admin] --profile [admin]' first. \n" +
                    "[admin] is the account profile you will be using for this example. \n");
                // Prerequisite check
                if (process.argv.length !== 4) {
                    console.log("Required usage: pnpm swap [swap_address] [user_private_key]");
                    process.exit(1);
                }
                aptosConfig = new ts_sdk_1.AptosConfig({ network: APTOS_NETWORK });
                aptos = new ts_sdk_1.Aptos(aptosConfig);
                swapAddress = ts_sdk_1.AccountAddress.from(process.argv[2]);
                admin = ts_sdk_1.Account.fromPrivateKey({
                    privateKey: new ts_sdk_1.Ed25519PrivateKey(process.argv[3]),
                    address: swapAddress,
                });
                console.log("====== Account info ======\n");
                console.log("Admin's address is: ".concat(admin.accountAddress.toString()));
                console.log("Swap address is: ".concat(swapAddress.toString()));
                // Fund Admin account
                return [4 /*yield*/, aptos.fundAccount({ accountAddress: admin.accountAddress, amount: 100000000 })];
            case 1:
                // Fund Admin account
                _o.sent();
                console.log("\n====== Create Fungible Asset -> (Dog and Cat coin) ======\n");
                return [4 /*yield*/, createFungibleAsset(aptos, admin)];
            case 2:
                _o.sent();
                return [4 /*yield*/, getAssetType(aptos, admin)];
            case 3:
                assetTypes = _o.sent();
                dogCoinAddr = ts_sdk_1.AccountAddress.from(assetTypes.dog);
                catCoinAddr = ts_sdk_1.AccountAddress.from(assetTypes.cat);
                console.log("Cat FACoin asset type: ".concat(catCoinAddr));
                console.log("Dog FACoin asset type: ".concat(dogCoinAddr));
                console.log("\n====== Mint Dog and Cat Coin ======\n");
                console.log("minting 20_000_000 Dog coin...");
                return [4 /*yield*/, mintCoin(aptos, admin, 20000000, "dog")];
            case 4:
                _o.sent();
                console.log("minting 30_000_000 Cat coin...");
                return [4 /*yield*/, mintCoin(aptos, admin, 30000000, "cat")];
            case 5:
                _o.sent();
                console.log("\n====== Current Balance ======\n");
                _b = (_a = console).log;
                _c = "Admin's Dog coin balance: ".concat;
                return [4 /*yield*/, getFaBalance(aptos, admin, dogCoinAddr.toString())];
            case 6:
                _b.apply(_a, [_c.apply("Admin's Dog coin balance: ", [_o.sent(), "."])]);
                _e = (_d = console).log;
                _f = "Admin's Cat coin balance: ".concat;
                return [4 /*yield*/, getFaBalance(aptos, admin, catCoinAddr.toString())];
            case 7:
                _e.apply(_d, [_f.apply("Admin's Cat coin balance: ", [_o.sent(), "."])]);
                console.log("\n====== Create Liquidity Pool ======\n");
                console.log("initializing Liquidity Pool......");
                return [4 /*yield*/, initLiquidityPool(aptos, swapAddress, admin)];
            case 8:
                _o.sent();
                console.log("Creating liquidity pool......");
                return [4 /*yield*/, createLiquidityPool(aptos, swapAddress, admin, dogCoinAddr, catCoinAddr)];
            case 9:
                _o.sent();
                console.log("Getting optimal LP amount......");
                return [4 /*yield*/, getOptimalLpAmount(aptos, swapAddress, dogCoinAddr, catCoinAddr)];
            case 10:
                _o.sent();
                console.log("Adding liquidity......");
                return [4 /*yield*/, addLiquidity(aptos, swapAddress, admin, dogCoinAddr, catCoinAddr)];
            case 11:
                _o.sent();
                console.log("Done.");
                console.log("\n====== Swap 100 Dog coins for Cat coins ======\n");
                console.log("Swapping 100 Dog coin to Cat coin......");
                return [4 /*yield*/, swapAssets(aptos, swapAddress, admin, dogCoinAddr, catCoinAddr, 100, 1, admin.accountAddress)];
            case 12:
                _o.sent();
                console.log("Swap finished.");
                console.log("\n====== Current Balance ======\n");
                _h = (_g = console).log;
                _j = "Admin's Dog coin balance: ".concat;
                return [4 /*yield*/, getFaBalance(aptos, admin, dogCoinAddr.toString())];
            case 13:
                _h.apply(_g, [_j.apply("Admin's Dog coin balance: ", [_o.sent(), "."])]);
                _l = (_k = console).log;
                _m = "Admin's Cat coin balance: ".concat;
                return [4 /*yield*/, getFaBalance(aptos, admin, catCoinAddr.toString())];
            case 14:
                _l.apply(_k, [_m.apply("Admin's Cat coin balance: ", [_o.sent(), "."])]);
                readline.close();
                return [2 /*return*/];
        }
    });
}); };
example();
