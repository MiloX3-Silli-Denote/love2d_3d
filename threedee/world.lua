local World = {};
World.__index = World;

function World.new()
  local instance = setmetatable({}, World);

  instance.prefabs = {};
  instance.objects = {};

  return instance;
end

function World:loadPrefab(object, name)
  assert(self.prefabs[name] == nil, "tried to create a prefab with name that already is in use");

  self.prefabs[name] = object;
end

function World:addToWorld(object)
  table.insert(self.objects, object);
end

function World:instantiate(obj_name)
  if type(obj_name) == "string" then
    local objCopy = self.prefabs[obj_name];
  end

  local objCopy = obj_copy:copy();

  table.insert(self.objects, objCopy);
  return objCopy;
end

function World:update(dt)
  -- nothing yet
end

function World:draw()
  for i, v in ipairs(self.objects) do
    v:draw();
  end
end

return World;
