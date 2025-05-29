local path = (...);

_G.Threedee = {};
local self = Threedee; -- localized, for readability

function Threedee.init()
  local Matrix = require(path .. "/matrix");
  local Shaders = require(path .. "/shaders");
  local Camera = require(path .. "/camera");
  local Model = require(path .. "/model");
  local Mesh = require(path .. "/mesh");
  local Parser = require(path .. "/parser");
  local World = require(path .. "/world");

  Threedee.newMatrx = Matrix.new;
  Threedee.newCamera = Camera.new;
  Threedee.newShader = Shaders.new;
  Threedee.newModel = Model.new;
  Threedee.newMesh = Mesh.new;
  Threedee.loadModel = Parser.loadModel;
  Threedee.newWorld = World.new;

  self.activeCamera = Camera.new(); -- create a new camera as the main camera
  self.activeWorld = World.new(); -- create a new world as the main world
end

function Threedee.setActiveCamera(cam)
  self.activeCamera = cam;
end
function Threedee.setActiveWorld(world)
  self.activeWorld = world;
end
function Threedee.getCamera()
  return self.activeCamera;
end
function Threedee.getWorld()
  return self.activeWorld;
end

function Threedee.loadPrefab(...)
  self.activeWorld:loadPrefab(...);
end
function Threedee.addToWorld(...)
  self.activeWorld:addToWorld(...);
end
function Threedee.instantiate(...)
  self.activeWorld:instantiate(...);
end
function Threedee.update(...)
  self.activeWorld:update(...);
end
function Threedee.draw()
  self.activeWorld:draw();
end

function Threedee.newShader(pixelCode, vertexCode)
  pixelCode = pixelCode or path .. "/default.frag";
  vertexCode = vertexCode or path .. "/default.vert";

  return love.graphics.newShader(pixelCode, vertexCode);
end

Threedee.init(); -- call on require
return Threedee;
