//
//  WrapperForSwift.m
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//
#import "WrapperForSwift.h"
#import "FitDecode.h"
#import "FitEncode.h"
#include "fit_file_id_mesg.hpp"
#include "fit_record_mesg.hpp"
#include "fit_mesg_broadcaster.hpp"
#include "fit_event_mesg.hpp"
#include "math.h"
#include "fit_file_id_mesg_listener.hpp"
#include "fit_record_mesg_listener.hpp"
#include <dispatch/dispatch.h>
#import "exampleios-Swift.h"


class ActivityListener : fit::FileIdMesgListener, fit::MesgListener, fit::EventMesgListener, fit::RecordMesgListener, fit::SessionMesgListener
{
    WrapperForSwift* parent;

    dispatch_block_t simple_block;
    typedef FIT_UINT8 (^block_with_record_mesg_param)(fit::RecordMesg);
    typedef FIT_UINT8 (^block_with_event_mesg_param)(fit::EventMesg);
    typedef FIT_UINT8 (^block_with_fileid_mesg_parm)(fit::FileIdMesg);
    typedef FIT_UINT8 (^block_with_software_mesg_param)(fit::SoftwareMesg);
    typedef FIT_UINT8 (^block_with_session_mesg_param)(fit::SessionMesg);
    block_with_record_mesg_param record_mesg_block;
    block_with_event_mesg_param event_mesg_block;
    block_with_fileid_mesg_parm fileid_mesg_block;
    block_with_software_mesg_param software_mesg_block;
    block_with_session_mesg_param session_mesg_block;
    

    
public:
    void setParent(WrapperForSwift* wrapper) {
        parent = wrapper;
        [parent method_callback:0];
    }
    
    void block_with_no_params(dispatch_block_t block)
    {
        // required to copy the block to the heap, otherwise it's on the stack
        simple_block = [block copy];

    }
    
    void setup_block_with_record_mesg_param(block_with_record_mesg_param block)
    {
        // required to copy the block to the heap, otherwise it's on the stack
        record_mesg_block = [block copy];
        //block(5);
    }
    
    void setup_block_with_event_mesg_param(block_with_event_mesg_param block)
    {
        // required to copy the block to the heap, otherwise it's on the stack
        event_mesg_block = [block copy];
    }
    
    void setup_block_with_fileid_mesg_param(block_with_fileid_mesg_parm block)
    {
        
        fileid_mesg_block = [block copy];
    }
    
    void setup_block_with_software_mesg_param(block_with_software_mesg_param block)
    {
        software_mesg_block = [block copy];
    }
    
    void setup_block_with_session_mesg_param(block_with_session_mesg_param block)
    {
        session_mesg_block = [block copy];
    }
    
    void OnMesg(fit::SessionMesg& mesg)
    {
        FIT_UINT8 result;
        if(session_mesg_block != nil) {
            result = session_mesg_block(mesg);
            NSLog(@"RESULT=%d", result);
        }
    }
    
    void OnMesg(fit::RecordMesg& mesg)
    {
        FIT_FLOAT64 _big = pow(2,31);

        //[self fitTimestampToNSDate:mesg.GetTimeCreated()];
        
        FIT_FLOAT64 _lat_sc = mesg.GetPositionLat();
        FIT_FLOAT64 _lon_sc = mesg.GetPositionLong();
        FIT_FLOAT64 _lat_deg = (_lat_sc * 180) / _big;
        FIT_FLOAT64 _lon_deg = _lon_sc * 180 / _big;
        NSLog(@"Lat=%f", _lat_deg);
        NSLog(@"Lon=%f", _lon_deg);
        
        /**
         *   Three ways of getting data back to the human world
         *
         */
        
        // Option 1: using method callback
        if(parent != nil) {
            [parent method_callback:_lat_deg];
        }
        
        // Option 2: using block with params and return value
        FIT_UINT8 result;
        if(record_mesg_block != nil) {
            result = record_mesg_block(mesg);
            NSLog(@"RESULT=%d", result);
        }
        
        // Option 3: using a simple block
        if(simple_block != nil) {
            simple_block();
        }
        
    
    }
    
    
    void OnMesg(fit::FileIdMesg& mesg)
    {
        NSLog(@"Type: %d", mesg.GetType());
        NSLog(@"Manufacturer: %d", mesg.GetManufacturer());
        NSLog(@"Product: %d", mesg.GetProduct());
        NSLog(@"SerialNumber: %d", mesg.GetSerialNumber());
        
        FIT_UINT8 result;
        if(fileid_mesg_block != nil) {
            result = fileid_mesg_block(mesg);
            NSLog(@"RESULT=%d", result);
        }
        
        
    }
    
    void OnMesg(fit::EventMesg& mesg)
    {
//        NSLog(@"Type: %d", mesg.GetEventType());
//        NSLog(@"Timestamp: %d", mesg.GetTimestamp());
//        NSLog(@"Name: %s", mesg.GetName().c_str());
//        NSLog(@"Battery Value: %f", mesg.GetBatteryLevel());
//        for (FIT_UINT16 i = 0; i < (FIT_UINT16)mesg.GetNumFields(); i++)
//        {
//            fit::Field* field = mesg.GetFieldByIndex(i);
//            NSLog(@"   Field %d (%s) has %d value(s) and units %s", i, field->GetName().c_str(), field->GetNumValues(), field->GetUnits().c_str());
//            PrintValues(*field);
//        }
        
        // Option 2: using block with params and return value
        FIT_UINT8 result;
        if(event_mesg_block != nil) {
            result = event_mesg_block(mesg);
            NSLog(@"RESULT=%d", result);
        }

        
    }

    void PrintValues(const fit::FieldBase& field)
    {
        for (FIT_UINT8 j=0; j< (FIT_UINT8)field.GetNumValues(); j++)
        {
            switch (field.GetType())
            {
                    // Get float 64 values for numeric types to receive values that have
                    // their scale and offset properly applied.
                case FIT_BASE_TYPE_ENUM:
                case FIT_BASE_TYPE_BYTE:
                case FIT_BASE_TYPE_SINT8:
                case FIT_BASE_TYPE_UINT8:
                case FIT_BASE_TYPE_SINT16:
                case FIT_BASE_TYPE_UINT16:
                case FIT_BASE_TYPE_SINT32:
                case FIT_BASE_TYPE_UINT32:
                case FIT_BASE_TYPE_SINT64:
                case FIT_BASE_TYPE_UINT64:
                case FIT_BASE_TYPE_UINT8Z:
                case FIT_BASE_TYPE_UINT16Z:
                case FIT_BASE_TYPE_UINT32Z:
                case FIT_BASE_TYPE_UINT64Z:
                case FIT_BASE_TYPE_FLOAT32:
                case FIT_BASE_TYPE_FLOAT64:
                    NSLog(@"%f", field.GetFLOAT64Value(j));
                    break;
//                case FIT_BASE_TYPE_STRING:
//                    NSLog(@"%@", [Example stringForWString:field.GetSTRINGValue(j)]);
//                    break;
                default:
                    break;
            }
        }
    }

    void OnMesg(fit::Mesg& mesg)
    {
        NSLog(@"New Mesg: %s. It has %d field(s) and %d developer field(s).", mesg.GetName().c_str(), mesg.GetNumFields(), mesg.GetNumDevFields());

        for (FIT_UINT16 i = 0; i < (FIT_UINT16)mesg.GetNumFields(); i++)
        {
            fit::Field* field = mesg.GetFieldByIndex(i);
            NSLog(@"   Field %d (%s) has %d value(s) and units %s", i, field->GetName().c_str(), field->GetNumValues(), field->GetUnits().c_str());
            PrintValues(*field);
        }

        for (auto devField : mesg.GetDeveloperFields())
        {
            NSLog(@"Developer Field(%s) has %d value(s)", devField.GetName().c_str(), devField.GetNumValues());
            PrintValues(devField);
        }
    }
};


@implementation WrapperForSwift

SwiftThatUsesWrapperForSwift *supervisor;

FIT_FLOAT64 SEMICIRCLES_PER_DEGREE;

- (void)setSupervisor:(SwiftThatUsesWrapperForSwift *)_supervisor {
    supervisor = _supervisor;
}

- (id)init:(SwiftThatUsesWrapperForSwift *)_supervisor
{
    self = [super init];
    self.supervisor = _supervisor;
    SEMICIRCLES_PER_DEGREE = pow(2,31)/180;
    
    return self;
}



- (FILE *)openFile:(NSString *)fileName withParams:(const char *)params
{
//    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [docsPath stringByAppendingPathComponent:fileName];
//    return fopen([filePath UTF8String], params);
    return fopen([fileName UTF8String], params);
}
/**
    Option 1 — A simple method callback
 */
- (void)method_callback:(Float64)val
{
    NSLog(@"Method Callback: %f", val);
}


- (UInt8)encode
{
    FILE *file;
    FitEncode *fe = [[FitEncode alloc] initWithVersion:fit::ProtocolVersion::V10];
    
    file = [self openFile:@"/Users/julian/Desktop/I-Made-A-Settings-File.fit" withParams:"wb+"];
    
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
    
    [fe Open:file];
    [fe WriteMesg:fileId];
    [fe WriteMesg:userProfile];
    
    if(![fe Close])
    {
        NSLog(@"Error closing file");
        return -1;
    }
    
    fclose(file);
    file = NULL;
    return 0;
    
}


- (NSData *)decode:(NSString *)fileName {
   
    NSData *result = [[NSData alloc]init];
    @try {
        FILE *file;
        FitDecode *fd = [[FitDecode alloc]init];

        file = [self openFile:fileName withParams:"rb"];
        
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:fileName];
        result = [fh readDataToEndOfFile];
        
        
        
        
        if ([fd IsFit:file]) {
            NSLog(@"Fit File");
        }
        if( file == NULL)
        {
            NSLog(@"Error opening file"/*, super.fileName*/);
            return result;
        }
        
        //        [fd Read:file withListener:<#(fit::MesgListener *)#> andDefListener:<#(fit::MesgDefinitionListener *)#>]
        //
        ActivityListener listener;
        listener.setParent(self);
        
        fit::MesgBroadcaster mesgBroadcaster = fit::MesgBroadcaster();
        //mesgBroadcaster.AddListener((fit::ActivityMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::FileIdMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::MesgListener &)listener);
        mesgBroadcaster.AddListener((fit::EventMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::RecordMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::SoftwareMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::SessionMesgListener &)listener);
        
        // CALLBACK
        listener.block_with_no_params(^{
            NSLog(@"Callback with no parameters, no return value");
        });
        
        
        // CALLBACK WITH PARAMETER
        listener.setup_block_with_record_mesg_param(^FIT_UINT8(fit::RecordMesg mesg) {
            //
            FIT_FLOAT64 _lat_sc = mesg.GetPositionLat();
            FIT_FLOAT64 _lon_sc = mesg.GetPositionLong();
            FIT_FLOAT64 _lat_deg = (_lat_sc) / SEMICIRCLES_PER_DEGREE;
            FIT_FLOAT64 _lon_deg = _lon_sc / SEMICIRCLES_PER_DEGREE;
            NSLog(@"Timestamp (UTC)=%@", [self fitTimestampToUTCNSDate:mesg.GetTimestamp()]);
            NSLog(@"Lat=%f", _lat_deg);
            NSLog(@"Lon=%f", _lon_deg);
            NSLog(@"Speed=%f", mesg.GetSpeed());
            
            
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self dateToNSString:[self fitTimestampToUTCNSDate:mesg.GetTimestamp()]],@"timestamp",
                               [NSNumber numberWithDouble:mesg.GetSpeed()], @"speed",
                               [NSNumber numberWithDouble:_lat_deg], @"position_lat",
                               [NSNumber numberWithDouble:_lon_deg], @"position_lon",
                               [NSNumber numberWithDouble:mesg.GetTemperature()], @"temperature",
                               [NSNumber numberWithDouble:mesg.GetGpsAccuracy()], @"gps_accuracy",
                               [NSNumber numberWithDouble:mesg.GetEnhancedAltitude()], @"enhanced_altitude",
                               [NSNumber numberWithDouble:mesg.GetEnhancedSpeed()], @"enhanced_speed",
                               [NSNumber numberWithDouble:mesg.GetAltitude()], @"altitude",
                               [NSNumber numberWithDouble:mesg.GetDistance()], @"distance",
                               nil];
                               
            //NSDate *date = [self fitTimestampToUTCNSDate:mesg.GetTimestamp()];
            UInt8 result = 0;
            
            if(supervisor) {
            result = [supervisor callbackWithRecordMesg:d];
            }
            
            return result;
        });
        
        // CALLBACK WITH PARAMETER
        listener.setup_block_with_event_mesg_param(^FIT_UINT8(fit::EventMesg mesg) {
            //
            NSLog(@"Type: %d", mesg.GetEventType());
            NSLog(@"Timestamp (UTC)=%@", [self fitTimestampToUTCNSDate:mesg.GetTimestamp()]);
            NSLog(@"Name: %s", mesg.GetName().c_str());
            NSLog(@"Battery Value: %f", mesg.GetBatteryLevel());
            //NSDate *x = [self fitTimestampToUTCNSDate:mesg.GetTimestamp()];
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:mesg.GetEventType()], @"event_type",
            [NSNumber numberWithDouble:mesg.GetTimestamp()], @"timestamp_n",
                              // x, @"date",
                               [self dateToNSString:[self fitTimestampToUTCNSDate:mesg.GetTimestamp()]],@"timestamp",
                               //mesg.GetName().c_str(), @"name",
                               [NSNumber numberWithDouble:mesg.GetBatteryLevel()], @"battery_level"
                               , nil];
            
            if(supervisor) {
                [supervisor callbackWithEventMesg:d];
            }
            
            return 0;
        });
        
        
        listener.setup_block_with_fileid_mesg_param(^FIT_UINT8(fit::FileIdMesg mesg) {
            //[self fitTimestampToNSDate:mesg.GetTimeCreated()];
            NSLog(@"Time Created: %d", mesg.GetTimeCreated());
            NSLog(@"Manufacturer: %d", mesg.GetManufacturer());
            //mesg.GetProductName().c_str();
            
            return 0;
        });
        
        listener.setup_block_with_software_mesg_param(^FIT_UINT8(fit::SoftwareMesg mesg) {
            mesg.GetVersion();
            mesg.GetPartNumber();
            
            return 0;
        });
        
        listener.setup_block_with_session_mesg_param(^FIT_UINT8(fit::SessionMesg mesg) {
            //
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self dateToNSString:[self fitTimestampToUTCNSDate:mesg.GetTimestamp()]], @"timestamp",
                               [self dateToNSString:[self fitTimestampToUTCNSDate:mesg.GetStartTime()]], @"start_time",
                               [NSNumber numberWithDouble:mesg.GetStartTime()], @"start_time_n",
                               [NSNumber numberWithDouble:mesg.GetTotalElapsedTime()], @"total_elapsed_time",
                               [NSNumber numberWithDouble:mesg.GetTotalTimerTime()], @"total_timer_time",
                               [NSNumber numberWithDouble:mesg.GetTotalDistance()], @"total_distance",
                               [NSNumber numberWithDouble:mesg.GetMaxSpeed()], @"max_speed",
                               [NSNumber numberWithDouble:mesg.GetTotalAscent()], @"total_ascent",
                               //mesg.GetSport(), @"sport",
                               [NSNumber numberWithDouble:mesg.GetEnhancedMaxSpeed()], @"enhanced_max_speed",
                               nil];
            
            if(supervisor) {
            [supervisor callbackWithSessionMesg:d];
            }
            return 0;
        });
        
        
        if([fd IsFit:file] &&[fd CheckIntegrity:file]) {
            
            [fd Read:file withListener:&mesgBroadcaster andDefListener:NULL];
            fclose(file);
            file = NULL;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
    @finally {
        //return -1;
        return result;
    }

    
    
    return result;
}

/**
- (NSDate *)dateToLocal:(NSDate *)date
{
//    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//    NSDate *dateInLocalTimezone = [date dateByAddingTimeInterval:timeZoneSeconds];
//    
//    
//    
    
    
    NSCalendar *anotherCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    
    
    anotherCalendar.timeZone = [NSTimeZone localTimeZone];
    
    NSDateComponents *anotherComponents = [anotherCalendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond) fromDate:date];
    [anotherComponents setCalendar:anotherCalendar];

    return [anotherComponents date];
    
    
    
    
    
    
    
    //return dateInLocalTimezone;
}
 **/

- (NSString *)dateToNSString:(NSDate *) date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMyyyy'_'HHmmss Z"];
    NSString *stringDate = [dateFormatter stringFromDate:date];
    //NSLog(@"%@", stringDate);
    return stringDate;
}

- (NSDate *)fitTimestampToUTCNSDate:(FIT_DATE_TIME) timestamp
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
     NSCalendar *foo = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [comps setCalendar:foo];
    [comps setTimeZone:[[NSTimeZone alloc]initWithName:@"GMT"]];
    [comps setYear:1989];
    [comps setMonth:12];
    [comps setDay:31];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    //NSDate *FIT_REF_DATE = [comps date];
    NSDate *fit_ref_date = [[comps date]copy];
    
    NSDate *result = [NSDate dateWithTimeInterval:timestamp sinceDate:fit_ref_date];
    return result;
}


@end
