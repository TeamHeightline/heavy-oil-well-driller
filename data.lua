local name = "heavy-oil-well-driller"
local root = "__" .. name .. "__/"
local art = require("graphics.sprite-definitions")
local car = table.deepcopy(data.raw.car.car)
car.name = name
car.icon = root .. "graphics/icon.png"
car.icon_size = 128
car.minable = {mining_time = 1, result = name}
car.max_health = 2500
car.collision_box = {{-1.1, -2.25}, {1.1, 4.4}}
car.selection_box = {{-1.5, -5.7}, {1.5, 6}}
car.drawing_box_vertical_extension = 5
car.weight = 16000
car.consumption = "600kW"
car.effectivity = 1
car.braking_power = "2400kW"
car.friction = 0.006
car.rotation_speed = 0.0025
car.rotation_snap_angle = 0
car.tank_driving = true
car.has_belt_immunity = true
-- The two wide tracks straddle the channel; the central collision box may overlap water.
car.collision_mask=table.deepcopy(require("collision-mask-util").get_mask(car))
car.collision_mask.layers.water_tile=nil
car.collision_mask.layers.player=nil
car.collision_mask.layers.out_of_map=true
if data.raw["collision-layer"]["lava_tile"] then car.collision_mask.layers.lava_tile=true end
car.inventory_size = 60
car.trash_inventory_size = 0
car.auto_sort_inventory = true
-- Native vehicle acceleration, braking, traction and collision damage.
car.energy_per_hit_point = 1
car.resistances = {{type="fire",percent=50},{type="impact",percent=20},{type="acid",percent=20}}
car.immune_to_tree_impacts = false
car.immune_to_rock_impacts = false
car.energy_source = {type = "burner", fuel_categories = {"chemical"}, effectivity = 1, fuel_inventory_size = 3}
car.guns = nil
car.turret_animation = nil
car.light_animation = nil
car.track_particle_triggers = nil
car.corpse = nil
-- True orthographic 3D renders: matching model and shadow for every direction.






local function rendered(spec,shadow)
 local stripes={}
 for _,sheet in ipairs(spec.files)do stripes[#stripes+1]={filename=root.."graphics/"..sheet.file,width_in_frames=sheet.columns,height_in_frames=sheet.rows}end
 return {stripes=stripes,width=spec.width,height=spec.height,scale=spec.scale,shift=spec.shift,frame_count=1,direction_count=128,line_length=spec.files[1].columns,apply_projection=true,draw_as_shadow=shadow or false}
end
car.animation={filename="__core__/graphics/empty.png",width=1,height=1,frame_count=1,direction_count=1}
car.radius_visualisation_specification={distance=12,draw_in_cursor=true,draw_on_selection=false,sprite={filename=root.."graphics/placement.png",width=1024,height=1024,scale=.75}}

car.localised_name = {"entity-name." .. name}
car.localised_description = {"entity-description." .. name}
data:extend({car,
  {type = "item-with-entity-data", name = name, icon = car.icon, icon_size = 128,
    subgroup = "transport", order = "b[personal-transport]-c[mulcher]", place_result = name, stack_size = 1},
  {type="recipe",name=name,enabled=false,energy_required=45,ingredients={{type="item",name="steel-plate",amount=80},{type="item",name="iron-gear-wheel",amount=40},{type="item",name="engine-unit",amount=20},{type="item",name="electronic-circuit",amount=30},{type="item",name="pipe",amount=50}},results={{type="item",name=name,amount=1}}},
})

require("graphics.motion-data")



require("graphics.motion-data")

table.insert(data.raw.technology.railway.effects,{type="unlock-recipe",recipe=name})
