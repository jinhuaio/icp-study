# 动态管理 多人签名 Canister Demo

## 安装 didc 工具

 * 下载Mac版本
```bash
https://github.com/dfinity/candid/releases
```
 * 修改名称
```bash
mv didc-macos didc
```
 * 修改可执行权限
```bash
chmod a+x didc
```
 * 移动到bin目录
```bash
sudo mv didc /usr/local/bin
```

## 安装 ic-repl 工具

 * 下载Mac版本
```bash
https://github.com/chenyan2002/ic-repl/releases
```
 * 修改可执行权限
```bash
chmod a+x ic-repl-macos
```
 * 移动到bin目录
```bash
sudo mv ic-repl-macos /usr/local/bin/ic-repl
```



## IC Manager did 接口编译

 * 下载
```bash
https://github.com/dfinity/interface-spec/blob/master/spec/ic.did
```

 * 编译成motoko文件
```bash
didc bind -t mo ic.did > src/dynamic_canister/ic.mo
```

## 启动、部署和测试调用

* 启动服务
```bash
dfx start --background
```

* 部署Canister
```bash
dfx deploy dynamic_canister --argument '(record {minimum=1; controllers=vec {principal "rwlgt-iiaaa-aaaaa-aaaaa-cai"; principal "rrkah-fqaaa-aaaaa-aaaaq-cai"; principal "rrkah-fqaaa-aaaaa-aaaaq-cai"}})'

dfx canister create dynamic_canister_assets

dfx generate
```

* 创建Canister 并提交 install_code 提案
```bash
./scripts/propose_install_code.sh
```

* 查询提案
```bash
dfx canister call dynamic_canister show_propose '()'
```

* 投票提案
```bash
dfx canister call dynamic_canister vote '(record {propose_id=1; agree=true})'
```

* 查询 hello_cycles 余额
```bash
./scripts/test_hello_cycles_wallet_balance.sh
```

* 创建Canister
```bash
dfx canister call dynamic_canister create_canister '(record {describe="这是一个动态创建的Canister"})'
```

* 查询Canister
```bash
dfx canister call dynamic_canister show_canisters '()'
```

* 调用Canister call_canister_wallet_balance
```bash
dfx canister call dynamic_canister call_canister_wallet_balance '()'
```


* 部署后更新 canister ID
将 .dfx/local/canister_ids.json 的 dynamic_canister 对应的principal 更新至 ./test.sh 文件对应位置
```bash
import dynamic_canister = "${WALLET_ID:-rrkah-fqaaa-aaaaa-aaaaq-cai}" as "src/declarations/dynamic_canister/dynamic_canister.did";
```

 * 动态创建和管理Canister：create_canister、install_code、canister_status、start_canister、 stop_canister、 delete_canister 方法 执行以下脚本

```bash
./test.sh
```
