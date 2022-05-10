import Iter "mo:base/Iter";
import List "mo:base/List";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Self "mo:base/Func";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Map "mo:base/HashMap";
import TrieSet "mo:base/TrieSet";
import Nat "mo:base/Nat";

shared (install) actor class Icblog () {
    private stable var owner : Principal = install.caller;

    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    // 消息记录数据结构。
    public type Message = {
        msg: Text;
        time: Time.Time;
        };

    public type Icblog = actor {
        follow: shared (Principal) -> async(); // 添加关注对象，需要鉴权
        follows: shared query () -> async [Principal]; //返回关注列表
        post: shared (Text) -> async (); //发布消息，需要鉴权
        posts: shared query (since: Time.Time) -> async [Message]; //返回所发布的消息
        timeline: shared (since: Time.Time) -> async [Message]; //返回所关注对象发布的消息
        subscribe: shared (since: Time.Time) -> async [Message]; //他人订阅我的博客时，他人需要调的方法
        receiveSubscribe: shared (msg: Message) -> async (); // 我订阅他人博客后，当他人博客有新消息时，会通知我，此时我通过此方法接收对方的消息
    };

    // 检查权限
    private func checkAuthor(id: Principal) : Bool {
        if (id != owner) {
            let tip = "您当前的身份 " # Principal.toText(id) # " 没有权限执行该操作，请使用管理员身份 " # Principal.toText(owner) # " 操作！";
            let temp = "参考命令： dfx canister --wallet=$(dfx identity get-wallet) call ... ";
            Debug.print(tip);
            Debug.print(temp);
            false;
        } else {
            true;
        };
    };

    // 我关注他人的博客集合
    stable var followed = TrieSet.empty<Principal>();
    
    // dfx canister --wallet=$(dfx identity get-wallet) call icblog follow "(principal \"$(dfx canister id icblog1)\")"
    public shared (msg) func follow(id: Principal) : async () {
        assert(checkAuthor(msg.caller));
        followed := TrieSet.put<Principal>(followed,id,Principal.hash(id),Principal.equal);
        await doSubscribe(id);
    };

    // 查询我关注的博客列表
    public shared query func follows() : async [Principal] {
        TrieSet.toArray(followed);
    };

    // 已发布的博客消息列表
    stable var messages : List.List<Message> = List.nil();

    // 发表消息 dfx canister --wallet=$(dfx identity get-wallet) call icblog post "(\" hello icblog 5 msg! \")"
    public shared (msg) func post(text: Text) : async () {
        assert(checkAuthor(msg.caller));
        let newMsg = {msg = text;time = Time.now()};
        messages := List.push(newMsg,messages);
        await broadcastToSubscribers(newMsg);
    };

    // 查询已发布列表
    public shared query func posts(since: Time.Time) : async [Message] {
        searchPosts(since);
    };

    // 检索已发布的文章
    private func searchPosts(since: Time.Time) : [Message] {
        var match : List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            if (msg.time > since) {
                match := List.push(msg,match);
            };
        };
        List.toArray(match);
    };

    // 关注的消息列表
    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        
        for (id in Iter.fromArray(TrieSet.toArray(followed))) {
            let msgs : [Message] = if (isInitMsgCache(id) ==  false) {
                // 该ID没有初始化缓存时，则需要查询所有记录，并进行缓存。
                let canister : Icblog = actor(Principal.toText(id));
                let tempMsgs : [Message] = await canister.posts(0);
                initBlogCache(id,tempMsgs);
                Debug.print("初始化缓存 " # Principal.toText(id) # " 消息数 " # Nat.toText(tempMsgs.size()));
                fromCache(id,since);
            } else {
                let tempMsgs = fromCache(id,since);
                Debug.print("从缓存获取 " # Principal.toText(id) # " 消息数 " # Nat.toText(tempMsgs.size()));
                tempMsgs;
            };
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg,all);
            };
        };

        List.toArray(all);
    };

    // 执行订阅他人博客
    private func doSubscribe(tagId: Principal) : async () {
        let tagCanister : Icblog = actor(Principal.toText(tagId));
        // 订阅他人博客时，获取对方所有消息，并缓存在内存中
        let msgs : [Message] = await tagCanister.subscribe(0);
        initBlogCache(tagId,msgs);
    };

    // 他人关注（订阅）我的博客集合
    stable var subscribed = TrieSet.empty<Principal>();

    // 他人订阅我的博客
    public shared (msg) func subscribe(since: Time.Time) : async [Message] {
        subscribed := TrieSet.put(subscribed,msg.caller,Principal.hash(msg.caller),Principal.equal);
        searchPosts(since);
    };

    // 获取他人订阅我博客的列表。
    public shared query func subscribes() : async [Principal] {
        TrieSet.toArray(subscribed);
    };
    
    //广播分发给订阅者
    private func broadcastToSubscribers(msg: Message) : async () {
        for (id in Iter.fromArray(TrieSet.toArray(subscribed))) {
            let canister : Icblog = actor(Principal.toText(id));
            await canister.receiveSubscribe(msg);
        };
    };
    
    // 接收到订阅的消息，校验该消息来源是否为我订阅过的博客，防止收到非订阅的信息。
    public shared (sender) func receiveSubscribe(msg: Message) : async () {
        let tip : Text =  if (TrieSet.mem<Principal>(followed,sender.caller,Principal.hash(sender.caller),Principal.equal) == true) {
            addCache(sender.caller,msg);
            "receiveSubscribe "# Principal.toText(owner) #" 收到常规订阅 "# Principal.toText(sender.caller) #" 发的微博消息： "# msg.msg;
        } else {
            "receiveSubscribe "# Principal.toText(owner) #" 收到非法订阅 "# Principal.toText(sender.caller) #" 发的微博消息： "# msg.msg;
        };
        Debug.print(tip);
    };
    
    // 是否已初始化缓存过消息列表，当canister 升级时，缓存会丢失，此时需要重新初始化已关注博客的历史消息列表。
    var initMsgCache = Map.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
    // 已缓存关注博客的消息列表
    var messagesCache = Map.HashMap<Principal, [Message]>(0, Principal.equal, Principal.hash);
    
    // 初始化关注的博客缓存
    private func initBlogCache(id : Principal, msgs : [Message]) : () {
        messagesCache.put(id, msgs);
        initMsgCache.put(id,true);
    };

    // 是否已缓存过指定的ID
    private func isInitMsgCache(id : Principal) : Bool {
        switch (initMsgCache.get(id)) {
            case null { 
                false;
            };
            case (?isCache) { 
                isCache == true;
             };
        };
    };

    // 新增消息的缓存
    private func addCache(id : Principal, msg : Message) {
        var msgs : [Message] = switch (messagesCache.get(id)) {
            case null { 
                [];
            };
            case (?msgCache) { 
                msgCache;
            };
        };
        msgs := Array.append<Message>(msgs, [msg]);
        messagesCache.put(id, msgs);
    };
    
    // 从缓存中获取关注的消息列表
    private func fromCache(id : Principal,since: Time.Time) : [Message] {
        switch (messagesCache.get(id)) {
            case null { 
                []
            };
            case (?msgCache) { 
                var match : [Message] = [];
                for (msg in Iter.fromArray(msgCache)) {
                    if (msg.time > since) {
                        match := Array.append<Message>(match, [msg]);
                    };
                };
                match;
             };
        };
    }
};
