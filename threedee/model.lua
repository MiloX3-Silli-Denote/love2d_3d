local Model = {};
Model.__index = Model;

Model.shader = Threedee.newShader(); -- default shader

function Model.new(meshes)
  local instance = setmetatable({}, Model);

  instance.meshes = meshes;
  instance.modelMatrix = Threedee.newMatrix();

  instance.x = 0;
  instance.y = 0;
  instance.z = 0;

  instance.yaw = 0;
  instance.pitch = 0;
  instance.roll = 0;

  instance.sx = 1;
  instance.sy = 1;
  instance.sz = 1;

  instance.updateModelMat = true;

  return instance;
end

function Model:setShader(shader)
  self.shader = shader;
end

function Model:setPosition(x, y, z)
  self.x = x;
  self.y = y;
  self.z = z;

  self.updateModelMat = true;
end
function Model:translate(x, y, z)
  self.x = self.x + x;
  self.y = self.y + y;
  self.z = self.z + z;

  self.updateModelMat = true;
end

function Model:setRotation(yaw, pitch roll)
  self.yaw = yaw;
  self.pitch = pitch;
  self.roll = roll;

  self.updateModelMat = true;
end
function Model:rotate(yaw, pitch, roll)
  self.yaw = self.yaw + yaw;
  self.pitch = self.pitch + pitch;
  self.roll = self.roll + roll;

  self.updateModelMat = true;
end

function Model:setScale(x, y, z)
  self.sx = x;
  self.sy = y;
  self.sz = z;

  self.updateModelMat = true;
end
function Model:scale(x, y, z)
  self.sx = self.sx * x;
  self.sy = self.sy * y;
  self.sz = self.sz * z;

  self.updateModelMat = true;
end

function Model:updateModelMatrix()
  self.modelMatrix:setTransformationMatrix(
    self.x, self.y, self.z,
    self.sx, self.sy, self.sz,
    self.pitch, self.yaw, self.roll
  );
end

function Model:draw()
  if self.updateModelMat then
    self:updateModelMatrix();
    self.updateModelMat = false;
  end

  love.graphics.setShader(self.shader); -- enable shader
  self.shader:send("modelMatrix", self.modelMatrix);
  Threedee.getCamera():sendToShader(self.shader);

  for i, v in ipairs(self.meshes) do
    v:draw();
  end

  love.graphics.setShader(); -- dissable shader
end

return Model;
