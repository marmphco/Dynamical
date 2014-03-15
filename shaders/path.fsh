
#version 150

in vec3 fVelocity;
uniform float evolution;

out vec4 fragColor;
out vec4 fragID;

void main() {
    float v = 1.0-length(fVelocity)/20.0;
    float m = evolution;
    
    vec4 none = vec4(0.0, 0.0, 0.0, 1.0);
    float r = min((m-0.33)*3.0, 1.0);
    float g = min((0.5-abs(0.5-m))*3.0, 1.0);
    float b = min((0.66-m)*3.0, 1.0);
    fragColor = vec4(r, g, b, max(0.0, min(v, 0.8))+0.2);
    fragID = vec4(0.0);
}
