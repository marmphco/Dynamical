/*
 basic.vsh
*/

#version 150

in vec4 vPosition;
in vec3 vVelocity;

out vec3 fVelocity;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

void main() {
    fVelocity = vVelocity;
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vPosition;
}
