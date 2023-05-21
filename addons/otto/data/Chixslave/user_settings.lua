return {
    ["aspir"] = {
        ["casting_mp"] = 80,
        ["casts_all"] = true,
        ["enabled"] = false,
        ["tier"] = 3
    },
    ["assist"] = {
        ["enabled"] = true,
        ["master"] = "Twochix",
        ["slaves"] = {
            ["Chixslave"] = "backline",
            ["Fivechix"] = "backline",
            ["Fourchix"] = "frontline",
            ["Onechix"] = "frontline",
            ["Threechix"] = "backline"
        },
        ["yalm_fight_range"] = 3.5
    },
    ["dispel"] = {
        ["enabled"] = false
    },
    ["follow"] = {
        ["active"] = false,
        ["delay"] = 0.2,
        ["distance"] = 1,
        ["target"] = "Twochix"
    },
    ["healer"] = {
        ["activateOutdoors"] = true,
        ["deactivateIndoors"] = true,
        ["disable"] = {
            ["curaga"] = false,
            ["cure"] = false
        },
        ["enabled"] = true,
        ["healing"] = {
            ["curaga_min_targets"] = 5,
            ["max"] = {
                ["curaga"] = 5,
                ["cure"] = 6,
                ["waltz"] = 0,
                ["waltzga"] = 0
            },
            ["min"] = {
                ["curaga"] = 1,
                ["cure"] = 1,
                ["waltz"] = 3,
                ["waltzga"] = 2
            },
            ["mode"] = "cure",
            ["modega"] = "curaga"
        },
        ["ignoreTrusts"] = false
    },
    ["job"] = {},
    ["magic_burst"] = {
        ["cast_tier"] = 2,
        ["cast_type"] = "holy",
        ["change_target"] = true,
        ["check_day"] = true,
        ["check_weather"] = true,
        ["double_burst"] = false,
        ["enabled"] = false,
        ["gearswap"] = true,
        ["mp"] = 100,
        ["show_spell"] = false
    },
    ["pull"] = {
        ["enabled"] = false,
        ["with"] = ""
    },
    ["weaponskill"] = {
        ["enable"] = true,
        ["min_hp"] = 80,
        ["name"] = "Savage Blade",
        ["partner"] = "none"
    }
}
