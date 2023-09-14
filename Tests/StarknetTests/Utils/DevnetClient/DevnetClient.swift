import BigInt
import Foundation
@testable import Starknet

protocol DevnetClientProtocol {
    var gatewayUrl: String { get }
    var feederGatewayUrl: String { get }
    var rpcUrl: String { get }

    func start() async throws
    func close()

    func isRunning() -> Bool

    func prefundAccount(address: Felt) async throws
    func deployAccount(name: String, classHash: Felt, salt: Felt?, maxFee: Felt?) async throws -> DeployAccountResult
    func deployContract(classHash: Felt, constructorCalldata: [Felt], salt: Felt?, unique: Bool, maxFee: Felt) async throws -> DeployContractResult
    func declareDeployContract(contractName: String, constructorCalldata: [Felt], salt: Felt?, unique: Bool, maxFeeDeclare: Felt, maxFeeDeploy: Felt) async throws -> DeployContractResult
    func declareContract(contractName: String, maxFee: Felt) async throws -> DeclareContractResult
    func readAccountDetails(accountName: String) throws -> AccountDetails

    func assertTransactionSucceeded(transactionHash: Felt) async throws
    func assertTransactionFailed(transactionHash: Felt) async throws
    func isTransactionSuccessful(transactionHash: Felt) async throws -> Bool
}

extension DevnetClientProtocol {
    func deployAccount(name: String,
                       classHash: Felt = DevnetClient.accountContractClassHash,
                       salt: Felt? = .zero,
                       maxFee: Felt? = nil) async throws -> DeployAccountResult
    {
        try await deployAccount(
            name: name,
            classHash: classHash,
            salt: salt,
            maxFee: maxFee
        )
    }

    func deployAccount() async throws -> DeployAccountResult {
        try await deployAccount(
            name: UUID().uuidString,
            classHash: DevnetClient.accountContractClassHash,
            salt: .zero,
            maxFee: nil
        )
    }

    func declareContract(contractName: String, maxFee: Felt = 1_000_000_000_000_000) async throws -> DeclareContractResult {
        try await declareContract(contractName: contractName, maxFee: maxFee)
    }

    func declareDeployContract(contractName: String,
                               constructorCalldata: [Felt] = [],
                               salt: Felt? = .zero,
                               unique: Bool = false,
                               maxFeeDeclare: Felt = 1_000_000_000_000_000,
                               maxFeeDeploy: Felt = 1_000_000_000_000_000) async throws -> DeployContractResult
    {
        try await declareDeployContract(
            contractName: contractName,
            constructorCalldata: constructorCalldata,
            salt: salt,
            unique: unique,
            maxFeeDeclare: maxFeeDeclare,
            maxFeeDeploy: maxFeeDeploy
        )
    }

    func deployContract(classHash: Felt,
                        constructorCalldata: [Felt] = [],
                        salt: Felt? = .zero,
                        unique: Bool,
                        maxFee: Felt) async throws -> DeployContractResult
    {
        try await deployContract(
            classHash: classHash,
            constructorCalldata: constructorCalldata,
            salt: salt,
            unique: unique,
            maxFee: maxFee
        )
    }
}

// Due to DevnetClient being albe to run only on a macos, this
// factory method will throw, when ran on any other platform.
func makeDevnetClient() -> DevnetClientProtocol {
    #if os(macOS)
        return DevnetClient()
    #else
        fatalError("Invalid test Platform")
    #endif
}

#if os(macOS)

    class DevnetClient: DevnetClientProtocol {
        private let host: String
        private let port: Int
        private let seed: Int
        private let accountDirectory: URL
        private let baseUrl: String

        private var devnetProcess: Process?

        private let devnetPath: String
        private let starknetPath: String
        private let scarbPath: String
        private let snCastPath: String
        private var scarbTomlPath: String!
        private var contractsPath: String!
        private let tmpPath: String

        // Source: https://github.com/0xSpaceShard/starknet-devnet-rs/blob/323f907bc3e3e4dc66b403ec6f8b58744e8d6f9a/crates/starknet/src/constants.rs
        public static let accountContractClassHash: Felt = "0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f"
        public static let erc20ContractClassHash: Felt = "0x6a22bf63c7bc07effa39a25dfbd21523d211db0100a0afd054d172b81840eaf"
        public static let erc20ContractAddress: Felt = "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
        public static let udcContractClassHash: Felt = "0x7b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69"
        public static let udcContractAddress: Felt = "0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf"
        public static let predeployedAccount1: AccountDetails = .init(privateKey: "0xa2ed22bb0cb0b49c69f6d6a8d24bc5ea", publicKey: "0x198e98e771ebb5da7f4f05658a80a3d6be2213dc5096d055cbbefa62901ab06", address: "0x1323cacbc02b4aaed9bb6b24d121fb712d8946376040990f2f2fa0dcf17bb5b", salt: 20)
        public static let predeployedAccount2: AccountDetails = .init(privateKey: "0xc1c7db92d22ef773de96f8bde8e56c85", publicKey: "0x26df62f8e61920575f9c9391ed5f08397cfcfd2ade02d47781a4a8836c091fd", address: "0x34864aab9f693157f88f2213ffdaa7303a46bbea92b702416a648c3d0e42f35", salt: 20)

        private var deployedContractsAtName: [String: DeployContractResult] = [:]

        let gatewayUrl: String
        let feederGatewayUrl: String
        let rpcUrl: String

        init(host: String = "0.0.0.0", port: Int = 5051, seed: Int = 1_053_545_547) {
            self.host = host
            self.port = port
            self.seed = seed

            baseUrl = "http://\(host):\(port)"
            gatewayUrl = "\(baseUrl)/gateway"
            feederGatewayUrl = "\(baseUrl)/feeder_gateway"
            rpcUrl = "\(baseUrl)/rpc"

            devnetPath = ProcessInfo.processInfo.environment["DEVNET_PATH"] ?? "starknet-devnet"
            starknetPath = ProcessInfo.processInfo.environment["STARKNET_PATH"] ?? "starknet"
            scarbPath = ProcessInfo.processInfo.environment["SCARB_PATH"] ?? "scarb"
            snCastPath = ProcessInfo.processInfo.environment["SNCAST_PATH"] ?? "sncast"

            tmpPath = ProcessInfo.processInfo.environment["TMPDIR"] ?? "/tmp/starknet-swift"
            accountDirectory = URL(string: tmpPath)!
        }

        public func start() async throws {
            guard let scarbTomlPath = Bundle.module.path(forResource: "Scarb", ofType: "toml") else {
                throw DevnetClientError.missingResourceFile
            }

            self.scarbTomlPath = scarbTomlPath
            contractsPath = URL(fileURLWithPath: scarbTomlPath).deletingLastPathComponent().path

            guard !self.devnetPath.isEmpty, !self.starknetPath.isEmpty, !self.scarbPath.isEmpty, !self.snCastPath.isEmpty else {
                throw DevnetClientError.environmentVariablesNotSet
            }

            // This kills any zombie devnet processes left over from previous
            // test runs, if any.
            let task = Process()
            task.arguments = [
                "-c",
                "pkill -f starknet-devnet",
            ]

            task.launchPath = "/bin/sh"
            task.launch()
            task.waitUntilExit()

            let devnetProcess = Process()
            let pipe = Pipe()

            devnetProcess.standardOutput = pipe
            devnetProcess.standardError = pipe
            devnetProcess.arguments = [
                "--host",
                "\(host)",
                "--port",
                "\(port)",
                "--seed",
                "\(seed)",
            ]

            devnetProcess.launchPath = devnetPath
            devnetProcess.standardInput = nil
            devnetProcess.launch()

            try await sleep(seconds: 3)

            guard let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) else {
                throw DevnetClientError.devnetError
            }

            if output.contains("Connection in use") {
                throw DevnetClientError.portAlreadyInUse
            }

            guard devnetProcess.isRunning else {
//                print(String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) ?? "No available output")
                throw DevnetClientError.devnetError
            }

            let fileManager = FileManager.default
            guard let filePaths = try? fileManager.contentsOfDirectory(at: accountDirectory, includingPropertiesForKeys: nil, options: []) else {
                throw DevnetClientError.devnetError
            }

            for filePath in filePaths {
                try? fileManager.removeItem(at: filePath)
            }

            //  Recreating proper file structure requried by scarb
            let originalScarbTomlPath = URL(fileURLWithPath: self.scarbTomlPath)
            let newContractsPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts")
            let newScarbTomlPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts/Scarb.toml")
            let newContractsSrcPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts/src")
            try fileManager.createDirectory(at: newContractsPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: newContractsSrcPath, withIntermediateDirectories: true, attributes: nil)

            try fileManager.copyItem(at: originalScarbTomlPath, to: newScarbTomlPath)

            guard let cairoSrcPaths = Bundle.module.urls(forResourcesWithExtension: "cairo", subdirectory: nil) else {
                throw DevnetClientError.missingResourceFile
            }
            for cairoContract in cairoSrcPaths {
                let newCairoContractPath = URL(fileURLWithPath: "\(newContractsSrcPath.path)/\(cairoContract.lastPathComponent)")
                try fileManager.copyItem(at: cairoContract, to: newCairoContractPath)
            }

            self.scarbTomlPath = newScarbTomlPath.path
            self.contractsPath = newContractsPath.path

            self.devnetProcess = devnetProcess

            // Initialize new accounts file
            let _ = try await deployAccount(name: "__default_cast__")
        }

        public func close() {
            guard devnetProcess != nil else {
                return
            }

            guard devnetProcess!.isRunning else {
                return
            }

            devnetProcess!.terminate()
            devnetProcess!.waitUntilExit()

            self.devnetProcess = nil
        }

        public func prefundAccount(address: Felt) async throws {
            try guardDevnetIsRunning()

            let url = URL(string: "\(baseUrl)/mint")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let payload = PrefundPayload(address: address, amount: 5_000_000_000_000_000)
            request.httpBody = try JSONEncoder().encode(payload)

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            var response: URLResponse?

            (_, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw DevnetClientError.devnetError
            }

            guard response.statusCode == 200 else {
                throw DevnetClientError.devnetError
            }
        }

        private func createAccount(name: String,
                                   classHash: Felt = accountContractClassHash,
                                   salt: Felt? = nil) async throws -> AccountCreateSnCastResponse
        {
            var params = [
                "create",
                "--name",
                name,
                "--class-hash",
                classHash.toHex(),
            ]
            if salt != nil {
                params.append("--salt")
                params.append(salt!.toHex())
            }

            let response = try runSnCast(
                command: "account",
                args: params
            ) as! AccountCreateSnCastResponse

            return response
        }

        public func deployAccount(name: String,
                                  classHash: Felt = DevnetClient.accountContractClassHash,
                                  salt: Felt? = nil,
                                  maxFee: Felt? = nil) async throws -> DeployAccountResult
        {
            try guardDevnetIsRunning()

            let newAccount = try await createAccount(name: name, salt: salt)
            let maxFeeEstimate = newAccount.maxFee

            let details = try readAccountDetails(accountName: name)
            try await prefundAccount(address: details.address)

            let params = [
                "deploy",
                "--name",
                name,
                "--max-fee",
                maxFee?.toHex() ?? Felt(maxFeeEstimate.value * 2)!.toHex(),
                "--class-hash",
                classHash.toHex(),
            ]
            let result = try runSnCast(
                command: "account",
                args: params
            ) as! AccountDeploySnCastResponse

            return DeployAccountResult(
                details: details,
                transactionHash: result.transactionHash
            )
        }

        public func declareContract(contractName: String, maxFee: Felt) async throws -> DeclareContractResult {
            try guardDevnetIsRunning()

            let cairoFilePath = "\(self.contractsPath!)/src/\(contractName).cairo"

            guard FileManager.default.fileExists(atPath: cairoFilePath) else {
                throw DevnetClientError.missingResourceFile
            }

            let params = [
                "--contract-name",
                contractName,
                "--max-fee",
                maxFee.toHex(),
            ]
            let result = try runSnCast(
                command: "declare",
                args: params
            ) as! DeclareSnCastResponse

            return DeclareContractResult(
                classHash: result.classHash,
                transactionHash: result.transactionHash
            )
        }

        public func declareDeployContract(contractName: String,
                                          constructorCalldata: [Felt] = [],
                                          salt: Felt? = nil,
                                          unique: Bool = false,
                                          maxFeeDeclare: Felt = 1_000_000_000_000_000,
                                          maxFeeDeploy: Felt = 1_000_000_000_000_000) async throws -> DeployContractResult
        {
            try guardDevnetIsRunning()

            if let result = deployedContractsAtName[contractName] {
                return result
            }
            let declaredContract = try await declareContract(contractName: contractName, maxFee: maxFeeDeclare)

            let classHash = declaredContract.classHash
            let result = try await deployContract(
                classHash: classHash,
                constructorCalldata: constructorCalldata,
                salt: salt,
                unique: unique,
                maxFee: maxFeeDeploy
            )

            deployedContractsAtName[contractName] = result

            return result
        }

        public func deployContract(classHash: Felt,
                                   constructorCalldata: [Felt] = [],
                                   salt: Felt? = nil,
                                   unique: Bool = false,
                                   maxFee: Felt = 1_000_000_000_000_000) async throws -> DeployContractResult
        {
            try guardDevnetIsRunning()

            var params = [
                "--class-hash",
                classHash.toHex(),
                "--max-fee",
                maxFee.toHex(),
            ]
            if !constructorCalldata.isEmpty {
                params.append("--constructor-calldata")

                let hexCalldata = constructorCalldata.map { $0.toHex() }
                params.append(contentsOf: hexCalldata)
            }
            if unique {
                params.append("--unique")
            }
            if salt != nil {
                params.append("--salt")
                params.append(salt!.toHex())
            }

            let result = try runSnCast(
                command: "deploy",
                args: params
            ) as! DeploySnCastResponse

            return DeployContractResult(
                contractAddress: result.contractAddress,
                transactionHash: result.transactionHash
            )
        }

        public func isRunning() -> Bool {
            if let devnetProcess, devnetProcess.isRunning {
                return true
            }

            return false
        }

        private func runSnCast(command: String, args: [String], profileName: String = "default") throws -> SnCastResponse {
            let process = Process()

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            // TODO: migrate to URLs everywhere - path fields are marked as deprecated
            process.launchPath = snCastPath
            process.currentDirectoryPath = contractsPath!
            process.arguments = [
                "--json",
//                "--path-to-scarb-toml",
//                contractsPath,
//                scarbTomlPath!,
                "--accounts-file",
                "\(accountDirectory)/starknet_open_zeppelin_accounts.json",
                "--profile",
                profileName,
                command,
            ] + args

            var environment = ProcessInfo.processInfo.environment
            let existingPath = environment["PATH"] ?? ""

            let scarbParentDir = URL(fileURLWithPath: scarbPath).deletingLastPathComponent().path
            let newPath = [existingPath, scarbParentDir].joined(separator: ":")
            environment["PATH"] = newPath
            process.environment = environment

            process.standardInput = nil
            process.launch()
            process.waitUntilExit()

//            let command = "\(process.launchPath!) \(process.arguments!.joined(separator: " "))"
//             print(command)

            guard process.terminationStatus == 0 else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let error = String(decoding: errorData, as: UTF8.self)

                throw SnCastError.snCastError(error)
            }

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            var output = String(decoding: outputData, as: UTF8.self)

            // TODO: remove this - pending sncast update
            if let range = output.range(of: "{") {
                // Remove all characters before the first `{`
                output.removeSubrange(output.startIndex ..< range.lowerBound)
            } else {
                throw SnCastError.invalidResponseJson
            }

            // Try parsing the trimmed output as JSON
            let outputDataTrimmed = output.data(using: .utf8)!
            let result = try JSONDecoder().decode(SnCastResponseWrapper.self, from: outputDataTrimmed)

            return result.response
        }

        typealias AccountDetailsResponse = [String: [String: AccountDetails]]

        public func readAccountDetails(accountName: String) throws -> AccountDetails {
            let result = AccountDetails(privateKey: 0, publicKey: 0, address: 0, salt: 0)
            let filename = "\(accountDirectory)/starknet_open_zeppelin_accounts.json"

            let contents = try String(contentsOfFile: filename)

            if let data = contents.data(using: .utf8),
               let response = try? JSONDecoder().decode(AccountDetailsResponse.self, from: data),
               let account = response["alpha-goerli"]?[accountName]
            {
                return account
            }

            throw DevnetClientError.accountNotFound
        }

        private func getValueFromLine(line: String, index: Int = 1) -> String {
            let split = line.components(separatedBy: ": ")
            return split[index]
        }

        private func getTransactionResult(lines: [String], offset: Int = 2) -> DeployContractResult {
            let address = Felt(fromHex: getValueFromLine(line: lines[offset])) ?? 0
            let transactionHash = Felt(fromHex: getValueFromLine(line: lines[offset + 1])) ?? 0
            return DeployContractResult(contractAddress: address, transactionHash: transactionHash)
        }

        private func guardDevnetIsRunning() throws {
            guard isRunning() else {
                throw DevnetClientError.devnetNotRunning
            }
        }

        private func sleep(seconds: UInt64) async throws {
            try await Task.sleep(nanoseconds: seconds * UInt64(Double(NSEC_PER_SEC)))
        }

        public func assertTransactionSucceeded(transactionHash: Felt) async throws {
            guard try await isTransactionSuccessful(transactionHash: transactionHash) == true else {
                throw DevnetClientError.transactionFailed
            }
        }

        public func assertTransactionFailed(transactionHash: Felt) async throws {
            guard try await isTransactionSuccessful(transactionHash: transactionHash) == false else {
                throw DevnetClientError.transactionSucceeded
            }
        }

        public func isTransactionSuccessful(transactionHash: Felt) async throws -> Bool {
            let params = [transactionHash]
            let rpcPayload = JsonRpcPayload(method: .getTransactionReceipt, params: params)

            let url = URL(string: rpcUrl)!
            let networkProvider = HttpNetworkProvider()
            var response: JsonRpcResponse<DevnetReceipt>

            let config = HttpNetworkProvider.Configuration(url: url, method: "POST", params: [
                (header: "Content-Type", value: "application/json"),
                (header: "Accept", value: "application/json"),
            ])

            do {
                response = try await networkProvider.send(payload: rpcPayload, config: config, receive: JsonRpcResponse<DevnetReceipt>.self)
            } catch _ as HttpNetworkProviderError {
                throw DevnetClientError.networkProviderError
            } catch {
                throw DevnetClientError.devnetError
            }

            if let result = response.result {
                return result.isSuccessful
            } else if let error = response.error {
                throw DevnetClientError.jsonRpcError(error.code, error.message)
            } else {
                throw DevnetClientError.devnetError
            }
        }
    }

#endif
