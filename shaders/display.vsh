/*
    display.vsh
    Matthew Jee
    mcjee@ucsc.edu
*/

#version 150

out vec4 fPosition;
in vec4 vPosition;

uniform float aspectRatio; //cuts off and letterboxes x axis

void main() {
    fPosition.x = vPosition.x*0.5*aspectRatio+0.5;
    fPosition.y = vPosition.y*0.5+0.5;
    gl_Position = vPosition;
}
