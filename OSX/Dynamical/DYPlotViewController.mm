//
//  DYPlotViewController.m
//  Dynamical
//
//  Created by Matthew Jee on 2/8/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotViewController.h"

@interface DYPlotViewController ()

@end

void setupVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    loc = object->shader->getAttribLocation("vVelocity");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
};

void setupAxesVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 0, 0);
};

Mesh *loadCube(float width, float height, float depth) {
    float vertexData[] = {
        0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, 0.0, 0.0, 1.0, 1.0, 1.0,
        width, height, 0.0, 1.0, 1.0, 1.0,
        0.0, height, 0.0, 1.0, 1.0, 1.0,
        
        0.0, 0.0, depth, 1.0, 1.0, 1.0,
        width, 0.0, depth, 1.0, 1.0, 1.0,
        width, height, depth, 1.0, 1.0, 1.0,
        0.0, height, depth, 1.0, 1.0, 1.0
    };
    GLuint indexData[] = {
        0, 3, 1,
        3, 2, 1,
        1, 2, 5,
        2, 6, 5,
        0, 7, 3,
        0, 4, 7,
        3, 7, 2,
        7, 6, 2,
        4, 5, 7,
        7, 5, 6,
        0, 1, 4,
        1, 5, 4,
    };
    return new Mesh(vertexData, indexData, 16, 36, 3);
}

@implementation DYPlotViewController

- (id)initWithView:(NSOpenGLView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
        self.plotView = (NSOpenGLView *)self.view;
        
        // setup 3.2 context
        
        CGLPixelFormatAttribute attributes[] = {
            kCGLPFAColorSize, (CGLPixelFormatAttribute)24,
            kCGLPFADepthSize, (CGLPixelFormatAttribute)16,
            kCGLPFADoubleBuffer,
            kCGLPFAOpenGLProfile, (CGLPixelFormatAttribute)kCGLOGLPVersion_3_2_Core,
            (CGLPixelFormatAttribute)0
        };
        
        CGLPixelFormatObj object;
        GLint npix;
        CGLChoosePixelFormat(attributes, &object, &npix);
        
        CGLContextObj newcontext;
        CGLCreateContext(object, NULL, &newcontext);
        
        NSOpenGLContext *newNSContext = [[NSOpenGLContext alloc] initWithCGLContextObj:newcontext];
        [NSOpenGLContext clearCurrentContext];
        [self.plotView setOpenGLContext:newNSContext];
        [newNSContext makeCurrentContext];
        
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
        
        cubeMesh = loadCube(1.0, 1.0, 1.0);
        
        scene = new Scene(framebuffer);
        scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 2.0, 60.0f);
        scene->camera.transform.position = Vector3(0.0, 0.0, 10.0);
        scene->add(axes);
    }
    return self;
}

- (void)viewDidResize
{
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
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

- (Seed *)addSeed
{
    GLfloat vertices[6] = {0, 0, 0, 0, 0, 0};
    GLuint indices[1] = {0};
    Mesh *mesh = new Mesh((GLfloat *)vertices, indices, 2, 1, 3);
    
    Renderable *path = new Renderable(mesh, basicShader, GL_LINE_STRIP);
    path->setupVertexAttributes = setupVertexAttributes;
    path->init();
    
    int pathID = scene->add(path);
    
    Seed *seed = new Seed(cubeMesh, pickShader, pathID);
    seed->setupVertexAttributes = setupVertexAttributes;
    seed->init();
    seed->transform.center = Vector3(0.0, 0.0, 0.0);
    seed->seedID = scene->add(seed);
    
    seeds.push_back(seed);
    return seed;
}

- (void)enumerateSeedsWithBlock:(void (^)(Seed *))block
{
    std::list<Seed *>::iterator i;
    for (i = seeds.begin(); i != seeds.end(); ++i) {
        block(*i);
    }
}

- (void)replacePathWithID:(int)pathID
                 vertices:(GLfloat *)vertices
                  indices:(GLuint *)indices
              vertexCount:(int)vertexCount
               indexCount:(int)indexCount
{
    Renderable *path = scene->getObject(pathID);
    path->mesh->modifyData((GLfloat *)vertices, indices, vertexCount, indexCount, 3);
}

- (void)redraw
{
    scene->render();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.plotView.frame.size.width, self.plotView.frame.size.height);
    displayShader->use();
    displayShader->setUniform1f("aspectRatio", 1.0);
    displayTexture->present(displayShader);
    [self.plotView.openGLContext flushBuffer];
}

static int selected = -1;

- (void)mouseUp:(NSEvent *)theEvent
{
    selected = -1;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [theEvent locationInWindow];
    previousPointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
    selected = scene->pickObjectID(previousPointInView.x, previousPointInView.y);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint point = [theEvent locationInWindow];
    NSPoint pointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
    float dx = pointInView.x-previousPointInView.x;
    float dy = pointInView.y-previousPointInView.y;
    Vector3 axis = Vector3(-dy, dx, 0.0);
    float magnitude = axis.length();

    if (selected == -1) {
        scene->transform.rotateGlobal(magnitude, axis.normalized());
    } else {
        Renderable *selection = scene->getObject(selected);
        Matrix4 viewMatrix = scene->camera.viewMatrix()*scene->transform.matrix();
        Matrix3 viewRotation = viewMatrix.matrix3().transpose();
        
        Vector3 viewXAxis = viewRotation * X_AXIS;
        Vector3 viewYAxis = viewRotation * Y_AXIS;
        
        //the depth of the object plane in view space
        float n = 2.0;
        float f = (viewMatrix*(selection->transform.position+selection->transform.center)).z;
        float worldx = (pointInView.x*2.0/self.view.frame.size.width-1.0)*f/n;
        float worldy = (pointInView.y*2.0/self.view.frame.size.height-1.0)*f/n;
        float worldlastx = (previousPointInView.x*2.0/self.view.frame.size.width-1.0)*f/n;
        float worldlasty = (previousPointInView.y*2.0/self.view.frame.size.height-1.0)*f/n;
        float worldxDiff = worldx-worldlastx;
        float worldyDiff = worldy-worldlasty;
        
        float scaleFactor = 1.0/(scene->transform.scale.x*scene->transform.scale.x);
        selection->transform.position += viewXAxis*-worldxDiff*scaleFactor + viewYAxis*-worldyDiff*scaleFactor;
        [self.delegate seedWasMoved:(Seed *)selection];
    }
    
    previousPointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
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
@end
