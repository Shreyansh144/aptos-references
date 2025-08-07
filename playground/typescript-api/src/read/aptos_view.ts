import { aptos } from "../utils/aptos_util";
import { InputViewFunctionData } from "@aptos-labs/ts-sdk";

const ACCOUNT = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
const MODULE_NAME = "PhotonMock";

const viewModuleFunction = async (symbol: string) => {
    const payload: InputViewFunctionData = {
        function: `${ACCOUNT}::${MODULE_NAME}::get_token_price`,
        typeArguments: [],
        functionArguments: [`string:${symbol}`],
      };
      const output = (await aptos.view({ payload }));
      console.log(output[0]);
};

viewModuleFunction("BTC");