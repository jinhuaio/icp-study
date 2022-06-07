import type { Principal } from '@dfinity/principal';
export interface HelloCycles {
  'transfer' : (arg_0: [Principal, string], arg_1: bigint) => Promise<
      { 'refunded' : bigint }
    >,
  'wallet_balance' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<{ 'accepted' : bigint }>,
}
export interface _SERVICE extends HelloCycles {}
