data:extend({
    {
      type = "assembling-machine",
      name = "space-elevator",
  
      icon = "__space-elevator__/graphics/icons/space-elevator.png",
      icon_size = 32,
  
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 1, result = "space-elevator"},
      max_health = 1000,
  
      collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  
      crafting_categories = {"crafting"},
      crafting_speed = 1,
  
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
      },
      energy_usage = "1MW",
  
      animation = {
        filename = "__base__/graphics/entity/steel-furnace/steel-furnace.png",
        width = 85,
        height = 87,
        frame_count = 1,
        shift = {0, 0}
      }
    }
  })