// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type HelloCycles = actor {
    transfer : shared (shared () -> async (), Nat) -> async { refunded : Nat };
    wallet_balance : shared () -> async Nat;
    wallet_receive : shared () -> async { accepted : Nat64 };
  };
  public type Self = () -> async HelloCycles
}
