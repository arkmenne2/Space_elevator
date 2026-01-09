local space_elevator = {
    type = "assembling-machine",
    name = "space-elevator",
    icon = "__space-elevator__/graphics/icons/space-elevator.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 2, result = "space-elevator"},
    max_health = 5000,
    corpse = "big-remnants",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    crafting_categories = {"space-elevator"},
    crafting_speed = 1,
    energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions = 0
    },
    energy_usage = "50MW",
    animation = {
    layers = {
    {
    filename = "__space-elevator__/graphics/entity/space-elevator-placeholder.png",
    width = 320,
    height = 320,
    frame_count = 1,
    shift = {0, 0}
    }
    }
    }
    }
    
    
    data:extend({ space_elevator })