#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

// Renamed uniforms to avoid conflicts and match a clear convention
uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uColor;
uniform vec2 uMouse;
uniform float uAmplitude;
uniform float uSpeed;

out vec4 fragColor;

void main() {
    // Use Flutter's provided fragment coordinate
    vec2 fragCoord = FlutterFragCoord().xy;
    
    // Normalize fragment coordinates to a range of 0.0 to 1.0.
    vec2 vUv = fragCoord.xy / uResolution.xy;

    // Adjust coordinates to be centered and aspect-ratio correct.
    float mr = min(uResolution.x, uResolution.y);
    vec2 uv = (vUv.xy * 2.0 - 1.0) * uResolution.xy / mr;

    // Apply mouse-based displacement.
    // The mouse coordinates are already adjusted in the Dart code.
    uv += (uMouse - vec2(0.5)) * uAmplitude;

    // The core iridescent/noise algorithm.
    float d = -uTime * 0.5 * uSpeed;
    float a = 0.0;
    for (float i = 0.0; i < 8.0; ++i) {
        a += cos(i - d - a * uv.x);
        d += sin(uv.y * i + a);
    }
    d += uTime * 0.5 * uSpeed;

    // Calculate the final color.
    vec3 col = vec3(cos(uv * vec2(d, a)) * 0.6 + 0.4, cos(a + d) * 0.5 + 0.5);
    col = cos(col * cos(vec3(d, a, 2.5)) * 0.5 + 0.5) * uColor;

    // Output the final color.
    fragColor = vec4(col, 1.0);
}
