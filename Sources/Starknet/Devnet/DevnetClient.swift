import Foundation

class DevnetClient{
    private var host = "0.0.0.0"
    private var port = 5051
    private var seed = 1053545547
    
    private var isDevnetRunning = false
    private var devnetProcess: Process!
    
    public func start(){
        
        let arguments = "--host \(host) --port \(port) --seed \(seed)"
        
        // This kills any zombie devnet processes left over from previous
        // test runs, if any.
        let task = Process()
        task.arguments = ["-c", "pkill -f starknet-devnet " + arguments]
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
        devnetProcess.arguments = ["-c", command + " " + arguments]
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
}
