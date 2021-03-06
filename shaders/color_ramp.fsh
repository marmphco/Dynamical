
#version 150

in vec3 fVelocity;

out vec4 fragColor;
out vec4 fragID;

void main() {
    float m = fVelocity.x;
    
    vec4 none = vec4(0.0, 0.0, 0.0, 1.0);
    float r = min((m-0.33)*3.0, 1.0);
    float g = min((0.5-abs(0.5-m))*3.0, 1.0);
    float b = min((0.66-m)*3.0, 1.0);
    fragColor = vec4(r, g, b, 1.0);
    fragID = vec4(0.0);
}
