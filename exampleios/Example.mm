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

#import <Foundation/Foundation.h>
#import "Example.h"

@implementation Example

@synthesize fileName;
@synthesize fe;
@synthesize fd;

- (id)init
{
    self = [super init];
    if(self)
    {
        fileName = @"";
        fe = NULL;
        fd = NULL;
    }
    return self;
}

- (const char *)readOnlyParam
{
    return "rb";
}

- (const char *)writeOnlyParam
{
    return "wb+";
}

- (FILE *)openFileWithParams:(const char *)params
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docsPath stringByAppendingPathComponent:fileName];
    return fopen([filePath UTF8String], params);
}

+ (NSString *)stringForWString:(FIT_WSTRING)wString
{
    return [[NSString alloc] initWithBytes:wString.data() length:wString.size() * sizeof(wchar_t) encoding:NSUTF32LittleEndianStringEncoding];
}

- (FIT_UINT8)encode
{
    return -1;
}

- (FIT_UINT8)decode
{
    return -1;
}

@end