
import Nat "mo:base/Nat";

module {
    public type Stats = {
    start_index: Nat;
    bucket_sizes: [Nat];
    log_size: Nat;
    canister_size: Nat;
  };
}
