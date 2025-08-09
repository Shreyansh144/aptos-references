// import { aptos } from "../utils/aptos_util";
// import { InputViewFunctionData } from "@aptos-labs/ts-sdk";

// const ACCOUNT = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
// const MODULE_NAME = "PhotonMock";

// const viewModuleFunction = async (symbol: string) => {
//     const payload: InputViewFunctionData = {
//         function: `${ACCOUNT}::${MODULE_NAME}::get_token_price`,
//         typeArguments: [],
//         functionArguments: [`string:${symbol}`],
//       };
//       const output = (await aptos.view({ payload }));
//       console.log(output[0]);
// };

// viewModuleFunction("BTC");

// import { Aptos, Network, InputViewFunctionData } from "@aptos-labs/ts-sdk";
// import { AptosConfig, NetworkToNetworkName } from "@aptos-labs/ts-sdk";
// import { aptos } from "../utils/aptos_util";
  
//   const APTOS_NETWORK: Network = NetworkToNetworkName[Network.TESTNET];

// // Replace with your module address
// const MODULE_ADDRESS = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
// const MODULE_NAME = "PhotonMock";

// // 1. Get metadata object address (the token address)
// async function getMetadataObjectAddress(): Promise<string> {
//   const payload: InputViewFunctionData = {
//     function: `${MODULE_ADDRESS}::${MODULE_NAME}::get_metadata`,
//     typeArguments: [],
//     functionArguments: [],
//   };

//   const result = await aptos.view({ payload });
//   const metadataObjectAddress = result[0] as string;
//   return metadataObjectAddress;
// }

// // 2. Read balance from `0x1::primary_fungible_store::PrimaryFungibleStore<Asset>`
// async function getPhotonTokenBalance(userAddress: string): Promise<string> {
//   const assetAddress = await getMetadataObjectAddress();

//   const resourceType = `0x1::primary_fungible_store::PrimaryFungibleStore<${assetAddress}>`;

//   try {
//     const resource = await aptos.getAccountResource({
//       accountAddress: userAddress,
//       resourceType: `0x1::primary_fungible_store::PrimaryFungibleStore<${assetAddress}>`,
//     });

//     // @ts-ignore
//     return resource.data.balance;
//   } catch (err) {
//     console.error("Failed to get balance:", err);
//     return "0";
//   }
// }

// // Example usage
// (async () => {
//   const user = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
//   const balance = await getPhotonTokenBalance(user);
//   console.log(`Balance of Photon token for ${user}: ${balance}`);
// })();


import { aptos } from "../utils/aptos_util";

const userAddress = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
const assetAddress = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb"; // ← result from get_metadata() view function

const resourceType = `0x1::primary_fungible_store::PrimaryFungibleStore<${assetAddress}>`;

const balance = async () => {
  try {
    const tokenType = "0xabc::my_token::PAT"; // Full struct tag
const resourceType = `0x1::primary_fungible_store::PrimaryFungibleStore<${tokenType}>`;

const resource = await aptos.getAccountResource({
  accountAddress: userAddress,
  resourceType,
});
    const balance = (resource as any).data.balance;
console.log("Balance:", balance);
  } catch (err) {
    console.error("Error reading resource:", err);
  }
};

balance();
