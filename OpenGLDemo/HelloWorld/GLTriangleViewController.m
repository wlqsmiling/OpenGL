//
//  GLTriangleViewController.m
//  OpenGL
//
//  Created by wuliqun on 2020/7/20.
//  Copyright © 2020 wuliqun. All rights reserved.
//

#import "GLTriangleViewController.h"

typedef struct{
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0}},
    {{0.5f,-0.5f,0.0}},
    {{-0.5f,0.5f,0.0}}
};

@interface GLTriangleViewController()
{
    GLuint vertexBufferID;
}

@property (nonatomic, strong) GLKBaseEffect * baseEffect;

@end

@implementation GLTriangleViewController

-(void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0!=vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        //设置vertexBufferID为0避免了在对应的缓存被删除后还使用其无效的标识符。
        vertexBufferID = 0;
    }
    
    //设置视图的上下文属性为nil并设置当前的上下文为nil，以便让Cocoa Touch收回所有上下文使用的内存和其他资源
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 100, 30)];
    btn.backgroundColor = [UIColor cyanColor];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    GLKView *view = (GLKView *)self.view;
    //使用NSAssert()函数的一个运行时检查会验证self.view是否为正确的类型
    NSAssert([view isKindOfClass:[GLKView class]], @"viewcontroller’s view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//分配一个新的EAGLContext的实例，并将它初始化为OpenGL ES 2.0
    [EAGLContext setCurrentContext:view.context];//在任何其他的OpenGL ES配置或者渲染之前，应用的GLKview实例的上下文属性都要设置为当前
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    
    //red green blue alpha
    self.baseEffect.constantColor = GLKVector4Make(0.4f,0.6f,0.2f,1.0f);
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    glGenBuffers(1, &vertexBufferID);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);//为接下来的应用绑定缓存
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
