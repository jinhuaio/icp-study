export const idlFactory = ({ IDL }) => {
  const Stats = IDL.Record({
    'log_size' : IDL.Nat,
    'bucket_sizes' : IDL.Vec(IDL.Nat),
    'canister_size' : IDL.Nat,
    'start_index' : IDL.Nat,
  });
  const View = IDL.Record({
    'messages' : IDL.Vec(IDL.Text),
    'start_index' : IDL.Nat,
  });
  const Main = IDL.Service({
    'append' : IDL.Func([IDL.Vec(IDL.Text)], [], ['oneway']),
    'stats' : IDL.Func([], [Stats], []),
    'view' : IDL.Func([IDL.Nat, IDL.Nat], [View], []),
  });
  return Main;
};
export const init = ({ IDL }) => { return []; };
