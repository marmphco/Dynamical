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

Mesh *loadWireCube(float width, float height, float depth) {
    float vertexData[] = {
        0.0, 0.0, 0.0,
        width, 0.0, 0.0,
        width, height, 0.0,
        0.0, height, 0.0,
        
        0.0, 0.0, depth,
        width, 0.0, depth,
        width, height, depth,
        0.0, height, depth,
    };
    GLuint indexData[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        1, 5, 2, 6, 3, 7, 0, 4,
    };
    return new Mesh(vertexData, indexData, 8, 24, 3);
}

void setupVertexAttributes(Renderable *object) {
    GLint loc = object->shader->getAttribLocation("vPosition");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), 0);
    loc = object->shader->getAttribLocation("vVelocity");
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(GLfloat), (GLvoid *)(3*sizeof(GLfloat)));
};

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
        
        Shader *shader = new Shader();
        displayShader = new Shader();
        try {
            shader->compile([[[NSBundle mainBundle] pathForResource:@"shaders/basic" ofType:@"vsh"] UTF8String],
                            [[[NSBundle mainBundle] pathForResource:@"shaders/basic" ofType:@"fsh"] UTF8String]);
            displayShader->compile([[[NSBundle mainBundle] pathForResource:@"shaders/display" ofType:@"vsh"] UTF8String],
                                   [[[NSBundle mainBundle] pathForResource:@"shaders/display" ofType:@"fsh"] UTF8String]);
        } catch(exception &e) {
            cout << e.what() << endl;
        }
        
        displayTexture = new Texture2D(GL_RGBA, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, 480, 480);
        displayTexture->interpolation(GL_LINEAR);
        displayTexture->borderColor(Vector4(1.0, 1.0, 0.0, 1.0));
        displayTexture->initData((float *)0);
        
        Framebuffer *framebuffer = new Framebuffer(480, 480);
        framebuffer->addRenderTarget(displayTexture, GL_COLOR_ATTACHMENT0);
        framebuffer->addRenderTarget(GL_DEPTH_COMPONENT, GL_DEPTH_ATTACHMENT);
        framebuffer->backgroundColor = Vector4(0.0, 0.0, 0.0, 0.0);
        framebuffer->clear(GL_COLOR_BUFFER_BIT);
        
        GLfloat vertices[384000];
        GLuint indices[64000];
        mesh = new Mesh((GLfloat *)vertices, indices, 128000, 64000, 3);
        
        model = new Renderable(mesh, shader, GL_LINE_STRIP);
        model->setupVertexAttributes = setupVertexAttributes;
        model->scale = Vector3(0.1, 0.1, 0.1);
        model->center = Vector3(00, 20, 20);
        model->init();
        
        scene = new Scene(framebuffer);
        scene->camera.perspective(-1.0f, 1.0f, -1.0f, 1.0f, 2.0, 30.0f);
        scene->camera.position = Vector3(0.0, 0.0, 10.0);
        scene->add(model);
        
        int width = self.plotView.frame.size.width;
        int height = self.plotView.frame.size.height;
        GLint loc = displayShader->getUniformLocation("aspectRatio");
        displayShader->use();
        glUniform1f(loc, 1.0*width/height);
    }
    return self;
}

- (void)replacePathWithVertices:(GLfloat *)vertices indices:(GLuint *)indices
{
    mesh->modifyData((GLfloat *)vertices, indices, 128000, 64000, 3);
}

- (void)redraw
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    scene->render();
    
    glViewport(0, 0, self.plotView.frame.size.width, self.plotView.frame.size.height);
    displayShader->setUniform1f("aspectRatio", 1.0*self.plotView.frame.size.width/self.plotView.frame.size.height);
    displayTexture->present(displayShader);
    [self.plotView.openGLContext flushBuffer];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [theEvent locationInWindow];
    previousPointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint point = [theEvent locationInWindow];
    NSPoint pointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
    float dx = pointInView.x-previousPointInView.x;
    float dy = pointInView.y-previousPointInView.y;
    Vector3 axis = Vector3(-dy, dx, 0.0);
    float magnitude = axis.length();
    model->rotateGlobal(magnitude, axis.normalized());
    previousPointInView = [self.view convertPoint:point fromView:theEvent.window.contentView];
    [self redraw];
}
@end
