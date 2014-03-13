
#version 150

in vec3 fVelocity;

out vec4 fragColor;

void main() {
    float m = length(fVelocity)/1.0;
    
    vec4 none = vec4(0.0, 0.0, 0.0, 1.0);
    /*vec4 r = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 g = vec4(0.0, 1.0, 0.0, 1.0);
    vec4 b = vec4(0.0, 0.0, 1.0, 1.0);
    
    fragColor = mix(none, r, (m-0.33)*3.0)+mix(g, none, (abs(0.5-m)*2.0-0.33)*3.0)+mix(b, none, (m-0.33)*3.0);*/
    float r = min((m-0.33)*3.0, 1.0);
    float g = min((0.5-abs(0.5-m))*3.0, 1.0);
    float b = min((0.66-m)*3.0, 1.0);
    fragColor = vec4(r, g, b, 1.0);
}
