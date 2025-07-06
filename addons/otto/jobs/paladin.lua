-- otto pld by TC
-- TODO 
-- add a whm mp check and enable disable healer at certain mpp levels
-- cover for allies taking damage combine with movement?

local paladin = { }
local player = windower.ffxi.get_player()
paladin.timers = {buffs={}}

-- job check ticks
paladin.check_interval = 0.4
paladin.delay = 4
paladin.counter = 0

paladin.bufflist = {
    [855] = {id=855,en="Enlight II",ja="エンライトII",cast_time=3,duration=180,element=6,icon_id=337,icon_id_nq=6,levels={[7]=100},mp_cost=36,prefix="/magic",range=0,recast=30,recast_id=855,requirements=0,skill=32,status=274,targets=1,type="WhiteMagic"},
    [97] = {id=97,en="Reprisal",ja="リアクト",cast_time=1,duration=60,element=6,icon_id=196,icon_id_nq=6,levels={[7]=61},mp_cost=24,prefix="/magic",range=0,recast=52,recast_id=97,requirements=0,skill=34,status=403,targets=1,type="WhiteMagic"},
    -- [51] = {id=51,en="Shell IV",ja="シェルIV",cast_time=1.75,duration=1800,element=6,icon_id=130,icon_id_nq=6,levels={[3]=68,[5]=68,[7]=80,[20]=71,[22]=70},mp_cost=75,overwrites={48,49,50},prefix="/magic",range=12,recast=5.75,recast_id=51,requirements=1,skill=34,status=41,targets=29,type="WhiteMagic"},
    -- [52] = {id=52,en="Shell V",ja="シェルV",cast_time=2,duration=1800,element=6,icon_id=132,icon_id_nq=6,levels={[3]=76,[5]=87,[20]=90,[22]=90},mp_cost=93,overwrites={48,49,50,51},prefix="/magic",range=12,recast=6,recast_id=52,requirements=1,skill=34,status=41,targets=29,type="WhiteMagic"},
    -- [47] = {id=47,en="Protect V",ja="プロテスV",cast_time=2,duration=1800,element=6,icon_id=122,icon_id_nq=6,levels={[3]=76,[5]=77,[7]=90,[20]=80},mp_cost=84,overwrites={43,44,45,46},prefix="/magic",range=12,recast=6,recast_id=47,requirements=1,skill=34,status=40,targets=29,type="WhiteMagic"},
    [476] = {id=476,en="Crusade",ja="クルセード",cast_time=3,duration=300,element=7,icon_id=552,icon_id_nq=7,levels={[7]=88,[22]=88},mp_cost=18,prefix="/magic",range=12,recast=10,recast_id=476,requirements=0,skill=34,status=289,targets=1,type="WhiteMagic"},
    [106] = {id=106,en="Phalanx",ja="ファランクス",cast_time=3,duration=180,element=6,icon_id=186,icon_id_nq=6,levels={[5]=33,[7]=77,[22]=68},mp_cost=21,prefix="/magic",range=12,recast=10,recast_id=106,requirements=1,skill=34,status=116,targets=1,type="WhiteMagic"}
}
paladin.debufflist = {
    [112] = {id=112,en="Flash",ja="フラッシュ",cast_time=0.5,element=6,icon_id=158,icon_id_nq=6,levels={[3]=45,[7]=37,[22]=45},mp_cost=25,prefix="/magic",range=12,recast=45,recast_id=112,requirements=0,skill=32,targets=32,type="WhiteMagic"}
}

-- make this configurable when I need for content that uses things like holy hircle or fealty
paladin.jalist = { 
    [46] = {id=46,en="Shield Bash",ja="シールドバッシュ",element=4,icon_id=406,mp_cost=0,prefix="/jobability",range=2,recast_id=73,targets=32,tp_cost=0,type="JobAbility"},
    -- [394] = {id=394,en="Majesty",ja="マジェスティ",duration=180,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=150,status=621,targets=1,tp_cost=0,type="JobAbility"},
    [92] = {id=92,en="Rampart",ja="ランパート",duration=30,element=3,icon_id=409,mp_cost=0,prefix="/jobability",range=0,recast_id=77,status=93,targets=1,tp_cost=0,type="JobAbility"},
    [48] = {id=48,en="Sentinel",ja="センチネル",duration=30,element=3,icon_id=407,mp_cost=0,prefix="/jobability",range=0,recast_id=75,status=62,targets=1,tp_cost=0,type="JobAbility"},
    [278] = {id=278,en="Palisade",ja="パリセード",duration=60,element=6,icon_id=413,mp_cost=0,prefix="/jobability",range=0,recast_id=42,status=478,targets=1,tp_cost=0,type="JobAbility"},
    [329] = {id=329,en="Intervene",ja="インターヴィーン",duration=30,element=6,icon_id=1070,mp_cost=0,prefix="/jobability",range=2,recast_id=254,status=496,targets=32,tp_cost=0,type="JobAbility"},

    -- situational, increases resistance to enfeebling magic
    -- [157] = {id=157,en="Fealty",ja="フィールティ",duration=60,element=6,icon_id=413,mp_cost=0,prefix="/jobability",range=0,recast_id=78,status=344,targets=1,tp_cost=0,type="JobAbility"},

    -- sitautional, good for undead fights
    -- [277] = {id=277,en="Sepulcher",ja="セプルカー",duration=180,element=6,icon_id=411,mp_cost=0,prefix="/jobability",range=8,recast_id=41,status=463,targets=32,tp_cost=0,type="JobAbility"},
    -- [47] = {id=47,en="Holy Circle",ja="ホーリーサークル",duration=180,element=6,icon_id=405,mp_cost=0,prefix="/jobability",range=0,recast_id=74,status=74,targets=1,tp_cost=0,type="JobAbility"},
}

function paladin.init()
    local defaults = { enabled = true }
    defaults.enabled = true
    defaults.cooldowns = true

    if user_settings.job.paladin == nil then
        user_settings.job.paladin = defaults
        user_settings:save()
    end
    paladin.create_bufflist()

    paladin.check_pld:loop(paladin.check_interval)
end

function paladin.deinit() 
    -- empty for now I guess...
end

function paladin.create_bufflist()

    if player.sub_job == "BLU" then
        -- paladin.bufflist[547] = {id=547,en="Cocoon",ja="コクーン",blu_points=1,cast_time=1.75,duration=90,element=15,icon_id=-1,icon_id_nq=59,levels={[16]=8},mp_cost=10,prefix="/magic",range=0,recast=60,recast_id=547,requirements=0,skill=43,status=93,targets=1,type="BlueMagic"}
        paladin.debufflist[605] = {id=605,en="Geist Wall",ja="ガイストウォール",blu_points=3,cast_time=3,element=7,icon_id=-1,icon_id_nq=63,levels={[16]=46},mp_cost=35,prefix="/magic",range=4,recast=30,recast_id=605,requirements=0,skill=43,targets=32,type="BlueMagic"}
        -- paladin.debufflist[584] = {id=584,en="Sheep Song",ja="シープソング",blu_points=2,cast_time=3,duration=60,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=16},mp_cost=22,prefix="/magic",range=4,recast=60,recast_id=584,requirements=0,skill=43,status=2,targets=32,type="BlueMagic"}
        -- paladin.debufflist[592] = {id=592,en="Blank Gaze",ja="ブランクゲイズ",blu_points=2,cast_time=3,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=38},mp_cost=25,prefix="/magic",range=9,recast=10,recast_id=592,requirements=0,skill=43,targets=32,type="BlueMagic"}
    end
end 


-- The pld main function.
function paladin.check_pld()
    if not user_settings.job.paladin.enabled then return end
    paladin.counter = paladin.counter + paladin.check_interval

    if paladin.counter >= paladin.delay then
        paladin.counter = 0
        paladin.delay = paladin.check_interval

        local target = windower.ffxi.get_mob_by_target('t')

        if not (target ~= nil and target.valid_target and target.claim_id > 0 and target.is_npc) then return end
        if actor:is_moving() then return end 
        
        local buffs = S(player.buffs)
        local sleep = {id=253,en="Sleep",ja="スリプル",cast_time=2.5,duration=60,element=7,icon_id=310,icon_id_nq=15,levels={[4]=20,[5]=25,[8]=30,[20]=30,[21]=35},mp_cost=19,prefix="/magic",range=12,recast=30,recast_id=253,requirements=6,skill=35,status=2,targets=32,type="BlackMagic"}

        -- wake up sleeping allies
        for _, ally in pairs(otto.fight.my_allies) do
            if ally.debuffs['sleep'] then
                local cure = res.spells[1]
                local pre_action = res.job_abilities[394] -- use majesty for buffed cure

                local delay = otto.cast.spell_with_pre_action(cure, pre_action, ally.name)
                paladin.delay = delay
                return
            end 
        end

        for _, ja in pairs(paladin.jalist) do
            local recast = windower.ffxi.get_ability_recasts()[ja.recast_id]

            if recast == 0 and target ~= nil then
                if ja.range == 0 then
                    local delay = otto.cast.job_ability(ja, '<me>')
                    paladin.delay = delay
                    return
                else 
                    local delay = otto.cast.job_ability(ja, '<t>')
                    paladin.delay = delay
                    return
                end
            end
        end

        for _, spell in pairs(paladin.debufflist) do
            local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]

            if recast == 0 then
                local delay = otto.cast.spell(spell, '<t>')
                paladin.delay = delay
                return
            end
        end


        for _, spell in pairs(paladin.bufflist) do
            local player_id = windower.ffxi.get_player().id
            local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]
            local my_buffs = otto.fight.my_allies[player_id].buffs

            if my_buffs[spell.status] == nil and recast == 0 then
                local buff = res.buffs[spell.status]

                if buff.en == "Protect" then
                    local pre_action = res.job_abilities[394] -- use majesty for buffed protect
                    -- add check to see if fam is in range.
                    local delay = otto.cast.spell_with_pre_action(spell, pre_action, '<me>')
                    paladin.delay = delay
                    return
                else
                    local delay = otto.cast.spell(spell, '<me>')
                    paladin.delay = delay
                    return
    
                end
            end
        end
    end
end

function paladin.action_handler(category, action, actor_id, add_effect, target)
	local categories = S{     
    	'job_ability',
    	'casting_begin',
        'spell_finish',
        'item_finish',
        'item_begin'
	 }

     local start_categories = S{ 'casting_begin', 'item_begin'}

    if not categories:contains(category) or action.param == 0 then
        return
    end

    if actor_id ~= player.id then return end

    -- Casting finish
    if category == 'spell_finish' then
        paladin.delay = 5
    end

    if category == 'item_finish' then 
        paladin.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            paladin.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            paladin.delay = 2.2
        end
    end

end


return paladin