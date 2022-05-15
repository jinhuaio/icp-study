import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Debug    "mo:base/Debug";
import Iter "mo:base/Iter";
import Principal  "mo:base/Principal";
import RBT "mo:base/RBTree"; //RB树的库文件

import Logger "mo:ic-logger/Logger";

import LoggerWrapper "./LoggerWrapper";
import T "./Types";

shared(msg) actor class Main() {
  private let OWNER = msg.caller;

  //每个Logger canister 存放最大日志条数。
  private let LOGGER_MESSAGE_MAX_SIZE = 10;
  
  private stable var loggerCanisterIndex : Nat = 0;
  private let loggerWrapperBrt = RBT.RBTree<Nat, Principal>(Nat.compare); //存储创建的 Logger canister

  //当前的 Logger canister 
  private var currentLogger : ?LoggerWrapper.LoggerWrapper = null;

  //创建新的 Logger Canister
  private func newLoggerCanister(caller : Principal) : async LoggerWrapper.LoggerWrapper{
    Debug.print(" newLoggerCanister index : " # Nat.toText(loggerCanisterIndex));
    let logger : LoggerWrapper.LoggerWrapper = await LoggerWrapper.LoggerWrapper(caller);
    let principal = Principal.fromActor(logger);
    loggerWrapperBrt.put(loggerCanisterIndex, principal);
    loggerCanisterIndex += 1;
    logger;
  };

  //获取当前的 Logger Canister 对象，当 Logger Actor 为空或者达到最大存储数量时，自动创新的 Logger Canister
  private func getCurrentLogger(caller : Principal) : async LoggerWrapper.LoggerWrapper{
    switch(currentLogger) {
      case null { 
        let logger : LoggerWrapper.LoggerWrapper = await newLoggerCanister(caller);
        currentLogger :=  ?logger;
        logger;
      };
      case (?logger) {
        // 需要判断当前Logger 的 canister 是否达到最大值，达到最大值时，需要新创建
        let size = await logger.logCounts();
        if(size >= LOGGER_MESSAGE_MAX_SIZE) {
          let newLogger : LoggerWrapper.LoggerWrapper = await newLoggerCanister(caller);
          currentLogger :=  ?newLogger;
          newLogger;
        } else {
          logger;
        };
      };
    };
  };
  
  // Add a set of messages to the log.
  public shared (msg) func append(msgs: [Text]) {
    var logger : LoggerWrapper.LoggerWrapper = await getCurrentLogger(msg.caller);
    logger.append(msgs);
  };

  public func stats() : async T.Stats {
    switch(currentLogger) {
      case null { 
        // 此处应该返回空值
        { start_index = 0; bucket_sizes = [0];log_size = 0; canister_size = 0 };
      };
      case (?logger) {
        let buf = Buffer.Buffer<Nat>(0);
        var startIndex = 0;
        var isFirst = true;
        var logCounts = 0;
        //遍历所有的Logger Canister
        label LOOP for (i in Iter.range(0, loggerCanisterIndex - 1)) {
          let canisterId : ?Principal = loggerWrapperBrt.get(i);
          switch (canisterId) {
            case null { continue LOOP};
            case (?id) {
              let loggerCanister : LoggerWrapper.LoggerWrapper = actor(Principal.toText(id));
              let stats : Logger.Stats = await loggerCanister.stats();
              if (isFirst) {
                startIndex := stats.start_index;
                isFirst := false;
              };
              for (size in Iter.fromArray(stats.bucket_sizes)) {
                buf.add(size);
                logCounts := logCounts + size;
              };
            };
          };
        };
        { start_index = startIndex; bucket_sizes = buf.toArray();log_size = logCounts; canister_size = loggerCanisterIndex };
      };
    };
  };

  // Return the messages between from and to indice (inclusive).
  public shared (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {
    // assert(msg.caller == OWNER);

    switch(currentLogger) {
      case null { 
        // TODO 此处应该返回空值
        var state : Logger.State<Text> = Logger.new<Text>(0, null);
        let logger = Logger.Logger<Text>(state);
        logger.view(from, to);
      };
      case (?logger) {
        let buf = Buffer.Buffer<Text>(to - from + 1);
        var startIndex = 0;
        var isFirst = true;
        //遍历所有的Logger Canister
        label LOOP for (i in Iter.range(0, loggerCanisterIndex - 1)) {
          let canisterId : ?Principal = loggerWrapperBrt.get(i);
          switch (canisterId) {
            case null { continue LOOP};
            case (?id) {
              let loggerCanister : LoggerWrapper.LoggerWrapper = actor(Principal.toText(id));
              let view : Logger.View<Text> = await loggerCanister.view(null, null);
              if (isFirst) {
                startIndex := view.start_index;
                isFirst := false;
              };
              for (msg in Iter.fromArray(view.messages)) {
                buf.add(msg);
              };
            };
          };
        };
        {
          start_index = if (startIndex > from) { startIndex } else { from };
          messages = buf.toArray();
        };
      };
    };
  };
}
