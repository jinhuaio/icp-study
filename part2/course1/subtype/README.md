# subtype

Welcome to your new subtype project and to the internet computer development community. By default, creating a new project adds this README and some template files to your project directory. You can edit these template files to customize your project and to include your own code to speed up the development cycle.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

To learn more before you start working with subtype, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)
- [JavaScript API Reference](https://erxue-5aaaa-aaaab-qaagq-cai.raw.ic0.app)

If you want to start working on your project right away, you might want to try the following commands:

```bash
cd subtype/
dfx help
dfx config --help
```

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```


## 判断下述子类型关系是否为真

```bash
{a: Bool} <= {a : Bool; b : Nat}
{a: Bool} <= {}
{#red; #blue} <= {#red; #yellow; #blue}
Nat <= Int
Int <= Int32
() -> () <= (Text) -> ()
() -> () <= () -> ()
() -> ({#male; #female}) <= () -> ()
(Int) -> (Nat) <= (Nat) -> (Int)
(Int16, Nat8) <= (Int32, Nat32)
```