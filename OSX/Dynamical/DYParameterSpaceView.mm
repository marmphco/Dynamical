//
//  DYParameterSpaceView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYParameterSpaceView.h"

@implementation DYParameterSpaceView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    handleMesh = loadCube(1.0, 1.0, 1.0);
    
    minHandle = new ParameterHandle(handleMesh, pickShader);
    minHandle->setupVertexAttributes = setupVertexAttributes;
    minHandle->init();
    maxHandle = new ParameterHandle(handleMesh, pickShader);
    maxHandle->setupVertexAttributes = setupVertexAttributes;
    maxHandle->init();
    
    scene->add(minHandle);
    scene->add(maxHandle);
}

- (void)dealloc
{
    delete handleMesh;
    delete minHandle;
    delete maxHandle;
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    [super renderable:renderable draggedFromPoint:origin toPoint:destination];
    [self.delegate parameterSpaceViewBoundsDidChange:self];
}

- (double)minValueForAxis:(int)axis
{
    switch (axis) {
        case 0: return minHandle->transform.position.x;
        case 1: return minHandle->transform.position.y;
        case 2: return minHandle->transform.position.z;
        default: return 0;
    }
}

- (double)maxValueForAxis:(int)axis
{
    switch (axis) {
        case 0: return maxHandle->transform.position.x;
        case 1: return maxHandle->transform.position.y;
        case 2: return maxHandle->transform.position.z;
        default: return 0;
    }
}

@end
