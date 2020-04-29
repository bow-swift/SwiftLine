//
//  Runner.swift
//  🏃
//
//  Created by Omar Abdelhafith on 02/11/2015.
//  Copyright © 2015 Omar Abdelhafith. All rights reserved.
//

import Foundation


class 🏃{
    
    class func runWithoutCapture(_ command: String) -> Int {
        let initalSettings = RunSettings()
        initalSettings.execution = .interactive
        return run(command, args: [], settings: initalSettings).exitStatus
    }
    
    @discardableResult
    class func run(_ command: String, args: String...) -> RunResults {
        return run(command, args: args as [String])
    }
    
    @discardableResult
    class func run(_ command: String, args: [String]) -> RunResults {
        let settings = RunSettings()
        return run(command, args: args, settings: settings)
    }
    
    @discardableResult
    class func run(_ command: String, settings: ((RunSettings) -> Void)) -> RunResults {
        let initalSettings = RunSettings()
        settings(initalSettings)
        
        return run(command, args: [], settings: initalSettings)
    }
    
    @discardableResult
    class func run(_ command: String, args: [String], settings: ((RunSettings) -> Void)) -> RunResults {
        let initalSettings = RunSettings()
        settings(initalSettings)
        
        return run(command, args: args, settings: initalSettings)
    }
    
    @discardableResult
    class func run(_ command: String, echo: EchoSettings) -> RunResults {
        let initalSettings = RunSettings()
        initalSettings.echo = echo
        return run(command, args: [], settings: initalSettings)
    }
    
    @discardableResult
    class func run(_ command: String, args: [String], settings: RunSettings) -> RunResults {
        
        let commandParts = commandToRun(command, args: args)
        
        let result: RunResults
        
        echoCommand(commandParts, settings: settings)
        
        switch settings.execution {
        case .default:
            result = executeActualCommand(commandParts)
        case .parallelizable:
            result = executeActualCommand(commandParts, executor: ActualTaskExecutor())
        case .dryRun:
            result = executeDryCommand(commandParts)
        case .interactive:
            result = executeIneractiveCommand(commandParts)
        case .log(let path):
            result = executeLogCommand(commandParts, logPath: path)
        }
        
        echoResult(result, settings: settings)
        
        return result
    }
    
    fileprivate class func executeDryCommand(_ commandParts: [String]) -> RunResults {
        return execute(commandParts, withExecutor: DryTaskExecutor())
    }
    
    fileprivate class func executeIneractiveCommand(_ commandParts: [String]) -> RunResults {
        return execute(commandParts, withExecutor: InteractiveTaskExecutor())
    }
    
    fileprivate class func executeLogCommand(_ commandParts: [String], logPath: String) -> RunResults {
        return execute(commandParts, withExecutor: LogTaskExecutor(logPath: logPath))
    }
    
    fileprivate class func executeActualCommand(_ commandParts: [String], executor: TaskExecutor = CommandExecutor.currentTaskExecutor) -> RunResults {
        return execute(commandParts, withExecutor: executor)
    }
    
    fileprivate class func execute(_ commandParts: [String], withExecutor executor: TaskExecutor) -> RunResults {
        let (status, stdout, stderr) = executor.execute(commandParts)
        return RunResults(exitStatus: status, stdout: stdout, stderr: stderr)
    }
    
    fileprivate class func commandToRun(_ command: String, args: [String]) -> [String] {
        return splitCommandToArgs(command) + args
    }
    
    fileprivate class func echoCommand(_ command: [String], settings: RunSettings) {
        if settings.echo.contains(.Command) {
            echoStringIfNotEmpty("Command", string: command.joined(separator: " "))
        }
    }
    
    fileprivate class func echoResult(_ result: RunResults, settings: RunSettings) {
        if settings.echo.contains(.Stdout) {
            echoStringIfNotEmpty("Stdout", string: result.stdout)
        }
        
        if settings.echo.contains(.Stderr) {
            echoStringIfNotEmpty("Stderr", string: result.stderr)
        }
    }
    
    fileprivate class func echoStringIfNotEmpty(_ title: String, string: String) {
        if !string.isEmpty {
            PromptSettings.print("\(title): \n\(string)")
        }
    }
}
