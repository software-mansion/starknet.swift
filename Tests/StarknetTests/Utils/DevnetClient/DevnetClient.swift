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
    func deployAccount(name: String) async throws -> DeployAccountResult
    func deployContract(contractName: String) async throws -> TransactionResult
    func declareContract(contractName: String) async throws -> Felt
    func readAccountDetails(accountName: String) throws -> AccountDetails

    func assertTransactionPassed(transactionHash: Felt) async throws
}

extension DevnetClientProtocol {
    func deployAccount() async throws -> DeployAccountResult {
        try await deployAccount(name: UUID().uuidString)
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

        let gatewayUrl: String
        let feederGatewayUrl: String
        let rpcUrl: String

        init(host: String = "localhost", port: Int = 5050, seed: Int = 1_053_545_547) {
            self.host = host
            self.port = port
            self.seed = seed

            baseUrl = "http://\(host):\(port)"
            gatewayUrl = "\(baseUrl)/gateway"
            feederGatewayUrl = "\(baseUrl)/feeder_gateway"
            rpcUrl = "\(baseUrl)/rpc"

            devnetPath = ProcessInfo.processInfo.environment["DEVNET_PATH"] ?? "starknet-devnet"
            starknetPath = ProcessInfo.processInfo.environment["STARKNET_PATH"] ?? "starknet"

            let tmpPath = ProcessInfo.processInfo.environment["TMPDIR"] ?? "/tmp/starknet-swift"
            accountDirectory = URL(string: tmpPath)!
        }

        public func start() async throws {
            let arguments = "--host \(host) --port \(port) --seed \(seed) --disable-rpc-request-validation"

            guard !self.devnetPath.isEmpty, !self.starknetPath.isEmpty else {
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
                "-l",
                "-c",
                "\(devnetPath) \(arguments)",
            ]

            devnetProcess.launchPath = "/bin/sh"
            devnetProcess.standardInput = nil
            devnetProcess.launch()

            try await sleep(seconds: 3)

            guard let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) else {
                throw DevnetClientError.devnetError
            }

            print(output)

            if output.contains("Connection in use") {
                throw DevnetClientError.portAlreadyInUse
            }

            guard devnetProcess.isRunning else {
                throw DevnetClientError.devnetError
            }

            let fileManager = FileManager.default
            guard let filePaths = try? fileManager.contentsOfDirectory(at: accountDirectory, includingPropertiesForKeys: nil, options: []) else {
                throw DevnetClientError.devnetError
            }

            for filePath in filePaths {
                try? fileManager.removeItem(at: filePath)
            }

            self.devnetProcess = devnetProcess

            // Initialize new accounts file
            let _ = try await deployAccount(name: "__default__")
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

        public func deployAccount(name: String) async throws -> DeployAccountResult {
            try guardDevnetIsRunning()

            let params = [
                "--account_dir",
                accountDirectory.absoluteString,
                "--account",
                name,
                "--wallet",
                "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
            ]

            let _ = try runStarknetCli(
                command: "new_account",
                args: params.joined(separator: " ")
            )

            let details = try readAccountDetails(accountName: name)
            try await prefundAccount(address: details.address)

            let result = try runStarknetCli(
                command: "deploy_account",
                args: params.joined(separator: " ")
            )

            let array = result.components(separatedBy: CharacterSet.newlines)
            let transactionResult = getTransactionResult(lines: array, offset: 3)

            try await assertTransactionPassed(transactionHash: transactionResult.hash)

            return DeployAccountResult(details: details, txHash: transactionResult.hash)
        }

        public func deployContract(contractName: String) async throws -> TransactionResult {
            try guardDevnetIsRunning()

            let classHash = try await declareContract(contractName: contractName)

            let params = [
                "--class_hash",
                classHash.toHex(),
                "--account_dir",
                accountDirectory.absoluteString,
                "--wallet",
                "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
                "--max_fee",
                "0",
            ]

            let result = try runStarknetCli(
                command: "deploy",
                args: params.joined(separator: " ")
            )

            let array = result.components(separatedBy: CharacterSet.newlines)
            let transactionResult = getTransactionResult(lines: array)

            try await assertTransactionPassed(transactionHash: transactionResult.hash)
            return transactionResult
        }

        public func declareContract(contractName: String) async throws -> Felt {
            try guardDevnetIsRunning()

            guard let contractPath = Bundle.module.path(forResource: contractName, ofType: "json") else {
                throw DevnetClientError.missingResourceFile
            }

            let params = [
                "--contract",
                contractPath,
                "--account_dir",
                accountDirectory.absoluteString,
                "--wallet",
                "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
            ]

            let result = try runStarknetCli(
                command: "declare",
                args: params.joined(separator: " ")
            )

            let array = result.components(separatedBy: CharacterSet.newlines)

            let classHash = getValueFromLine(line: array[2])

            return Felt(fromHex: classHash)!
        }

        public func isRunning() -> Bool {
            if let devnetProcess, devnetProcess.isRunning {
                return true
            }

            return false
        }

        private func runStarknetCli(command: String, args: String) throws -> String {
            let process = Process()

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            process.arguments = [
                "-l",
                "-c",
                "\(starknetPath) \(command) \(args) --gateway_url \(gatewayUrl) --feeder_gateway_url \(feederGatewayUrl) --network alpha-goerli",
            ]

            process.launchPath = "/bin/sh"
            process.standardInput = nil
            process.launch()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let error = String(decoding: errorData, as: UTF8.self)

                throw DevnetClientError.devnetError
            }

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outputData, as: UTF8.self)

            return output
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

        private func getTransactionResult(lines: [String], offset: Int = 1) -> TransactionResult {
            let address = Felt(fromHex: getValueFromLine(line: lines[offset])) ?? 0
            let hash = Felt(fromHex: getValueFromLine(line: lines[offset + 1])) ?? 0
            return TransactionResult(address: address, hash: hash)
        }

        private func guardDevnetIsRunning() throws {
            guard isRunning() else {
                throw DevnetClientError.devnetNotRunning
            }
        }

        private func sleep(seconds: UInt64) async throws {
            try await Task.sleep(nanoseconds: seconds * UInt64(Double(NSEC_PER_SEC)))
        }

        public func assertTransactionPassed(transactionHash: Felt) async throws {
            var attempts = 5

            while attempts > 0 {
                let response = try runStarknetCli(command: "tx_status", args: "--hash \(transactionHash.toHex())")

                guard let statusResponse = try? JSONSerialization.jsonObject(with: response.data(using: .utf8)!) as? [String: Any],
                      let status = statusResponse["tx_status"] as? String
                else {
                    throw DevnetClientError.deserializationError
                }

                switch status {
                case "ACCEPTED_ON_L2", "ACCEPTED_ON_L1":
                    return
                case "REJECTED":
                    throw DevnetClientError.transactionRejected
                default:
                    attempts -= 1
                    try await sleep(seconds: 1)
                }
            }

            throw DevnetClientError.timeout
        }
    }

#endif
