// Persistent logger keeping track of what is going on.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Debug    "mo:base/Debug";
import Iter "mo:base/Iter";
import Principal  "mo:base/Principal";

import Logger "mo:ic-logger/Logger";

shared({caller}) actor class LoggerWrapper(installer : Principal) = this {
  
  let OWNER = installer;

  stable var state : Logger.State<Text> = Logger.new<Text>(0, null);
  let logger = Logger.Logger<Text>(state);

  // Principals that are allowed to log messages.
  stable var allowed : [Principal] = [OWNER];

  // Set allowed principals.
  public shared (msg) func allow(ids: [Principal]) {
    Debug.print("msg.caller:" # Principal.toText(msg.caller));
    Debug.print("OWNER:" # Principal.toText(OWNER));
    // assert(msg.caller == OWNER);
    allowed := ids;
  };

  // Add a set of messages to the log.
  public shared (msg) func append(msgs: [Text]) {
    // assert(Option.isSome(Array.find(allowed, func (id: Principal) : Bool { msg.caller == id })));
    logger.append(msgs);
  };

  // Return log stats, where:
  //   start_index is the first index of log message.
  //   bucket_sizes is the size of all buckets, from oldest to newest.
  public shared query (msg) func stats() : async Logger.Stats {
    logger.stats()
  };

  //查询日志条数
  public shared query (msg) func logCounts() : async Nat {
    counts();
  };

  private func counts() : Nat {
    let stats : Logger.Stats = logger.stats();
    var counts = 0;
    for (size in Iter.fromArray(stats.bucket_sizes)) {
        counts := counts + size;
    };
    counts;
  };

  // Return the messages between from and to indice (inclusive).
  public shared query (msg) func view(from: ?Nat, to: ?Nat) : async Logger.View<Text> {
    // assert(msg.caller == OWNER);
    let fromIndex = switch(from) {
      case null {0};
      case (?index) {
        index;
      };
    };

    let toIndex = switch(to) {
      case null {
        counts();
      };
      case (?index) {
        index;
      };
    };
    logger.view(fromIndex, toIndex)
  };

  // Drop past buckets (oldest first).
  public shared (msg) func pop_buckets(num: Nat) {
    // assert(msg.caller == OWNER);
    logger.pop_buckets(num)
  }
}
