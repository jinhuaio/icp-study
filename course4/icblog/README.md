# Icblog

欢迎来到您的新Icblog项目，这是互联网计算机（IC）开发社区提供的去中心化blog项目的模版原型，您可基于该原型创建模拟传统互联网bolg后台业务模型的去中心化IC项目。


# 如何提高 timeline 查询效率的方案

总体方案思路：对timeline方法调用canister.posts()方法的查询结果使用缓存机制，以便在下一次的查询中从当前canister的本地缓存中获取，以提高查询效率。

详细实现的关键步骤：
1、在调用关注微博方法 follow(id: Principal) 中，同时调用对方canister的订阅方法 详细见 doSubscribe(tagId: Principal)
2、在调用对方canister的订阅方法 await tagCanister.subscribe(0) 时，对方将返回其微博的所有历史消息内容，此时获取到所有历史消息内容后，对消息进行缓存至本地变量中var messagesCache
3、若此时对方的canister发布新的微博消息，此时在func post(text: Text) 方法中，将会同时调用 func broadcastToSubscribers(msg: Message) 分发给订阅者新消息
4、订阅者将在func receiveSubscribe(msg: Message) 方法中获取到推送过来的新消息，此时同样将新消息缓存在本地变量 var messagesCache 中。
5、此时，若通过 func timeline(since: Time.Time) 方法查询本canister关注的消息列表，若本地已有缓存，则优先从本地缓存 var messagesCache 中查找；若本地尚未有对该canister进行过缓存（通过var initMsgCache变量来标记是否有记录过缓存），则先通过对方的canister.posts(0)获取所有消息，然后再次缓存至本地变量 var messagesCache
6、因 var messagesCache 没有做成持久化，因此在canister升级时，缓存数据会丢失，此时会在首次调用 timeline 方法时，会重新获取一次所有信息，并对其再次缓存在本地。

思考：该方案也存在一些缺陷，若我有太多的粉丝关注了我的微博，那么在我发微博消息时 func post(text: Text) ，会因需要广播给所有的粉丝，因此同样会存在性能瓶颈，这里是否有办法能在canister中执行多线程的异步后台任务？

备注：关于上述方案可以参考本项目 src/icblog/main.mo 的代码实现。

## 第1步：在本地部署和运行

如果你想在本地测试你的项目，你可以使用以下命令:

```bash
# 在后台运行 definity 服务
dfx start --background

# 将你的canisters部署到definity本地服务上，并生成你的candid界面
dfx deploy
```

本项目默认内置 icblog、icblog1、icblog2、icblog3、icblog4、icblog5 共6个 canister 的 blog 服务，以便用于模拟测试bolg之间的关注和订阅以及消息的发送和接收。

部署完成后，您可以通过类似这个地址访问您的服务 `http://localhost:8000?canisterId={asset_canister_id}`.



## 第2步：发微博消息 和 显示消息 功能

```bash

# 使用 icblog 发消息
dfx canister --wallet=$(dfx identity get-wallet) call icblog post "(\" hello icblog msg 1 ! \")"

# 查看 icblog 已发的所有消息
dfx canister call icblog posts 0

# 此时应该类似如下输出
(
  vec {
    record {
      msg = " hello icblog msg 1 ! ";
      time = 1_642_227_045_248_560_000 : int;
    };
  },
)

```

## 第3步：关注 和 订阅 功能

```bash

# 使用 icblog1 先发送一条消息
dfx canister --wallet=$(dfx identity get-wallet) call icblog1 post "(\" hello icblog1 msg 1 ! \")"
# 查询 icblog1 的消息记录
dfx canister call icblog1 posts 0  
# 此时应该查到类似如下已发消息
(
  vec {
    record {
      msg = " hello icblog1 msg 1 ! ";
      time = 1_642_227_091_044_096_000 : int;
    };
  },
)
# 使用 icblog 关注 icblog1 
dfx canister --wallet=$(dfx identity get-wallet) call icblog follow "(principal \"$(dfx canister id icblog1)\")"

# 查看 icblog 已关注微博的所有消息
dfx canister call icblog timeline 0

# 此时应该类似如下输出
(
  vec {
    record {
      msg = " hello icblog1 msg 1 ! ";
      time = 1_642_227_091_044_096_000 : int;
    };
  },
)

# 同时在 dfx start 终端日志中，会有如下类似日志信息输出，表明本次调用 timeline 方法是从缓存中获取
[Canister rrkah-fqaaa-aaaaa-aaaaq-cai] 从缓存获取 ryjl3-tyaaa-aaaaa-aaaba-cai 消息数 1

# 此时使用 icblog1 发送第2条消息
dfx canister --wallet=$(dfx identity get-wallet) call icblog1 post "(\" hello icblog1 msg 2 ! \")"

# 因 icblog 已关注了 icblog1 ,因此在 dfx start 终端日志中，会有类似如下日志输出，表明 icblog 收到了 订阅 icblog1 推送过来的消息
[Canister rrkah-fqaaa-aaaaa-aaaaq-cai] receiveSubscribe rwlgt-iiaaa-aaaaa-aaaaa-cai 收到常规订阅 ryjl3-tyaaa-aaaaa-aaaba-cai 发的微博消息：  hello icblog1 msg 2 ! 

# 此时再次查看 icblog 已关注微博的所有消息
dfx canister call icblog timeline 0

# 应该有如下类似的两条消息
(
  vec {
    record {
      msg = " hello icblog1 msg 2 ! ";
      time = 1_642_227_423_260_924_000 : int;
    };
    record {
      msg = " hello icblog1 msg 1 ! ";
      time = 1_642_227_091_044_096_000 : int;
    };
  },
)

# 同时在 dfx start 终端日志中，会有如下类似日志信息输出，表明本次调用 timeline 方法是从缓存中获取
[Canister rrkah-fqaaa-aaaaa-aaaaq-cai] 从缓存获取 ryjl3-tyaaa-aaaaa-aaaba-cai 消息数 2

```


# 开发参考资料

如果您想了解更多的开发资料，请参阅以下在线文档:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)
- [JavaScript API Reference](https://erxue-5aaaa-aaaab-qaagq-cai.raw.ic0.app)