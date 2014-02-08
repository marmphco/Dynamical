//
//  DYPlotViewController.m
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotWindowController.h"

enum LorenzParameter {
    LORENZ_SIGMA,
    LORENZ_RHO,
    LORENZ_BETA
};

enum RosslerParameter {
    ROSSLER_A,
    ROSSLER_B,
    ROSSLER_C
};

Vector3 lorenz(ParameterList &p, Vector3 x, double t);
Vector3 rossler(ParameterList &p, Vector3 x, double t);

// test integrables in here for now
Vector3 lorenz(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double rho = p[LORENZ_RHO].value();
    double sigma = p[LORENZ_SIGMA].value();
    double beta = p[LORENZ_BETA].value();
    
    return Vector3(
                   sigma*(x.y-x.x),
                   x.x*(rho-x.z)-x.y,
                   x.x*x.y-beta*x.z
                   );
}

Vector3 rossler(ParameterList &p, Vector3 x, double) {
    assert(p.size() == 3);
    
    double a = p[ROSSLER_A].value();
    double b = p[ROSSLER_B].value();
    double c = p[ROSSLER_C].value();
    
    return Vector3(
                   -x.y-x.z,
                   x.x+a*x.y,
                   b+x.z*(x.x-c)
                   );
}

@implementation DYPlotWindowController


- (void)windowDidLoad
{
    self.plotViewController = [[DYPlotViewController alloc] initWithView:self.openGLView];
    self.plotViewController.nextResponder = self.openGLView.nextResponder;
    self.openGLView.nextResponder = self.plotViewController;
    
    EulerIntegrator *integrator = new EulerIntegrator(0.01);
    
    lorenzSystem = new DynamicalSystem(lorenz, integrator, 3);
    
    Parameter &sigma = lorenzSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = lorenzSystem->parameter(LORENZ_RHO);
    Parameter &beta = lorenzSystem->parameter(LORENZ_BETA);
    
    sigma.name = "sigma";
    rho.name = "rho";
    beta.name = "beta";
    sigma.setValue(10.0);
    rho.setValue(28.0);
    beta.setValue(8.0/3.0);
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.016 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)timerFired:(NSTimer *)timer
{
    //[self.plotViewController redraw];
}

- (IBAction)changeParameter:(id)sender
{
    lorenzSystem->parameter(LORENZ_SIGMA).setValue([self.paramSliderSigma doubleValue]);
    lorenzSystem->parameter(LORENZ_RHO).setValue([self.paramSliderRho doubleValue]);
    lorenzSystem->parameter(LORENZ_BETA).setValue([self.paramSliderBeta doubleValue]);
    GLfloat vertices[384000];
    GLuint indices[64000];
    int idx = 0;
    for (double z = -2; z < 2; z++) {
        for (double y = -2; y < 2; y++) {
            for (double x = -2; x < 2; x++) {
                Vector3 p(x, y, z);
                double t = 0.0;
                for (int i = 0; i < 1000; i++) {
                    Vector3 op = p;
                    p = lorenzSystem->evaluate(p, t);
                    
                    vertices[idx*6] = (GLfloat)p.x;
                    vertices[idx*6+1] = (GLfloat)p.y;
                    vertices[idx*6+2] = (GLfloat)p.z;
                    
                    vertices[idx*6+3] = 1.0;//(GLfloat)p.x-op.x;
                    vertices[idx*6+4] = 1.0;//(GLfloat)p.y-op.y;
                    vertices[idx*6+5] = 1.0;//(GLfloat)p.z-op.z;
                    
                    indices[idx] = idx;
                    idx++;
                    t += 0.01;
                }
            }
        }
    }
    [self.plotViewController replacePathWithVertices:vertices indices:indices];
    [self.plotViewController redraw];
}

- (IBAction)changeZoom:(id)sender
{
    //scene->camera.zoom = [self.zoomSlider floatValue];
    //float zoom = [self.zoomSlider floatValue]*0.1;
    //model->scale = Vector3(zoom, zoom, zoom);
}

@end
