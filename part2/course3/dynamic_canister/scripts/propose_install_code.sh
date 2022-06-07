#!/usr/local/bin/ic-repl
function propose_install_code(dynamic_canister,wasm) {
  let id = call dynamic_canister.create_canister(
    record {
      describe = "";
    }
  );
  
  let result = call dynamic_canister.add_propose(
    record {
      canister_id = id;
      action = variant { install = record {wasm = wasm} };
      describe = "";
    }
  );
  result
};

identity alice;

import dynamic_canister = "${WALLET_ID:-rrkah-fqaaa-aaaaa-aaaaq-cai}" as "../src/declarations/dynamic_canister/dynamic_canister.did";

let propose = propose_install_code(dynamic_canister,file "hello_cycles.wasm");
