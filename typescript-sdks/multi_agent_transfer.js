"use strict";
/* eslint-disable max-len */
/* eslint-disable no-console */
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
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * This example shows how to use the Aptos client to create accounts, fund them, and transfer between them.
 */
// import "dotenv";
var ts_sdk_1 = require("@aptos-labs/ts-sdk");
// TODO: There currently isn't a way to use the APTOS_COIN in the COIN_STORE due to a regex
var APTOS_COIN = "0x1::aptos_coin::AptosCoin";
var COIN_STORE = "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>";
var ALICE_INITIAL_BALANCE = 100000000;
var BOB_INITIAL_BALANCE = 100000000;
var TRANSFER_AMOUNT = 10;
// Default to devnet, but allow for overriding
var APTOS_NETWORK = ts_sdk_1.NetworkToNetworkName[(_a = process.env.APTOS_NETWORK) !== null && _a !== void 0 ? _a : ts_sdk_1.Network.DEVNET];
/**
 * Prints the balance of an account
 * @param aptos
 * @param name
 * @param address
 * @returns {Promise<*>}
 *
 */
var balance = function (aptos, name, address) { return __awaiter(void 0, void 0, void 0, function () {
    var resource, amount;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                return [4 /*yield*/, aptos.getAccountResource({
                        accountAddress: address,
                        resourceType: COIN_STORE,
                    })];
            case 1:
                resource = _a.sent();
                amount = Number(resource.coin.value);
                console.log("".concat(name, "'s balance is: ").concat(amount));
                return [2 /*return*/, amount];
        }
    });
}); };
var CREATE_OBJECT_SCRIPT = "0xa11ceb0b060000000601000402040403080a051209071b3608512000000001000302000102000200000402030001060c000105010800066f626a656374067369676e65720a616464726573735f6f660e436f6e7374727563746f725265660d6372656174655f6f626a6563740000000000000000000000000000000000000000000000000000000000000001000001050b00110011010102";
var TRANSFER_SCRIPT = "0xa11ceb0b060000000701000602060a031017042706052d2d075a4b08a5012000000001000201030701000101040800020503040000060602010001070408010801060902010801050207030704060c060c0503010b000108010001060c010501090003060c0503010801010b0001090003060c0b000109000504636f696e066f626a656374067369676e6572064f626a6563740a4f626a656374436f72650a616464726573735f6f66087472616e7366657211616464726573735f746f5f6f626a6563740000000000000000000000000000000000000000000000000000000000000001010000010e0a010a0011000b0338000b0238010c040b000b040b011100380202";
var example = function () { return __awaiter(void 0, void 0, void 0, function () {
    var config, aptos, alice, bob, aliceFundTxn, bobFundTxn, alicePreBalance, bobPreBalance, createObject, pendingObjectTxn, response, objects, objectAddress, transferTxn, aliceSignature, bobSignature, pendingTransferTxn, transferResponse, bobObjectsAfter, alicePostBalance, bobPostBalance;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                console.log("This example will create two accounts (Alice and Bob), fund them, create an object, and transfer the object between them using move scripts and a multi-agent transaction.");
                config = new ts_sdk_1.AptosConfig({ network: APTOS_NETWORK });
                aptos = new ts_sdk_1.Aptos(config);
                alice = ts_sdk_1.Account.generate();
                bob = ts_sdk_1.Account.generate();
                console.log("=== Addresses ===\n");
                console.log("Alice's address is: ".concat(alice.accountAddress));
                console.log("Bob's address is: ".concat(bob.accountAddress));
                // Fund the accounts
                console.log("\n=== Funding accounts ===\n");
                return [4 /*yield*/, aptos.fundAccount({
                        accountAddress: alice.accountAddress,
                        amount: ALICE_INITIAL_BALANCE,
                    })];
            case 1:
                aliceFundTxn = _a.sent();
                console.log("Alice's fund transaction: ", aliceFundTxn);
                return [4 /*yield*/, aptos.fundAccount({
                        accountAddress: bob.accountAddress,
                        amount: BOB_INITIAL_BALANCE,
                    })];
            case 2:
                bobFundTxn = _a.sent();
                console.log("Bob's fund transaction: ", bobFundTxn);
                // Show the balances
                console.log("\n=== Balances ===\n");
                return [4 /*yield*/, balance(aptos, "Alice", alice.accountAddress)];
            case 3:
                alicePreBalance = _a.sent();
                return [4 /*yield*/, balance(aptos, "Bob", bob.accountAddress)];
            case 4:
                bobPreBalance = _a.sent();
                console.log("Alice: ".concat(alicePreBalance));
                console.log("Bob: ".concat(bobPreBalance));
                if (alicePreBalance !== ALICE_INITIAL_BALANCE)
                    throw new Error("Alice's balance is incorrect");
                if (bobPreBalance !== BOB_INITIAL_BALANCE)
                    throw new Error("Bob's balance is incorrect");
                // Create the object
                console.log("\n=== Create an object owned by Alice ===\n");
                return [4 /*yield*/, aptos.transaction.build.simple({
                        sender: alice.accountAddress,
                        data: {
                            bytecode: CREATE_OBJECT_SCRIPT,
                            functionArguments: [],
                        },
                    })];
            case 5:
                createObject = _a.sent();
                return [4 /*yield*/, aptos.signAndSubmitTransaction({ signer: alice, transaction: createObject })];
            case 6:
                pendingObjectTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingObjectTxn.hash })];
            case 7:
                response = _a.sent();
                return [4 /*yield*/, aptos.getAccountOwnedObjects({
                        accountAddress: alice.accountAddress,
                        minimumLedgerVersion: BigInt(response.version),
                    })];
            case 8:
                objects = _a.sent();
                objectAddress = objects[0].object_address;
                console.log("Created object ".concat(objectAddress, " with transaction: ").concat(pendingObjectTxn.hash));
                console.log("\n=== Transfer object ownership to Bob ===\n");
                return [4 /*yield*/, aptos.transaction.build.multiAgent({
                        sender: alice.accountAddress,
                        secondarySignerAddresses: [bob.accountAddress],
                        data: {
                            bytecode: TRANSFER_SCRIPT,
                            typeArguments: [(0, ts_sdk_1.parseTypeTag)(APTOS_COIN)],
                            functionArguments: [ts_sdk_1.AccountAddress.fromString(objectAddress), new ts_sdk_1.U64(TRANSFER_AMOUNT)],
                        },
                    })];
            case 9:
                transferTxn = _a.sent();
                aliceSignature = aptos.transaction.sign({ signer: alice, transaction: transferTxn });
                bobSignature = aptos.transaction.sign({ signer: bob, transaction: transferTxn });
                return [4 /*yield*/, aptos.transaction.submit.multiAgent({
                        transaction: transferTxn,
                        senderAuthenticator: aliceSignature,
                        additionalSignersAuthenticators: [bobSignature],
                    })];
            case 10:
                pendingTransferTxn = _a.sent();
                return [4 /*yield*/, aptos.waitForTransaction({ transactionHash: pendingTransferTxn.hash })];
            case 11:
                transferResponse = _a.sent();
                return [4 /*yield*/, aptos.getAccountOwnedObjects({
                        accountAddress: bob.accountAddress,
                        minimumLedgerVersion: BigInt(transferResponse.version),
                    })];
            case 12:
                bobObjectsAfter = _a.sent();
                if (bobObjectsAfter.find(function (object) { return object.object_address === objectAddress; }) === undefined) {
                    throw new Error("Failed to transfer object to bob ".concat(objectAddress));
                }
                // Check balance
                console.log("\n=== New Balances ===\n");
                return [4 /*yield*/, balance(aptos, "Alice", alice.accountAddress)];
            case 13:
                alicePostBalance = _a.sent();
                return [4 /*yield*/, balance(aptos, "Bob", bob.accountAddress)];
            case 14:
                bobPostBalance = _a.sent();
                if (alicePostBalance >= ALICE_INITIAL_BALANCE + TRANSFER_AMOUNT)
                    throw new Error("Alice's balance is incorrect");
                if (bobPostBalance !== BOB_INITIAL_BALANCE - TRANSFER_AMOUNT)
                    throw new Error("Bob's balance is incorrect");
                return [2 /*return*/];
        }
    });
}); };
example();
