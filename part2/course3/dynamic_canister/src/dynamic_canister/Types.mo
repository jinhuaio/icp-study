import Time "mo:base/Time";
import Result     "mo:base/Result";
import IC "./ic";

module {

    public type CanisterId = IC.canister_id;

    //允许对多人签名的 Canister 进行管理的动作
    public type Action = {
        #install : {wasm : [Nat8]};
        #reinstall : {wasm : [Nat8]};
        #upgrade : {wasm : [Nat8]};
        #start_canister;
        #stop_canister;
        #delete_canister;
        #uninstall_code;
        #addController : {newControllers : [Principal]};
        #removeController : {oldControllers : [Principal]};
        
    };

    //提案数据结构
    public type Propose = {
        propose_id: Nat;//提案ID
        creator: Principal;//提案创建者
        canister_id: CanisterId;//针对哪个canister进行的提案
        action: Action;//提案通过后，执行的动作
        describe: Text;//提案内容描述，方便其他成员进行投票审核提案内容
        votes: [Vote];//该提案的投票数据
        executed: Bool;//该提案是否已被执行
        expiry: Time.Time;//提案有效期，若该提案在有效期内未通过，则自动失效，将不会再被执行
    };

    //投票数据结构
    public type Vote = {
        controller : Principal;
        agree : Bool;
    };

    //多签名Canister的数据结构
    public type MultiSignatureCanister = {
        canister_id: CanisterId;
        controllers : [Principal];
        describe : Text;
    };

    //发起提案返回结果
    public type ProposeResult = Result.Result<ProposeSuccess, ProposeErr>;
    public type ProposeSuccess = {
        propose : Propose;
    };
    public type ProposeErr = {
        message : ?Text;
        kind : {
        #InvalidController;
        #Other;
        };
    };

    //投票返回结果
    public type VoteResult = Result.Result<VoteSuccess, VoteErr>;
    public type VoteSuccess = {
        propose : Propose;
    };
    public type VoteErr = {
        message : ?Text;
        kind : {
        #BadProposeID;
        #InvalidController;
        #Expiration;
        #HasBeenExecuted;
        #ActionFail;
        #Other;
        };
    };

    // // Canister 调用参数
    // public type CanisterCallArgs = {
    //     canisterId : Text;
    //     functionName : Text;
    //     param : Text;
    // };
    
    // // Canister 调用返回结果
    // public type CanisterCallResult = Result.Result<CanisterCallSuccess, CanisterCallErr>;
    // public type CanisterCallSuccess = {
    //     value : Text;
    // };
    // public type CanisterCallErr = {
    //     message : ?Text;
    //     kind : {
    //     #CanisterIdNotFound;
    //     #FuncNotFound;
    //     #ParamError;
    //     #Other;
    //     };
    // };

    public type CanisterCallWalletBalanceArgs = {
        canisterId : Text;
    };
    
    public type CanisterCallWalletBalanceResult = Result.Result<CanisterCallWalletBalanceSuccess, CanisterCallWalletBalanceErr>;
    public type CanisterCallWalletBalanceSuccess = {
        value : Nat;
    };
    public type CanisterCallWalletBalanceErr = {
        message : ?Text;
        kind : {
        #CanisterIdNotFound;
        #FuncNotFound;
        #ParamError;
        #Other;
        };
    };
}