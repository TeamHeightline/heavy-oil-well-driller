local M={}
local function debit(car, amount)
  local burner=car.burner
  local paid=0
  while paid<amount do
    if burner.remaining_burning_fuel<=0 then
      local old=burner.currently_burning
      if old then
        local burnt=old.name.burnt_result
        if burnt and burner.burnt_result_inventory.get_insertable_count(burnt.name)<1 then break end
        if burnt then burner.burnt_result_inventory.insert({name=burnt.name,count=1,quality=old.quality.name}) end
        burner.currently_burning=nil
      end
      local found=false
      for i=1,#burner.inventory do
        local stack=burner.inventory[i]
        if stack.valid_for_read and stack.prototype.fuel_value>0 then
          local name,quality,value=stack.name,stack.quality.name,stack.prototype.fuel_value
          stack.count=stack.count-1
          burner.currently_burning={name=name,quality=quality}
          burner.remaining_burning_fuel=value
          found=true;break
        end
      end
      if not found then break end
    end
    local use=math.min(amount-paid,burner.remaining_burning_fuel)
    burner.remaining_burning_fuel=burner.remaining_burning_fuel-use
    paid=paid+use
  end
  return paid
end

M.debit=debit
return M
