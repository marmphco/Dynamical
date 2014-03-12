//
//  DYParameterSpaceViewDelegate.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DYParameterSpaceView;

@protocol DYParameterSpaceViewDelegate <NSObject>

- (void)parameterSpaceViewBoundsDidChange:(DYParameterSpaceView *)view;

@end
