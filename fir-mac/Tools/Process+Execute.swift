//
//  Process+Execute.swift
//  fir-mac
//
//  Created by isaced on 2017/5/10.
//
//

import Foundation

struct ProcessOutput {
    var output: String
    var status: Int32
    var success: Bool {
        return status != 0
    }
    init(status: Int32, output: String){
        self.status = status
        self.output = output
    }
}

extension Process {
    func launchSyncronous() -> ProcessOutput {
        self.standardInput = FileHandle.nullDevice
        let pipe = Pipe()
        self.standardOutput = pipe
        self.standardError = pipe
        self.launch()
        self.waitUntilExit()

        let pipeFile = pipe.fileHandleForReading
        let data = pipeFile.readDataToEndOfFile()
        pipeFile.closeFile();
        
        self.terminate();
        
        let output = String(data: data, encoding: .utf8)
        
        return ProcessOutput(status: self.terminationStatus, output: output!)
        
    }
    
    func execute(_ launchPath: String, workingDirectory: String?, arguments: [String]?) -> ProcessOutput{
        self.launchPath = launchPath
        if arguments != nil {
            self.arguments = arguments
        }
        if workingDirectory != nil {
            self.currentDirectoryPath = workingDirectory!
        }
        return self.launchSyncronous()
    }
    
}
