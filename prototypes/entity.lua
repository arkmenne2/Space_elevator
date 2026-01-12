data:extend({
  icon_size = 64,
  
  
  flags = {"placeable-neutral", "player-creation"},
  minable = {mining_time = 2, result = "space-elevator"},
  max_health = 5000,
  
  
  collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
  selection_box = {{-5, -5}, {5, 5}},
  
  
  fluid_boxes = {
  {
  production_type = "input",
  base_area = 1000,
  pipe_connections = {{ position = {-5, -5} }}
  },
  {
  production_type = "input",
  base_area = 1000,
  pipe_connections = {{ position = {5, -5} }}
  },
  {
  production_type = "input",
  base_area = 1000,
  pipe_connections = {{ position = {-5, 5} }}
  },
  {
  production_type = "input",
  base_area = 1000,
  pipe_connections = {{ position = {5, 5} }}
  },
  off_when_no_fluid_recipe = false
  },
  
  
  energy_source = {
  type = "electric",
  usage_priority = "secondary-input"
  },
  energy_usage = "5GW",
  
  
  crafting_categories = {"space-elevator-transfer"},
  crafting_speed = 10000, -- items per second placeholder
  
  
  ingredient_count = 50,
  
  
  animation = {
  layers = {
  {
  filename = "__base__/graphics/entity/rocket-silo/rocket-silo.png",
  width = 300,
  height = 300,
  frame_count = 1,
  shift = {0, -0.5}
  }
  }
  }
  }
  })