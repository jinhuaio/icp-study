import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

shared (install) actor class Microblog() {
    private stable var owner : Principal = install.caller;

    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    stable let password : Text = "p123456";

    public type Message = {
        msg: Text;
        time: Time.Time;
        author: ?Text;
        };

    public type Follow = {
        pid: Text;
        author: ?Text;
        };

    public type Microblog = actor {
        follow: shared(id:Principal, pass: Text) -> async(); // 添加关注对象
        follows: shared query () -> async [Follow]; //返回关注列表
        post: shared (text: Text, pass: Text) -> async (); //发布消息
        posts: shared query (since: Time.Time) -> async [Message]; //返回所有发布的消息
        timeline: shared (pid: Text,since: Time.Time) -> async [Message]; //返回所有关注对象发布的消息
        set_name: shared (name: Text) -> async(); //设置发布者名字
        get_name: shared query () -> async ?Text; //获取发布者名字
    };

    stable var followed : List.List<Follow> = List.nil();

    public shared func follow(id: Principal,pass: Text) : async () {
        assert(password == pass);
        let canister : Microblog = actor(Principal.toText(id));
        let name : ?Text = await canister.get_name();
        followed := List.push({pid = Principal.toText(id); author = name},followed);
    };

    public shared query func follows() : async [Follow] {
        List.toArray(followed);
    };
    
    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post(text: Text,pass: Text): async () {
        // assert(msg.caller == owner);
        assert(password == pass);
        messages := List.push({msg = text;time = Time.now();author = authorName},messages);
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

    public shared func timeline(pid: Text,since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        if (pid == "") {
            for (id in Iter.fromList(followed)) {
                let canister : Microblog = actor(id.pid);
                let msgs : [Message] = await canister.posts(0);
                for (msg in Iter.fromArray(msgs)) {
                    all := List.push(msg,all);
                }
            };
        } else {
            let canister : Microblog = actor(pid);
            let msgs : [Message] = await canister.posts(0);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg,all);
            };
        };
        List.toArray(all);
    };

    stable var authorName : ?Text = ?"No.86";
    
    public shared (msg) func set_name(name: ?Text) : async () {
        assert(msg.caller == owner);
        authorName := name;
    };

    public shared query func get_name() : async ?Text {
        authorName;
    };

};
