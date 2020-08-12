attribute vec4 position;
attribute vec4 color;
uniform float variable;
varying vec4 fColor;

void main(void) {
    fColor = color;
    float xPos = position.x * cos(variable) - position.y * sin(variable);
    float yPos = position.x * sin(variable) + position.y * cos(variable);
    gl_Position = vec4(xPos, yPos, position.z, 1.0);
    
    //    fColor = color;
    //    float xPos = position.x * sin(variable);
    //    float yPos = position.y * sin(variable);
    //    gl_Position = vec4(xPos, yPos, position.z, 1.0);
}
