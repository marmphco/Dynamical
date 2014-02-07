
#version 150

in vec3 fVelocity;

out vec4 fragColor;

void main() {
    fragColor = vec4(fVelocity*0.1, 1.0);
}
