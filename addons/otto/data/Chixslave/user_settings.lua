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
            ["Fivechix"] = "tank",
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
        ["activateOutdoors"] = true,
        ["deactivateIndoors"] = true,
        ["disable"] = {
            ["curaga"] = false,
            ["cure"] = false
        },
        ["enabled"] = false,
        ["healing"] = {
            ["curaga_min_targets"] = 3,
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
    ["job"] = {
        ["whitemage"] = T{
            ["buff"] = T{
                ["Chixslave"] = L{
                    [1] = "Haste",
                    [2] = "Reraise IV",
                    [3] = "Aurorastorm",
                    ["n"] = 3
                },
                ["Fivechix"] = L{
                    [1] = "Haste",
                    ["n"] = 1
                },
                ["Fourchix"] = L{
                    [1] = "Haste",
                    ["n"] = 1
                },
                ["Onechix"] = L{
                    [1] = "Haste",
                    ["n"] = 1
                },
                ["Threechix"] = L{
                    [1] = "Haste",
                    ["n"] = 1
                },
                ["Twochix"] = L{
                    [1] = "Haste",
                    ["n"] = 1
                }
            },
            ["buffs"] = L{
                [1] = "Protectra V",
                [2] = "Shellra V",
                [3] = "Auspice",
                ["n"] = 3
            },
            ["debuffs"] = L{
                [1] = "Dia II",
                [2] = "Slow",
                [3] = "Paralyze",
                [4] = "Silence",
                [5] = "Addle",
                ["n"] = 5
            },
            ["enabled"] = true,
            ["settings"] = T{
                ["auto_raise"] = true,
                ["blow_cooldowns"] = true,
                ["devotion"] = {
                    ["enabled"] = true,
                    ["target"] = "Fivechix"
                }
            }
        }
    },
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
        ["enabled"] = false
    }
}
