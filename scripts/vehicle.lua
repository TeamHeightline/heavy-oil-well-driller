local config=require('machine-config')
local fuel=require('scripts.fuel')
local M={name=config.name}
local function drive_lock(s,enabled)
  local car=s.entity
  if not car or not car.valid then return end
  if enabled then
    if not s.drill_lock then
      s.drive_disabled_before=car.disabled_by_script
      s.drive_rotatable_before=car.rotatable
      s.drill_lock_orientation=car.orientation
      s.drill_lock=true
    end
    car.speed=0
    car.disabled_by_script=true
    car.rotatable=false
    car.effectivity_modifier=0
    car.orientation=s.drill_lock_orientation
  elseif s.drill_lock then
    car.disabled_by_script=s.drive_disabled_before or false
    car.rotatable=s.drive_rotatable_before
    car.effectivity_modifier=1
    s.drill_lock=nil;s.drive_disabled_before=nil;s.drive_rotatable_before=nil;s.drill_lock_orientation=nil
  end
end

function M.new_state(car)
  return {entity=car,enabled=false,progress=0,total=1800,status='off'}
end
function M.toggle(s,enabled)
  s.enabled=enabled;s.progress=0;s.target=nil;s.origin=nil
  s.status=enabled and 'ready' or 'off'
  drive_lock(s,enabled)
end
local function head(car)
  local a=car.orientation*2*math.pi
  local x,y=math.sin(a),-math.cos(a)
  local distance=5.2/math.sqrt(x*x+2*y*y)
  return {x=car.position.x+x*distance,y=car.position.y+y*distance}
end
local function find_deposit(car)
  local target,distance
  local p=head(car)
  for _,e in pairs(car.surface.find_entities_filtered{position=p,radius=1.15,name='crude-oil'})do
    local d=(e.position.x-p.x)^2+(e.position.y-p.y)^2
    if not distance or d<distance then target=e;distance=d end
  end
  return target
end
local function clear_job(s)
  s.progress=0;s.target=nil;s.origin=nil
end
function M.update(car,s)
  drive_lock(s,s.enabled)
  if not s.enabled then if s.status~='complete' then s.status='off' end;return end
  if s.origin and ((car.position.x-s.origin.x)^2+(car.position.y-s.origin.y)^2>.04 or math.abs(((car.orientation-s.orientation+.5)%1)-.5)>.01) then clear_job(s) end
  local target=find_deposit(car)
  if not target then clear_job(s);s.status='ready';return end
  if target~=s.target then
    clear_job(s);s.target=target;s.origin=car.position;s.orientation=car.orientation
  end
  local trunk=car.get_inventory(defines.inventory.car_trunk)
  local stack
  for i=1,#trunk do
    if trunk[i].valid_for_read and trunk[i].name=='pumpjack' then stack=trunk[i];break end
  end
  if not stack or trunk.get_item_count('pipe')<10 then s.status='materials';return end
  local position=target.position
  if not car.surface.can_place_entity{name='pumpjack',position=position,direction=defines.direction.north,force=car.force,build_check_type=defines.build_check_type.manual} then s.status='blocked';return end
  local need=config.tool_power/60
  local paid=fuel.debit(car,need)
  if paid<=0 then s.status='fuel';return end
  s.progress=math.min(s.total,s.progress+paid/need);s.status='working'
  if s.progress<s.total then return end
  -- Consume the supplied building only after a real entity was created.
  local well=car.surface.create_entity{name='pumpjack',position=position,direction=defines.direction.north,force=car.force,quality=stack.quality,raise_built=true,create_build_effect_smoke=true}
  if not well or not well.valid then s.status='blocked';return end
  stack.count=stack.count-1;trunk.remove{name='pipe',count=10}
  s.enabled=false;s.status='complete';s.target=nil;s.origin=nil
  drive_lock(s,false)
end
return M
