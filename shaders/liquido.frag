#version 460 core
// Fundo: degradê vermelho -> preto + ondas de líquido que se espalham a
// partir do toque/mouse (recriação própria, inspirada no Vercel Ship).
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uBase;      // vermelho (topo)
uniform vec3 uInk;       // preto (base)
uniform vec4 uPts[12];   // x, y, instante de nascimento, força

out vec4 fragColor;

float altura(vec2 p) {
  float h = 0.0;
  for (int i = 0; i < 12; i++) {
    float idade = uTime - uPts[i].z;
    if (uPts[i].w <= 0.0 || idade < 0.0 || idade > 4.5) continue;
    float x = distance(p, uPts[i].xy) - idade * 260.0;
    h += sin(x * 0.11) * exp(-(x * x) / 4900.0) * exp(-idade * 0.8) * uPts[i].w;
  }
  return h;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float e = 1.5;
  float gx = altura(p + vec2(e, 0.0)) - altura(p - vec2(e, 0.0));
  float gy = altura(p + vec2(0.0, e)) - altura(p - vec2(0.0, e));
  float luz = clamp((gx + gy) * 1.6, -1.0, 1.0);

  // pequeno degradê: vermelho domina, só a parte de baixo escurece
  float t = smoothstep(0.25, 1.0, p.y / uSize.y);
  vec3 cor = mix(uBase, uInk, t * 0.9);

  if (luz > 0.0) {
    cor = mix(cor, vec3(1.0), luz * 0.30);
  } else {
    cor = mix(cor, uInk, -luz * 0.40);
  }
  fragColor = vec4(cor, 1.0);
}
