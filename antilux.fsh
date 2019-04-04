#extension GL_EXT_shader_framebuffer_fetch : require
precision mediump float;
varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;
uniform sampler2D inputImageTexture;//source
uniform sampler2D inputImageTexture2;//blurred
uniform sampler2D cdf;//cdf
uniform float filterStrength;

vec3 rgb_to_hsv(vec3 rgb) {
    float rc = rgb.r;
    float gc = rgb.g;
    float bc = rgb.b;
    
    float h = 0.0;
    float s = 0.0;
    float v = 0.0;
    
    float max_v = max(rc, max(gc, bc));
    float min_v = min(rc, min(gc, bc));
    float delta = max_v - min_v;
    
    v = max_v;
    
    if (max_v != 0.0) {
        s = delta / max_v;
    } else {
        s = 0.0;
    }
    
    if (s == 0.0) {
        h = 0.0;
    } else {
        if (rc == max_v) {
            h = (gc - bc) / delta;
        } else if (gc == max_v) {
            h = 2.0 + (bc - rc) / delta;
        } else if (bc == max_v) {
            h = 4.0 + (rc - gc) / delta;
        }
        
        h *= 60.0;
        if (h < 0.0) {
            h += 360.0;
        }
    }
    
    return vec3(h,s,v);
    
}

vec3 hsv_to_rgb(vec3 hsv) {
    float r; float g; float b;
    
    int i = 0;
    float f; float p; float q; float t;
    if( hsv.y == 0.0 ) {
        // achromatic (grey)
        r = g = b = hsv.z;
    } else {
        hsv.x /= 60.0;            // sector 0 to 5
        i = int(floor( hsv.x ));
        f = hsv.x - float(i);            // factorial part of h
        p = hsv.z * ( 1.0 - hsv.y );
        q = hsv.z * ( 1.0 - hsv.y * f );
        t = hsv.z * ( 1.0 - hsv.y * ( 1.0 - f ) );
        
        if (i == 0) {
            r = hsv.z;
            g = t;
            b = p;
        } else if (i == 1) {
            r = q;
            g = hsv.z;
            b = p;
        } else if (i == 2) {
            r = p;
            g = hsv.z;
            b = t;
        } else if (i == 3) {
            r = p;
            g = q;
            b = hsv.z;
        } else if (i == 4) {
            r = t;
            g = p;
            b = hsv.z;
            
        } else {
            r = hsv.z;
            g = p;
            b = q;
        }
    }
    return vec3(r,g,b);
}

// see: http://en.wikipedia.org/wiki/Adaptive_histogram_equalization
// return the point when the CDF crosses 0.5, the center of mass of the histogram.
// we'll adjust contrast around this point as the center.
float histogramCenter(sampler2D cdfTexture, vec2 coord, float brightness) {
    const float xHalfPix = 0.001953125; // (1.0/256.0)/2.0;
    const float yHalfPix = .03125; // (1.0/16.0)/2.0;
    brightness = brightness + xHalfPix;
    
    // find the coordinate within the interpolation mesh
    coord = clamp(coord, 0.125, 1.0 - 0.125001) - 0.125;
    coord = coord * (3.0 / (1.0-0.125*2.0));
    vec2 weight = fract(coord);     // the fractional part are our interpolation weights
    coord = floor(coord);           // floor to get the top-right corner
    
    // compute the 4 corners of the mesh we'll be interpolating
    // tl = top-left, tr = top-right etc
    float tl = float(coord.y*4.0 + coord.x)/16.0 + yHalfPix;
    float tr = float(coord.y*4.0 + coord.x + 1.0)/16.0 + yHalfPix;
    float bl = float((coord.y + 1.0)*4.0 + coord.x)/16.0 + yHalfPix;
    float br = float((coord.y + 1.0)*4.0 + coord.x + 1.0)/16.0 + yHalfPix;
    
    // obtain the cdf center values of the 4 corners
    vec4 b1 = texture2D(cdfTexture, vec2(1.0, tl));
    vec4 b2 = texture2D(cdfTexture, vec2(1.0, tr));
    vec4 b3 = texture2D(cdfTexture, vec2(1.0, bl));
    vec4 b4 = texture2D(cdfTexture, vec2(1.0, br));
    
    // the fourth channel, "a", is the histogram midpoint
    
    // linearly interpolate to obtain the final brightness
    float c1_2 = mix(b1.a, b2.a, weight.x);
    float c3_4 = mix(b3.a, b4.a, weight.x);
    return mix(c1_2, c3_4, weight.y);
}




void main() {
    
    vec4 texel = texture2D(inputImageTexture, textureCoordinate);
    vec4 inputTexel = texel;
    vec3 hsv = rgb_to_hsv(texel.rgb);
    
    vec3 blurredTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
    float blurredLum = (blurredTexel.r + blurredTexel.g + blurredTexel.b)/3.0;
    // boost highlights and shadows
    // first with a mask over regions, don't boost a bright pixel in a shadow region or a dark pixel in a highlight region
    float shadowMask = smoothstep(0.5, 0.0, blurredLum); // mask for "shadow areas"
    float highlightMask = smoothstep(0.5, 1.0, blurredLum); // mask for "highlight areas"
    
    // then adjust the luminace curve
    float srcDarkness = smoothstep(0.0, 0.25, hsv.z) * smoothstep(0.5, 0.25, hsv.z); // lerp on how dark this pixel is
    float srcHighlightness = smoothstep(0.50, 0.85, hsv.z); // lery on how bright this pixel is
    hsv.z = hsv.z + srcDarkness * 0.14 * shadowMask;
    hsv.z = hsv.z + srcHighlightness * 0.14 * highlightMask;
    
    // adjust saturation
    hsv.y = min(hsv.y * 0.825, 1.0);
    // adjust contrast centered around the CDF
    float flatBright = histogramCenter(cdf, textureCoordinate, hsv.z);
    hsv.z = mix(hsv.z, flatBright, 0.175);
    
    vec3 newRgb = hsv_to_rgb(hsv);
    // fade in a recycled paper gray colored overlay, the max is for a "lighten" blend mode
    newRgb = mix(newRgb, max(newRgb, vec3(0.651, 0.615, 0.580)), 0.18);
    texel.rgb = mix(texel.rgb, newRgb, filterStrength);
    
    gl_FragColor = texel;
}

