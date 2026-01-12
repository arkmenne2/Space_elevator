
local function init_globals()
    global = global or {}
    global.elevators = global.elevators or {}
  end
  
  script.on_init(init_globals)
  script.on_configuration_changed(init_globals)
  
  script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if not (entity and entity.valid and entity.name == "space-elevator") then
      return
    end
  
    global.elevators[entity.unit_number] = true
  end)
  
  script.on_event({
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_entity_died
  }, function(event)
    local entity = event.entity
    if entity and entity.name == "space-elevator" then
      global.elevators[entity.unit_number] = nil
    end
  end)