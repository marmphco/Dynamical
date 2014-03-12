//
//  DYPlotViewController.m
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotWindowController.h"
#import "DYParameterTableView.h"

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

- (void)windowWillLoad
{
    EulerIntegrator *integrator = new EulerIntegrator(0.01);
    
    dynamicalSystem = new DynamicalSystem(lorenz, integrator, 3);
    
    Parameter &sigma = dynamicalSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = dynamicalSystem->parameter(LORENZ_RHO);
    Parameter &beta = dynamicalSystem->parameter(LORENZ_BETA);
    
    sigma.name = "sigma";
    rho.name = "rho";
    beta.name = "beta";
    sigma.setMinValue(-25.0);
    rho.setMinValue(-50.0);
    beta.setMinValue(-5.0);
    sigma.setMaxValue(25.0);
    rho.setMaxValue(50.0);
    beta.setMaxValue(5.0);
    sigma.setValue(10.0);
    rho.setValue(28.0);
    beta.setValue(8.0/3.0);
}

- (void)windowDidLoad
{
    NSSize aspectRatio;
    aspectRatio.width = 1038;
    aspectRatio.height = 400;
    [self.window setContentAspectRatio:aspectRatio];
    
    [self.plotView addSeed]->transform.position = Vector3(1, 1, 1);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.plotView update];
        [self.parameterView update];
    });
}

- (void)updateSeed:(Seed *)seed
{
    /*GLfloat vertices[6000];
    GLuint indices[1000];
    int idx = 0;
    Vector3 p = seed->transform.position;
    double t = 0.0;
    for (int i = 0; i < 1000; i++) {
        Vector3 op = p;
        p = dynamicalSystem->evaluate(p, t);
        
        vertices[idx*6] = (GLfloat)p.x;
        vertices[idx*6+1] = (GLfloat)p.y;
        vertices[idx*6+2] = (GLfloat)p.z;
        
        vertices[idx*6+3] = (GLfloat)p.x-op.x;
        vertices[idx*6+4] = (GLfloat)p.y-op.y;
        vertices[idx*6+5] = (GLfloat)p.z-op.z;
        
        indices[idx] = idx;
        idx++;
        t += 0.01;
    }
    [self.plotView replacePathWithID:seed->pathID
                                      vertices:vertices
                                       indices:indices
                                   vertexCount:2000
                                    indexCount:1000];*/
  /*  int count = 1000;
    int evolutions = seed->evolutionCount;
    GLfloat vertices[count*6*evolutions];
    GLuint indices[count*evolutions];
    
    Parameter &sigma = dynamicalSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = dynamicalSystem->parameter(LORENZ_RHO);
    Parameter &beta = dynamicalSystem->parameter(LORENZ_BETA);
    
    int idx = 0;
    for (int j = 0; j < evolutions; j++) {
        Vector3 p = seed->transform.position;
        
        double s = j*1.0/evolutions;
        sigma.setValue(sigma.minValue()+(sigma.maxValue()-sigma.minValue())*s);
        rho.setValue(rho.minValue()+(rho.maxValue()-rho.minValue())*s);
        beta.setValue(beta.minValue()+(beta.maxValue()-beta.minValue())*s);
        
        double t = 0.0;
        for (int i = 0; i < count; i++) {
            Vector3 op = p;
            p = dynamicalSystem->evaluate(p, t);
            
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
    [self.plotView replacePathWithID:seed->pathID
                            vertices:vertices
                             indices:indices
                         vertexCount:count*2*evolutions
                          indexCount:count*evolutions];*/
    int count = 1000;
    int evolutions = seed->evolutionCount;
    
    Parameter &sigma = dynamicalSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = dynamicalSystem->parameter(LORENZ_RHO);
    Parameter &beta = dynamicalSystem->parameter(LORENZ_BETA);
    
    for (int j = 0; j < evolutions; j++) {
        
        GLfloat vertices[count*6];
        GLuint indices[count];
        Vector3 p = seed->transform.position;
        
        double s = j*1.0/evolutions;
        sigma.setValue(sigma.minValue()+(sigma.maxValue()-sigma.minValue())*s);
        rho.setValue(rho.minValue()+(rho.maxValue()-rho.minValue())*s);
        beta.setValue(beta.minValue()+(beta.maxValue()-beta.minValue())*s);
        
        double t = 0.0;
        for (int i = 0; i < count; i++) {
            Vector3 op = p;
            p = dynamicalSystem->evaluate(p, t);
            
            vertices[i*6] = (GLfloat)p.x;
            vertices[i*6+1] = (GLfloat)p.y;
            vertices[i*6+2] = (GLfloat)p.z;
            
            vertices[i*6+3] = s;//(GLfloat)p.x-op.x;
            vertices[i*6+4] = s;//(GLfloat)p.y-op.y;
            vertices[i*6+5] = s;//(GLfloat)p.z-op.z;
            
            indices[i] = i;
            t += 0.01;
        }
        [self.plotView replacePathWithID:seed->pathIDs[j]
                                vertices:vertices
                                 indices:indices
                             vertexCount:count*2
                              indexCount:count];
    }
}

- (void)seedWasMoved:(Seed *)seed
{
    [self updateSeed:seed];
}

- (IBAction)changeParameter:(id)sender
{
    NSSlider *slider = (NSSlider *)sender;
    dynamicalSystem->parameter((int)slider.tag).setValue([slider doubleValue]);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    NSIndexSet *rowIndices = [NSIndexSet indexSetWithIndex:slider.tag];
    NSIndexSet *colIndices = [NSIndexSet indexSetWithIndex:0];
    [self.sliderTableView reloadDataForRowIndexes:rowIndices columnIndexes:colIndices];
    [self.plotView redraw];
}

- (IBAction)addSeed:(id)sender
{
    [self updateSeed:[self.plotView addSeed]];
    [self.plotView redraw];
}

- (IBAction)removeSeed:(id)sender
{
    [self.plotView removeSelectedSeed];
    [self.plotView redraw];
}

#pragma mark -
#pragma mark DYParameterSpaceViewDelegate

- (void)parameterSpaceViewBoundsDidChange:(DYParameterSpaceView *)view
{
    dynamicalSystem->parameter(0).setMinValue([view minValueForAxis:0]);
    dynamicalSystem->parameter(0).setMaxValue([view maxValueForAxis:0]);
    dynamicalSystem->parameter(1).setMinValue([view minValueForAxis:1]);
    dynamicalSystem->parameter(1).setMaxValue([view maxValueForAxis:1]);
    dynamicalSystem->parameter(2).setMinValue([view minValueForAxis:2]);
    dynamicalSystem->parameter(2).setMaxValue([view maxValueForAxis:2]);
    [self.sliderTableView reloadData];
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    [self.plotView redraw];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return dynamicalSystem->parameterCount();
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Parameter &parameter = dynamicalSystem->parameter((int)row);

    DYParameterTableView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    view.nameField.stringValue = [NSString stringWithUTF8String:parameter.name.c_str()];
    [view.valueField setFloatValue:parameter.value()];
    [view.minField setFloatValue:parameter.minValue()];
    [view.maxField setFloatValue:parameter.maxValue()];
    [view.slider setMaxValue:parameter.maxValue()];
    [view.slider setMinValue:parameter.minValue()];
    [view.slider setDoubleValue:parameter.value()];
    view.slider.tag = row;
    return view;
}

@end
