![alt text](logo.png)

# starknet.swift
StarkNet SDK for Swift to interact with the starknet rpc nodes.

## Installation

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

## Documentation
You can find the documentation of the project [here](https://docs.swmansion.com/starknet.swift/documentation/starknet/).

## Demo app
In the `Examples` folder you can find a demo ios application.

Before running it, make sure to run starknet devnet with given configuration:
```
starknet-devnet --port 5050 --seed 0
```
and run the demo app on ios simulator, to be able to access the local devnet instance.

## Development

#### Git hooks
Install hooks by running `install_hooks.sh` script from `Scripts` folder.

#### Code formatting
This project uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for linting and formatting code. You can install it by running `brew install swiftformat`. Unformatted code will be rejected by pre push hook and lint github action. To format code in the project, run
```
swiftformat .
```
in main project directory.

#### Testing
Due to reliability on `starknet-devnet` for testing, tests can only be ran on macos targets. Additionaly you'll need to set two environment variables.
`DEVNET_PATH` that points to `starknet-devnet` cli, and `STARKNET_PATH` that points to `starknet` cli. You can set them in xcode scheme or by running these
commands:

```
export DEVNET_PATH="$(which starknet-devnet)"
export STARKNET_PATH="$(which starknet)"
```
This assumes you already have installed [`starknet-devnet`](https://github.com/Shard-Labs/starknet-devnet) and [`cairo-lang`](https://www.cairo-lang.org/docs/quickstart.html) python packages.

#### Binary dependencies
This project depends on two binary frameworks.
- crypto-cpp from starkware, with c bindings. Compiled for ios and macosx targets. Built in [this repo](https://github.com/software-mansion-labs/crypto-cpp-swift)
- generate_k method, from starknet-rs sdk, wrapped in a c binding. Compiled for ios and macosx targets. Built in [this repo](https://github.com/bartekryba/starknet-rs-c-bindings)

### Acknowledgements
This product includes software developed by the "Marcin Krzyzanowski" (http://krzyzanowskim.com/).
