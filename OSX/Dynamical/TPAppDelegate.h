//
//  TPAppDelegate.h
//  Dynamical
//
//  Created by Matthew Jee on 2/6/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "DYPlotWindowController.h"

@interface TPAppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableArray *_windowControllers;
}

- (IBAction)openFile:(id)sender;

- (void)createPlotWindowWithURL:(NSURL *)url;

- (void)plotWindowWillClose:(NSNotification *)notification;

@end
