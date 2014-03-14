//
//  TPAppDelegate.m
//  Dynamical
//
//  Created by Matthew Jee on 2/6/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "TPAppDelegate.h"

@implementation TPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _windowControllers = [[NSMutableArray alloc] init];
    
    DYPlotWindowController *controller;
    controller = [[DYPlotWindowController alloc] initWithIntegrable:lorenz parameters:@[@"sigma", @"rho", @"beta"]];
    [controller showWindow:self];
    [_windowControllers addObject:controller];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(plotWindowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:controller.window];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    for (NSString *name in filenames) {
        [self createPlotWindowWithURL:[NSURL fileURLWithPath:name]];
    }
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"js"]];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            for (NSURL *url in panel.URLs) {
                [self createPlotWindowWithURL:url];
                [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
            }
        }
    }];
}

- (void)createPlotWindowWithURL:(NSURL *)url
{
    DYPlotWindowController *controller;
    controller = [[DYPlotWindowController alloc] initWithContentsOfURL:url];
    [controller showWindow:self];
    [_windowControllers addObject:controller];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(plotWindowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:controller.window];
}

- (void)plotWindowWillClose:(NSNotification *)note
{
    [_windowControllers removeObjectAtIndex:[_windowControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj window] == [note object];
    }]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowWillCloseNotification
                                                  object:[note object]];
}

@end
