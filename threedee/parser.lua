local Parser = {};

function Parser.loadModel(filename)
  local filetype = string.match(filename, "%..-$");

  if filetype == ".obj" then -- wavefront
    return Parser.loadWavefront(filename);
  end
end

-- returns one mesh, does not parse mtl file, non triangulated faces are triangulated with a fan
function Parser.loadWavefront(filename)
  local position = {};
  local texCoord = {};
  local normal = {};
  local vertices = {};

  for line in love.filesystem.lines(filename) do
    line = string.match(line, "^[^#]*");

    if line == "" then
      goto continue;
    end

    local lineType;
    lineType, line = string.match(line, "^([^%s]*)%s(.*)$");

    if lineType == "v" then -- declare a vertex position
      local x, y, z,  w = string.match(line, "^(%-?[%d.]*)%s(%-?[%d.]*)%s(%-?[%d.]*)%s?(%-?[%d.]*)$");
      x = tonumber(x);
      y = tonumber(y);
      z = tonumber(z);
      w = tonumber(w) or 1;

      table.insert(position, {x, y, z, w});

      goto continue;
    elseif lineType == "vt" then -- declare a texture coordinate
      local u,  v,w = string.match(line, "^(%-?[%d.]*)%s?(%-?[%d.]*)%s?(%-?[%d.]*)$");
      u = tonumber(u);
      v = tonumber(v) or 0;
      w = tonumber(w) or 0;

      table.insert(texCoord, {u, v, w});

      goto continue;
    elseif lineType == "vn" then -- declare a vertex normal
      local x, y, z - string.match(line, "^(%-?[%d.]*)%s(%-?[%d.]*)%s(%-?[%d.]*)$");
      x = tonumber(x);
      y = tonumber(y);
      z = tonumber(z);

      -- normalize (just in case
      local mag = 1 / math.sqrt(x*x + y*y + z*z);
      x = x * mag;
      y = y * mag;
      z = z * mag;

      table.insert(normal, {x, y, z});

      goto continue;
    elseif lineType == "f" then -- define a face
      local verts = {};

      for vert in string.gmatch(line, "[^%s]+") do
        local posInd, texInd, normInd = string.match(vert, "(%-?[%d.]*)/?(%-?[%d.]*)/?(%-?[%d.]*)");
        posInd = tonumber(posInd);
        texInd = tonumber(texInd);
        normInd = tonumber(normInd);

        if posInd then
          posInd = (posInd - 1) % #position + 1;
        end
        if texInd then
          texInd = (texInd - 1) % #texCoord + 1;
        end
        if normInd then
          normInd = (normInd - 1) % #normInd + 1;
        end

        table.insert(verts, {posInd, texInd, normInd});
      end

      if #verts == 3 then -- triangle
        table.insert(vertices, {
            position[verts[1][1]][1], position[verts[1][1]][2], position[verts[1][1]][2],
            texCoord[verts[1][2]][1], texCoord[verts[1][2]][2],
            normal[verts[1][3]][1], normal[verts[1][3]][2], normal[verts[1][3]][3]
        });

        table.insert(vertices, {
            position[verts[2][1]][1], position[verts[2][1]][2], position[verts[2][1]][2],
            texCoord[verts[2][2]][1], texCoord[verts[2][2]][2],
            normal[verts[2][3]][1], normal[verts[2][3]][2], normal[verts[2][3]][3]
        });

        table.insert(vertices, {
            position[verts[3][1]][1], position[verts[3][1]][2], position[verts[3][1]][2],
            texCoord[verts[3][2]][1], texCoord[verts[3][2]][2],
            normal[verts[3][3]][1], normal[verts[3][3]][2], normal[verts[3][3]][3]
        });
      else
        -- triangle fan
        for i = 2, #verts do
          table.insert(vertices, {
            position[verts[1][1]][1], position[verts[1][1]][2], position[verts[1][1]][2],
            texCoord[verts[1][2]][1], texCoord[verts[1][2]][2],
            normal[verts[1][3]][1], normal[verts[1][3]][2], normal[verts[1][3]][3]
          });

          table.insert(vertices, {
              position[verts[i - 1][1]][1], position[verts[i - 1][1]][2], position[verts[i - 1][1]][2],
              texCoord[verts[i - 1][2]][1], texCoord[verts[i - 1][2]][2],
              normal[verts[i - 1][3]][1], normal[verts[i - 1][3]][2], normal[verts[i - 1][3]][3]
          });

          table.insert(vertices, {
              position[verts[i][1]][1], position[verts[i][1]][2], position[verts[i][1]][2],
              texCoord[verts[i][2]][1], texCoord[verts[i][2]][2],
              normal[verts[i][3]][1], normal[verts[i][3]][2], normal[verts[i][3]][3]
          });
        end

        goto continue;
      end
    end
    
    ::continue:: -- typically a bad coding practice but it makes this more readable
  end

  return Threedee.newMesh(vertices); -- construct mesh and return it
end

return Parser;
