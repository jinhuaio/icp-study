export const idlFactory = ({ IDL }) => {
  const Action = IDL.Variant({
    'stop_canister' : IDL.Null,
    'reinstall' : IDL.Record({ 'wasm' : IDL.Vec(IDL.Nat8) }),
    'start_canister' : IDL.Null,
    'upgrade' : IDL.Record({ 'wasm' : IDL.Vec(IDL.Nat8) }),
    'addController' : IDL.Record({ 'newControllers' : IDL.Vec(IDL.Principal) }),
    'delete_canister' : IDL.Null,
    'install' : IDL.Record({ 'wasm' : IDL.Vec(IDL.Nat8) }),
    'uninstall_code' : IDL.Null,
    'removeController' : IDL.Record({
      'oldControllers' : IDL.Vec(IDL.Principal),
    }),
  });
  const CanisterId = IDL.Principal;
  const Vote = IDL.Record({ 'controller' : IDL.Principal, 'agree' : IDL.Bool });
  const Time = IDL.Int;
  const Propose = IDL.Record({
    'describe' : IDL.Text,
    'creator' : IDL.Principal,
    'action' : Action,
    'votes' : IDL.Vec(Vote),
    'canister_id' : CanisterId,
    'executed' : IDL.Bool,
    'expiry' : Time,
    'propose_id' : IDL.Nat,
  });
  const ProposeSuccess = IDL.Record({ 'propose' : Propose });
  const ProposeErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidController' : IDL.Null,
      'Other' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const ProposeResult = IDL.Variant({
    'ok' : ProposeSuccess,
    'err' : ProposeErr,
  });
  const MultiSignatureCanister = IDL.Record({
    'describe' : IDL.Text,
    'controllers' : IDL.Vec(IDL.Principal),
    'canister_id' : CanisterId,
  });
  const VoteSuccess = IDL.Record({ 'propose' : Propose });
  const VoteErr = IDL.Record({
    'kind' : IDL.Variant({
      'InvalidController' : IDL.Null,
      'ActionFail' : IDL.Null,
      'BadProposeID' : IDL.Null,
      'Expiration' : IDL.Null,
      'Other' : IDL.Null,
      'HasBeenExecuted' : IDL.Null,
    }),
    'message' : IDL.Opt(IDL.Text),
  });
  const VoteResult = IDL.Variant({ 'ok' : VoteSuccess, 'err' : VoteErr });
  const anon_class_15_1 = IDL.Service({
    'add_propose' : IDL.Func(
        [
          IDL.Record({
            'describe' : IDL.Text,
            'action' : Action,
            'canister_id' : CanisterId,
          }),
        ],
        [ProposeResult],
        [],
      ),
    'create_canister' : IDL.Func(
        [IDL.Record({ 'describe' : IDL.Text })],
        [CanisterId],
        [],
      ),
    'get_canister' : IDL.Func(
        [CanisterId],
        [IDL.Opt(MultiSignatureCanister)],
        [],
      ),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], []),
    'show_canisters' : IDL.Func([], [IDL.Vec(MultiSignatureCanister)], []),
    'show_propose' : IDL.Func([], [IDL.Vec(Propose)], []),
    'vote' : IDL.Func(
        [IDL.Record({ 'agree' : IDL.Bool, 'propose_id' : IDL.Nat })],
        [VoteResult],
        [],
      ),
  });
  return anon_class_15_1;
};
export const init = ({ IDL }) => {
  return [
    IDL.Record({ 'controllers' : IDL.Vec(IDL.Principal), 'minimum' : IDL.Nat }),
  ];
};
