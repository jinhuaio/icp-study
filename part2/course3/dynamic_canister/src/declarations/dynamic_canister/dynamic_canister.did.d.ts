import type { Principal } from '@dfinity/principal';
export type Action = { 'stop_canister' : null } |
  { 'reinstall' : { 'wasm' : Array<number> } } |
  { 'start_canister' : null } |
  { 'upgrade' : { 'wasm' : Array<number> } } |
  { 'addController' : { 'newControllers' : Array<Principal> } } |
  { 'delete_canister' : null } |
  { 'install' : { 'wasm' : Array<number> } } |
  { 'uninstall_code' : null } |
  { 'removeController' : { 'oldControllers' : Array<Principal> } };
export type CanisterId = Principal;
export interface MultiSignatureCanister {
  'describe' : string,
  'controllers' : Array<Principal>,
  'canister_id' : CanisterId,
}
export interface Propose {
  'describe' : string,
  'creator' : Principal,
  'action' : Action,
  'votes' : Array<Vote>,
  'canister_id' : CanisterId,
  'executed' : boolean,
  'expiry' : Time,
  'propose_id' : bigint,
}
export interface ProposeErr {
  'kind' : { 'InvalidController' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type ProposeResult = { 'ok' : ProposeSuccess } |
  { 'err' : ProposeErr };
export interface ProposeSuccess { 'propose' : Propose }
export type Time = bigint;
export interface Vote { 'controller' : Principal, 'agree' : boolean }
export interface VoteErr {
  'kind' : { 'InvalidController' : null } |
    { 'ActionFail' : null } |
    { 'BadProposeID' : null } |
    { 'Expiration' : null } |
    { 'Other' : null } |
    { 'HasBeenExecuted' : null },
  'message' : [] | [string],
}
export type VoteResult = { 'ok' : VoteSuccess } |
  { 'err' : VoteErr };
export interface VoteSuccess { 'propose' : Propose }
export interface anon_class_15_1 {
  'add_propose' : (
      arg_0: {
        'describe' : string,
        'action' : Action,
        'canister_id' : CanisterId,
      },
    ) => Promise<ProposeResult>,
  'create_canister' : (arg_0: { 'describe' : string }) => Promise<CanisterId>,
  'get_canister' : (arg_0: CanisterId) => Promise<
      [] | [MultiSignatureCanister]
    >,
  'greet' : (arg_0: string) => Promise<string>,
  'show_canisters' : () => Promise<Array<MultiSignatureCanister>>,
  'show_propose' : () => Promise<Array<Propose>>,
  'vote' : (arg_0: { 'agree' : boolean, 'propose_id' : bigint }) => Promise<
      VoteResult
    >,
}
export interface _SERVICE extends anon_class_15_1 {}
