////////////////////////////////////////////////////////////////////////////////
// The following FIT Protocol software provided may be used with FIT protocol
// devices only and remains the copyrighted property of Dynastream Innovations Inc.
// The software is being provided on an "as-is" basis and as an accommodation,
// and therefore all warranties, representations, or guarantees of any kind
// (whether express, implied or statutory) including, without limitation,
// warranties of merchantability, non-infringement, or fitness for a particular
// purpose, are specifically disclaimed.
//
// Copyright 2016 Dynastream Innovations Inc.
////////////////////////////////////////////////////////////////////////////////

#ifndef Example_h
#define Example_h

#import "FitEncode.h"
#import "FitDecode.h"

#include "fit.hpp"

@interface Example : NSObject

- (FIT_UINT8)encode;
- (FIT_UINT8)decode;
- (const char *)readOnlyParam;
- (const char *)writeOnlyParam;
- (FILE *)openFileWithParams:(const char *)params;

+ (NSString *)stringForWString:(FIT_WSTRING)wString;

@property NSString *fileName;
@property FitEncode *fe;
@property FitDecode *fd;

@end


#endif /* Example_h */
