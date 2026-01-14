local ELEVATOR_NAME = "space-elevator"
local PLATFORM_NAME = "space-elevator-platform"
local ORBIT_SURFACE_NAME = "space-elevator-orbit"

-- Throughput
local MAX_TRANSFER_PER_TICK = 167          -- ~10k items/sec @ 60 UPS
local FLUID_TRANSFER_PER_TICK = 50

------------------------------------------------------------
-- Globals
------------------------------------------------------------

local function ensure_globals()
  global = global or {}
  global.elevators = global.elevators or {}
  global.ui_target = global.ui_target or {}
end

script.on_init(function()
  ensure_globals()
end)

script.on_configuration_changed(function()
  ensure_globals()
end)

------------------------------------------------------------
-- Orbit surface creation + lighting + forced loading
------------------------------------------------------------

local function ensure_orbit_surface()
  local surface = game.surfaces[ORBIT_SURFACE_NAME]

  if not surface then
    surface = game.create_surface(ORBIT_SURFACE_NAME, {
      width = 128,
      height = 128,
      peaceful_mode = true
    })
    if not surface then return nil end

    -- Lighting (kill the eternal darkness)
    surface.daytime = 0.5
    surface.freeze_daytime = true
    surface.show_clouds = false
    surface.brightness_visual_weights = {1, 1, 1}
    surface.min_brightness = 1

    -- Buildable concrete platform
    local tiles = {}
    for x = -64, 63 do
      for y = -64, 63 do
        tiles[#tiles + 1] = {
          name = "refined-concrete",
          position = {x, y}
        }
      end
    end
    surface.set_tiles(tiles)
  end

  -- Force chunks to exist + stay visible
  surface.request_to_generate_chunks({0, 0}, 4)
  surface.force_generate_chunk_requests()

  local force = game.forces.player
  if force then
    force.chart(surface, {{-128, -128}, {128, 128}})
  end

  return surface
end

------------------------------------------------------------
-- Hidden radar (keeps surface alive like a watchdog)
------------------------------------------------------------

local function ensure_orbit_radar(surface)
  if not surface then return end

  local radars = surface.find_entities_filtered { name = "radar" }
  if #radars > 0 then return end

  local radar = surface.create_entity({
    name = "radar",
    position = {0, 0},
    force = game.forces.player
  })

  if radar then
    radar.destructible = false
    radar.operable = false
    radar.minable = false
    radar.active = true
  end
end

------------------------------------------------------------
-- Fluid transfer (safe API usage)
------------------------------------------------------------

local function move_fluid(src_entity, src_index, dst_entity, dst_index, max_amount)
  local src = src_entity.fluidbox[src_index]
  if not src then return end

  local dst = dst_entity.fluidbox[dst_index]

  -- Prevent mixing fluids
  if dst and dst.name and dst.name ~= src.name then return end

  local amount = math.min(src.amount or 0, max_amount)
  if amount <= 0 then return end

  -- Remove from source
  local removed = src_entity.remove_fluid{
    name = src.name,
    amount = amount
  }
  if removed <= 0 then return end

  -- Insert into destination
  local inserted = dst_entity.insert_fluid{
    name = src.name,
    amount = removed,
    temperature = src.temperature
  }

  -- Return overflow if destination was full
  if inserted < removed then
    src_entity.insert_fluid{
      name = src.name,
      amount = removed - inserted,
      temperature = src.temperature
    }
  end
end


local function sync_fluids(elevator, platform)
  if not (elevator and platform) then return end

  -- Ports 1–2: Elevator → Platform
  move_fluid(elevator, 1, platform, 1, FLUID_TRANSFER_PER_TICK)
  move_fluid(elevator, 2, platform, 2, FLUID_TRANSFER_PER_TICK)

  -- Ports 3–4: Platform → Elevator
  move_fluid(platform, 3, elevator, 3, FLUID_TRANSFER_PER_TICK)
  move_fluid(platform, 4, elevator, 4, FLUID_TRANSFER_PER_TICK)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------

local function destroy_ui(player)
  if player.gui.screen.space_elevator_ui then
    player.gui.screen.space_elevator_ui.destroy()
  end
end


local function create_ui(player, elevator)
  destroy_ui(player)

  local frame = player.gui.screen.add{
    type = "frame",
    name = "space_elevator_ui",
    caption = "Space Elevator Control",
    direction = "vertical"
  }
  frame.auto_center = true

  frame.add{ type = "label", caption = "Elevator ID: " .. elevator.unit_number }

  frame.add{
    type = "label",
    name = "status_label",
    caption = "Status: Connected"
  }

  local fluid_table = frame.add{
    type = "table",
    name = "fluid_table",
    column_count = 2
  }

  for i = 1, 4 do
    fluid_table.add{ type = "label", caption = "Port " .. i .. ":" }
    fluid_table.add{
      type = "label",
      name = "fluid_" .. i,
      caption = "Loading..."
    }
  end

  player.opened = frame
  global.ui_target[player.index] = elevator.unit_number
end


local function update_ui(player, elevator, platform)
  local frame = player.gui.screen.space_elevator_ui
  if not frame then return end

  local table = frame.fluid_table
  if not table then return end

  for i = 1, 4 do
    local label = table["fluid_" .. i]
    if not label then goto continue end

    if not platform or not platform.valid then
      label.caption = "No platform"
      goto continue
    end

    local box = platform.fluidbox[i]

    if box and box.name then
      label.caption = box.name .. ": " .. math.floor(box.amount)
    elseif box then
      label.caption = "(Empty box)"
    else
      label.caption = "(No fluidbox)"
    end

    ::continue::
  end
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
  if not (entity and entity.valid and entity.name == ELEVATOR_NAME) then return end

  local surface = ensure_orbit_surface()
  if not surface then return end

  ensure_orbit_radar(surface)

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
-- Open UI when clicking elevator
------------------------------------------------------------

local ELEVATOR_NAME = "space-elevator"
local PLATFORM_NAME = "space-elevator-platform"
local ORBIT_SURFACE_NAME = "space-elevator-orbit"

-- Throughput
local MAX_TRANSFER_PER_TICK = 167          -- ~10k items/sec @ 60 UPS
local FLUID_TRANSFER_PER_TICK = 50

------------------------------------------------------------
-- Globals
------------------------------------------------------------

local function ensure_globals()
  global = global or {}
  global.elevators = global.elevators or {}
  global.ui_target = global.ui_target or {}
end

script.on_init(function()
  ensure_globals()
end)

script.on_configuration_changed(function()
  ensure_globals()
end)

------------------------------------------------------------
-- Orbit surface creation + lighting + forced loading
------------------------------------------------------------

local function ensure_orbit_surface()
  local surface = game.surfaces[ORBIT_SURFACE_NAME]

  if not surface then
    surface = game.create_surface(ORBIT_SURFACE_NAME, {
      width = 128,
      height = 128,
      peaceful_mode = true
    })
    if not surface then return nil end

    -- Lighting (kill the eternal darkness)
    surface.daytime = 0.5
    surface.freeze_daytime = true
    surface.show_clouds = false
    surface.brightness_visual_weights = {1, 1, 1}
    surface.min_brightness = 1

    -- Buildable concrete platform
    local tiles = {}
    for x = -64, 63 do
      for y = -64, 63 do
        tiles[#tiles + 1] = {
          name = "refined-concrete",
          position = {x, y}
        }
      end
    end
    surface.set_tiles(tiles)
  end

  -- Force chunks to exist + stay visible
  surface.request_to_generate_chunks({0, 0}, 4)
  surface.force_generate_chunk_requests()

  local force = game.forces.player
  if force then
    force.chart(surface, {{-128, -128}, {128, 128}})
  end

  return surface
end

------------------------------------------------------------
-- Hidden radar (keeps surface alive like a watchdog)
------------------------------------------------------------

local function ensure_orbit_radar(surface)
  if not surface then return end

  local radars = surface.find_entities_filtered { name = "radar" }
  if #radars > 0 then return end

  local radar = surface.create_entity({
    name = "radar",
    position = {0, 0},
    force = game.forces.player
  })

  if radar then
    radar.destructible = false
    radar.operable = false
    radar.minable = false
    radar.active = true
  end
end

------------------------------------------------------------
-- Fluid transfer (safe API usage)
------------------------------------------------------------

local function move_fluid(src_entity, src_index, dst_entity, dst_index, max_amount)
  local src = src_entity.fluidbox[src_index]
  if not src then return end

  local dst = dst_entity.fluidbox[dst_index]

  -- Prevent mixing fluids
  if dst and dst.name and dst.name ~= src.name then return end

  local amount = math.min(src.amount or 0, max_amount)
  if amount <= 0 then return end

  -- Remove from source
  local removed = src_entity.remove_fluid{
    name = src.name,
    amount = amount
  }
  if removed <= 0 then return end

  -- Insert into destination
  local inserted = dst_entity.insert_fluid{
    name = src.name,
    amount = removed,
    temperature = src.temperature
  }

  -- Return overflow if destination was full
  if inserted < removed then
    src_entity.insert_fluid{
      name = src.name,
      amount = removed - inserted,
      temperature = src.temperature
    }
  end
end


local function sync_fluids(elevator, platform)
  if not (elevator and platform) then return end

  -- Ports 1–2: Elevator → Platform
  move_fluid(elevator, 1, platform, 1, FLUID_TRANSFER_PER_TICK)
  move_fluid(elevator, 2, platform, 2, FLUID_TRANSFER_PER_TICK)

  -- Ports 3–4: Platform → Elevator
  move_fluid(platform, 3, elevator, 3, FLUID_TRANSFER_PER_TICK)
  move_fluid(platform, 4, elevator, 4, FLUID_TRANSFER_PER_TICK)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------

local function destroy_ui(player)
  if player.gui.screen.space_elevator_ui then
    player.gui.screen.space_elevator_ui.destroy()
  end
end


local function create_ui(player, elevator)
  destroy_ui(player)

  local frame = player.gui.screen.add{
    type = "frame",
    name = "space_elevator_ui",
    caption = "Space Elevator Control",
    direction = "vertical"
  }
  frame.auto_center = true

  frame.add{ type = "label", caption = "Elevator ID: " .. elevator.unit_number }

  frame.add{
    type = "label",
    name = "status_label",
    caption = "Status: Connected"
  }

  local fluid_table = frame.add{
    type = "table",
    name = "fluid_table",
    column_count = 2
  }

  for i = 1, 4 do
    fluid_table.add{ type = "label", caption = "Port " .. i .. ":" }
    fluid_table.add{
      type = "label",
      name = "fluid_" .. i,
      caption = "Loading..."
    }
  end

  player.opened = frame
  global.ui_target[player.index] = elevator.unit_number
end


local function update_ui(player, elevator, platform)
  local frame = player.gui.screen.space_elevator_ui
  if not frame then return end

  local table = frame.fluid_table
  if not table then return end

  for i = 1, 4 do
    local label = table["fluid_" .. i]
    if not label then goto continue end

    if not platform or not platform.valid then
      label.caption = "No platform"
      goto continue
    end

    local box = platform.fluidbox[i]

    if box and box.name then
      label.caption = box.name .. ": " .. math.floor(box.amount)
    elseif box then
      label.caption = "(Empty box)"
    else
      label.caption = "(No fluidbox)"
    end

    ::continue::
  end
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
  if not (entity and entity.valid and entity.name == ELEVATOR_NAME) then return end

  local surface = ensure_orbit_surface()
  if not surface then return end

  ensure_orbit_radar(surface)

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
-- Open UI when clicking elevator
------------------------------------------------------------

script.on_event({ defines.events.on_player_opened }, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local entity = event.entity
  if entity and entity.valid and entity.name == ELEVATOR_NAME then
    create_ui(player, entity)
  else
    destroy_ui(player)
  end
end)

------------------------------------------------------------
-- Cleanup when UI closes
------------------------------------------------------------

script.on_event({ defines.events.on_gui_closed }, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  global.ui_target[player.index] = nil
  destroy_ui(player)
end)

------------------------------------------------------------
-- Main tick loop
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
      ------------------------------------------------
      -- Item transfer
      ------------------------------------------------
      local inv_e = elevator.get_inventory(defines.inventory.assembling_machine_input)
      local inv_p = platform.get_inventory(defines.inventory.assembling_machine_input)

      if inv_e and inv_p then
        for name, count in pairs(inv_e.get_contents()) do
          local moved = math.min(count, MAX_TRANSFER_PER_TICK)
          local inserted = inv_p.insert({ name = name, count = moved })

          if inserted > 0 then
            inv_e.remove({ name = name, count = inserted })
          end
        end
      end

      ------------------------------------------------
      -- Fluid transfer
      ------------------------------------------------
      sync_fluids(elevator, platform)

      ------------------------------------------------
      -- UI refresh
      ------------------------------------------------
      for _, player in pairs(game.connected_players) do
        local unit = global.ui_target[player.index]
        if unit then
          local elev = game.get_entity_by_unit_number(unit)
          if elev and elev.valid and player.gui.screen.space_elevator_ui then
            update_ui(player, elev, platform)
          end
        end
      end
    end
  end
end)

------------------------------------------------------------
-- Keep orbit surface alive
------------------------------------------------------------

script.on_nth_tick(600, function()
  local surface = game.surfaces[ORBIT_SURFACE_NAME]
  if not surface then return end

  surface.request_to_generate_chunks({0, 0}, 4)
  surface.force_generate_chunk_requests()

  local force = game.forces.player
  if force then
    force.chart(surface, {{-128, -128}, {128, 128}})
  end
end)

------------------------------------------------------------
-- Cleanup when UI closes
------------------------------------------------------------

script.on_event({ defines.events.on_gui_closed }, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  global.ui_target[player.index] = nil
  destroy_ui(player)
end)

------------------------------------------------------------
-- Main tick loop
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
      ------------------------------------------------
      -- Item transfer
      ------------------------------------------------
      local inv_e = elevator.get_inventory(defines.inventory.assembling_machine_input)
      local inv_p = platform.get_inventory(defines.inventory.assembling_machine_input)

      if inv_e and inv_p then
        for name, count in pairs(inv_e.get_contents()) do
          local moved = math.min(count, MAX_TRANSFER_PER_TICK)
          local inserted = inv_p.insert({ name = name, count = moved })

          if inserted > 0 then
            inv_e.remove({ name = name, count = inserted })
          end
        end
      end

      ------------------------------------------------
      -- Fluid transfer
      ------------------------------------------------
      sync_fluids(elevator, platform)

      ------------------------------------------------
      -- UI refresh
      ------------------------------------------------
      for _, player in pairs(game.connected_players) do
        local unit = global.ui_target[player.index]
        if unit then
          local elev = game.get_entity_by_unit_number(unit)
          if elev and elev.valid and player.gui.screen.space_elevator_ui then
            update_ui(player, elev, platform)
          end
        end
      end
    end
  end
end)

------------------------------------------------------------
-- Keep orbit surface alive
------------------------------------------------------------

script.on_nth_tick(600, function()
  local surface = game.surfaces[ORBIT_SURFACE_NAME]
  if not surface then return end

  surface.request_to_generate_chunks({0, 0}, 4)
  surface.force_generate_chunk_requests()

  local force = game.forces.player
  if force then
    force.chart(surface, {{-128, -128}, {128, 128}})
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