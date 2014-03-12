//
//  DYOpenGLView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYOpenGLView.h"
/*
static void setupVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    loc = object->shader->getAttribLocation("vVelocity");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
};

static void setupAxesVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 0, 0);
};

@implementation DYOpenGLView

+ (NSOpenGLContext *)sharedContext
{
    static NSOpenGLContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOpenGLPixelFormatAttribute formatAttributes[] = {
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFADepthSize, 16,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
            0
        };
        NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:formatAttributes];
        context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
        [context makeCurrentContext];
    });
    return context;
}

- (void)awakeFromNib
{
    [self setOpenGLContext:[DYPlotView sharedContext]];
    
    NSLog(@"%s", glGetString(GL_VERSION));
    
    glEnable(GL_DEPTH_TEST);
    
    // setup scene
    
    basicShader = new Shader();
    pickShader = new Shader();
    displayShader = new Shader();
    try {
        basicShader->compile([[[NSBundle mainBundle] pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                             [[[NSBundle mainBundle] pathForResource:@"shaders/basic" ofType:@"fsh"] UTF8String]);
        pickShader->compile([[[NSBundle mainBundle] pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                            [[[NSBundle mainBundle] pathForResource:@"shaders/pick" ofType:@"fsh"] UTF8String]);
        displayShader->compile([[[NSBundle mainBundle] pathForResource:@"shaders/display" ofType:@"vsh"] UTF8String],
                               [[[NSBundle mainBundle] pathForResource:@"shaders/display" ofType:@"fsh"] UTF8String]);
    } catch(exception &e) {
        cout << e.what() << endl;
    }
    
    displayTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, 480, 480);
    displayTexture->interpolation(GL_LINEAR);
    displayTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    displayTexture->initData((float *)0);
    
    pickTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, 480, 480);
    pickTexture->interpolation(GL_LINEAR);
    pickTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    pickTexture->initData((float *)0);
    
    Framebuffer *framebuffer = new Framebuffer(480, 480);
    framebuffer->addRenderTarget(displayTexture, GL_COLOR_ATTACHMENT0);
    framebuffer->addRenderTarget(pickTexture, GL_COLOR_ATTACHMENT1);
    framebuffer->addRenderTarget(GL_DEPTH_COMPONENT, GL_DEPTH_ATTACHMENT);
    
    GLenum buffers[] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1};
    glDrawBuffers(2, buffers);
    
    framebuffer->backgroundColor = Vector4(0.0, 0.0, 0.0, 0.0);
    framebuffer->clear(GL_COLOR_BUFFER_BIT);
    
    GLfloat axesVertices[] = {
        -10.0, 0.0,  0.0,
        1.0, 0.0,  0.0,
        10.0, 0.0,  0.0,
        1.0, 0.0,  0.0,
        0.0, -10.0, 0.0,
        0.0,  1.0,  0.0,
        0.0,  10.0, 0.0,
        0.0,  1.0, 0.0,
        0.0,  0.0, -10.0,
        0.0,  0.0, 1.0,
        0.0,  0.0,  10.0,
        0.0,  0.0,  1.0
    };
    GLuint axesIndices[] = {0, 1, 2, 3, 4, 5};
    axesMesh = new Mesh(axesVertices, axesIndices, 12, 6, 3);
    axes = new Renderable(axesMesh, basicShader, GL_LINES);
    axes->setupVertexAttributes = setupVertexAttributes;
    axes->init();
        
    scene = new Scene(framebuffer);
    scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 2.0, 60.0f);
    scene->camera.transform.position = Vector3(0.0, 0.0, 10.0);
    scene->add(axes);
    
    selected = -1;
}

- (void)update
{
    [self.openGLContext setView:self];
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    // recreate framebuffer
    displayTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, width, height);
    displayTexture->interpolation(GL_LINEAR);
    displayTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    displayTexture->initData((float *)0);
    
    pickTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, width, height);
    pickTexture->interpolation(GL_LINEAR);
    pickTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
    pickTexture->initData((float *)0);
    
    Framebuffer *framebuffer = new Framebuffer(width, height);
    framebuffer->addRenderTarget(displayTexture, GL_COLOR_ATTACHMENT0);
    framebuffer->addRenderTarget(pickTexture, GL_COLOR_ATTACHMENT1);
    framebuffer->addRenderTarget(GL_DEPTH_COMPONENT, GL_DEPTH_ATTACHMENT);
    
    GLenum buffers[] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1};
    glDrawBuffers(2, buffers);
    
    framebuffer->backgroundColor = Vector4(0.0, 0.0, 0.0, 0.0);
    framebuffer->clear(GL_COLOR_BUFFER_BIT);
    
    delete scene->framebuffer;
    scene->framebuffer = framebuffer;
    
    [self redraw];
}

- (void)redraw
{
    [self.openGLContext setView:self];
    scene->render();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    displayShader->use();
    displayShader->setUniform1f("aspectRatio", 1.0);
    displayTexture->present(displayShader);
    [self.openGLContext flushBuffer];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    selected = -1;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.openGLContext setView:self];
    NSPoint point = [theEvent locationInWindow];
    previousPointInView = [self convertPoint:point fromView:theEvent.window.contentView];
    selected = scene->pickObjectID(previousPointInView.x, previousPointInView.y);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self.openGLContext setView:self];
    NSPoint point = [theEvent locationInWindow];
    NSPoint pointInView = [self convertPoint:point fromView:theEvent.window.contentView];
    float dx = pointInView.x-previousPointInView.x;
    float dy = pointInView.y-previousPointInView.y;
    Vector3 axis = Vector3(-dy, dx, 0.0);
    float magnitude = axis.length();

    if (selected == -1) {
        scene->transform.rotateGlobal(magnitude, axis.normalized());
    } else {
        // something for subclass to deal with
    }
    
    previousPointInView = [self convertPoint:point fromView:theEvent.window.contentView];
    [self redraw];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    scene->transform.scaleUniform(1.0+[theEvent deltaY]*0.01);
    [self redraw];
}

- (void)setZoom:(float)zoom
{
    scene->transform.scale = Vector3(zoom, zoom, zoom);
}


@end*/
