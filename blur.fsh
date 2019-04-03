precision mediump float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform vec2 blurVector;
const float kernelSize = 9.0;
void main()
{
    vec4 texel = texture2D(inputImageTexture, textureCoordinate);
    vec4 inputTexel = texel;
    vec4 avgValue = vec4(0.0);
    float coefficientSum = 0.0;
    
    // ceter pixel
    avgValue += texel;
    coefficientSum += 1.0;
    // Go through the remaining 8 vertical samples (4 on each side of the center)
    for (float i = 1.0; i < kernelSize + 1.0; i++) {
        avgValue += texture2D(inputImageTexture, textureCoordinate - i * blurVector);
        avgValue += texture2D(inputImageTexture, textureCoordinate + i * blurVector);
        coefficientSum += 2.0;
    }
    
    texel = avgValue / coefficientSum;
    gl_FragColor = texel;
}
