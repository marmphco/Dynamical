/*
 basic.vsh
*/

#version 120

attribute vec4 vPosition;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 inverseModelMatrix;
uniform mat4 viewMatrix;
uniform mat4 inverseViewMatrix;

void main() {
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vPosition;
}
