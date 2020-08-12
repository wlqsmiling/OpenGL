//
//  GLUseShaderTriangleViewController.h
//  OpenGL
//
//  Created by wuliqun on 2020/7/23.
//  Copyright © 2020 wuliqun. All rights reserved.
//

#import "GLUseTextureViewController.h"

@interface GLUseTextureViewController (){
    
    GLuint program;
}

@property (assign, nonatomic) GLfloat changeValue;

@property (strong, nonatomic) EAGLContext *glContext;

@end

@implementation GLUseTextureViewController

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
    static GLfloat attrArr[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    

    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(program, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    //加载纹理
    [self setupTexture:@"4.jpg"];
    
    //获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    GLuint rotate = glGetUniformLocation(program, "rotateMatrix");
    
    float radians = 10 * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = { //
        c, -s, 0, 0.2, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };
    
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)compileShaders {
    
    // 生成一个顶点着色器对象
    GLuint vertexShader = [self compileShader:@"TextureV" withType:GL_VERTEX_SHADER];
    
    // 生成一个片段着色器对象
    GLuint fragmentShader = [self compileShader:@"TextureF" withType:GL_FRAGMENT_SHADER];
    
    
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

- (GLuint)setupTexture:(NSString *)fileName {
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
