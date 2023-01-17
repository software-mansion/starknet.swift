import Foundation

#if os(macOS)

class DevnetClient{
    private var host = "0.0.0.0"
    private var port = 5050
    private var seed = 1053545547
    // Paths still arent working properly, for now I'm using absolute paths
    private var accountDirectory = "/Users/jakub/test"
    private var baseUrl: String
   
    private var isDevnetRunning = false
    private var devnetProcess: Process!
    
    var gatewayUrl: String
    var feederGatewayUrl: String
    var rpcUrl: String
    
    struct AccountDetails{
        var private_key: Felt
        var public_key: Felt
        var address: Felt
        var salt: Felt
    }
    
    struct TransactionResult {
        var address: Felt
        var hash: Felt
    }
    
    struct DeployAccountResult{
        var details: AccountDetails
        var txHash: Felt
    }
    
    
    
    init() {
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
        
        task.launchPath = "/bin/zsh"
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
        
        devnetProcess.launchPath = "/bin/zsh"
        devnetProcess.standardInput = nil
        devnetProcess.launch()
        
        isDevnetRunning = true
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
    public func prefundAccount(accountAddress: Felt) {
        let url = URL(string: "https://httpbin.org/post?address=\(accountAddress)&amount=5000000000000000")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "{\"address\":\"\(accountAddress.toHex())\",\"amount\": 5000000000000000}"
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
    
    public func deployAccount(name: String) {
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
        
        //TODO prefundAccount
        let _ = runStarknetCli(
                        name: "Account deployment",
                        command: "deploy_account",
                        args: params.joined(separator: " "))
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
        
        process.launchPath = "/bin/zsh"
        process.standardInput = nil
        process.launch()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        
        return output
    }
    
    
    public func readAccountDetails(accountName: String) -> AccountDetails {
        var result = AccountDetails(private_key:0, public_key:0, address:0, salt:0)
        let filename = "\(accountDirectory)/starknet_open_zeppelin_accounts.json"
        print(filename)
        do {
            let contents = try String(contentsOfFile: filename)
            if let data = contents.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        //return json
                    if let accounts = json!["alpha-goerli"] {
                        let dict = accounts as? [String: Any]
                        if let wantedAccount = dict![accountName] {
                            let dict2 = wantedAccount as? [String : Any]
                            result.address = Felt(fromHex: dict2?["address"] as! String) ?? "0x0"
                            result.private_key = Felt(fromHex: dict2?["private_key"] as! String) ?? "0x0"
                            result.salt = Felt(fromHex: dict2?["salt"] as! String) ?? "0x0"
                            result.public_key = Felt(fromHex: dict2?["public_key"] as! String) ?? "0x0"
                        }
                    }
                } catch {
                    print("Something went wrong")
                }
            }        } catch {
            //TODO error handling
        }
        
        return result
    }
    
}

#endif
