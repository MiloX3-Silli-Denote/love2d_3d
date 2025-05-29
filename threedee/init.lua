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

  Threedee.newMatrx = Matrix.new;
  Threedee.newCamera = Camera.new;
  Threedee.newShader = Shaders.new;
  Threedee.newModel = Model.new;
  Threedee.newMesh = Mesh.new;
  Threedee.loadModel = Parser.loadModel;

  self.activeCamera = Camera.new(); -- create a new camera as the main camera
end

function Threedee.setActiveCamera(cam)
  self.activeCamera = cam;
end
function Threedee.getCamera()
  return self.activeCamera;
end

function Threedee.newShader(pixelCode, vertexCode)
  pixelCode = pixelCode or path .. "/default.frag";
  vertexCode = vertexCode or path .. "/default.vert";

  return love.graphics.newShader(pixelCode, vertexCode);
end

Threedee.init(); -- call on require
return Threedee;
