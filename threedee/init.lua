local path = (...);

local Threedee = {};
local self = Threedee; -- localized, for readability

function Threedee.init()
 local Matrix = require(path .. "/matrix");
 local Shaders = require(path .. "/shaders");
 local Camera = require(path .. "/camera");

 Threedee.newMatrx = Matrix.new;
 Threedee.newCamera = Camera.new;
 Threedee.newShader = Shaders.new;

 self.activeCamera = Camera.new(); -- create a new camera as the main camera
end

function Threedee.setActiveCamera(cam)
 self.activeCamera = cam;
end

Threedee.init(); -- call on require
return Threedee;
