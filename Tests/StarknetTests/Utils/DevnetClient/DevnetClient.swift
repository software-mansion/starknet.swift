import BigInt
import Foundation
@testable import Starknet

protocol DevnetClientProtocol {
    var rpcUrl: String { get }
    var mintUrl: String { get }

    var host: String { get }
    var port: Int { get }
    var seed: Int { get }
    var baseUrl: String { get }

    var constants: DevnetClientConstants.Type { get }

    func start() async throws
    func close()

    func isRunning() -> Bool

    func prefundAccount(address: Felt, amount: UInt64, unit: StarknetPriceUnit) async throws
    func createDeployAccount(name: String, classHash: Felt, salt: Felt?) async throws -> DeployAccountResult
    func createAccount(name: String, classHash: Felt, salt: Felt?) async throws -> CreateAccountResult
    func deployAccount(name: String, classHash: Felt, prefund: Bool) async throws -> DeployAccountResult
    func declareDeployContract(contractName: String, constructorCalldata: [Felt], salt: Felt?, unique: Bool) async throws -> DeclareDeployContractResult
    func declareContract(contractName: String) async throws -> DeclareContractResult
    func deployContract(classHash: Felt, constructorCalldata: [Felt], salt: Felt?, unique: Bool) async throws -> DeployContractResult
    func invokeContract(contractAddress: Felt, function: String, calldata: [Felt]) async throws -> InvokeContractResult
    func readAccountDetails(accountName: String) throws -> AccountDetails

    func assertTransactionSucceeded(transactionHash: Felt) async throws
    func assertTransactionFailed(transactionHash: Felt) async throws
    func isTransactionSuccessful(transactionHash: Felt) async throws -> Bool
}

extension DevnetClientProtocol {
    func prefundAccount(address: Felt, amount: UInt64 = 5_000_000_000_000_000_000, unit: StarknetPriceUnit = .wei) async throws {
        try await prefundAccount(address: address, amount: amount, unit: unit)
    }

    func createDeployAccount(
        name: String,
        classHash: Felt = DevnetClientConstants.accountContractClassHash,
        salt: Felt? = .zero
    ) async throws -> DeployAccountResult {
        try await createDeployAccount(
            name: name,
            classHash: classHash,
            salt: salt
        )
    }

    func createDeployAccount() async throws -> DeployAccountResult {
        try await createDeployAccount(
            name: UUID().uuidString,
            classHash: DevnetClientConstants.accountContractClassHash,
            salt: .zero
        )
    }

    func createAccount(
        name: String,
        classHash: Felt = DevnetClientConstants.accountContractClassHash,
        salt: Felt? = .zero
    ) async throws -> CreateAccountResult {
        try await createAccount(
            name: name,
            classHash: classHash,
            salt: salt
        )
    }

    func createAccount() async throws -> CreateAccountResult {
        try await createAccount(
            name: UUID().uuidString,
            classHash: DevnetClientConstants.accountContractClassHash,
            salt: .zero
        )
    }

    func deployAccount(
        name: String,
        classHash: Felt = DevnetClientConstants.accountContractClassHash,
        prefund: Bool = true
    ) async throws -> DeployAccountResult {
        try await deployAccount(name: name, classHash: classHash, prefund: prefund)
    }

    func declareContract(contractName: String) async throws -> DeclareContractResult {
        try await declareContract(contractName: contractName)
    }

    func declareDeployContract(
        contractName: String,
        constructorCalldata: [Felt] = [],
        salt: Felt? = .zero,
        unique: Bool = false
    ) async throws -> DeclareDeployContractResult {
        try await declareDeployContract(
            contractName: contractName,
            constructorCalldata: constructorCalldata,
            salt: salt,
            unique: unique
        )
    }

    func deployContract(
        classHash: Felt,
        constructorCalldata: [Felt] = [],
        salt: Felt? = .zero,
        unique: Bool = false
    ) async throws -> DeployContractResult {
        try await deployContract(
            classHash: classHash,
            constructorCalldata: constructorCalldata,
            salt: salt,
            unique: unique
        )
    }

    func invokeContract(
        contractAddress: Felt,
        function: String,
        calldata: [Felt] = []
    ) async throws -> InvokeContractResult {
        try await invokeContract(
            contractAddress: contractAddress,
            function: function,
            calldata: calldata
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
        private var devnetProcess: Process?

        private let accountDirectory: URL
        private let devnetPath: String
        private let scarbPath: String
        private let snCastPath: String
        private var scarbTomlPath: String!
        private var toolVersionsPath: String!
        private var contractsPath: String!
        private let tmpPath: String

        // Cache declared and deployed contracts by name and classHash respectively
        private var declaredContractsAtName: [String: DeclareContractResult] = [:]
        private var deployedContracts: [Felt: DeployContractResult] = [:]
        private var deployedAccounts: [Felt: DeployAccountResult] = [:]

        let host: String
        let port: Int
        let seed: Int
        let baseUrl: String
        let rpcUrl: String
        let mintUrl: String

        let constants: DevnetClientConstants.Type = DevnetClientConstants.self

        init(host: String = "127.0.0.1", port: Int = 5051, seed: Int = 1_053_545_547) {
            self.host = host
            self.port = port
            self.seed = seed

            baseUrl = "http://\(host):\(port)"
            rpcUrl = "\(baseUrl)/rpc"
            mintUrl = "\(baseUrl)/mint"

            devnetPath = ProcessInfo.processInfo.environment["DEVNET_PATH"] ?? "starknet-devnet"
            scarbPath = ProcessInfo.processInfo.environment["SCARB_PATH"] ?? "scarb"
            snCastPath = ProcessInfo.processInfo.environment["SNCAST_PATH"] ?? "sncast"
            tmpPath = ProcessInfo.processInfo.environment["TMPDIR"] ?? "/tmp/starknet-swift"
            accountDirectory = URL(string: tmpPath)!
        }

        public func start() async throws {
            guard !self.devnetPath.isEmpty, !self.scarbPath.isEmpty, !self.snCastPath.isEmpty else {
                throw DevnetClientError.environmentVariablesNotSet
            }

            // This kills any zombie devnet processes left over from previous test runs, if any.
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
                "--state-archive-capacity",
                "full",
                "--initial-balance",
                "1000000000000000000000000000000000000000000000000000000000000000000",
            ]
            devnetProcess.launchPath = devnetPath
            devnetProcess.standardInput = nil
            devnetProcess.launch()

            try await sleep(seconds: 3)

            guard let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) else {
                throw DevnetClientError.startupError
            }

            if output.contains("Connection in use") {
                throw DevnetClientError.portAlreadyInUse
            }

            guard devnetProcess.isRunning else {
                throw DevnetClientError.startupError
            }

            self.devnetProcess = devnetProcess

            // Setting up a temporary directory for accounts file and cairo contracts
            let fileManager = FileManager.default
            let tmpDirectoryPath = URL(string: tmpPath)!
            guard let filePaths = try? fileManager.contentsOfDirectory(at: tmpDirectoryPath, includingPropertiesForKeys: nil, options: []) else {
                throw DevnetClientError.fileManagerError
            }
            for filePath in filePaths {
                try? fileManager.removeItem(at: filePath)
            }

            //  Recreating a file structure required by scarb
            guard let scarbTomlPath = Bundle.module.path(forResource: "Scarb", ofType: "toml") else {
                throw DevnetClientError.missingResourceFile
            }

            guard let toolVersionsPath = Bundle.module.path(forResource: "tool-versions", ofType: nil) else {
                throw DevnetClientError.missingResourceFile
            }

            let scarbTomlResourcePath = URL(fileURLWithPath: scarbTomlPath)
            let toolVersionsResourcePath = URL(fileURLWithPath: toolVersionsPath)
            guard let contractResourcePaths = Bundle.module.urls(forResourcesWithExtension: "cairo", subdirectory: nil) else {
                throw DevnetClientError.missingResourceFile
            }

            let newContractsPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts")
            let newScarbTomlPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts/Scarb.toml")
            let newToolVersionsPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts/.tool-versions")
            let newContractsSrcPath = URL(fileURLWithPath: "\(self.tmpPath)/Contracts/src")

            try fileManager.createDirectory(at: newContractsPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: newContractsSrcPath, withIntermediateDirectories: true, attributes: nil)

            try fileManager.copyItem(at: scarbTomlResourcePath, to: newScarbTomlPath)
            try fileManager.copyItem(at: toolVersionsResourcePath, to: newToolVersionsPath)
            for contractPath in contractResourcePaths {
                let newContractPath = URL(fileURLWithPath: "\(newContractsSrcPath.path)/\(contractPath.lastPathComponent)")
                try fileManager.copyItem(at: contractPath, to: newContractPath)
            }

            self.scarbTomlPath = newScarbTomlPath.path
            self.toolVersionsPath = newToolVersionsPath.path
            self.contractsPath = newContractsPath.path

            // TODO: (#130) Use the old approach once we're able to update sncast
            guard let accountsPath = Bundle.module.path(forResource: "starknet_open_zeppelin_accounts", ofType: "json") else {
                throw DevnetClientError.missingResourceFile
            }
            let accountsResourcePath = URL(fileURLWithPath: accountsPath)
            let newAccountsPath = URL(fileURLWithPath: "\(self.tmpPath)/starknet_open_zeppelin_accounts.json")
            try fileManager.copyItem(at: accountsResourcePath, to: newAccountsPath)

            // FIXME:
//            let _ = try await deployAccount(name: "__default__")

            // // Initialize new accounts file
            // let _ = try await createDeployAccount(name: "__default__")
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

        public func prefundAccount(address: Felt, amount: UInt64, unit: StarknetPriceUnit) async throws {
            try guardDevnetIsRunning()

            let url = URL(string: mintUrl)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let payload = PrefundPayload(address: address, amount: amount, unit: unit)
            request.httpBody = try JSONEncoder().encode(payload)

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            var response: URLResponse?
            do {
                (_, response) = try await URLSession.shared.data(for: request)
            } catch {
                throw DevnetClientError.prefundError
            }
            guard let response = response as? HTTPURLResponse else {
                throw DevnetClientError.prefundError
            }
            guard response.statusCode == 200 else {
                throw DevnetClientError.prefundError
            }
        }

        public func createDeployAccount(
            name: String,
            classHash: Felt = DevnetClientConstants.accountContractClassHash,
            salt: Felt? = nil
        ) async throws -> DeployAccountResult {
            try guardDevnetIsRunning()

            let createResult = try await createAccount(name: name, salt: salt)
            let details = createResult.details
            try await prefundAccount(address: details.address)
            let deployResult = try await deployAccount(name: name, classHash: classHash)

            return DeployAccountResult(
                details: details,
                transactionHash: deployResult.transactionHash
            )
        }

        public func createAccount(
            name: String,
            classHash: Felt = DevnetClientConstants.accountContractClassHash,
            salt: Felt? = nil,
            type: String
        ) async throws -> CreateAccountResult {
            var params = [
                "create",
                "--name",
                name,
                "--class-hash",
                classHash.toHex(),
                "--type",
                type,
                "--silent",
                "--url",
                rpcUrl,
            ]
            if salt != nil {
                params.append("--salt")
                params.append(salt!.toHex())
            }

            let response = try runSnCast(
                command: "account",
                args: params
            ) as! AccountCreateSnCastResponse

            let details = try readAccountDetails(accountName: name)

            return CreateAccountResult(
                name: name,
                details: details
            )
        }

        public func deployAccount(
            name: String,
            classHash _: Felt = DevnetClientConstants.accountContractClassHash,
            prefund: Bool = true
        ) async throws -> DeployAccountResult {
            let details = try readAccountDetails(accountName: name)

            if let result = deployedAccounts[details.address] {
                return result
            }

            if prefund {
                try await prefundAccount(address: details.address)
            }

            let params = [
                "deploy",
                "--name",
                name,
                "--url",
                rpcUrl,
            ]
            let response = try runSnCast(
                command: "account",
                args: params
            ) as! AccountDeploySnCastResponse

            let result = DeployAccountResult(
                details: details,
                transactionHash: response.transactionHash
            )

            deployedAccounts[details.address] = result

            return result
        }

        public func declareDeployContract(
            contractName: String,
            constructorCalldata: [Felt] = [],
            salt: Felt? = nil,
            unique: Bool = false
        ) async throws -> DeclareDeployContractResult {
            try guardDevnetIsRunning()

            let declareResult = try await declareContract(contractName: contractName)
            let classHash = declareResult.classHash
            let deployResult = try await deployContract(
                classHash: classHash,
                constructorCalldata: constructorCalldata,
                salt: salt,
                unique: unique
            )
            return DeclareDeployContractResult(
                declare: declareResult,
                deploy: deployResult
            )
        }

        public func declareContract(contractName: String) async throws -> DeclareContractResult {
            try guardDevnetIsRunning()

            if let result = declaredContractsAtName[contractName] {
                return result
            }

            let params = [
                "--contract-name",
                contractName,
                "--url",
                rpcUrl,
            ]
            let response = try runSnCast(
                command: "declare",
                args: params
            ) as! DeclareSnCastResponse

            let result = DeclareContractResult(
                classHash: response.classHash,
                transactionHash: response.transactionHash
            )
            declaredContractsAtName[contractName] = result

            return result
        }

        public func deployContract(
            classHash: Felt,
            constructorCalldata: [Felt] = [],
            salt: Felt? = nil,
            unique: Bool = false
        ) async throws -> DeployContractResult {
            try guardDevnetIsRunning()

            if let result = deployedContracts[classHash] {
                return result
            }

            var params = [
                "--class-hash",
                classHash.toHex(),
                "--url",
                rpcUrl,
            ]
            if !constructorCalldata.isEmpty {
                params.append("--constructor-calldata")
                let hexCalldata = constructorCalldata.map { $0.toHex() }
                params.append(hexCalldata.joined(separator: " "))
            }
            if unique {
                params.append("--unique")
            }
            if salt != nil {
                params.append("--salt")
                params.append(salt!.toHex())
            }

            let response = try runSnCast(
                command: "deploy",
                args: params
            ) as! DeploySnCastResponse

            let result = DeployContractResult(
                contractAddress: response.contractAddress,
                transactionHash: response.transactionHash
            )
            deployedContracts[classHash] = result

            return result
        }

        public func invokeContract(
            contractAddress: Felt,
            function: String,
            calldata: [Felt] = [],
            accountName: String = "__default__"
        ) async throws -> InvokeContractResult {
            var params = [
                "--contract-address",
                contractAddress.toHex(),
                "--function",
                function,
                "--url",
                rpcUrl,
            ]

            if !calldata.isEmpty {
                params.append("--calldata")
                let hexCalldata = calldata.map { $0.toHex() }
                params.append(hexCalldata.joined(separator: " "))
            }

            let response = try runSnCast(
                command: "invoke",
                args: params,
                accountName: accountName
            ) as! InvokeSnCastResponse

            return InvokeContractResult(transactionHash: response.transactionHash)
        }

        public func isRunning() -> Bool {
            if let devnetProcess, devnetProcess.isRunning {
                return true
            }

            return false
        }

        private func runSnCast(command: String, args: [String], accountName: String = "__default__") throws -> SnCastResponse {
            let process = Process()

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            // TODO: migrate to URLs everywhere - path fields are marked as deprecated
            process.launchPath = snCastPath
            process.currentDirectoryPath = contractsPath!
            process.arguments = [
                "--hex-format",
                "--json",
                "--accounts-file",
                "\(accountDirectory)/starknet_open_zeppelin_accounts.json",
                "--account",
                accountName,
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
            
            guard process.terminationStatus == 0 else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let error = String(decoding: errorData, as: UTF8.self)

                throw SnCastError.snCastError(error)
            }
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            var output = String(decoding: outputData, as: UTF8.self)

            // TODO: remove this - pending sncast update
            // As of sncast 0.40.0, "account create" currently outputs non-json data
            if let range = output.range(of: "{") {
                // Remove all characters before the first `{`
                output.removeSubrange(output.startIndex ..< range.lowerBound)
            } else {
                throw SnCastError.invalidResponseJson
            }
//            if let range = output.lastIndex(of: "{") {
//                output.removeSubrange(output.startIndex ..< range)
//            }

            let outputDataTrimmed = output.data(using: .utf8)!
            let result = try JSONDecoder().decode(SnCastResponseWrapper.self, from: outputDataTrimmed)

            return result.response
        }

        typealias AccountDetailsResponse = [String: [String: AccountDetails]]

        public func readAccountDetails(accountName: String) throws -> AccountDetails {
            let filename = "\(accountDirectory)/starknet_open_zeppelin_accounts.json"

            let contents = try String(contentsOfFile: filename)

            if let data = contents.data(using: .utf8),
               let response = try? JSONDecoder().decode(AccountDetailsResponse.self, from: data),
               let account = response["alpha-sepolia"]?[accountName]
            {
                return account
            }

            throw DevnetClientError.accountNotFound
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
            let params = GetTransactionByHashParams(hash: transactionHash)
            let rpcPayload = JsonRpcPayload(method: .getTransactionReceipt, params: .getTransactionByHash(params))

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
