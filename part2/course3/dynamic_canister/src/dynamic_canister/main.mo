
import Principal    "mo:base/Principal";
import Option       "mo:base/Option";
import Map          "mo:base/HashMap";
import Hash         "mo:base/Hash";
import Nat          "mo:base/Nat";
import Time         "mo:base/Time";
import Iter         "mo:base/Iter";
import IC           "./ic";
import HelloCycles  "./hello_cycles";
import Buffer       "./ExtBuffer";
import T            "./Types";

// minimum: 提案通过最低维护者人数，即后续升级和维护 canister 最低需要多少人同意通过提案才能执行
// controllers: 控制者清单，控制者清单人数必须大于等于 minimum 数量
shared(initializer) actor class ({minimum : Nat;controllers : [Principal]}) = self{
  
  private stable var canister_owner : Principal = initializer.caller;

  //多签名Canister的缓存数据
  private var multiSignatureCanisters = Map.HashMap<T.CanisterId, T.MultiSignatureCanister>(10, Principal.equal, Principal.hash);

  //提案数据集合
  private var proposeMap = Map.HashMap<Nat, T.Propose>(10, Nat.equal, Hash.hash);

  //提案ID
  private var proposeId : Nat = 0;

  // 提案发起后有效期 1 天
  private let proposeExpiration = 24 * 60 * 60_000_000_000;

  //所有控制者
  private var allControllers = controllers;

  public func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  // 创建 canister 
  // describe: 该canister的描述信息
  public shared func create_canister({describe : Text}) : async T.CanisterId{
    //确认维护者数量是否超过控制者人数
    assert(allControllers.size() >= minimum);

    let setting = {
      freezing_threshold = null;
      controllers = ?allControllers;
      memory_allocation = null;
      compute_allocation = null;
    };
    let ic : IC.Self = actor("aaaaa-aa");
    let result = await ic.create_canister({settings = ?setting});
    let canister : T.MultiSignatureCanister = {
      canister_id = result.canister_id;
      controllers = allControllers;
      describe = describe;
    };
    //缓存 canister
    multiSignatureCanisters.put(result.canister_id, canister);
    result.canister_id;
  };

  //显示所有Canister
  public shared func show_canisters() : async [T.MultiSignatureCanister] {
    Iter.toArray(multiSignatureCanisters.vals());
  };

  //获取Canister
  public shared func get_canister(canister_id : T.CanisterId) : async ?T.MultiSignatureCanister {
    multiSignatureCanisters.get(canister_id);
  };

  //安装/升级 Canister 代码
  private func install_code({canister_id : T.CanisterId ;mode : { #reinstall; #upgrade; #install }; wasm : IC.wasm_module}) : async Bool {
    //TODO 此处应先缓存 install_code 的执行内容，待签名人数达到最低要求后，再执行
    let ic : IC.Self = actor("aaaaa-aa");
    let install = {
      arg = [];
      wasm_module = wasm;
      mode = mode;
      canister_id = canister_id;
    };
    await ic.install_code(install);
    true;
  };

  private func start_canister(canister_id : T.CanisterId) : async Bool {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.start_canister({canister_id = canister_id});
    true;
  };

  private func stop_canister(canister_id : T.CanisterId) : async Bool {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.stop_canister({canister_id = canister_id});
    true;
  };

  private func delete_canister(canister_id : T.CanisterId) : async Bool {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.delete_canister({canister_id = canister_id});
    true;
  };

  private func uninstall_code(canister_id : T.CanisterId) : async Bool {
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.uninstall_code({canister_id = canister_id});
    true;
  };

  //获取下一个提案ID
  private func nextProposeId() : Nat {
    proposeId := proposeId + 1;
    proposeId;
  };

  //发起（新）提案
  public shared({ caller }) func add_propose({
    canister_id: T.CanisterId;//针对哪个canister进行的提案
    action: T.Action;//提案通过后，执行的动作
    describe: Text;//提案内容描述，方便其他成员进行投票审核提案内容
  }) : async T.ProposeResult {

    let pid = nextProposeId();
    let propose = {
      propose_id = pid;
      creator = caller;
      canister_id = canister_id;
      action = action;
      describe = describe;
      votes = [];
      executed = false;
      expiry = Time.now() + proposeExpiration;
    };
    proposeMap.put(pid,propose);
    #ok({propose});
  };

  //查询所有提案
  public shared({ caller }) func show_propose() : async [T.Propose] {
    //查询提案不需要校验权限
    Iter.toArray(proposeMap.vals());
  };

  //投票提案
  public shared({ caller }) func vote({
    propose_id: Nat;//针对哪个提案进行投票
    agree: Bool//是否同意该提案
  }) : async T.VoteResult {
    //检查权限
    if(checkPermissions(caller) == false) {
      return #err({
        message = ?"您不是控制者，无法参与投票";
        kind = #InvalidController;
      });
    };

    switch(proposeMap.get(propose_id)) {
      case null {
        let msg = "该提案号(" # Nat.toText(propose_id) # ")不存在";
        #err({
          message = ?msg;
          kind = #BadProposeID;
        });
      };
      case (?p) {
        if (p.executed) {
          let msg = "该提案号(" # Nat.toText(propose_id) # ")已被执行，无法进行投票";
          #err({
            message = ?msg;
            kind = #HasBeenExecuted;
          });
        } else if (p.expiry < Time.now()) {
          let msg = "该提案号(" # Nat.toText(propose_id) # ")已过期，无法进行投票";
          #err({
            message = ?msg;
            kind = #Expiration;
          });
        } else {
          //执行投票
          let propose = await doVote({
              controller = caller;
              agree = agree;
            },p);
          #ok({propose});
        }
      };
    };
  };

  //校验该调用者是否有权限
  private func checkPermissions(caller : Principal) : Bool {
    //检查 caller 是否在 allControllers 列表中
    for (x in allControllers.vals()) {
      if (x == caller) {
        return true;
      };
    };
    //当前暂时不需要检查，则默认都返回true
    true;
  };

  //执行投票
  private func doVote(vote : T.Vote, propose : T.Propose) : async T.Propose{
    let buf = Buffer.ExtBuffer<T.Vote>(propose.votes.size() + 1);
    buf.appendArray(propose.votes);
    buf.add(vote);
    var agreeCount = 0;
    let votes = buf.toArray();
    for (v in votes.vals()) {
      if (v.agree) {
        agreeCount := agreeCount + 1;
      };
    };

    var executed = false;
    if (agreeCount >= minimum) {
      //同意该提案达到最小维护者数量，则执行提案的内容
      executed := await doAction(propose);
    };

    let updatePropose = {
      propose_id = propose.propose_id;
      creator = propose.creator;
      canister_id = propose.canister_id;
      action = propose.action;
      describe = propose.describe;
      votes = votes;
      executed = executed;
      expiry = propose.expiry;
    };
    proposeMap.put(updatePropose.propose_id,updatePropose);
    updatePropose;
  };

  //提案通过后，执行相应的动作
  private func doAction(propose : T.Propose) : async Bool{
    switch(propose.action) {
      case (#install({wasm})) { await install_code({
        canister_id = propose.canister_id;
        mode = #install;
        wasm = wasm;
      }) };
      case (#reinstall({wasm})) { await install_code({
        canister_id = propose.canister_id;
        mode = #reinstall;
        wasm = wasm;
      }) };
      case (#upgrade({wasm})) { await install_code({
        canister_id = propose.canister_id;
        mode = #upgrade;
        wasm = wasm;
      }) };
      case (#start_canister) { await start_canister(propose.canister_id) };
      case (#stop_canister) { await stop_canister(propose.canister_id) };
      case (#delete_canister) { await delete_canister(propose.canister_id) }; 
      case (#uninstall_code) { await uninstall_code(propose.canister_id) }; 
      case (#addController({newControllers})) { addController(newControllers) }; 
      case (#removeController({oldControllers})) { removeController(oldControllers) }; 
    };
  };

  private func addController(cs : [Principal]) : Bool {
    //TODO 对 allControllers 新增 cs
    let buf = Buffer.ExtBuffer<Principal>(allControllers.size() + cs.size());
    buf.appendArray(allControllers);
    buf.appendArray(cs);
    allControllers := buf.toArray();
    true;
  };

  private func removeController(cs : [Principal]) : Bool {
    // 对 allControllers 移除 cs
    let buf = Buffer.ExtBuffer<Principal>(1);
    for (x in allControllers.vals()) {
      var flagRemove = false;
      for (y in cs.vals()) {
        if (x == y) {
          flagRemove := true;
        };
      };
      if (flagRemove == false) {
        //不需要移除，则保留下来
        buf.add(x);
      };
    };
    allControllers := buf.toArray();
    true;
  };

  // //调用 Canister
  // public shared({ caller }) func call_canister(args : T.CanisterCallArgs) : async T.CanisterCallResult {
  //   let pid : Principal = Principal.fromText(args.canisterId);
  //   switch(multiSignatureCanisters.get(pid)) {
  //     case null {
  //       let msg = "该Canister(" # args.canisterId # ")不存在";
  //       return #err({
  //           message = ?msg;
  //           kind = #CanisterIdNotFound;
  //         });
  //     };
  //     case (?c) {
  //       // TODO 需要实现动调用 指定 Canister 的某个方法
  //       // Canister: args.canister_id
  //       // 方法函数： args.functionName
  //       // 方法参数： args.param
  //       return #ok({
  //           value = "成功调用：" # args.canisterId # "." # args.functionName # "(" # args.param #")";
  //         });
  //     };
  //   };
  // };
  
  //调用 Canister
  public shared({ caller }) func call_canister_wallet_balance(args : T.CanisterCallWalletBalanceArgs) : async T.CanisterCallWalletBalanceResult {
    let pid : Principal = Principal.fromText(args.canisterId);
    switch(multiSignatureCanisters.get(pid)) {
      case null {
        let msg = "该Canister(" # args.canisterId # ")不存在";
        return #err({
            message = ?msg;
            kind = #CanisterIdNotFound;
          });
      };
      case (?c) {
        let hc : HelloCycles.HelloCycles = actor(args.canisterId);
        let balance = await hc.wallet_balance();
        return #ok({
            value = balance;
          });
      };
    };
  };
};
