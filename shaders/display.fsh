/*
    display.fsh
    Matthew Jee
    mcjee@ucsc.edu
*/

#version 150

in vec4 fPosition;
uniform sampler2D texture0;

out vec4 fragColor;

void main() {
    fragColor = texture(texture0, fPosition.xy);
}
