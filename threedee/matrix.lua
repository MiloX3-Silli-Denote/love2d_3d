local Matrix = {};
Matrix.__index = Matrix;

function Matrix.new()
  local instance = setmetatable({}, Matrix);

  -- initialize matrix as identity matrix
  instance[1],  instance[2],  instance[3],  instance[4]  = 1, 0, 0, 0;
  instance[5],  instance[6],  instance[7],  instance[8]  = 0, 1, 0, 0;
  instance[9],  instance[10], instance[11], instance[12] = 0, 0, 1, 0;
  instance[13], instance[14], instance[15], instance[16] = 0, 0, 0, 1;

  return instance;
end

-- x,y,z, [scalex=1,scaley=scalex,scalez=scaley, rotx=0,roty=0,rotz=0, rotk]
-- if rotx, roty, and rotz are given then they will rotate in the order: z, y, x
-- if rotx, roty, rotz, and rotk are given then they will be interpreted as a quaternion
function Matrix:setTransformationMatrix(x,y,z, sx,sy,sz, rx,ry,rz,rk) -- translation, rotation, scale
  sx = sx or 1;
  sy = sy or sx;
  sz = sz or sy;

  rx = rx or 0;
  ry = ry or 0;
  rz = rs or 0;
  
  -- transformation
  self[4]  = x;
  self[8]  = y;
  self[12] = z;

  -- scaling is built into the rotations
  if (rotx ~= 0 or roty ~= 0 or rotz ~= 0) and not rotk then -- use 3D rotation vector as euler angles
    local ca, cb, cc = math.cos(rz), math.cos(ry), math.cos(rx);
    local sa, sb, sc = math.sin(rz), math.sin(ry), math.sin(rx);

    self[1], self[2],  self[3]  = ca*cb * sx, (ca*sb*sc - sa*cc) * sy, (ca*sb*cc + sa*sc) * sz;
    self[5], self[6],  self[7]  = sa*cb * sx, (sa*sb*sc + ca*cc) * sy, (sa*sb*cc - ca*sc) * sz;
    self[9], self[10], self[11] = -sb * sx, cb*sc * sy, cb*cc * sz;
  elseif rotk then -- use 3d rotation vector as quaternion
    local s = rotx;
    local i, j, k = roty, rotz, rotk;

    -- normalize the quaternion
    local len = s * s + i * i + j * j + k * k;

    if len ~= 1 then
      len = math.sqrt(len);

      s = s / len;
      i = i / len;
      j = j / len;
      k = k / len;
    end

    self[1] = sx * 2 * (s * s + i * i) - 1;
    self[2] = sy * 2 * (i * j - s * k);
    self[3] = sz * 2 * (i * k + s * j);
     
    self[5] = sx * 2 * (i * j + s * k);
    self[6] = sy * 2 * (s * s + j * j) - 1;
    self[7] = sz * 2 * (j * k - s * i);
     
    self[9]  = sx * 2 * (i * k - s * j);
    self[10] = sy * 2 * (j * k + s * i);
    self[11] = sz * 2 * (s * s + k * k) - 1;
  else -- if no rotation is present then at least scale
    self[1], self[2] , self[3]  = sx, 0, 0;
    self[5], self[6] , self[7]  = 0, sy, 0;
    self[9], self[10], self[11] = 0, 0, sz;
  end

  -- fourth row is not used, just set it to the fourth row of the identity Matrix
  self[13], self[14], self[15], self[16] = 0, 0, 0, 1;
end

-- transpose of the camera (look at) Matrix
function Matrix:lookAtFrom(posX,posY,posZ, targetX,targetY,targetZ, upX,upY,upZ)
  self[4]  = posX;
  self[8]  = posY;
  self[12] = posZ;

  local fx = posX - targetX;
  local fy = posY - targetY;
  local fz = posZ - targetZ;

  local len = 1 / math.sqrt(fx*fx + fy*fy + fz*fz);

  fx = fx * len;
  fy = fy * len;
  fz = fz * len;

  local sx = upY * fz - upZ * fy;
  local sy = upZ * fx - upX * fz;
  local sz = upX * fy - upY * fx;

  len = 1 / math.sqrt(sx * sx + sy * sy + sz * sz);

  sx = sx * len;
  sy = sy * len;
  sz = sz * len;

  local ux = fy * sz - fz * sy;
  local uy = fz * sx - fx * sz;
  local uz = fx * sy - fy * sx;

  self[1], self[2], self[3]   = fx, sx * sy, ux * sz;
  self[5], self[6], self[7]   = fy, sy * sy, uy * sz;
  self[9], self[10], self[11] = fz, sz * sy, uz * sz;
end

function Matrix:setProjectionMatrix(fov, near, far, aspectRatio)
  local top   = near * math.tan(fov / 2);
  local right = top * aspectRatio;
  local fmn   = 1 / (far - near);

  self[1],  self[2],  self[3],  self[4]  = near / right, 0         , 0                  , 0;
  self[5],  self[6],  self[7],  self[8]  = 0           , near / top, 0                  , 0;
  self[9],  self[10], self[11], self[12] = 0           , 0         , -(far + near) * fmn, -2 * far * near * fmn;
  self[13], self[14], self[15], self[16] = 0           , 0         , -1                 , 0;
end

function Matrix:setViewMatrix(eyeX,eyeY,eyeZ, targetX,targetY,targetZ, upX,upY,upZ)
  local z1 = eyeX - targetX;
  local z2 = eyeY - targetY;
  local z3 = eyeZ - targetZ;

  local len = 1 / math.sqrt(z1 * z1 + z2 * z2 + z3 * z3);

  z1 = z1 * len;
  z2 = z2 * len;
  z3 = z3 * len;

  local x1 = upY * z3 - upZ * z2;
  local x2 = upZ * z1 - upX * z3;
  local x3 = upX * z2 - upY * z1;

  len = 1 / math.sqrt(x1 * x1 + x2 * x2 + x3 * x3);

  x1 = x1 * len;
  x2 = x2 * len;
  x3 = x3 * len;

  local y1 = z2 * x3 - z3 * x2;
  local y2 = z3 * x1 - z1 * x3;
  local y3 = z1 * x2 - z2 * x1;

  self[1],  self[2],  self[3],  self[4]  = x1, x2, x3, -(x1 * eyeX + x2 * eyeY + x3 * eyeZ);
  self[5],  self[6],  self[7],  self[8]  = y1, y2, y3, -(y1 * eyeX + y2 * eyeY + y3 * eyeZ);
  self[9],  self[10], self[11], self[12] = z1, z2, z3, -(z1 * eyeX + z2 * eyeY + z3 * eyeZ);
  self[13], self[14], self[15], self[16] = 0 , 0 , 0 , 1;
end

return Matrix;
