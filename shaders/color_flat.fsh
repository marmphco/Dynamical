#version 150

in vec3 fVelocity;
out vec4 fragColor;
out vec4 fragID;

void main() {
    fragColor = vec4(fVelocity, 1.0);
    fragID = vec4(0.0);
}
