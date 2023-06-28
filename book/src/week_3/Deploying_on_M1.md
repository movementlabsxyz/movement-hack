# Deploying on M1
At the time of writing, only the M1 testnet is available. To set up for deployment you only need to make sure you have a testnet profile configured.

```bash
movement init --network testnet
```

You may then use the `movement` CLI to publish your package.

```bash
movement move publish --named-addresses hello_blockchain=default
```

We encourage however to take a look at `aptos_framework::resource_account` and `aptos_framework::resource_group` for more advanced publication options.

## 💻 MulticontractFib
We encourage you to checkout `examples/movement/multicontract_fib` for an easy to inspect. Once you've deployed, simply run the command below to check out the on chain resources.
```bash
movement account list --query resources --account default
```