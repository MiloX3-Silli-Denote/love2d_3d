local Mesh = {};
Mesh.__index = Mesh;

Mesh.defaultVertexFormat = {
  {"VertexPosition", "float", 3};
  {"VertexTexCoord", "float", 2};
  {"VertexNormal", "float", 3};
  {"VertexTangent", "float", 3};
  {"VertexBitangent", "float", 3};
};

-- {x,y,z, u,v, xn,yn,zn, r,g,b,a}, {}, {} ...
function Mesh.new(...)
  local vertices = {...};
  assert(#vertices % 3 == 0, "tried to create a mesh with a non multiple of 3 number of vertices (meshes are in 'triangle' MeshDrawMode)");
  
  local instance = setmetatable({}, Mesh);

  for i = 1, #vertices - 1, 3 do -- calculate tangent and bitangent from triangulated surface
    local v1 = vertices[i];
    local v2 = vertices[i + 1];
    local v3 = vertices[i + 2];

    local edge1x = v2[1] - v1[1];
    local edge1y = v2[2] - v1[2];
    local edge1z = v2[3] - v1[3];

    local edge2x = v3[1] - v1[1];
    local edge2y = v3[2] - v1[2];
    local edge2z = v3[3] - v1[3];

    local d1u = v2[4] - v1[4];
    local d1v = v2[5] - v1[5];

    local d2u = v3[4] - v1[4];
    local d2v = v3[5] - v1[5];

    local f = 1 / (d1u * d2v - d2u * d1v);

    local tanx = f * (d2v * edge1x - d1v * edge2x);
    local tany = f * (d2v * edge1y - d1v * edge2y);
    local tanz = f * (d2v * edge1z - d1v * edge2z);
    local bitanx = f * (-d2u * edge1x + d1u * edge2x);
    local bitany = f * (-d2u * edge1y + d1u * edge2y);
    local bitanz = f * (-d2u * edge1z + d1u * edge2z);

    -- tangent
    table.insert(v1, tanx);--
    table.insert(v1, tany);
    table.insert(v1, tanz);
    table.insert(v2, tanx);--
    table.insert(v2, tany);
    table.insert(v2, tanz);
    table.insert(v3, tanx);--
    table.insert(v3, tany);
    table.insert(v3, tanz);
    -- bitangent
    table.insert(v1, bitanx);--
    table.insert(v1, bitany);
    table.insert(v1, bitanz);
    table.insert(v2, bitanx);--
    table.insert(v2, bitany);
    table.insert(v2, bitanz);
    table.insert(v3, bitanx);--
    table.insert(v3, bitany);
    table.insert(v3, bitanz);
  end

  -- generate the drawable
  instance.mesh = love.graphics.newMesh(instance.defaultVertexFormat, vertices, "triangle", "static");

  return instance;
end

function Mesh:draw()
  love.graphics.draw(self.mesh);
end

return Mesh;
