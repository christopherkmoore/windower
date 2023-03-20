return {
    ["aspir"] = {
        ["casting_mp"] = 80,
        ["casts_all"] = true,
        ["enabled"] = false,
        ["tier"] = 1
    },
    ["assist"] = {
        ["enabled"] = true,
        ["master"] = "Twochix",
        ["slaves"] = {
            ["Chixslave"] = "backline",
            ["Fivechix"] = "frontline",
            ["Fourchix"] = "backline",
            ["Onechix"] = "frontline",
            ["Threechix"] = "backline"
        },
        ["yalm_fight_range"] = 3.5
    },
    ["dispel"] = {
        ["enabled"] = true
    },
    ["follow"] = {
        ["active"] = false,
        ["delay"] = 0.2,
        ["distance"] = 1,
        ["target"] = "Twochix"
    },
    ["healer"] = {
        ["activateOutdoors"] = false,
        ["deactivateIndoors"] = true,
        ["disable"] = {
            ["curaga"] = false,
            ["cure"] = true
        },
        ["enabled"] = false,
        ["healing"] = {
            ["curaga_min_targets"] = 3,
            ["max"] = {
                ["curaga"] = 0,
                ["cure"] = 4,
                ["waltz"] = 0,
                ["waltzga"] = 0
            },
            ["min"] = {
                ["curaga"] = 3,
                ["cure"] = 3,
                ["waltz"] = 3,
                ["waltzga"] = 2
            },
            ["mode"] = "cure",
            ["modega"] = "curaga"
        },
        ["ignoreTrusts"] = true
    },
    ["job"] = {},
    ["magic_burst"] = {
        ["cast_tier"] = 2,
        ["cast_type"] = "spell",
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
        ["enabled"] = true,
        ["min_hp"] = 80,
        ["name"] = "Savage Blade",
        ["partner"] = "none"
    }
}
