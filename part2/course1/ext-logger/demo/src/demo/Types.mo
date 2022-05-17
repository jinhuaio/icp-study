
import Nat "mo:base/Nat";
import Int "mo:base/Int";


module {
    public type Stats = {
        start_index: Nat;
        bucket_sizes: [Nat];
        log_size: Nat;
        canister_count: Nat;
        canister_log_max_size: Nat;
    };

    //存储的日志信息结构
    public type LogInfo = {
        time: Int;
        message: Text;
    };

    public type LogInfoDisplay = {
        canisterId: Text;
        time: Int;
        message: Text;
    };
}
