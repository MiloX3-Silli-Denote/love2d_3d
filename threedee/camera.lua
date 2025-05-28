local Camera = {};
Camera.__index = Camera;

function Camera.new()
  local instance = setmetatable({}, Camera);

  -- position
  instance.x = 0;
  instance.y = 0;
  instance.z = 0;

  -- orientation
  instance.yaw = 0;   -- left to right rotation
  instance.pitch = 0; -- up to down rotation
  instance.roll = 0;  -- tilt

  instance.fov = math.pi / 2; -- 90 degrees

  instance.near = 0.01; -- closest available distance viewable
  instance.far  = 1000; -- furthest available distance viewable

  instance.aspectRatio = love.graphics.getWidth() / love.graphics.getHeight(); -- aspect ration of the screen being drawn to

  -- 'private' variables. should ONLY be altered internally

  instance.viewMatrix = Threedee.newMatrix(); -- view matrix
  instance.projectionMatrix = Threedee.newMatrix(); -- projectionMatrix

  -- where 'up' is for the camera (in global coordinates)
  instance.upx = 0;
  instance.upy = 1;
  instance.upz = 0;
  -- point that the camera is looking at
  instance.lookNormalX = 0;
  instance.lookNormalY = 0;
  instance.lookNormalZ = 1;

  instance.updateViewMat = true; -- whether or not the view matrix needs to be updated before the next draw
  instance.updateProjectionMat = true; -- whether or not the projection matrix needs to be updated before the next draw

  return instance;
end

function Camera:setPosition(x, y, z)
  self.x = x;
  self.y = y;
  self.z = z;

  self.updateViewMat = true;
end
function Camera:translate(x, y, z)
  self.x = self.x + x;
  self.y = self.y + y;
  self.z = self.z + z;

  self.updateViewMat = true;
end

-- yaw, pitch, [roll=0]
function Camera:setOrientation(yaw, pitch, roll)
  roll = roll or 0;

  self.yaw = yaw;
  self.pitch = pitch;
  self.roll = roll;

  local ca, cb, cc = math.cos(roll), math.cos(yaw), math.cos(pitch);
  local sa, sb, sc = math.sin(roll), math.sin(yaw), math.sin(pitch);

  self.lookNormalX = (ca * sb * cc + sa * sc);
  self.lookNormalY = (sa * sb * cc - ca * sc);
  self.lookNormalZ = cb * cc;

  self.upx = (ca * sb * sc - sa * cc);
  self.upy = (sa * sb * sc + ca * cc);
  self.upz = cb * sc;

  self.updateViewMat = true;
end
-- yaw, pitch, [roll=0]
function Camera:rotate(yaw, pitch, roll)
  roll = roll or 0;

  self:setOrientation(self.yaw + yaw, self.pitch + pitch, self.roll + roll);
end

-- giving just the ratio is allowed here
-- x, [y=1]
function Camera:setAspectRatio(x, y)
  y = y or 1;

  local ratio = x / y;

  self.aspectRatio = ratio;

  self.updateProjectionMat = true;
end

function Camera:setFOV(fov)
  self.fov = fov;

  self.updateProjectionMat = true;
end
Camera.setFieldOfView = Camera.setFOV; -- allow either to be used

function Camera:updateViewMatrix()
  self.viewMatrix:setViewMatrix(
    self.x, self.y, self.x,
    self.lookNormalX, self.lookNormalY, self,lookNormalZ,
    self.upx, self.upy, self.upz
  );
end

function Camera:updateProjectionMatrix()
  self.projectionMatrix:setProjectionMatrix(self.fov, self.near, self.far, self.aspectRatio);
end

function Camera:sendToShader(shader)
  if self.updateProjectionMat then
    self:updateProjectionMatrix();
    self.updateProjectionMat = false;
  end

  if self.updateViewMat then
    self:updateViewMatrix();
    self.updatViewMat = false;
  end
  
  shader:send("viewMatrix", self.viewMatrix);
  shader:send("projectionMatrix", self.projectionMatrix);
end

return Camera;
