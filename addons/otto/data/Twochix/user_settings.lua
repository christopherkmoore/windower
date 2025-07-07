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
        ["should_engage"] = false,
        ["slaves"] = {
            ["Chixslave"] = "backline",
            ["Fivechix"] = "frontline",
            ["Fourchix"] = "frontline",
            ["Onechix"] = "backline",
            ["Threechix"] = "backline",
            ["Twochix"] = "frontline"
        },
        ["yalm_fight_range"] = 3.5
    },
    ["debug"] = {
        ["enabled"] = false
    },
    ["dispel"] = {
        ["enabled"] = false
    },
    ["follow"] = {
        ["active"] = false,
        ["delay"] = 0.2,
        ["distance"] = 5,
        ["target"] = "Twochix"
    },
    ["healer"] = {
        ["activateOutdoors"] = false,
        ["deactivateIndoors"] = true,
        ["disable"] = {
            ["curaga"] = false,
            ["cure"] = true
        },
        ["enabled"] = true,
        ["healing"] = {
            ["curaga_min_targets"] = 3,
            ["max"] = {
                ["curaga"] = 0,
                ["cure"] = 0,
                ["waltz"] = 0,
                ["waltzga"] = 0
            },
            ["min"] = {
                ["curaga"] = 3,
                ["cure"] = 3,
                ["waltz"] = 3,
                ["waltzga"] = 2
            },
            ["mode"] = "waltz",
            ["modega"] = "waltzga"
        },
        ["ignoreTrusts"] = true
    },
    ["job"] = {
        ["blackmage"] = {
            ["cooldowns"] = true,
            ["enabled"] = false
        }
    },
    ["magic_burst"] = {
        ["cast_tier"] = 2,
        ["cast_type"] = "none",
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
        ["enabled"] = false
    }
}
