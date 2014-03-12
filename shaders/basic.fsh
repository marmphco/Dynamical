
#version 150

in vec3 fVelocity;

out vec4 fragColor;

void main() {
    float m = length(fVelocity)/10.0;
    
    vec4 none = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 r = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 g = vec4(0.0, 1.0, 0.0, 1.0);
    vec4 b = vec4(0.0, 0.0, 1.0, 1.0);
    
    fragColor = mix(none, r, (m-0.33)*3.0)+mix(g, none, (abs(0.5-m)*2.0-0.33)*3.0)+mix(b, none, (m-0.33)*3.0);
}
