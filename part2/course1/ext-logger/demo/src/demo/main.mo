import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Debug    "mo:base/Debug";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Principal  "mo:base/Principal";
import RBT "mo:base/RBTree"; //RB树的库文件

import Logger "mo:ic-logger/Logger";

import LoggerWrapper "./LoggerWrapper";
import T "./Types";

shared(msg) actor class Main() {

  private type LogInfo = T.LogInfo;
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
        let size = await logger.logSize();
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
  
  private func toLogInfo(msgs: [Text]) : [LogInfo] {
    let buf = Buffer.Buffer<LogInfo>(msgs.size());
    let now = Time.now();
    for (msg in Iter.fromArray(msgs)) {
      buf.add({time = now; message = msg});
    };
    buf.toArray();
  };

  // Add a set of messages to the log.
  public shared (msg) func append(msgs: [Text]) {
    ignore await forAppend(toLogInfo(msgs));
  };

  //递归添加日志信息，若该Canister Logger满后，再循环获取新的Canister进行添加
  private func forAppend(msgs: [LogInfo]) : async [LogInfo] {
    var logger : LoggerWrapper.LoggerWrapper = await getCurrentLogger(msg.caller);
    let remainingMsgs : [LogInfo] = await logger.append(msgs);
    if (remainingMsgs.size() > 0) {
      await forAppend(remainingMsgs);
    } else {
      [];
    };
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
  public shared (msg) func view(from: Nat, to: Nat) : async Logger.View<T.LogInfoDisplay> {
    // assert(msg.caller == OWNER);

    switch(currentLogger) {
      case null { 
        // 此处应该返回空值
        {
          start_index = 0;
          messages = [];
        };
      };
      case (?logger) {
        let buf = Buffer.Buffer<T.LogInfoDisplay>(to - from + 1);
        var startIndex = 0;
        var isFirst = true;
        //获取即将遍历 Logger Canister 范围
        let indexs : CanisterIndex = getLoggerCanisterIndexs(from,to);
        Debug.print(" getLoggerCanisterIndexs start_canister_index : " # Nat.toText(indexs.start_canister_index) # " end_canister_index : " # Nat.toText(indexs.end_canister_index) # " from_log_index:" # Nat.toText(indexs.from_log_index) # " to_log_index:" # Nat.toText(indexs.to_log_index));
        //遍历获取区间内的日志信息
        label LOOP for (i in Iter.range(indexs.start_canister_index, indexs.end_canister_index)) {
          let canisterPrincipal : ?Principal = loggerWrapperBrt.get(i);
          Debug.print(" range canister_index : " # Nat.toText(i));
          switch (canisterPrincipal) {
            case null { continue LOOP};
            case (?id) {
              let cid = Principal.toText(id);
              let loggerCanister : LoggerWrapper.LoggerWrapper = actor(cid);
              let viewFrom = if (isFirst) {indexs.from_log_index} else {0};
              let viewTo = if (isFirst) {
                  if (indexs.start_canister_index == indexs.end_canister_index) {indexs.to_log_index} 
                  else {LOGGER_MESSAGE_MAX_SIZE}
                } else {indexs.to_log_index};

              Debug.print("viewFrom : " # Nat.toText(viewFrom) # " viewTo : " # Nat.toText(viewTo));
              let view : Logger.View<LogInfo> = await loggerCanister.view(?viewFrom, ?viewTo);
              if (isFirst) {
                startIndex := indexs.start_canister_index * LOGGER_MESSAGE_MAX_SIZE + viewFrom;
              };
              for (msg in Iter.fromArray(view.messages)) {
                buf.add({time = msg.time; canisterId = cid; message = msg.message});
              };
              isFirst := false;
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

  type CanisterIndex = {
    start_canister_index : Nat;
    end_canister_index : Nat;
    from_log_index : Nat;
    to_log_index : Nat; 
  };

  //根据查询的范围，获取这些日志所在的哪些Canister中
  private func getLoggerCanisterIndexs(from: Nat, to: Nat) : CanisterIndex {
    let start_index = from / LOGGER_MESSAGE_MAX_SIZE;
    var end_index = to / LOGGER_MESSAGE_MAX_SIZE;

    //查询的范围超出最大的canister时，则以最大canister为限进行查询
    end_index := if (end_index>=loggerCanisterIndex) {loggerCanisterIndex - 1} else {end_index};

    let from_index = from % LOGGER_MESSAGE_MAX_SIZE;
    var to_index = to % LOGGER_MESSAGE_MAX_SIZE;

    to_index := if (to_index == 0) {LOGGER_MESSAGE_MAX_SIZE} else {to_index};
    {
      start_canister_index = start_index;
      end_canister_index = end_index;
      from_log_index = from_index;
      to_log_index = to_index; 
    }
  };

}
