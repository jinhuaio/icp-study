#!/usr/local/bin/ic-repl
function deploy(dynamic_canister,wasm) {
  let id = call dynamic_canister.create_canister(
    record {
      maintainers = 1;
      controllers = null;
      mode = variant { install };
      describe = null;
    }
  );
  
  call dynamic_canister.install_code(
    record {
      canister_id = id;
      mode = variant { install };
      wasm = wasm;
    }
  );
  id
};

identity alice;

import dynamic_canister = "${WALLET_ID:-rrkah-fqaaa-aaaaa-aaaaq-cai}" as "src/declarations/dynamic_canister/dynamic_canister.did";

let hello_cycles = deploy(dynamic_canister,file "hello_cycles.wasm");
let status = call ic.canister_status(record {canister_id = hello_cycles});
call hello_cycles.wallet_balance();
call dynamic_canister.stop_canister(hello_cycles);
call dynamic_canister.start_canister(hello_cycles);
call dynamic_canister.stop_canister(hello_cycles);
call dynamic_canister.delete_canister(hello_cycles);
