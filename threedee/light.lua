local Light = {};
Light.__index = Light;

function Light.new(x,y,z, brightness, r,g,b)
  local instance = setmetatable({}, Light);

  instance.x = x or 0;
  instance.y = y or 0;
  instance.z = z or 0;

  instance.r = r or 1;
  instance.g = g or 1;
  instance.b = b or 1;
  instance.brightness = brightness or 5;

  instance.update = true;

  return instance;
end

function Light.newPointLight(x,y,z, brightness, r,g,b)
  local instance = Light.new(x,y,z, brightness, r,g,b);

  instance.lightType = "point";

  return instance;
end

function Light.newSpotLight(x,y,z, dx,dy,dz, fov, brightness, r,g,b)
  local instance = Light.new(x,y,z, brightness, r,g,b);

  instance.dx = dx;
  instance.dy = dy;
  instance.dz = dz;

  instance.fov = fov or math.pi / 2;

  instance.lightType = "spot";

  return instance;
end

function Light.newDirectionLight(dx,dy,dz, r,g,b)
  local instance = Light.new(dx,dy,dz, 1, r,g,b);

  instance.lightType = "direction";

  return instance;
end

function Light:setPosition(x, y, z)
  if self.lightType == "direction" then
    return;
  end

  self.x = x;
  self.y = y;
  self.z = z;

  self.update = true;
end
function Light:setDirection(x, y, z)
  if self.lightType == "point" then
    return;
  end

  if self.lightType == "direction" then
    self.x = x;
    self.y = y;
    self.z = z;

    self.update = true;

    return;
  end

  self.dx = x;
  self.dy = y;
  self.dz = z;

  self.update = true;
end

function Light:setColour(r, g, b)
  self.r = r;
  self.g = g;
  self.b = b;

  self.update = true;
end

function Light:setBrightness(bright)
  if self.lightType == "direction" then
    return;
  end

  self.brightness = bright;

  self.update = true;
end

function Light:setFOV(fov)
  if self.lightType == "spot" then
    self.fov = fov;

    self.update = true;
  end
end
Light.setFieldOfView = Light.setFOV;

function Light:sendToShader(shader)
  if self.lightType == "point" then
  end
end

return Light;
