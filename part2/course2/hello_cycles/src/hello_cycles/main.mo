import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

shared(initializer) actor class HelloCycles() = this {
  
  private stable var canister_owner : Principal = initializer.caller;
  let limit = 10_000_000;

  public shared({ caller }) func wallet_balance() : async Nat {
    Debug.print("caller = " # Principal.toText(caller) # " canister_owner="#Principal.toText(canister_owner));
    assert caller == canister_owner;
    return Cycles.balance();
  };

  public func wallet_receive() : async { accepted: Nat64 } {
    let available = Cycles.available();
    let accepted = Cycles.accept(Nat.min(available, limit));
    { accepted = Nat64.fromNat(accepted) };
  };

  public func transfer(
    receiver : shared () -> async (),
    amount : Nat) : async { refunded : Nat } {
      Cycles.add(amount);
      await receiver();
      { refunded = Cycles.refunded() };
  };

};
