varying vec4 localPosition;      // position relative to untransformed model
varying vec4 worldPosition;      // position relative to transfomed model
varying vec4 viewPosition;       // position relative to the camera
varying vec4 screenPosition;     // position viewed on the screen
varying mat3 tangentSpaceNormal; // matrix for transforming normals to tangent space
varying mat3 worldSpaceNormal;   // matrix for transforming normals to world space
varying mat3 viewSpaceNormal;    // matrix for transforming normals to view space

uniform vec3 sunNormal = vec3(-0.5, -1.0, 0.5);

vec4 effect(vec4 colour, Image texture, vec2 textureCoords, vec2 screenCoords)
{
  vec3 normal = worldSpaceNormal * vec3(0.0, 0.0, 1.0);
  vec3 lightNormal = normalize(sunNormal);
  vec3 reflectDir = reflect(vec3(0.0, 0.0, 1.0), viewSpaceNormal * vec3(0.0, 0.0, 1.0));

  float lighting = dot(normal, lightNormal);
  float specularLighting = pow(dot(reflectDir, lightNormal), 4.0);

  vec4 pixel = Texel(texture, textureCoords) * colour * (0.2 + lighting * 0.8 + specularLighting * 0.4);

  return pixel;
}
