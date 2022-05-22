import IC "./ic";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Buffer "./ExtBuffer";
import Map "mo:base/HashMap";

actor class () = self{

  //多签名Canister的数据结构
  type MultiSignatureCanister = {
      canister_id: IC.canister_id;
      controllers : [Principal];
      describe : ?Text;
  };

  //多签名Canister的缓存数据
  private var multiSignatureCanisters = Map.HashMap<IC.canister_id, MultiSignatureCanister>(10, Principal.equal, Principal.hash);

  public func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  // 创建 canister 需要指定
  // maintainers: 维护者人数，即后续升级和维护此 canister 最低需要多少人才允许升级
  // controllers: 控制者清单，控制者清单人数必须大于等于 maintainers 数量
  // describe: 该canister的描述信息
  public shared ({caller}) func create_canister({maintainers : Nat; controllers : ?[Principal]; describe : ?Text}) : async IC.canister_id{
    let cs : [Principal] = switch (controllers) {
      case null {[caller,Principal.fromActor(self)]};
      case (?c) {
        let buf = Buffer.ExtBuffer<Principal>(c.size() + 2);
        buf.appendArray(c);
        buf.add(caller);
        buf.add(Principal.fromActor(self));
        buf.toArray();
      };
    };
    //确认维护者数量是否超过控制者人数
    assert(cs.size() >= maintainers);

    let setting = {
      freezing_threshold = null;
      controllers = ?cs;
      memory_allocation = null;
      compute_allocation = null;
    };
    let ic : IC.Self = actor("aaaaa-aa");
    let result = await ic.create_canister({settings = ?setting});
    let canister = {
      canister_id = result.canister_id;
      controllers = cs;
      describe = describe;
    };
    //缓存 canister
    multiSignatureCanisters.put(result.canister_id, canister);
    result.canister_id;
  };

  //安装/升级 Canister 代码
  public func install_code({canister_id : IC.canister_id ;mode : { #reinstall; #upgrade; #install }; wasm : IC.wasm_module}) : async () {
    
    assert checkMultiSignature();

    //TODO 此处应先缓存 install_code 的执行内容，待签名人数达到最低要求后，再执行
    let ic : IC.Self = actor("aaaaa-aa");
    let install = {
      arg = [];
      wasm_module = wasm;
      mode = mode;
      canister_id = canister_id;
    };
    await ic.install_code(install);
  };

  private func checkMultiSignature() : Bool{
    //TODO 校验签名的人数是否达到最低要求，待实现
    true;
  };

  public func start_canister(canister_id : IC.canister_id) : async (){
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.start_canister({canister_id = canister_id});
  };

  public func stop_canister(canister_id : IC.canister_id) : async (){
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.stop_canister({canister_id = canister_id});
  };

  public func delete_canister(canister_id : IC.canister_id) : async (){
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.delete_canister({canister_id = canister_id});
  };

  public func uninstall_code(canister_id : IC.canister_id) : async (){
    assert checkMultiSignature();
    //TODO 此处应先缓存 install_code 的执行内容，待签名人数达到最低要求后，再执行
    let ic : IC.Self = actor("aaaaa-aa");
    await ic.uninstall_code({canister_id = canister_id});
  };

  
};
