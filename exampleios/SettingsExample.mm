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
#import "SettingsExample.h"

#include "fit_mesg_broadcaster.hpp"
#include "fit_file_id_mesg.hpp"
#include "fit_file_id_mesg_listener.hpp"
#include "fit_user_profile_mesg.hpp"
#include "fit_user_profile_mesg_listener.hpp"

class SettingsListener : fit::FileIdMesgListener, fit::UserProfileMesgListener
{
public:
    void OnMesg(fit::FileIdMesg& mesg)
    {
        NSLog(@"Type: %d", mesg.GetType());
        NSLog(@"Manufacturer: %d", mesg.GetManufacturer());
        NSLog(@"Product: %d", mesg.GetProduct());
        NSLog(@"SerialNumber: %d", mesg.GetSerialNumber());
    }

    void OnMesg(fit::UserProfileMesg& mesg)
    {
        NSLog(@"Age: %d", mesg.GetAge());
        NSLog(@"Weight: %f", mesg.GetWeight());
        NSLog(@"Gender: %d", mesg.GetGender());
        NSLog(@"Name: %@", [Example stringForWString:mesg.GetFriendlyName()]);
    }
};

@interface SettingsExample ()

@end

@implementation SettingsExample

- (id)init
{
    self = [super init];
    if(self)
    {
        super.fileName = @"SettingsFile.fit";
    }
    return self;
}

- (FIT_UINT8)encode
{
    FILE *file;
    super.fe = [[FitEncode alloc] initWithVersion:fit::ProtocolVersion::V10];

    if( ( file = [super openFileWithParams:[super writeOnlyParam]] ) == NULL )
    {
        NSLog(@"Error opening file %@", super.fileName);
        return -1;
    }

    fit::FileIdMesg fileId; // Every FIT file requires a File ID message
    fileId.SetType(FIT_FILE_SETTINGS);
    fileId.SetManufacturer(FIT_MANUFACTURER_DYNASTREAM);
    fileId.SetProduct(1000);
    fileId.SetSerialNumber(12345);

    fit::UserProfileMesg userProfile;
    userProfile.SetGender(FIT_GENDER_FEMALE);
    userProfile.SetWeight((FIT_FLOAT32)63.1);
    userProfile.SetAge(99);
    std::wstring wstring_name(L"TestUser");
    userProfile.SetFriendlyName(wstring_name);

    [super.fe Open:file];
    [super.fe WriteMesg:fileId];
    [super.fe WriteMesg:userProfile];

    if(![super.fe Close])
    {
        NSLog(@"Error closing file %@", super.fileName);
        return -1;
    }

    fclose(file);
    file = NULL;
    return 0;
}

- (FIT_UINT8)decode
{
    @try {
        FILE *file;
        super.fd = [[FitDecode alloc] init];
        if( ( file = [super openFileWithParams:[super readOnlyParam]] ) == NULL)
        {
            NSLog(@"Error opening file %@", super.fileName);
            return -1;
        }

        SettingsListener listener;
        fit::MesgBroadcaster mesgBroadcaster = fit::MesgBroadcaster();
        mesgBroadcaster.AddListener((fit::FileIdMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::UserProfileMesgListener &)listener);
        [super.fd IsFit:file];
        [super.fd CheckIntegrity:file];
        [super.fd Read:file withListener:&mesgBroadcaster andDefListener:NULL];
        fclose(file);
        file = NULL;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
    @finally {
        return -1;
    }
    return 0;
}

@end