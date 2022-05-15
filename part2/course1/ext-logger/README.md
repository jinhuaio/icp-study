# IC Logger

This [motoko] library provides a module to help create an append-only logger actor.

## Usage


```
cd demo
dfx deploy
```



### 使用钱包身份调用
```
dfx canister --wallet=$(dfx identity get-wallet) call extlogger allow "vec {principal \"$(dfx identity get-principal)\"}"
```
