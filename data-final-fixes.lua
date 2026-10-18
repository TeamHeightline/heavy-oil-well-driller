-- Synchronise the optional assembly-plant recipe without a mandatory dependency.
local name=require('machine-config').name
local factory='factory-heavy-construction-machinery-plant-'..name
local category='heavy-construction-machinery-plant'
if data.raw['recipe-category'][category] then
  local copy=table.deepcopy(data.raw.recipe[name])
  copy.name=factory;copy.category=category;copy.auto_recycle=false
  copy.localised_name={'item-name.'..name}
  data:extend{copy}
end
-- Exactly one unlock per recipe, always at the same milestone as locomotives.
for _,tech in pairs(data.raw.technology) do
  local effects={}
  for _,effect in ipairs(tech.effects or {}) do
    if effect.type~='unlock-recipe' or effect.recipe~=name and effect.recipe~=factory then
      effects[#effects+1]=effect
    end
  end
  tech.effects=effects
end
local railway=data.raw.technology.railway
railway.effects=railway.effects or {}
railway.effects[#railway.effects+1]={type='unlock-recipe',recipe=name}
if data.raw.recipe[factory] then railway.effects[#railway.effects+1]={type='unlock-recipe',recipe=factory} end
