#!/usr/bin/env node

const RPCS = [
  "https://bsc-dataseed.binance.org",
  "https://bsc-dataseed1.bnbchain.org"
];

const T1Y_TOKEN = "0x56b776483096c16a3eDD76156Eee47cdcbC05F7f";
const T1Y_TOKEN_EXT = "0x0379d39190e125b530e84254a132563e4eae37d2";
const T1Y_FEE_SWAPPER = "0x02a2060c730e009b4b2c2B9167f93e7af68D6Bbe";
const WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
const PANCAKE_FACTORY = "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73";

const SELECTORS = {
  owner: "0x8da5cb5b",
  pancakePair: "0xb8c9d25c",
  tokenExt: "0xfea4039f",
  feeSwapper: "0x5a37e8be",
  getPair: "0xe6a43905"
};

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

function padAddress(address) {
  return address.toLowerCase().replace(/^0x/, "").padStart(64, "0");
}

function normalizeAddress(address) {
  return address ? address.toLowerCase() : address;
}

function decodeAddress(hex) {
  if (!hex || hex === "0x") return null;
  return `0x${hex.slice(-40)}`.toLowerCase();
}

async function rpc(method, params) {
  let lastError;
  for (const url of RPCS) {
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ jsonrpc: "2.0", id: 1, method, params })
      });
      const payload = await response.json();
      if (payload.error) throw new Error(payload.error.message || JSON.stringify(payload.error));
      return payload.result;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
}

async function ethCall(to, data) {
  return rpc("eth_call", [{ to, data }, "latest"]);
}

async function readAddress(name, to, data) {
  try {
    return { name, value: decodeAddress(await ethCall(to, data)) };
  } catch (error) {
    return { name, error: error instanceof Error ? error.message : String(error) };
  }
}

async function main() {
  const block = Number.parseInt(await rpc("eth_blockNumber", []), 16);
  const getPairData = `${SELECTORS.getPair}${padAddress(T1Y_TOKEN)}${padAddress(WBNB)}`;

  const results = Object.fromEntries(
    (
      await Promise.all([
        readAddress("tokenOwner", T1Y_TOKEN, SELECTORS.owner),
        readAddress("swapperOwner", T1Y_FEE_SWAPPER, SELECTORS.owner),
        readAddress("extOwner", T1Y_TOKEN_EXT, SELECTORS.owner),
        readAddress("pancakePair", T1Y_TOKEN, SELECTORS.pancakePair),
        readAddress("tokenExt", T1Y_TOKEN, SELECTORS.tokenExt),
        readAddress("feeSwapper", T1Y_TOKEN, SELECTORS.feeSwapper),
        readAddress("factoryPair", PANCAKE_FACTORY, getPairData)
      ])
    ).map((result) => [result.name, result])
  );

  const expected = {
    tokenOwner: ZERO_ADDRESS,
    swapperOwner: ZERO_ADDRESS,
    pancakePair: normalizeAddress("0x9d3153f4d033a54fbc8199eaa195655cecc92262"),
    tokenExt: normalizeAddress(T1Y_TOKEN_EXT),
    feeSwapper: normalizeAddress(T1Y_FEE_SWAPPER),
    factoryPair: normalizeAddress("0x9d3153f4d033a54fbc8199eaa195655cecc92262")
  };

  const checks = Object.entries(expected).map(([name, expectedValue]) => {
    const actual = results[name].value;
    return { name, expected: expectedValue, actual, pass: actual === expectedValue };
  });

  const extOwnerReverted = Boolean(results.extOwner.error);
  const pass = checks.every((check) => check.pass) && extOwnerReverted;

  const report = {
    checkedAt: new Date().toISOString(),
    block,
    addresses: {
      T1Y_TOKEN,
      T1Y_TOKEN_EXT,
      T1Y_FEE_SWAPPER,
      WBNB,
      PANCAKE_FACTORY
    },
    results: {
      tokenOwner: results.tokenOwner.value,
      swapperOwner: results.swapperOwner.value,
      extOwner: results.extOwner.error ? `REVERT_OR_ERROR: ${results.extOwner.error}` : results.extOwner.value,
      pancakePair: results.pancakePair.value,
      tokenExt: results.tokenExt.value,
      feeSwapper: results.feeSwapper.value,
      factoryPair: results.factoryPair.value
    },
    checks,
    extOwnerExpectedRevert: extOwnerReverted,
    pass
  };

  console.log(JSON.stringify(report, null, 2));
  if (!pass) process.exitCode = 1;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
