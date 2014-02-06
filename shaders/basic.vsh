/*
 basic.vsh
*/

#version 150

in vec4 vPosition;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

void main() {
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vPosition;
}
