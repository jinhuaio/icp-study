#!/usr/local/bin/ic-repl
function get_wallet_balance(dynamic_canister) {
  let canister = call dynamic_canister.get_canister(
    principal "r7inp-6aaaa-aaaaa-aaabq-cai"
  );
  canister?.canister_id;
};

identity alice;

import dynamic_canister = "${WALLET_ID:-rrkah-fqaaa-aaaaa-aaaaq-cai}" as "../src/declarations/dynamic_canister/dynamic_canister.did";
let canister = get_wallet_balance(dynamic_canister);

call canister.wallet_balance();
