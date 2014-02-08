//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

#include "../../renderer/shader.h"
#include "../../renderer/texture.h"
#include "../../renderer/scene.h"
#include "../../renderer/mesh.h"

using namespace dynam;
using namespace std;

@interface DYPlotWindowController : NSWindowController
{
    DynamicalSystem *lorenzSystem;
    Scene *scene;
    Shader *displayShader;
    Renderable *model;
    Mesh *mesh;
    Texture2D *displayTexture;
}

@property (assign) IBOutlet NSOpenGLView *openGLView;

@property (assign) IBOutlet NSSlider *paramSliderRho;
@property (assign) IBOutlet NSSlider *paramSliderSigma;
@property (assign) IBOutlet NSSlider *paramSliderBeta;

@property (assign) IBOutlet NSSlider *zoomSlider;

- (IBAction)changeParameter:(id)sender;
- (IBAction)changeZoom:(id)sender;

@end
