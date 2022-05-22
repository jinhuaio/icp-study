import type { Principal } from '@dfinity/principal';
export interface anon_class_7_1 {
  'create_canister' : (
      arg_0: {
        'describe' : [] | [string],
        'controllers' : [] | [Array<Principal>],
        'maintainers' : bigint,
      },
    ) => Promise<canister_id>,
  'delete_canister' : (arg_0: canister_id) => Promise<undefined>,
  'greet' : (arg_0: string) => Promise<string>,
  'install_code' : (
      arg_0: {
        'mode' : { 'reinstall' : null } |
          { 'upgrade' : null } |
          { 'install' : null },
        'canister_id' : canister_id,
        'wasm' : wasm_module,
      },
    ) => Promise<undefined>,
  'start_canister' : (arg_0: canister_id) => Promise<undefined>,
  'stop_canister' : (arg_0: canister_id) => Promise<undefined>,
  'uninstall_code' : (arg_0: canister_id) => Promise<undefined>,
}
export type canister_id = Principal;
export type wasm_module = Array<number>;
export interface _SERVICE extends anon_class_7_1 {}
