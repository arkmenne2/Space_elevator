script.on_init(function()
    global.elevators = {}
    end)
    
    
    script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if entity and entity.name == "space-elevator" then
    table.insert(global.elevators, entity)
    end
    end)