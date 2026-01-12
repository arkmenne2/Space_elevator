

local ELEVATOR_NAME = "space-elevator"
local PLATFORM_NAME = "space-elevator-platform"
local ORBIT_SURFACE_NAME = "space-elevator-orbit"


-- 10,000 items/sec at 60 UPS
local MAX_TRANSFER_PER_TICK = 167


local function init_globals()
global = global or {}
global.elevators = global.elevators or {}
end


script.on_init(init_globals)
script.on_configuration_changed(init_globals)


local function ensure_orbit_surface()
if game.surfaces[ORBIT_SURFACE_NAME] then return end


game.create_surface(ORBIT_SURFACE_NAME, {
width = 64,
height = 64,
starting_area = "none",
peaceful_mode = true
})
end


local function spawn_platform(elevator)
ensure_orbit_surface()
local surface = game.surfaces[ORBIT_SURFACE_NAME]


local platform = surface.create_entity({
name = PLATFORM_NAME,
position = {0, 0},
force = elevator.force
})


global.elevators[elevator.unit_number] = true
end


script.on_event(defines.events.on_built_entity, function(event)
local entity = event.created_entity
if entity and entity.valid and entity.name == ELEVATOR_NAME then
spawn_platform(entity)
end
end)


script.on_nth_tick(1, function()
for unit_number, _ in pairs(global.elevators) do
local elevator = game.get_entity_by_unit_number(unit_number)
if not (elevator and elevator.valid) then
global.elevators[unit_number] = nil
else
local orbit = game.surfaces[ORBIT_SURFACE_NAME]
if orbit then
local platforms = orbit.find_entities_filtered{name = PLATFORM_NAME}
local platform = platforms[1]
if platform and platform.valid then
local inv_e = elevator.get_inventory(defines.inventory.assembling_machine_input)
local inv_p = platform.get_inventory(defines.inventory.chest)


if inv_e and inv_p then
for name, count in pairs(inv_e.get_contents()) do
local moved = math.min(count, MAX_TRANSFER_PER_TICK)
local inserted = inv_p.insert({name = name, count = moved})
if inserted > 0 then
inv_e.remove({name = name, count = inserted})
end
end
end
end
end
end
end
end)