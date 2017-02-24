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
#include "fit_file_id_mesg_listener.hpp"
#include "fit_record_mesg_listener.hpp"
#include "fit_mesg_broadcaster.hpp"

//@interface WrapperForSwift ()
//
//@end


class ActivityListener : fit::FileIdMesgListener, fit::MesgListener
{
public:
    void OnMesg(fit::FileIdMesg& mesg)
    {
        NSLog(@"Type: %d", mesg.GetType());
        NSLog(@"Manufacturer: %d", mesg.GetManufacturer());
        NSLog(@"Product: %d", mesg.GetProduct());
        NSLog(@"SerialNumber: %d", mesg.GetSerialNumber());
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
            NSLog(@"   Field %d (%s) has %d value(s)", i, field->GetName().c_str(), field->GetNumValues());
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

//- (id)init
//{
//    self = [super init];
//    if(self)
//    {
//        super.fileName = @"ActivityFile.fit";
//    }
//    return self;
//}

//- (UInt8)encode
//{
//    //std::list<fit::RecordMesg> records;
//    FILE *file;
//    super.fe = [[FitEncode alloc] initWithVersion:fit::ProtocolVersion::V10];
//    
//    if( ( file = [self openFileWithParams:[super writeOnlyParam]] ) == NULL)
//    {
//        NSLog(@"Error opening file %@", super.fileName);
//        return -1;
//    }
//    
//    fit::FileIdMesg fileId; // Every FIT file requires a File ID message
//    fileId.SetType(FIT_FILE_ACTIVITY);
//    fileId.SetManufacturer(FIT_MANUFACTURER_DYNASTREAM);
//    fileId.SetProduct(1231);
//    fileId.SetSerialNumber(12345);
//    
//    fit::DeveloperDataIdMesg devId;
//    for (FIT_UINT8 i = 0; i < 16; i++)
//    {
//        devId.SetApplicationId(i, i);
//    }
//    devId.SetDeveloperDataIndex(0);
//    
//    fit::FieldDescriptionMesg fieldDesc;
//    fieldDesc.SetDeveloperDataIndex(0);
//    fieldDesc.SetFieldDefinitionNumber(0);
//    fieldDesc.SetFitBaseTypeId(FIT_BASE_TYPE_SINT8);
//    fieldDesc.SetFieldName(0, L"doughnuts_earned");
//    fieldDesc.SetUnits(0, L"doughnuts");
//    
//    for (FIT_UINT8 i = 0; i < 3; i++)
//    {
//        fit::RecordMesg newRecord;
//        fit::DeveloperField doughnutsEarnedField(fieldDesc, devId);
//        newRecord.SetHeartRate(140 + (i * 2));
//        newRecord.SetCadence(88 + (i * 2));
//        newRecord.SetDistance(510 + (i * 100.0f));
//        newRecord.SetSpeed(2.8f + (i * 0.4f));
//        doughnutsEarnedField.AddValue(i + 1);
//        
//        newRecord.AddDeveloperField(doughnutsEarnedField);
//        /////////////// from std::list
//        ///////////records.push_back(newRecord);
//    }
//    
//    [super.fe Open:file];
//    [super.fe WriteMesg:fileId];
//    [super.fe WriteMesg:devId];
//    [super.fe WriteMesg:fieldDesc];
//    // from std::list
////    for (auto record : records)
////    {
////        [super.fe WriteMesg:record];
////    }
//    
//    if (![super.fe Close])
//    {
//        NSLog(@"Error closing file %@", super.fileName);
//        return -1;
//    }
//    fclose(file);
//    file = NULL;
//    
//    return 0;
//}

- (FILE *)openFile:(NSString *)fileName withParams:(const char *)params
{
//    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [docsPath stringByAppendingPathComponent:fileName];
//    return fopen([filePath UTF8String], params);
    return fopen([fileName UTF8String], params);
}



- (UInt8)decode
{
    @try {
        FILE *file;
        //super.fd = [[FitDecode alloc] init];
        FitDecode *fd = [[FitDecode alloc]init];
        
        file = [self openFile:@"/Users/julian/Desktop/170204164534.fit" withParams:"rb"];
        
//        if ([fd IsFit:file]) {
//            
//        }
//        
//        
//        //[fd IsFit:file];
        
        if( file == NULL)
        {
            NSLog(@"Error opening file"/*, super.fileName*/);
            return -1;
        }
        
//        [fd Read:file withListener:<#(fit::MesgListener *)#> andDefListener:<#(fit::MesgDefinitionListener *)#>]
//        
        ActivityListener listener;
        fit::MesgBroadcaster mesgBroadcaster = fit::MesgBroadcaster();
        mesgBroadcaster.AddListener((fit::FileIdMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::MesgListener &)listener);
        [fd IsFit:file];
        [fd CheckIntegrity:file];

        [fd Read:file withListener:&mesgBroadcaster andDefListener:NULL];
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
