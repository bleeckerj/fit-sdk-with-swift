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
#import "MonitoringExample.h"

#include "fit_file_id_mesg.hpp"
#include "fit_device_info_mesg.hpp"
#include "fit_monitoring_mesg.hpp"
#include "fit_mesg_broadcaster.hpp"
#include "fit_date_time.hpp"

class MonitoringListener : fit::FileIdMesgListener, fit::DeviceInfoMesgListener, fit::MonitoringMesgListener
{
public:
    void OnMesg(fit::FileIdMesg& mesg)
    {
        NSLog(@"FileIdMesg");
        NSLog(@"   Type: %d", mesg.GetType());
        NSLog(@"   Manufacturer: %d", mesg.GetManufacturer());
        NSLog(@"   Product: %d", mesg.GetProduct());
        NSLog(@"   SerialNumber: %d", mesg.GetSerialNumber());
    }

    void OnMesg(fit::MonitoringMesg& mesg)
    {
        NSLog(@"MonitoringMesg");
        if (mesg.GetTimestamp() != FIT_UINT32_INVALID)
            NSLog(@"   Timestamp: %d\n", mesg.GetTimestamp());

        NSLog(@"   Cycles: %f", mesg.GetCycles());
        NSLog(@"   Activity Type: %d", mesg.GetActivityType());
    }

    void OnMesg(fit::DeviceInfoMesg& mesg)
    {
        NSLog(@"Device info:\n");

        if (mesg.GetTimestamp() != FIT_UINT32_INVALID)
            NSLog(@"   Timestamp: %d\n", mesg.GetTimestamp());

        switch(mesg.GetBatteryStatus())
        {
            case FIT_BATTERY_STATUS_CRITICAL:
                NSLog(@"   Battery status: Critical\n");
                break;
            case FIT_BATTERY_STATUS_GOOD:
                NSLog(@"   Battery status: Good\n");
                break;
            case FIT_BATTERY_STATUS_LOW:
                NSLog(@"   Battery status: Low\n");
                break;
            case FIT_BATTERY_STATUS_NEW:
                NSLog(@"   Battery status: New\n");
                break;
            case FIT_BATTERY_STATUS_OK:
                NSLog(@"   Battery status: OK\n");
                break;
            default:
                NSLog(@"   Battery status: Invalid\n");
                break;
        }
    }
};

@interface MonitoringExample ()

@end

@implementation MonitoringExample

- (id)init
{
    self = [super init];
    if(self)
    {
        super.fileName = @"MonitoringFile.fit";
    }
    return self;
}

- (FIT_UINT8)encode
{
    FILE *file;
    super.fe = [[FitEncode alloc] initWithVersion:fit::ProtocolVersion::V10];

    if( ( file = [super openFileWithParams:[super writeOnlyParam]] ) == NULL)
    {
        NSLog(@"Error opening file %@", super.fileName);
        return -1;
    }

    [super.fe Open:file];

    time_t current_time_unix = time(0);
    fit::DateTime initTime(current_time_unix);

    fit::FileIdMesg fileId; // Every FIT file requires a File ID message
    fileId.SetType(FIT_FILE_MONITORING_B);
    fileId.SetManufacturer(FIT_MANUFACTURER_DYNASTREAM);
    fileId.SetProduct(1001);
    fileId.SetSerialNumber(54321);

    [super.fe WriteMesg:fileId];

    fit::DeviceInfoMesg deviceInfo;
    deviceInfo.SetTimestamp(initTime.GetTimeStamp()); // Convert to FIT time and write timestamp.
    deviceInfo.SetBatteryStatus(FIT_BATTERY_STATUS_GOOD);

    [super.fe WriteMesg:deviceInfo];

    fit::MonitoringMesg monitoring;
    // By default, each time a new message is written the Local Message Type 0 will be redefined to match the new message.
    // In this case,to avoid having a definition message each time there is a DeviceInfoMesg, we can manually set the Local Message Type of the MonitoringMessage to '1'.
    // By doing this we avoid an additional 7 definition messages in our FIT file.
    monitoring.SetLocalNum(1);

    monitoring.SetTimestamp(initTime.GetTimeStamp()); // Initialise Timestamp to now
    monitoring.SetCycles(0); // Initialise Cycles to 0
    for(int i = 0; i < 4; i++) // This loop represents 1/6 of a day
    {
        for(int j = 0; j < 4; j++) // Each one of these loops represent 1 hour
        {
            fit::DateTime walkingTime(current_time_unix);
            monitoring.SetTimestamp(walkingTime.GetTimeStamp());
            monitoring.SetActivityType(FIT_ACTIVITY_TYPE_WALKING); // By setting this to WALKING, the Cycles field will be interpretted as Steps
            monitoring.SetCycles(monitoring.GetCycles() + (rand()%1000+1)); // Cycles are accumulated (i.e. must be increasing)
            [super.fe WriteMesg:monitoring];
            current_time_unix += (time_t)(3600); //Add an hour to our contrieved timestamp
        }
        fit::DateTime statusTime(current_time_unix);
        deviceInfo.SetTimestamp(statusTime.GetTimeStamp());
        deviceInfo.SetBatteryStatus(FIT_BATTERY_STATUS_GOOD);
        [super.fe WriteMesg:deviceInfo];
    }

    if (![super.fe Close])
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
        if( ( file = [self openFileWithParams:[super readOnlyParam]] ) == NULL)
        {
            NSLog(@"Error opening file %@", super.fileName);
            return -1;
        }

        MonitoringListener listener;
        fit::MesgBroadcaster mesgBroadcaster = fit::MesgBroadcaster();
        mesgBroadcaster.AddListener((fit::FileIdMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::DeviceInfoMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::MonitoringMesgListener &)listener);
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