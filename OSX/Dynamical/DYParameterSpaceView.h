//
//  DYParameterSpaceView.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYOpenGLView.h"
#import "DYParameterSpaceViewDelegate.h"
#import "DYDefinitions.h"

using namespace dynam;

@interface DYParameterSpaceView : DYOpenGLView
{
    Mesh *handleMesh;
    Mesh *pathMesh;
    ParameterHandle *minHandle;
    ParameterHandle *maxHandle;
}

@property (nonatomic, weak) IBOutlet id<DYParameterSpaceViewDelegate> delegate;

- (double)minValueForAxis:(int)axis; //should be enum
- (double)maxValueForAxis:(int)axis; //should be enum

@end
