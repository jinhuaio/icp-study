import type { Principal } from '@dfinity/principal';
export interface LogInfoDisplay {
  'time' : bigint,
  'message' : string,
  'canisterId' : string,
}
export interface Main {
  'append' : (arg_0: Array<string>) => Promise<undefined>,
  'stats' : () => Promise<Stats>,
  'view' : (arg_0: bigint, arg_1: bigint) => Promise<View>,
}
export interface Stats {
  'canister_count' : bigint,
  'log_size' : bigint,
  'bucket_sizes' : Array<bigint>,
  'canister_log_max_size' : bigint,
  'start_index' : bigint,
}
export interface View {
  'messages' : Array<LogInfoDisplay>,
  'start_index' : bigint,
}
export interface _SERVICE extends Main {}
