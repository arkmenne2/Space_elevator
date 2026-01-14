data:extend({
  {
    type = "assembling-machine",
    name = "space-elevator-platform",

    icon = "__base__/graphics/icons/storage-tank.png",
    icon_size = 64,

    flags = {"placeable-neutral", "player-creation"},
    max_health = 3000,

    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},   -- 5x5 footprint
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},

    crafting_categories = {"crafting"}, -- dummy category
    crafting_speed = 1,
    ingredient_count = 50,

    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "1MW",

    -- Inventory size
    module_slots = 0,
    allowed_effects = {},
    result_inventory_size = 50,

    -- Fluid handling
    fluid_boxes_off_when_no_fluid_recipe = false,

    fluid_boxes = {
      -- Input 1 (top-left)
      {
        production_type = "input",
        volume = 1000,
        pipe_connections = {
          { position = {-2, -2}, direction = defines.direction.north }
        }
      },

      -- Input 2 (top-right)
      {
        production_type = "input",
        volume = 1000,
        pipe_connections = {
          { position = {2, -2}, direction = defines.direction.north }
        }
      },

      -- Output 1 (bottom-left)
      {
        production_type = "output",
        volume = 1000,
        pipe_connections = {
          { position = {-2, 2}, direction = defines.direction.south }
        }
      },

      -- Output 2 (bottom-right)
      {
        production_type = "output",
        volume = 1000,
        pipe_connections = {
          { position = {2, 2}, direction = defines.direction.south }
        }
      }
    },

    animation = {
      filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
      width = 256,
      height = 256,
      frame_count = 1,
      scale = 1,
      shift = {0, 0}
    }
  }
})