// Persistent logger keeping track of what is going on.

import Array "mo:base/Array";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Option "mo:base/Option";
import Debug    "mo:base/Debug";
import Iter "mo:base/Iter";
import Principal  "mo:base/Principal";
import Logger "mo:ic-logger/Logger";

import ExtBuffer "./ExtBuffer";
import T "./Types";

shared({caller}) actor class LoggerWrapper(installer : Principal, message_max_size : Nat) = this {
  
  private type LogInfo = T.LogInfo;

  private let OWNER = installer;
  
  //每个Logger canister 存放最大日志条数。
  private let LOGGER_MESSAGE_MAX_SIZE = message_max_size;

  private stable var state : Logger.State<LogInfo> = Logger.new<LogInfo>(0, null);
  private let logger = Logger.Logger<LogInfo>(state);

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
  public shared (msg) func append(msgs: [LogInfo]) : async [LogInfo]{
    // assert(Option.isSome(Array.find(allowed, func (id: Principal) : Bool { msg.caller == id })));
    let currSize = counts();
    if (currSize >= LOGGER_MESSAGE_MAX_SIZE) {
      //当前 actor 存储的日志已满
      return msgs;
    };
    let canisterId = Principal.toText(Principal.fromActor(this));
    let addSize = msgs.size();
    if(currSize + addSize > LOGGER_MESSAGE_MAX_SIZE) {
      let appendIndex = Int.abs(LOGGER_MESSAGE_MAX_SIZE - currSize - 1);
      let buf = ExtBuffer.ExtBuffer<LogInfo>(msgs.size());
      buf.appendArray(msgs);
      let msgAppend = buf.subArray(null,? appendIndex);
      let msgResult = buf.subArray(?(appendIndex + 1),null);
      logger.append(msgAppend);
      Debug.print("canister " # canisterId # " append part msg count : " # Nat.toText(msgAppend.size()) # " result size : " # Nat.toText(msgResult.size()));
      msgResult;//因 当前 actor 只能存放部分日志信息，剩余未能存储的部分返回
    } else {
      //将所有需要添加的日志存入当前的 actor
      logger.append(msgs);
      Debug.print("canister " # canisterId # " append all msg count : " # Nat.toText(msgs.size()));
      [];
    }
  };

  // Return log stats, where:
  //   start_index is the first index of log message.
  //   bucket_sizes is the size of all buckets, from oldest to newest.
  public shared query (msg) func stats() : async Logger.Stats {
    logger.stats()
  };

  //查询日志条数
  public shared query (msg) func logSize() : async Nat {
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
  public shared query (msg) func view(from: ?Nat, to: ?Nat) : async Logger.View<LogInfo> {
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
