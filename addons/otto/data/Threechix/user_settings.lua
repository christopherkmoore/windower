return {
    ["aspir"] = {
        ["casting_mp"] = 80,
        ["casts_all"] = true,
        ["enabled"] = true,
        ["tier"] = 3
    },
    ["assist"] = {
        ["enabled"] = true,
        ["fight_style"] = "free",
        ["master"] = "Twochix",
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
            ["mode"] = "cure",
            ["modega"] = "curaga"
        },
        ["ignoreTrusts"] = true
    },
    ["job"] = {
        ["blackmage"] = {
            ["cooldowns"] = true,
            ["enabled"] = false
        },
        ["geomancer"] = {
            ["bubble"] = {
                ["distance"] = 8,
                ["target"] = "Twochix"
            },
            ["cooldowns"] = false,
            ["enabled"] = true,
            ["entrust"] = {
                ["indi"] = "Indi-Precision",
                ["target"] = "Twochix"
            },
            ["geo"] = "Geo-Frailty",
            ["indi"] = "Indi-Fury"
        }
    },
    ["magic_burst"] = {
        ["cast_tier"] = 4,
        ["cast_type"] = "spell",
        ["change_target"] = true,
        ["check_day"] = true,
        ["check_weather"] = true,
        ["double_burst"] = true,
        ["enabled"] = true,
        ["gearswap"] = true,
        ["mp"] = 100,
        ["nuke_wall_offest"] = 1,
        ["show_spell"] = false
    },
    ["pull"] = {
        ["enabled"] = false,
        ["with"] = "/ma Poison"
    },
    ["weaponskill"] = {
        ["close"] = true,
        ["enabled"] = false
    }
}
