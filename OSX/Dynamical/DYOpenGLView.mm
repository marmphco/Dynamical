//
//  DYOpenGLView.m
//  Dynamical
//
//  Created by Matthew Jee on 3/11/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYOpenGLView.h"
#import "DYDefinitions.h"


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

- (void)dealloc
{
    delete scene;
    delete flatColorShader;
    delete pathShader;
    delete pickShader;
    delete displayShader;
    delete axes;
    delete axesMesh;
    delete displayTexture;
    delete pickTexture;
}

- (void)awakeFromNib
{
    [self setOpenGLContext:[DYOpenGLView sharedContext]];
    
    NSLog(@"Using Context: %s", glGetString(GL_VERSION));
    
    glEnable(GL_DEPTH_TEST);
    
    pathShader = new Shader();
    pickShader = new Shader();
    displayShader = new Shader();
    flatColorShader = new Shader();
    colorRampShader = new Shader();
    try {
        NSBundle *bundle = [NSBundle mainBundle];
        pathShader->compile([[bundle pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                             [[bundle pathForResource:@"shaders/path" ofType:@"fsh"] UTF8String]);
        pickShader->compile([[bundle pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                            [[bundle pathForResource:@"shaders/white_pick" ofType:@"fsh"] UTF8String]);
        displayShader->compile([[bundle pathForResource:@"shaders/display" ofType:@"vsh"] UTF8String],
                               [[bundle pathForResource:@"shaders/display" ofType:@"fsh"] UTF8String]);
        flatColorShader->compile([[bundle pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                                 [[bundle pathForResource:@"shaders/color_flat" ofType:@"fsh"] UTF8String]);
        colorRampShader->compile([[bundle pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                                 [[bundle pathForResource:@"shaders/color_ramp" ofType:@"fsh"] UTF8String]);
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
        -10.0, 0.0,  0.0, 1.0, 0.0,  0.0,
        10.0, 0.0,  0.0, 1.0, 0.0,  0.0,
        0.0, -10.0, 0.0, 0.0,  1.0,  0.0,
        0.0,  10.0, 0.0, 0.0,  1.0, 0.0,
        0.0,  0.0, -10.0, 0.0,  0.0, 1.0,
        0.0,  0.0,  10.0, 0.0,  0.0,  1.0
    };
    GLuint axesIndices[] = {0, 1, 2, 3, 4, 5};
    axesMesh = new Mesh(axesVertices, axesIndices, 12, 6, 3);
    axes = new Renderable(axesMesh, flatColorShader, GL_LINES);
    axes->setupVertexAttributes = setupVertexAttributes;
    axes->setupUniforms = setupSimpleUniforms;
    axes->init();
        
    scene = new Scene(framebuffer);
    scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 2.0, 60.0f);
    scene->camera.transform.position = Vector3(0.0, 0.0, 10.0);
    scene->add(axes);
    
    selected = NULL;
}

- (void)update
{
    [self.openGLContext setView:self];
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    float aspectRatio = width*1.0/height;
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
    
    scene->camera.perspective(-1.0f*aspectRatio, 1.0f*aspectRatio, -1.0f, 1.0f, 2.0f, 60.0f);
    
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
    //selected = NULL;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.openGLContext setView:self];
    NSPoint point = [theEvent locationInWindow];
    previousPointInView = [self convertPoint:point fromView:theEvent.window.contentView];
    int selectedID = scene->pickObjectID(previousPointInView.x, previousPointInView.y);
    if (selectedID != -1) {
        [self renderableWasDeselected:selected];
        selected = scene->getObject(selectedID);
        [self renderableWasSelected:selected];
    } else {
        [self renderableWasDeselected:selected];
        selected = NULL;
    }
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

    if (selected == NULL) {
        scene->transform.rotateGlobal(magnitude, axis.normalized());
    } else {
        [self renderable:selected draggedFromPoint:previousPointInView toPoint:pointInView];
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

- (void)renderableWasSelected:(Renderable *)renderable
{
    
}

- (void)renderableWasDeselected:(dynam::Renderable *)renderable
{
    
}

- (void)renderable:(Renderable *)renderable draggedFromPoint:(NSPoint)origin toPoint:(NSPoint)destination
{
    Matrix4 viewMatrix = scene->camera.viewMatrix()*scene->transform.matrix();
    Matrix3 viewRotation = viewMatrix.matrix3().transpose();
    
    Vector3 viewXAxis = viewRotation * X_AXIS;
    Vector3 viewYAxis = viewRotation * Y_AXIS;
    
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    float aspectRatio = width*1.0/height;
    
    //the depth of the object plane in view space
    float n = 2.0;
    float f = (viewMatrix*(renderable->transform.position+renderable->transform.center)).z;
    float worldx = (destination.x*2.0/self.frame.size.width-1.0)*f/n*aspectRatio;
    float worldy = (destination.y*2.0/self.frame.size.height-1.0)*f/n;
    float worldlastx = (origin.x*2.0/self.frame.size.width-1.0)*f/n*aspectRatio;
    float worldlasty = (origin.y*2.0/self.frame.size.height-1.0)*f/n;
    float worldxDiff = worldx-worldlastx;
    float worldyDiff = worldy-worldlasty;
    
    float scaleFactor = 1.0/(scene->transform.scale.x*scene->transform.scale.x);
    renderable->transform.position += viewXAxis*-worldxDiff*scaleFactor + viewYAxis*-worldyDiff*scaleFactor;
}


@end
