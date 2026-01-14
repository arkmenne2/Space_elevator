-- Space Elevator control script
-- Factorio 2.0 safe version

local ELEVATOR_NAME = "space-elevator"
local PLATFORM_NAME = "space-elevator-platform"
local ORBIT_SURFACE_NAME = "space-elevator-orbit"

-- 10,000 items/sec @ 60 UPS
local MAX_TRANSFER_PER_TICK = 167

------------------------------------------------------------
-- Global initialization
------------------------------------------------------------

local function ensure_globals()
  if not global then global = {} end
  if not global.elevators then global.elevators = {} end
end

script.on_init(function()
  ensure_globals()
end)

script.on_configuration_changed(function()
  ensure_globals()
end)

------------------------------------------------------------
-- Orbit surface creation
------------------------------------------------------------

local function ensure_orbit_surface()
  local surface = game.surfaces[ORBIT_SURFACE_NAME]

  if surface then
    return surface
  end

  surface = game.create_surface(ORBIT_SURFACE_NAME, {
    width = 128,
    height = 128,
    peaceful_mode = true
  })

  if not surface then
    return nil
  end

  -- Lighting / visuals
  surface.daytime = 0.5
  surface.freeze_daytime = true
  surface.show_clouds = false
  surface.brightness_visual_weights = {1, 1, 1}

  -- Generate tiles once
  local tiles = {}

-- Full concrete surface (buildable)
for x = -64, 63 do
  for y = -64, 63 do
    tiles[#tiles + 1] = {
      name = "refined-concrete",
      position = {x, y}
    }
  end
end

surface.set_tiles(tiles)

  -- Concrete platform island
  local PLATFORM_RADIUS = 20
  for x = -PLATFORM_RADIUS, PLATFORM_RADIUS do
    for y = -PLATFORM_RADIUS, PLATFORM_RADIUS do
      tiles[#tiles + 1] = {
        name = "refined-concrete",
        position = {x, y}
      }
    end
  end

  surface.set_tiles(tiles)

  return surface
end

------------------------------------------------------------
-- Elevator placement
------------------------------------------------------------

local build_events = {
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive
}

script.on_event(build_events, function(event)
  ensure_globals()

  local entity = event.created_entity or event.entity
  if not (entity and entity.valid and entity.name == ELEVATOR_NAME) then
    return
  end

  local surface = ensure_orbit_surface()
  if not surface then
    game.print("ERROR: Orbit surface failed to initialize")
    return
  end

  local platform = surface.create_entity({
    name = PLATFORM_NAME,
    position = {0.5, 0.5},
    force = entity.force
  })

  if not platform then
    game.print("ERROR: Failed to create orbital platform")
  end

  global.elevators[entity.unit_number] = true
end)

------------------------------------------------------------
-- Item transfer (tick-based)
------------------------------------------------------------

script.on_nth_tick(1, function()
  ensure_globals()

  local orbit = game.surfaces[ORBIT_SURFACE_NAME]
  if not orbit then return end

  local platforms = orbit.find_entities_filtered { name = PLATFORM_NAME }
  local platform = platforms[1]
  if not (platform and platform.valid) then return end

  for unit_number, _ in pairs(global.elevators) do
    local elevator = game.get_entity_by_unit_number(unit_number)

    if not (elevator and elevator.valid) then
      global.elevators[unit_number] = nil
    else
      local inv_e = elevator.get_inventory(defines.inventory.assembling_machine_input)
      local inv_p = platform.get_inventory(defines.inventory.chest)

      if inv_e and inv_p then
        for name, count in pairs(inv_e.get_contents()) do
          local moved = math.min(count, MAX_TRANSFER_PER_TICK)
          local inserted = inv_p.insert({ name = name, count = moved })

          if inserted > 0 then
            inv_e.remove({ name = name, count = inserted })
          end
        end
      end
    end
  end
end)





-- local ELEVATOR_NAME = "space-elevator"
-- local PLATFORM_NAME = "space-elevator-platform"
-- local ORBIT_SURFACE_NAME = "space-elevator-orbit"

-- -- 10,000 items/sec @ 60 UPS
-- local MAX_TRANSFER_PER_TICK = 167


-- local function ensure_globals()
--   if not global then global = {} end
--   if not global.elevators then global.elevators = {} end
-- end

-- script.on_init(function()
--   ensure_globals()
-- end)

-- script.on_configuration_changed(function()
--   ensure_globals()
-- end)


-- -- Orbit surface

-- local function ensure_orbit_surface()
--   local surface = ensure_orbit_surface()
-- if not surface then
--   game.print("ERROR: Orbit surface failed to initialize")
--   return
-- end

--   -- Create surface if missing
--   if not surface then
--     surface = game.create_surface(ORBIT_SURFACE_NAME, {
--       width = 128,
--       height = 128,
--       peaceful_mode = true
--     })

--     -- Lighting / visuals
--     surface.daytime = 0.5
--     surface.freeze_daytime = true
--     surface.show_clouds = false
--     surface.brightness_visual_weights = {1, 1, 1}

--     -- Generate tiles ONLY on first creation
--     local tiles = {}

--     -- Void background
--     for x = -64, 63 do
--       for y = -64, 63 do
--         tiles[#tiles+1] = {
--           name = "out-of-map",
--           position = {x, y}
--         }
--       end
--     end

--     -- Concrete platform island
--     local PLATFORM_RADIUS = 20
--     for x = -PLATFORM_RADIUS, PLATFORM_RADIUS do
--       for y = -PLATFORM_RADIUS, PLATFORM_RADIUS do
--         tiles[#tiles+1] = {
--           name = "refined-concrete",
--           position = {x, y}
--         }
--       end
--     end

--     surface.set_tiles(tiles)
--   end

--   return surface
-- end




-- local build_events = {
--   defines.events.on_built_entity,
--   defines.events.on_robot_built_entity,
--   defines.events.script_raised_built,
--   defines.events.script_raised_revive
-- }

-- script.on_event(build_events, function(event)
--   ensure_globals()

--   local entity = event.created_entity or event.entity
--   if not (entity and entity.valid and entity.name == ELEVATOR_NAME) then return end


--   local tiles = {}
--   for x = -64, 63 do
--     for y = -64, 63 do
--       tiles[#tiles+1] = {
--         name = "out-of-map",
--         position = {x, y}
--       }
--     end
--   end
  
--   local PLATFORM_RADIUS = 20
  
--   for x = -PLATFORM_RADIUS, PLATFORM_RADIUS do
--     for y = -PLATFORM_RADIUS, PLATFORM_RADIUS do
--       tiles[#tiles+1] = {
--         name = "refined-concrete",
--         position = {x, y}
--       }
--     end
--   end
  
--   surface.set_tiles(tiles)



--   global.elevators[entity.unit_number] = true
-- end)


-- -- Item transfer (tick-based)


-- script.on_nth_tick(1, function()
--   ensure_globals()

--   local orbit = game.surfaces[ORBIT_SURFACE_NAME]
--   if not orbit then return end

--   local platforms = orbit.find_entities_filtered{name = PLATFORM_NAME}
--   local platform = platforms[1]
--   if not (platform and platform.valid) then return end

--   for unit_number, _ in pairs(global.elevators) do
--     local elevator = game.get_entity_by_unit_number(unit_number)
--     if not (elevator and elevator.valid) then
--       global.elevators[unit_number] = nil
--     else
--       local inv_e = elevator.get_inventory(defines.inventory.assembling_machine_input)
--       local inv_p = platform.get_inventory(defines.inventory.chest)

--       if inv_e and inv_p then
--         for name, count in pairs(inv_e.get_contents()) do
--           local moved = math.min(count, MAX_TRANSFER_PER_TICK)
--           local inserted = inv_p.insert({name = name, count = moved})
--           if inserted > 0 then
--             inv_e.remove({name = name, count = inserted})
--           end
--         end
--       end
--     end
--   end
-- end)