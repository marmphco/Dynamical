//
//  DYPlotViewControllerDelegate.h
//  Dynamical
//
//  Created by Matthew Jee on 2/22/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "../../renderer/renderable.h"

class Seed;

@protocol DYPlotViewControllerDelegate <NSObject>

- (void)objectWasPicked:(int)objectID;
- (void)seedWasMoved:(Seed *)seed;

@end
