//
//  DYPlotViewControllerDelegate.h
//  Dynamical
//
//  Created by Matthew Jee on 2/22/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "../../renderer/renderable.h"
#include "DYDefinitions.h"

@class DYPlotView;

@protocol DYPlotViewDelegate <NSObject>

- (void)plotView:(DYPlotView *)plotView seedWasSelected:(int)objectID;
- (void)plotView:(DYPlotView *)plotView seedWasDeselected:(int)objectID;
- (void)plotView:(DYPlotView *)plotView seedWasMoved:(Seed *)seed;

@end
