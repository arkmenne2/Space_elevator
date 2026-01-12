data:extend({
    {
      type = "assembling-machine",
      name = "space-elevator",
  
      icon = "__base__/graphics/icons/rocket-silo.png",
      icon_size = 64,
  
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 2, result = "space-elevator"},
      max_health = 5000,
  
      collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
      selection_box = {{-5, -5}, {5, 5}},
  
      crafting_categories = {"crafting"},
      crafting_speed = 1,
      ingredient_count = 50,
  
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
      },
      energy_usage = "5GW",
  
      -- Factorio 2.0 field (correct place)
      fluid_boxes_off_when_no_fluid_recipe = false,
  
      -- ✅ FIXED: no extra nesting
      fluid_boxes = {
        {
          production_type = "input",
          volume = 1000,
          pipe_connections = {
            {
              position = {-4, -4},
              direction = defines.direction.north
            }
          }
        },
        {
          production_type = "input",
          volume = 1000,
          pipe_connections = {
            {
              position = {4, -4},
              direction = defines.direction.east
            }
          }
        },
        {
          production_type = "output",
          volume = 1000,
          pipe_connections = {
            {
              position = {-4, 4},
              direction = defines.direction.west
            }
          }
        },
        {
          production_type = "output",
          volume = 1000,
          pipe_connections = {
            {
              position = {4, 4},
              direction = defines.direction.south
            }
          }
        }
      },
  
      animation = {
        filename = "__base__/graphics/entity/rocket-silo/rocket-silo.png",
        width = 300,
        height = 300,
        frame_count = 1,
        shift = {0, -0.5}
      }
    }
  })
  