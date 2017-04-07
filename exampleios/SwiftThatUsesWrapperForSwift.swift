//
//  SwiftThatUsesWrapperForSwift.swift
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//

import Foundation

//extension String {
//    
//    var RFC3986UnreservedEncoded:String {
//        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
//        let unreservedCharsSet: CharacterSet = CharacterSet(charactersIn: unreservedChars)
//        let encodedString: String = self.addingPercentEncoding(withAllowedCharacters: unreservedCharsSet)!
//        return encodedString
//    }
//}

@objc class SwiftThatUsesWrapperForSwift:NSObject {
    
    var recordMessages : Array<Any> = Array()
    var sessionMessages: Array<Any> = Array()
    var eventMessages: Array<NSDictionary> = Array()
    var fileIDMessages: Array<Any> = Array()
    
    
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
    
    func callback(fileIDMesg: NSDictionary) -> Void {
        fileIDMessages.append(fileIDMesg)
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
        
        let fm: FileManager = FileManager()
        
        var files:[String]
        do {
            //let path = "/Users/julian/Desktop/Thingsee/Activities/"

            let path = "/Users/julian/Desktop/Thingsee/FIT_FILES/EZRA"
            
            
            files = try fm.contentsOfDirectory(atPath: path.appending("/"))
//            let paren = "("
            for file in files {
               // let _:Data = wrapper.decode(path.appending(file).replacingOccurrences(of: "(", with: paren, options: .literal, range: nil))
                //path = path.appending("/")
                
                if !(file.lowercased() .hasSuffix("fit"))   {
                    continue
                }
                
                
                let _:Data = wrapper.decode(path.appending("/").appending(file))

                let filename = file.components(separatedBy: ".").first!
                let path_json = URL(fileURLWithPath: path.appending("/").appending("\(filename)-summary.json"))
                let event_json = URL(fileURLWithPath: path.appending("/").appending("\(filename)-event.json"))
                let record_json = URL(fileURLWithPath: path.appending("/").appending("\(filename)-record.json"))
                
//                let path_fit =  dir.appendingPathComponent("170301154226.fit")
//                let path_json = dir.appendingPathComponent("170301154226-summary.json")
//                let event_json = dir.appendingPathComponent("170301154226-event.json")
                do {
                    let file_data : Data

                    
                    var withFileIDMessages : Array = [ [self.fileIDMessages, "file_id_messages"], [self.sessionMessages, "session_messages"] ]
                    try file_data = JSONSerialization.data(withJSONObject: withFileIDMessages)
                    
                    let event_data : Data
                    withFileIDMessages = [self.fileIDMessages, self.eventMessages]
                    try event_data = JSONSerialization.data(withJSONObject: withFileIDMessages)
                    
                    var record_data : Data
                    withFileIDMessages = [self.fileIDMessages, self.recordMessages]
                    try record_data = JSONSerialization.data(withJSONObject: withFileIDMessages)
                    
//                    var file_id_data : Data
//                    withFileIDMessages = [self.fileIDMessages, self.]
//                    try file_id_data = JSONSerialization.data(withJSONObject: self.fileIDMessages)
                    
                    try file_data.write(to: path_json)
                    
                    try event_data.write(to: event_json)
                    
                    try record_data.write(to: record_json)
                    
                    self.sessionMessages = []
                    self.eventMessages = []
                    self.recordMessages = []
                    self.fileIDMessages = []
                    
                }
                catch {/* error handling here */
                    NSLog("ERROR WRITING FILE")
                    
                }
            }
            
        } catch {
            print(error)
        }
        
        
   /*
        
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
 */
    //wrapper.decode()
    //wrapper.encode()
    
    
    
    
    
}
}


