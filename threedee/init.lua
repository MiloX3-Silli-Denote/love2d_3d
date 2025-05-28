local path = (...);

local Threedee = {};

 -- globalize these scripts
_G.Matrix = require(path .. "/matrix");
_G.Shaders = require(path .. "/shaders");
_G.Camera = require(path .. "/camera");

return Threedee;
