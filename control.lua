local motion=require("scripts.motion-visuals")
local vehicle=require("scripts.vehicle")
local config=require("machine-config")
local frame_name=config.name.."-panel"
local switch_name=config.name.."-switch"
local function register(car)
  if not car or not car.valid or car.name~=config.name then return end
  storage.machines=storage.machines or {}
  local state=storage.machines[car.unit_number]
  if not state then state=vehicle.new_state(car);storage.machines[car.unit_number]=state end
  if not state.motion_pose then motion.update(car,state) end
  return state
end
local function scan()
  storage.machines=storage.machines or {};storage.opened={}
  for _,force in pairs(game.forces) do
    local unlocked=force.technologies.railway and force.technologies.railway.researched or false
    for _,recipe in ipairs{config.name,'factory-heavy-construction-machinery-plant-'..config.name} do
      if force.recipes[recipe] then force.recipes[recipe].enabled=unlocked end
    end
  end
  for _,surface in pairs(game.surfaces)do for _,car in pairs(surface.find_entities_filtered({name=config.name}))do register(car)end end
end
remote.add_interface(config.name,{
  set_tool_enabled=function(unit,enabled)
    local s=storage.machines[unit]
    if s and s.entity.valid and type(enabled)=="boolean" then vehicle.toggle(s,enabled);return true end
    return false
  end,
  get_status=function(unit)
    local s=storage.machines[unit]
    if s and s.entity.valid then return {enabled=s.enabled,status=s.status,progress=s.progress,total=s.total} end
  end
})
script.on_init(scan)
script.on_configuration_changed(function(event)
  scan()
  if event.mod_changes and event.mod_changes[config.name] then
    for _,state in pairs(storage.machines)do vehicle.toggle(state,false);state.progress=0;state.row=nil end
  end
end)
script.on_event({defines.events.on_built_entity,defines.events.on_robot_built_entity,defines.events.script_raised_built,defines.events.script_raised_revive},function(e)register(e.entity)end)
script.on_event(defines.events.on_entity_cloned,function(e)register(e.destination)end)
script.on_event(defines.events.on_player_driving_changed_state,function(e)register(game.get_player(e.player_index).vehicle)end)
local function close(p)
  local f=p.gui.relative[frame_name];if f then f.destroy()end
  storage.opened[p.index]=nil
end
local function refresh(p,car)
  local frame=p.gui.relative[frame_name]
  if not frame then return end
  local s=register(car)
  frame[switch_name].switch_state=s.enabled and "right" or "left"
  frame.work_progress.value=s.progress/s.total
  frame.work_time.caption={config.name..".remaining",math.ceil(math.max(0,s.total-s.progress)/6)/10}
  frame.work_time.visible=s.status=="working" or s.progress>0
  frame.work_status.caption={config.name..".status-"..s.status}
end
script.on_event(defines.events.on_gui_opened,function(e)
  local p=game.get_player(e.player_index);close(p)
  local car=e.entity
  if not car or car.name~=config.name or car.force~=p.force then return end
  register(car);storage.opened[p.index]=car
  local frame=p.gui.relative.add({type="frame",name=frame_name,caption={config.name..".tool"},direction="vertical",anchor={gui=defines.relative_gui_type.car_gui,position=defines.relative_gui_position.left,name=config.name}})
  frame.add({type="switch",name=switch_name,left_label_caption={config.name..".off"},right_label_caption={config.name..".on"},switch_state="right"})
  frame.add({type="progressbar",name="work_progress",value=0}).style.width=250
  frame.add({type="label",name="work_status",caption=""})
  frame.add({type="label",name="work_time",caption=""})
  frame.add({type="label",caption={config.name..".instructions"}}).style.single_line=false
  frame.add({type="label",caption={config.name..".power",config.tool_power/1000000}})
  refresh(p,car)
end)
script.on_event(defines.events.on_gui_closed,function(e)close(game.get_player(e.player_index))end)
script.on_event(defines.events.on_gui_switch_state_changed,function(e)
  if not e.element or e.element.name~=switch_name then return end
  local car=storage.opened[e.player_index]
  if car and car.valid then vehicle.toggle(register(car),e.element.switch_state=="right") end
end)
script.on_event(defines.events.on_tick,function(e)
  for id,s in pairs(storage.machines)do
    if not s.entity.valid then motion.destroy(s);storage.machines[id]=nil else vehicle.update(s.entity,s)end
    if s.entity.valid then motion.update(s.entity,s)end
    if s.entity.valid and s.status=="working" and e.tick%15==0 then
      rendering.draw_text({text=math.floor(s.progress/s.total*100).."%",surface=s.entity.surface,target={entity=s.entity,offset={0,-2.4}},color={1,0.8,0.2},alignment="center",scale=1.2,time_to_live=16})
    end
  end
  if e.tick%15==0 then for index,car in pairs(storage.opened)do
    local p=game.get_player(index)
    if p and car.valid and p.opened==car then refresh(p,car)elseif p then close(p)end
  end end
end)
