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
  .package(url: "https://github.com/software-mansion/starknet.swift.git", from: "0.7.0")
]

Then add `starknet.swift` to the dependencies array of every target you want to use the package in.
```

## Documentation
You can find the documentation of the project [here](https://docs.swmansion.com/starknet.swift/documentation/starknet/).

## Demo app
In the `Examples` folder you can find a demo ios application.

Before running it, make sure that you're using devnet version which is compatible with the demo app. 
https://github.com/0xSpaceShard/starknet-devnet-rs/commit/fa1238e8039a53101b5d2d764d3622ff0403a527

If you use devnet repository, run the following command:
```
git checkout fa1238e8039a53101b5d2d764d3622ff0403a527
```

If you setup devnet with `cargo`, run following command:
```
cargo install \
--locked \
--git https://github.com/0xSpaceShard/starknet-devnet-rs.git \
--rev fa1238e
```

Also, make sure to run starknet devnet with given configuration:
```
starknet-devnet --port 5050 --seed 0
```
and run the demo app on ios simulator, to be able to access the local devnet instance.

## Development

### Git hooks
Install hooks by running `install_hooks.sh` script from `Scripts` folder.

### Code formatting
This project uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for linting and formatting code. You can install it by running `brew install swiftformat`. Unformatted code will be rejected by pre push hook and lint github action. To format code in the project, run
```bash
swiftformat .
```
in main project directory.

### Testing
#### Platforms
Due to reliability on `starknet-devnet-rs` for testing, tests can be ran on **macOS targets only**.
#### Prerequisites
You will need to set some environment variables:
- `DEVNET_PATH` - points to `starknet-devnet-rs` cli
- `SCARB_PATH` - points to `scarb` cli. 
- `SNCAST_PATH` - points to `sncast` cli.

You can set them in XCode scheme or by running these commands:
```bash
export DEVNET_PATH="$(which starknet-devnet)"
export SCARB_PATH="$(which scarb)"
export SNCAST_PATH="$(which sncast)"
```
This assumes you already have the following tools installed:
- [`starknet-devnet-rs`](https://github.com/0xSpaceShard/starknet-devnet-rs) 
- [`scarb`](https://github.com/software-mansion/scarb)
- [`starknet-foundry`](https://github.com/foundry-rs/starknet-foundry) - provides `sncast` module

---

## Binary dependencies
This project depends on two binary frameworks.
- crypto-cpp from starkware, with c bindings. Compiled for ios and macosx targets. Built in [this repo](https://github.com/software-mansion-labs/crypto-cpp-swift)
- poseidon from CryptoExperts. Compiled for ios and macosx targets. Built in [this repo](https://github.com/software-mansion-labs/poseidon-swift)
- generate_k method, from starknet-rs sdk, wrapped in a c binding. Compiled for ios and macosx targets. Built in [this repo](https://github.com/bartekryba/starknet-rs-c-bindings)

## Acknowledgements
This product includes software developed by the "Marcin Krzyzanowski" (http://krzyzanowskim.com/).
