#version 150

in vec3 fVelocity;

out vec4 fragColor;
out vec4 fragID;

uniform int objectID;

void main() {
    fragColor = vec4(1.0);
    fragID = vec4(objectID/255.0);
}
