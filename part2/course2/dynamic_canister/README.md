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
dfx deploy
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
