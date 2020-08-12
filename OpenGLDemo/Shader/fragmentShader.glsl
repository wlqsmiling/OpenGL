precision highp float;
varying lowp vec4 fColor;
uniform float variable;

void main(void) {
    float scale = (sin(variable) + 1.0) / 2.0;
    gl_FragColor = fColor * scale;
}


