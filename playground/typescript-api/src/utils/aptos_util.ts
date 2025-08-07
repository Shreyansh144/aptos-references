/* eslint-disable no-console */

import { Ed25519PrivateKey, 
    Aptos, AptosConfig, 
    Network, 
    NetworkToNetworkName } from "@aptos-labs/ts-sdk";
  
  const APTOS_NETWORK: Network = NetworkToNetworkName[Network.TESTNET];
  const config = new AptosConfig({ network: APTOS_NETWORK });
  const aptos = new Aptos(config);
  const OWNER_PRIVATE_KEY = "0xd23189a37d84b3913aa9f1f3e77a9c7252e89f6debc0c6d485f5a758cfbf37c9";     //how transaction success
  // const OWNER_PRIVATE_KEY = "0x1a29f8ee3b773ba27a4606762557dbf5ac70baa6a86dab2665a781afd60c8135";  //how transaction failed


  const getSigner = async () => {
    const privateKey = new Ed25519PrivateKey(OWNER_PRIVATE_KEY);
    const signer = await aptos.deriveAccountFromPrivateKey({ privateKey });
    return signer
  }

  export { aptos, getSigner };