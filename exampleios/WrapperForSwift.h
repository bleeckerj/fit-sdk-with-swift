//
//  WrapperForSwift.h
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//
//
#import <Foundation/Foundation.h>

@class SwiftThatUsesWrapperForSwift;

@interface WrapperForSwift : NSObject
- (id)init:(SwiftThatUsesWrapperForSwift *)_supervisor;
- (NSData *)decode:(NSString *)path;
- (UInt8)encode;
- (void)method_callback:(Float64)val;
- (void)setSupervisor:(SwiftThatUsesWrapperForSwift *)_supervisor;
@end
