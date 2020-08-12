
varying lowp vec2 varyTextCoord;

uniform sampler2D tex;


void main()
{
    gl_FragColor = texture2D(tex, varyTextCoord);
}
