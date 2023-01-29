//Vignette shader

void main()
  vec2 texCoord = gl_TexCoord[0].st;
  vec2 center = vec2(0.5, 0.5);
  float dist = distance(texCoord, center);
  float vignette = 1.0 - smoothstep(0.8, 1.0, dist * dist);
  vignette = mix(1.0, vignette, 0.4);
  gl_FragColor = texture2D(tex0, texCoord) * vignette;
{