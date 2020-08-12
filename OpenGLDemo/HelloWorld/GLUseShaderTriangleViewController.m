//
//  GLUseShaderTriangleViewController.h
//  OpenGL
//
//  Created by wuliqun on 2020/7/23.
//  Copyright © 2020 wuliqun. All rights reserved.
//

#import "GLUseShaderTriangleViewController.h"

@interface GLUseShaderTriangleViewController (){
    
    GLuint program;
}

@property (assign, nonatomic) GLfloat changeValue;

@property (strong, nonatomic) EAGLContext *glContext;

@end

@implementation GLUseShaderTriangleViewController

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
    
    [self setupGLContext];
    
    [self compileShaders];
    
}

- (void)setupGLContext {
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    self.preferredFramesPerSecond = 60;
    if (!self.glContext) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.glContext;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:self.glContext];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清空之前的绘制
    glClearColor(1.0, 1.0, 1.0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(program);
    
    [self drawGraphics];
    
    [self update];
}

- (void)update {
    NSTimeInterval time = self.timeSinceLastUpdate;
    self.changeValue += time;
}

- (void)drawGraphics {
    static GLfloat triangleData[18] = {
        
        // 位置           // 颜色
        0.0,   0.5f,  0,  1,  0,  0,
       -0.5f, -0.5f,  0,  0,  1,  0,
        0.5f, -0.5f,  0,  0,  0,  1,
    };
    

    GLuint positionLoca = glGetAttribLocation(program, "position");

    /* 默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的，意味着数据在着色器端是不可见的，哪怕数据已经上传到GPU，由glEnableVertexAttribArray启用指定属性，才可在顶点着色器中访问逐顶点的属性数据
     */
    glEnableVertexAttribArray(positionLoca);
    
    GLuint colorLoca = glGetAttribLocation(program, "color");
    glEnableVertexAttribArray(colorLoca);
    
    GLuint variableLoca = glGetUniformLocation(program, "variable");
    glUniform1f(variableLoca, (GLfloat)self.changeValue);
    
   /* glVertexAttribPointer或VBO只是建立CPU和GPU之间的逻辑连接，从而实现了CPU数据上传至GPU。但是，数据在GPU端是否可见，即，着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据
    */
    
    glVertexAttribPointer(positionLoca, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)triangleData);
    glVertexAttribPointer(colorLoca, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (char *)triangleData + 3 * sizeof(GLfloat));
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)compileShaders {
    
    // 生成一个顶点着色器对象
    GLuint vertexShader = [self compileShader:@"VertexShader" withType:GL_VERTEX_SHADER];
    
    // 生成一个片段着色器对象
    GLuint fragmentShader = [self compileShader:@"fragmentShader" withType:GL_FRAGMENT_SHADER];
    
    
    /*
     调用了glCreateProgram glAttachShader  glLinkProgram 连接 vertex 和 fragment shader成一个完整的program。
     着色器程序对象(Shader Program Object)是多个着色器合并之后并最终链接完成的版本。
     如果要使用刚才编译的着色器我们必须把它们链接(Link)为一个着色器程序对象，
     然后在渲染对象的时候激活这个着色器程序。已激活着色器程序的着色器将在我们发送渲染调用的时候被使用。
     */
    program = glCreateProgram();  // 创建一个程序对象
    glAttachShader(program, vertexShader); // 链接顶点着色器
    glAttachShader(program, fragmentShader); // 链接片段着色器
    glLinkProgram(program); // 链接程序
    
    // 把着色器对象链接到程序对象以后，记得删除着色器对象，我们不再需要它们了
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    // 调用 glGetProgramiv来检查是否有error，并输出信息。
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"着色器程序:%@", messageString);
        exit(1);
    }
}


- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType {
    
    // NSBundle中加载文件
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    
    // 如果为空就打印错误并退出
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 使用glCreateShader函数可以创建指定类型的着色器对象。shaderType是指定创建的着色器类型
    GLuint shader = glCreateShader(shaderType);
    
    // 这里把NSString转换成C-string
    const char* shaderStringUTF8 = [shaderString UTF8String];
    
    int shaderStringLength = (int)shaderString.length;
    
    // 使用glShaderSource将着色器源码加载到上面生成的着色器对象上
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 调用glCompileShader 在运行时编译shader
    glCompileShader(shader);
    
    // glGetShaderiv检查编译错误（然后退出）
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"生成着色器对象:%@", messageString);
        exit(1);
    }
    
    // 返回一个着色器对象
    return shader;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
