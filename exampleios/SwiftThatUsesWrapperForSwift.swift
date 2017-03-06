//
//  SwiftThatUsesWrapperForSwift.swift
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//

import Foundation


@objc class SwiftThatUsesWrapperForSwift:NSObject {
    
    var recordMessages : Array<Any> = Array()
    var sessionMessages: Array<Any> = Array()
    var eventMessages: Array<NSDictionary> = Array()
    
    
    func callback(timestamp: UInt32) -> Void {
        NSLog("%d", timestamp)
    }
    
    func callback(eventMesg: NSDictionary) -> Void {
        eventMessages.append(eventMesg)
    }
    
    func callback(sessionMesg: NSDictionary) -> Void {
        sessionMessages.append(sessionMesg)
        NSLog("\(sessionMessages)")
    }
    
    func callback(recordMesg: NSDictionary) -> UInt8 {
        NSLog("%@", recordMesg)
        recordMessages.append(recordMesg)
        //recordMesgs.append(recordMesg as! Dictionary<String, Any>)
        return 0;
    }
    
    func decodeFitFile(file : URL)
    {
        let wrapper:WrapperForSwift = WrapperForSwift(self)
        
        wrapper.setSupervisor(self)
        wrapper.decode(file.path)
        
    }
    
    func doSomething() {
        let wrapper:WrapperForSwift = WrapperForSwift(self)
        
        wrapper.setSupervisor(self)
        
        //        wrapper.decode("/Users/julian/Code/FitSDKRelease_20.24.01/examples/Activity.fit")
        let data:Data = wrapper.decode("/Users/julian/Desktop/170301154226.fit" )
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path_fit = dir.appendingPathComponent("170301154226.fit")
            let path_json = dir.appendingPathComponent("170301154226-summary.json")
            let event_json = dir.appendingPathComponent("170301154226-event.json")
            
            NSLog("\(path_json)")
            
            //writing
            do {
                var file_data : Data
                try file_data = JSONSerialization.data(withJSONObject: self.sessionMessages)
                var event_data : Data
                try event_data = JSONSerialization.data(withJSONObject: self.eventMessages)
                
                try data.write(to: path_fit, options: [])
                try file_data.write(to: path_json)
                try event_data.write(to: event_json)
                
                
            }
        catch {/* error handling here */
            NSLog("ERROR WRITING FILE")
            
        }
        
            decodeFitFile(file: path_fit)
        
    }
    //wrapper.decode()
    //wrapper.encode()
    
    
    
    
    
}
}


