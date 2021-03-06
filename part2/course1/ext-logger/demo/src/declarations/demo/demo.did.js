export const idlFactory = ({ IDL }) => {
  const Stats = IDL.Record({
    'canister_count' : IDL.Nat,
    'log_size' : IDL.Nat,
    'bucket_sizes' : IDL.Vec(IDL.Nat),
    'canister_log_max_size' : IDL.Nat,
    'start_index' : IDL.Nat,
  });
  const LogInfoDisplay = IDL.Record({
    'time' : IDL.Int,
    'message' : IDL.Text,
    'canisterId' : IDL.Text,
  });
  const View = IDL.Record({
    'messages' : IDL.Vec(LogInfoDisplay),
    'start_index' : IDL.Nat,
  });
  const Main = IDL.Service({
    'append' : IDL.Func([IDL.Vec(IDL.Text)], [], []),
    'stats' : IDL.Func([], [Stats], []),
    'view' : IDL.Func([IDL.Nat, IDL.Nat], [View], []),
  });
  return Main;
};
export const init = ({ IDL }) => { return []; };
