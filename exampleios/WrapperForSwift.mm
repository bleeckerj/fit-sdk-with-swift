//
//  WrapperForSwift.m
//  exampleios
//
//  Created by Julian Bleecker on 2/23/17.
//
//

#import "WrapperForSwift.h"
#import "FitDecode.h"
#include "fit_file_id_mesg.hpp"
#include "fit_record_mesg.hpp"
#include "fit_mesg_broadcaster.hpp"
#include "fit_event_mesg.hpp"
#include "math.h"
#include "fit_file_id_mesg_listener.hpp"
#include "fit_record_mesg_listener.hpp"
#include <dispatch/dispatch.h>

//@interface WrapperForSwift ()
//
//@end


class ActivityListener : fit::FileIdMesgListener, fit::MesgListener, fit::EventMesgListener, fit::RecordMesgListener
{
    WrapperForSwift* parent;
    dispatch_block_t simple_block;
    typedef FIT_UINT8 (^block_with_record_mesg_param)(fit::RecordMesg);
    typedef FIT_UINT8 (^block_with_event_mesg_param)(fit::EventMesg);
    block_with_record_mesg_param record_mesg_block;
    block_with_event_mesg_param event_mesg_block;

    
public:
    void setParent(WrapperForSwift* wrapper) {
        parent = wrapper;
        [parent method_callback:0];
    }
    
    void block_with_no_params(dispatch_block_t block)
    {
        // required to copy the block to the heap, otherwise it's on the stack
        simple_block = [block copy];
        
        // setup stuff here
        // when you want to call the callback, do as if it was a function pointer:
        // block();
        //copy();
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
    
    
    void OnMesg(fit::RecordMesg& mesg)
    {
        FIT_FLOAT64 _big = pow(2,31);

        
        NSLog(@"Timestamp: %d", mesg.GetTimestamp());
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
    }
    void OnMesg(fit::EventMesg& mesg)
    {
        NSLog(@"Type: %d", mesg.GetEventType());
        NSLog(@"Timestamp: %d", mesg.GetTimestamp());
        NSLog(@"Name: %s", mesg.GetName().c_str());
        NSLog(@"Battery Value: %f", mesg.GetBatteryLevel());
        for (FIT_UINT16 i = 0; i < (FIT_UINT16)mesg.GetNumFields(); i++)
        {
            fit::Field* field = mesg.GetFieldByIndex(i);
            NSLog(@"   Field %d (%s) has %d value(s) and units %s", i, field->GetName().c_str(), field->GetNumValues(), field->GetUnits().c_str());
            PrintValues(*field);
        }
        
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

FIT_FLOAT64 SEMICIRCLES_PER_DEGREE;

- (id)init
{
    self = [super init];
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


- (UInt8)decode
{
    @try {
        FILE *file;
        //super.fd = [[FitDecode alloc] init];
        FitDecode *fd = [[FitDecode alloc]init];

        //file = [self openFile:@"/Users/julian/Code/FitSDKRelease_20.24.01/examples/Activity.fit" withParams:"rb"];
        file = [self openFile:@"/Users/julian/Desktop/170214152444.fit" withParams:"rb"];
        
        if ([fd IsFit:file]) {
            NSLog(@"Fit File");
        }
        if( file == NULL)
        {
            NSLog(@"Error opening file"/*, super.fileName*/);
            return -1;
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
        
        listener.block_with_no_params(^{
            NSLog(@"Callback with no parameters, no return value");
        });
        
        listener.setup_block_with_record_mesg_param(^FIT_UINT8(fit::RecordMesg mesg) {
            //
            FIT_FLOAT64 _lat_sc = mesg.GetPositionLat();
            FIT_FLOAT64 _lon_sc = mesg.GetPositionLong();
            FIT_FLOAT64 _lat_deg = (_lat_sc) / SEMICIRCLES_PER_DEGREE;
            FIT_FLOAT64 _lon_deg = _lon_sc / SEMICIRCLES_PER_DEGREE;

            NSLog(@"Lat=%f", _lat_deg);
            NSLog(@"Lon=%f", _lon_deg);
            NSLog(@"Speed=%f", mesg.GetSpeed());
            return 0;
        });
        
        listener.setup_block_with_event_mesg_param(^FIT_UINT8(fit::EventMesg mesg) {
            //
            NSLog(@"Type: %d", mesg.GetEventType());
            NSLog(@"Timestamp: %d", mesg.GetTimestamp());
            NSLog(@"Name: %s", mesg.GetName().c_str());
            NSLog(@"Battery Value: %f", mesg.GetBatteryLevel());
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
        return -1;
    }
    return 0;
}

@end
