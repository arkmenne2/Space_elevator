-- data:extend({
--     {
--       type = "tile",
--       name = "space-elevator-floor",
--       needs_correction = false,
  
--       collision_mask = {
--         layers = {
--             ground_tile = true
--         }
--       },
  
--       walking_speed_modifier = 1.0,
--       layer = 70,
  
--       variants = {
--         main = {
--           {
--             picture = "__space-elevator__/graphics/tiles/space-dust.png",
--             count = 1,
--             size = 1
--           }
--         },
  
--         transition = {
--           overlay_layout = {
--             side = {
--               {
--                 picture = "__core__/graphics/empty.png",
--                 count = 1,
--                 size = 1
--               }
--             }
--           }
--         }
--       },
  
--       map_color = { r = 120, g = 110, b = 100 },
--       pollution_absorption_per_second = 0
--     }
--   })
  