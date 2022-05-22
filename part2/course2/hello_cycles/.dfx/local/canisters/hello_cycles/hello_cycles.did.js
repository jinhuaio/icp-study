export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'transfer' : IDL.Func(
        [IDL.Func([], [], []), IDL.Nat],
        [IDL.Record({ 'refunded' : IDL.Nat })],
        [],
      ),
    'wallet_balance' : IDL.Func([], [IDL.Nat], []),
    'wallet_receive' : IDL.Func(
        [],
        [IDL.Record({ 'accepted' : IDL.Nat64 })],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
