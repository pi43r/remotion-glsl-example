#define S(a,b,t) smoothstep(a,b,t)
uniform float iTime;
uniform vec2 iResolution;
varying vec2 vUv;

mat2 Rot(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, -s, s, c);
}

// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(2127.1, 81.17)), dot(p, vec2(1269.5, 283.37)));
  return fract(sin(p) * 43758.5453);
}

float noise(in vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 u = f * f * (3.0 - 2.0 * f);

  float n = mix(mix(dot(-1.0 + 2.0 * hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)), dot(-1.0 + 2.0 * hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x), mix(dot(-1.0 + 2.0 * hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)), dot(-1.0 + 2.0 * hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
  return 0.5 + 0.5 * n;
}

float grain(vec2 uv) {
  return noise(uv);
}

float smoothGrain(vec2 uv, float time) {
  float t1 = floor(time * 0.1) * 10.0;
  float t2 = t1 + 1.0;

  float f1 = grain(uv + t1);
  float f2 = grain(uv + t2);

  float mixFactor = fract(time * 0.1);

  return mix(f1, f2, mixFactor);
}

void main() {
  vec2 fragCoord = vUv * iResolution;
  vec2 uv = fragCoord / iResolution.xy;
  float ratio = iResolution.x / iResolution.y;

  vec2 tuv = uv;
  tuv -= .5;

    // Rotate with Noise
  float degree = noise(vec2(iTime * .1, tuv.x * tuv.y));

  tuv.y *= 1. / ratio;
  tuv *= Rot(radians((degree - .5) * 720. + 180.));
  tuv.y *= ratio;

    // Wave warp with sin
  float frequency = 5.;
  float amplitude = 30.;
  float speed = iTime * 2.;
  tuv.x += sin(tuv.y * frequency + speed) / amplitude;
  tuv.y += sin(tuv.x * frequency * 1.5 + speed) / (amplitude * .5);

    // Draw the image
  vec3 color1 = vec3(0.27, 0.33, 0.55);  // #rgb(0.27,0.33,0.55)
  vec3 color2 = vec3(0.40, 0.58, 0.73);  // #rgb(0.40,0.58,0.73)
  vec3 layer1 = mix(color1, color2, S(-.3, .2, (tuv * Rot(radians(-5.))).x));

  vec3 color3 = vec3(0.18, 0.52, 0.49);  // rgb(0.18,0.52,0.49)
  vec3 color4 = vec3(1.0, 1.0, 1.0); //vec3(0.867, 0.867, 0.867);  // #DDDDDD
  vec3 color5 = vec3(0.55, 0.42, 0.69);  // 0.55,0.42,0.69 (added with smaller ratio)

    // Blend color5 with layer2 with a smaller influence
  vec3 layer2 = mix(color3, color4, S(-.3, .2, (tuv * Rot(radians(-5.))).x));
  vec3 layer3 = mix(layer2, color5, 0.2);  // Smaller ratio for color5

  vec3 finalComp = mix(layer1, layer3, S(.5, -.3, tuv.y));

  vec3 col = finalComp;

    // Add smooth noise effect
  float noiseAmount = 0.1; // Adjust this value to increase/decrease the noise effect
  col += (smoothGrain(fragCoord.xy, iTime) - 0.5) * noiseAmount; // Centering noise around zero

  gl_FragColor = vec4(col, 1.0);
}
