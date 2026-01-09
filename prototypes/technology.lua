data:extend({
    {
    type = "technology",
    name = "space-elevator",
    icon = "__space-elevator__/graphics/technology/space-elevator-tech.png",
    icon_size = 256,
    prerequisites = {"space-science-pack"},
    effects = {
    { type = "unlock-recipe", recipe = "space-elevator" }
    },
    unit = {
    count = 3000,
    ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"space-science-pack", 1}
    },
    time = 60
    }
    }
    })