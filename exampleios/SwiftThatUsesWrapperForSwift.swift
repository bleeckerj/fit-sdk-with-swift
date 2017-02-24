//
//  SwiftThatUsesWrapperForSwift.swift
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//

import Foundation

@objc class SwiftThatUsesWrapperForSwift:NSObject {
    func doSomething() {
        let wrapper:WrapperForSwift = WrapperForSwift()
        wrapper.decode()
        
        
    }
}


