attribute vec3 VertexNormal; // add normal to the mesh vertex attributes
attribute vec3 VertexTangent;
attribute vec3 VertexBitangent;

uniform mat4 projectionMatrix; // handled by the camera
uniform mat4 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn

varying vec4 localPosition;    // position relative to untransformed model
varying vec4 worldPosition;    // position relative to transfomed model
varying vec4 viewPosition;     // position relative to the camera
varying vec4 screenPosition;   // position viewed on the screen
varying mat3 tangentSpace;     // matrix for transforming normals to tangent space
varying mat3 worldSpaceNormal; // matrix for transforming normals to world space
varying mat3 viewSpaceNormal;  // matrix for transforming normals to view space

mat3 inverse(mat3 m)
{
    float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
    float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
    float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

    float b01 = a22 * a11 - a12 * a21;
    float b11 = -a22 * a10 + a12 * a20;
    float b21 = a21 * a10 - a11 * a20;

    float det = a00 * b01 + a01 * b11 + a02 * b21;

    return mat3(
        b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
        b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
        b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)
    ) / det;
}

// transformProjection doesnt get used so none of the love.graphics transformations will do anything (maybe should allow them in some way?)
vec4 position(mat4 transformProjection, vec4 vertPosition)
{
    localPosition = vertPosition; // position relative to the model
    worldPosition = modelMatrix * localPosition; // position in the world
    viewPosition  = viewMatrix  * worldPosition; // position relative to camera
    screenPosition = projectionMatrix * viewPosition; // position on the screen

    vec3 T = normalize(VertexTangent);
    vec3 B = normalize(VertexBitangent);
    vec3 N = normalize(VertexNormal);

    tangentSpace = mat3(T, B, N); // normals as they would be on the model when its untransformed

    T = normalize(inverse(mat3(modelMatrix)) * VertexTangent);
    B = normalize(inverse(mat3(modelMatrix)) * VertexBitangent);
    N = normalize(inverse(mat3(modelMatrix)) * VertexNormal);

    worldSpaceNormal = mat3(T, B, N); // normals as they would be on the model after its transformed

    T = normalize(inverse(mat3(viewMatrix)) * T);
    B = normalize(inverse(mat3(viewMatrix)) * B);
    N = normalize(inverse(mat3(viewMatrix)) * N);

    viewSpaceNormal  = mat3(T, B, N); // normals as they are relative to the camera

    // supposedly only do this is there is a canvas active, but idk
    screenPosition.y *= -1.0;

    return screenPosition;
}
