//
//  DYParameterTableView.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DYParameterTableView : NSView

@property (assign) IBOutlet NSSlider *slider;
@property (assign) IBOutlet NSTextField *nameField;
@property (assign) IBOutlet NSTextField *valueField;
@property (assign) IBOutlet NSTextField *minField;
@property (assign) IBOutlet NSTextField *maxField;

@end
