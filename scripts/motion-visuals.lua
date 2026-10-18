-- Both poses use independently rendered, fixed-scale 3D views.
local M={}
local name=require('machine-config').name
local spec=require('graphics.motion-spec')
local roles={'shadow','body','tracks','head'}
local function clear(state,role)
  local o=state['motion_'..role]
  if o and o.valid then o.destroy() end
  state['motion_'..role]=nil
end
function M.destroy(state)
  for _,role in ipairs(roles) do clear(state,role) end
  state.motion_pose=nil
end
local function layer(state,car,pose,role,direction,phase)
  local key='motion_'..role
  local animation=name..'-'..pose..'-'..role..'-'..direction
  local o=state[key]
  if not o or not o.valid then
    o=rendering.draw_animation{
      animation=animation,animation_speed=0,animation_offset=phase,
      target=car,surface=car.surface,orientation=0,
      render_layer=role=='shadow' and 'object' or role=='head' and 'higher-object-under' or 'object'
    }
    state[key]=o
  else
    if o.animation~=animation then o.animation=animation end
    o.animation_speed=0
    o.animation_offset=phase
  end
end
function M.update(car,state)
  local heading=car.orientation*math.pi*2
  local turn=((car.orientation-(state.motion_orientation or car.orientation)+.5)%1)-.5
  local moving=math.abs(car.speed)>.001 or math.abs(turn)>.00001
  local pose=state.enabled and 'work' or 'travel'
  if state.motion_pose~=pose or state.motion_surface~=car.surface.index then M.destroy(state) end
  -- The native vehicle animation is empty; these layers own both poses.
  -- Driver/passenger color therefore cannot make a second pose show through.
  local projected=(math.atan2(math.sin(heading),math.cos(heading)*math.sqrt(2))/(math.pi*2))%1
  local direction=math.floor(projected*128+.5)%128
  local phase=state.track_phase or 0
  local previous=state.motion_position
  if previous and state.motion_surface==car.surface.index then
    local dx,dy=car.position.x-previous.x,car.position.y-previous.y
    if dx*dx+dy*dy<2.25 then
      local signed=dx*math.sin(heading)-dy*math.cos(heading)
      local pitch=spec[pose].track_pitch/math.sqrt(math.sin(heading)^2+2*math.cos(heading)^2)
      phase=(phase+(signed+math.abs(turn)*math.pi*2*1.25)*4/pitch)%4
    end
  end
  state.track_phase=phase
  local head_phase=state.head_phase or 0
  if pose=='work' and state.status=='working' then head_phase=(head_phase+.4)%4 end
  state.head_phase=head_phase
  for _,role in ipairs(roles) do
    if spec[pose][role] then
      layer(state,car,pose,role,direction,role=='tracks' and phase or role=='head' and head_phase or 0)
    else clear(state,role) end
  end
  state.motion_pose=pose
  state.motion_position={x=car.position.x,y=car.position.y}
  state.motion_orientation=car.orientation
  state.motion_surface=car.surface.index
end
return M
