//
//  DYParameterSpaceView.h
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYOpenGLView.h"
#import "DYParameterSpaceViewDelegate.h"

using namespace dynam;

class ParameterHandle : public Renderable {
public:
    ParameterHandle(Mesh *mesh, Shader *shader) :
        Renderable(mesh, shader, GL_TRIANGLES) {
        transform.center = Vector3(0.5, 0.5, 0.5);
    };
};

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
