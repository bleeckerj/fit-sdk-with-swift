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

#import "ViewController.h"

#include "fit.hpp"

#import "SettingsExample.h"
#import "MonitoringExample.h"
#import "ActivityExample.h"
#import "exampleios-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //SwiftThat
    SwiftThatUsesWrapperForSwift *wrapper = [[SwiftThatUsesWrapperForSwift alloc]init];
    [wrapper doSomething];
    
    
    SettingsExample *se = [[SettingsExample alloc] init];
    [se encode];
    [se decode];
    MonitoringExample *me = [[MonitoringExample alloc] init];
    [me encode];
    [me decode];
    ActivityExample *ae = [[ActivityExample alloc] init];
    [ae encode];
    [ae decode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
