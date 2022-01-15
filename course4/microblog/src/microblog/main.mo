import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

shared (install) actor class Microblog() {
    private stable var owner : Principal = install.caller;
    
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    public type Message = {
        msg: Text;
        time: Time.Time;
        };

    public type Microblog = actor {
        follow: shared(Principal) -> async(); // 添加关注对象
        follows: shared query () -> async [Principal]; //返回关注列表
        post: shared (Text) -> async (); //发布消息
        posts: shared query (since: Time.Time) -> async [Message]; //返回所有发布的消息
        timeline: shared (since: Time.Time) -> async [Message]; //返回所有关注对象发布的消息
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal) : async () {
        followed := List.push(id,followed);
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post(text: Text) : async () {
        assert(msg.caller == owner);
        messages := List.push({msg = text;time = Time.now()},messages);
    };

    public shared query func posts(since: Time.Time) : async [Message] {
        var match : List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            if (msg.time > since) {
                match := List.push(msg,match);
            };
        };
        List.toArray(match);
    };

    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs : [Message] = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg,all);
            }
        };

        List.toArray(all);
    };
};
