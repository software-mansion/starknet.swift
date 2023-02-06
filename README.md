![alt text](logo.png)

# starknet.swift
StarkNet SDK for Swift and Objective-C

### Installation

#### XCode
In XCode, go to your project, then select `Package Dependencies` tab. Click the + button, and in the window that just appeared search for `starknet.swift` package or paste the following url directly: `https://github.com/software-mansion/starknet.swift`. Select package and install it.

#### Swift Package Manager

Just add the package to the dependencies array in your `Package.swift` file:
```Swift
dependencies: [
  ...
  .package(url: "https://github.com/software-mansion/starknet.swift.git", from: "0.1.0")
]

Then add `starknet.swift` to the dependencies array of every target you want to use the package in.
```
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
