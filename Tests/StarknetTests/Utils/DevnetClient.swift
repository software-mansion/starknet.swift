import Foundation

import Starknet

protocol DevnetClientProtocol {
    var gatewayUrl: String { get }
    var feederGatewayUrl: String { get }
    var rpcUrl: String { get }
    
    func start()
    func close()
    
    func prefundAccount(address: Felt)
    func deployAccount(name: String) -> DeployAccountResult
    func deployContract(contractPath: String) -> TransactionResult
    func declareContract(contractPath: String) -> TransactionResult
    func readAccountDetails(accountName: String) -> AccountDetails
}

struct AccountDetails: Codable{
    var privateKey: Felt
    var publicKey: Felt
    var address: Felt
    var salt: Felt
    
    enum CodingKeys: String, CodingKey {
        case privateKey = "private_key"
        case publicKey = "public_key"
        case address
        case salt
    }
    
    init(privateKey: Felt, publicKey: Felt, address: Felt, salt: Felt) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.address = address
        self.salt = salt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.privateKey = try container.decode(Felt.self, forKey: .privateKey)
        self.publicKey = try container.decode(Felt.self, forKey: .publicKey)
        self.address = try container.decode(Felt.self, forKey: .address)
        self.salt = try container.decode(Felt.self, forKey: .salt)
        //try verifyTransactionIdentifiers(container: container, codingKeysType: CodingKeys.self)
    }
}

struct TransactionResult {
    var address: Felt
    var hash: Felt
}

struct DeployAccountResult{
    var details: AccountDetails
    var txHash: Felt
}

enum DevnetClientError: Error {
    case invalidTestPlatform
}

// Due to DevnetClient being albe to run only on a macos, this
// factory method will throw, when ran on any other platform.
func makeDevnetClient() throws -> DevnetClientProtocol {
#if os(macOS)
    return DevnetClient()
#endif
    
    throw DevnetClientError.invalidTestPlatform
}

#if os(macOS)

class DevnetClient: DevnetClientProtocol {
    private let host: String
    private let port: Int
    private let seed: Int
    // Paths still arent working properly, for now I'm using absolute paths
    private let accountDirectory = "/Users/jakub/test"
    private let baseUrl: String
   
    private var isDevnetRunning = false
    private var devnetProcess: Process!
    
    let gatewayUrl: String
    let feederGatewayUrl: String
    let rpcUrl: String
    
    init(_host: String = "0.0.0.0", _port: Int = 5050, _seed: Int = 1053545547) {
        host = _host
        port = _port
        seed = _seed
        baseUrl = "http://\(host):\(port)"
        gatewayUrl = "\(baseUrl)/gateway"
        feederGatewayUrl = "\(baseUrl)/feeder_gateway"
        rpcUrl = "\(baseUrl)/rpc"
    }
    
    public func start(){
        
        let arguments = "--host \(host) --port \(port) --seed \(seed)"
        
        // This kills any zombie devnet processes left over from previous
        // test runs, if any.
        let task = Process()
        task.arguments = [
            "-c",
            "pkill -f starknet-devnet",
            arguments]
        
        task.launchPath = "/bin/sh"
        task.launch()
        task.waitUntilExit()
        
        // For some reason PATH used for executing shell commands in swift differs from
        // PATH in the system. Currently full path to the program is needed
        let command = "/Users/jakub/.asdf/shims/starknet-devnet"
        //let command = "starknet-devnet"
        
        devnetProcess = Process()
        let pipe = Pipe()
            
        devnetProcess.standardOutput = pipe
        devnetProcess.standardError = pipe
        devnetProcess.arguments = [
            "-l",
            "-c",
            command,
            arguments]
        
        devnetProcess.launchPath = "/bin/sh"
        devnetProcess.standardInput = nil
        devnetProcess.launch()
        
        isDevnetRunning = true
        
        // TODO: clear accountDirectory folder
    }
    
    public func close(){
        if(!isDevnetRunning){
            return
        }
        
        devnetProcess.terminate()
        
        // Wait for the process to be terminated
        devnetProcess.waitUntilExit()
        isDevnetRunning = false
    }
    
    // needs finishing
    public func prefundAccount(address: Felt) {
        let url = URL(string: "http://127.0.0.1:5050/mint")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "{\"address\":\"\(address.toHex())\",\"amount\": 5000000000000000}"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
    }
    
    public func deployAccount(name: String) -> DeployAccountResult{
        let params = [
            "--account_dir",
            accountDirectory,
            "--account",
            name,
            "--wallet",
            "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"]
        
        let _ = runStarknetCli(
                name: "Create account config",
                command: "new_account",
                args: params.joined(separator: " "))
        
        let details = readAccountDetails(accountName: name)
        //prefundAccount(address: account.address)
        
        let result = runStarknetCli(
                        name: "Account deployment",
                        command: "deploy_account",
                        args: params.joined(separator: " "))
        
        let array = result.components(separatedBy: CharacterSet.newlines)
        let tx = getTransactionResult(lines: array, offset: 3)
        
        return DeployAccountResult(details: details, txHash: tx.hash)
    }
    
    public func deployContract(contractPath: String) -> TransactionResult {
        let classHash = declareContract(contractPath: contractPath).hash
        
        let params = [
            "--class_hash",
            classHash.toHex(),
            "--account_dir",
            accountDirectory,
            "--wallet",
            "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
            "--max_fee",
            "0"]
        
        let result = runStarknetCli(
            name: "Contract deployment",
            command: "deploy",
            args: params.joined(separator: " "))

        let array = result.components(separatedBy: CharacterSet.newlines)
        let tx = getTransactionResult(lines: array)

        //TODO assertTxPassed
        //assertTxPassed(tx.hash)
        return tx
    }
    
    public func declareContract(contractPath: String) -> TransactionResult {
        let params = [
            "--contract",
            contractPath,
            "--account_dir",
            accountDirectory,
            "--wallet",
            "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"]
        let result = runStarknetCli(
            name: "Contract declare",
            command: "declare",
            args: params.joined(separator: " "))

        let array = result.components(separatedBy: CharacterSet.newlines)
        let tx = getTransactionResult(lines: array, offset: 2)

        //TODO assertTxPassed
        //assertTxPassed(tx.hash)
        return tx
    }

    
    private func runStarknetCli(name: String, command: String, args: String) -> String {
        let process = Process()
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = [
            "-l",
            "-c",
            "/Users/jakub/.asdf/shims/starknet \(command) \(args) --gateway_url \(gatewayUrl) --feeder_gateway_url \(feederGatewayUrl) --network alpha-goerli"]
        
        process.launchPath = "/bin/sh"
        process.standardInput = nil
        process.launch()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(decoding: outputData, as: UTF8.self)
        let _ = String(decoding: errorData, as: UTF8.self)
        
        return output
    }
    typealias AccountDetailsResponse = [String: [String: AccountDetails]]
    
    public func readAccountDetails(accountName: String) -> AccountDetails {
        let result = AccountDetails(privateKey:0, publicKey:0, address:0, salt:0)
        let filename = "\(accountDirectory)/starknet_open_zeppelin_accounts.json"
        
        do {
            let contents = try String(contentsOfFile: filename)
            if let data = contents.data(using: .utf8) {
                if let response = try? JSONDecoder().decode(AccountDetailsResponse.self, from: data) {
                    return (response["alpha-goerli"]?[accountName])!
                }
            }
            
        } catch {
        }
        
        return result
    }
    
 
    private func getValueFromLine(line: String, index: Int = 1) -> String {
        let split = line.components(separatedBy: ": ")
        return split[index]
    }
    
    private func getTransactionResult(lines: Array<String>, offset: Int = 1) -> TransactionResult {
        let address = Felt(fromHex: getValueFromLine(line: lines[offset])) ?? 0
        let hash = Felt(fromHex: getValueFromLine(line: lines[offset + 1])) ?? 0
        return TransactionResult(address: address, hash: hash)
    }
    
}

#endif
