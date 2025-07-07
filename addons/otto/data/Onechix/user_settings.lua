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
        ["should_engage"] = true,
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
    ["job"] = {
        ["bard"] = T{
            ["action"] = false,
            ["bard_settings"] = {
                ["aoe"] = {
                    ["p1"] = true,
                    ["p2"] = true,
                    ["p3"] = true,
                    ["p4"] = true,
                    ["p5"] = true,
                    ["party"] = true
                },
                ["clarion"] = true,
                ["debuffing"] = true,
                ["marcato"] = true,
                ["nightingale"] = true,
                ["pianissimo"] = true,
                ["recast"] = 20,
                ["soul_voice"] = true,
                ["troubadour"] = true
            },
            ["debuffs"] = L{
                ["n"] = 0
            },
            ["dummy"] = L{
                [1] = "Knight's Minne",
                ["n"] = 1
            },
            ["playlist"] = T{
                ["clear"] = L{
                    ["n"] = 0
                }
            },
            ["settings"] = T{
                ["dispels"] = true,
                ["enabled"] = false,
                ["fight_type"] = "xp",
                ["sleeps"] = true
            },
            ["song"] = T{
                ["Chixslave"] = L{
                    ["n"] = 0
                },
                ["Fivechix"] = L{
                    ["n"] = 0
                },
                ["Threechix"] = L{
                    ["n"] = 0
                },
                ["Twochix"] = L{
                    ["n"] = 0
                }
            },
            ["songs"] = L{
                ["n"] = 0
            }
        }
    },
    ["magic_burst"] = {
        ["cast_tier"] = 3,
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
        ["with"] = "/ma carnage elegy"
    },
    ["weaponskill"] = {
        ["enabled"] = false
    }
}
