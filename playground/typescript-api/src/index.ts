import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import { aptos, getSigner } from "./utils/aptos_util";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

const ACCOUNT = "0x760637102c573ea852d0da8865872d62f04c2d8f145e4545a18a28f634698eeb";
const MODULE_NAME = "PhotonMock";

// ------------------ MODULE FUNCTIONS ------------------

const buildAndSubmit = async (functionName: string, args: string[]) => {
  const signer = await getSigner();
  const txn = await aptos.transaction.build.simple({
    sender: signer.accountAddress,
    data: {
      function: `${ACCOUNT}::${MODULE_NAME}::${functionName}`,
      typeArguments: [],
      functionArguments: args,
    },
  });

  const committedTxn = await aptos.signAndSubmitTransaction({
    signer,
    transaction: txn,
  });

  await aptos.waitForTransaction({ transactionHash: committedTxn.hash });
  return committedTxn.hash;
};

// ------------------ ROUTES ------------------

app.post("/mint", async (req, res) => {
  try {
    const { to, amount } = req.body;
    const hash = await buildAndSubmit("mint", [to, amount]);
    res.json({ success: true, hash });
  } catch (err) {
const error = err as Error;
    res.status(500).json({ success: false, error: error.message });  }
});

app.post("/claim", async (req, res) => {
  try {
    const { amount } = req.body;
    const hash = await buildAndSubmit("claim", [amount]);
    res.json({ success: true, hash });
  } catch (err) {
const error = err as Error;
    res.status(500).json({ success: false, error: error.message });  }
});

app.post("/transfer", async (req, res) => {
  try {
    const { from, to, amount } = req.body;
    const hash = await buildAndSubmit("transfer", [from, to, amount]);
    res.json({ success: true, hash });
  } catch (err) {
const error = err as Error;
    res.status(500).json({ success: false, error: error.message });  }
});

app.post("/spendOnMerchant", async (req, res) => {
  try {
    const { to, amount } = req.body;
    const hash = await buildAndSubmit("SpendOnMerchant", [to, amount]);
    res.json({ success: true, hash });
  } catch (err) {
    const error = err as Error;
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post("/spendOnProtocol", async (req, res) => {
  try {
    const { to, amount } = req.body;
    const hash = await buildAndSubmit("SpendOnProtocol", [to, amount]);
    res.json({ success: true, hash });
  } catch (err) {
    const error = err as Error;
    res.status(500).json({ success: false, error: error.message });
  }
});

// ------------------ SERVER ------------------

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
