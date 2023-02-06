# starknet.swift
StarkNet SDK for Swift and Objective-C

### Demo app
In the `Examples` folder you can find a demo ios application.

Before running it, make sure to run starknet devnet with given configuration:
```
starknet-devnet --port 5050 --seed 0
```
and run the demo app on ios simulator, to be able to access the local devnet instance.

### Binary dependencies
This project depends on two binary frameworks.
- crypto-cpp from starkware, with c bindings. Compiled for ios and macosx targets. Built in [this repo](https://github.com/software-mansion-labs/crypto-cpp-swift)
- generate_k method, from starknet-rs sdk, wrapped in a c binding. Compiled for ios and macosx targets. Built in [this repo](https://github.com/bartekryba/starknet-rs-c-bindings)

### Acknowledgements
This product includes software developed by the "Marcin Krzyzanowski" (http://krzyzanowskim.com/).
