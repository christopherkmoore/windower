-- otto blm by TC

local paladin = { }

paladin.bufflist = {
    [855] = {id=855,en="Enlight II",ja="エンライトII",cast_time=3,duration=180,element=6,icon_id=337,icon_id_nq=6,levels={[7]=100},mp_cost=36,prefix="/magic",range=0,recast=30,recast_id=855,requirements=0,skill=32,status=274,targets=1,type="WhiteMagic"},
    [97] = {id=97,en="Reprisal",ja="リアクト",cast_time=1,duration=60,element=6,icon_id=196,icon_id_nq=6,levels={[7]=61},mp_cost=24,prefix="/magic",range=0,recast=52,recast_id=97,requirements=0,skill=34,status=403,targets=1,type="WhiteMagic"},
    -- [52] = {id=52,en="Shell V",ja="シェルV",cast_time=2,duration=1800,element=6,icon_id=132,icon_id_nq=6,levels={[3]=76,[5]=87,[20]=90,[22]=90},mp_cost=93,overwrites={48,49,50,51},prefix="/magic",range=12,recast=6,recast_id=52,requirements=1,skill=34,status=41,targets=29,type="WhiteMagic"},
    -- [47] = {id=47,en="Protect V",ja="プロテスV",cast_time=2,duration=1800,element=6,icon_id=122,icon_id_nq=6,levels={[3]=76,[5]=77,[7]=90,[20]=80},mp_cost=84,overwrites={43,44,45,46},prefix="/magic",range=12,recast=6,recast_id=47,requirements=1,skill=34,status=40,targets=29,type="WhiteMagic"},
    [476] = {id=476,en="Crusade",ja="クルセード",cast_time=3,duration=300,element=7,icon_id=552,icon_id_nq=7,levels={[7]=88,[22]=88},mp_cost=18,prefix="/magic",range=12,recast=10,recast_id=476,requirements=0,skill=34,status=289,targets=1,type="WhiteMagic"},
    [106] = {id=106,en="Phalanx",ja="ファランクス",cast_time=3,duration=180,element=6,icon_id=186,icon_id_nq=6,levels={[5]=33,[7]=77,[22]=68},mp_cost=21,prefix="/magic",range=12,recast=10,recast_id=106,requirements=1,skill=34,status=116,targets=1,type="WhiteMagic"}
}
paladin.debufflist = {
    [112] = {id=112,en="Flash",ja="フラッシュ",cast_time=0.5,element=6,icon_id=158,icon_id_nq=6,levels={[3]=45,[7]=37,[22]=45},mp_cost=25,prefix="/magic",range=12,recast=45,recast_id=112,requirements=0,skill=32,targets=32,type="WhiteMagic"}
}

paladin.jalist = { 
    [46] = {id=46,en="Shield Bash",ja="シールドバッシュ",element=4,icon_id=406,mp_cost=0,prefix="/jobability",range=2,recast_id=73,targets=32,tp_cost=0,type="JobAbility"},
    [394] = {id=394,en="Majesty",ja="マジェスティ",duration=180,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=150,status=621,targets=1,tp_cost=0,type="JobAbility"},
    [92] = {id=92,en="Rampart",ja="ランパート",duration=30,element=3,icon_id=409,mp_cost=0,prefix="/jobability",range=0,recast_id=77,status=93,targets=1,tp_cost=0,type="JobAbility"},
    [48] = {id=48,en="Sentinel",ja="センチネル",duration=30,element=3,icon_id=407,mp_cost=0,prefix="/jobability",range=0,recast_id=75,status=62,targets=1,tp_cost=0,type="JobAbility"},
}

paladin.job_tick = 5
paladin.next_tick = os.clock()

function paladin.init()
    local defaults = { enabled = true }
    defaults.enabled = true
    defaults.cooldowns = true

    if user_settings.job.paladin == nil then
        user_settings.job.paladin = defaults
        user_settings:save()
    end
    paladin.next_tick = os.clock()
    paladin.create_bufflist()
end

function paladin.deinit() 
    utils.wipe_debufflist()
    utils.wipe_bufflist()
end

function paladin.create_bufflist()
    local player = windower.ffxi.get_player()

    if player.sub_job == "BLU" then
        -- paladin.bufflist[547] = {id=547,en="Cocoon",ja="コクーン",blu_points=1,cast_time=1.75,duration=90,element=15,icon_id=-1,icon_id_nq=59,levels={[16]=8},mp_cost=10,prefix="/magic",range=0,recast=60,recast_id=547,requirements=0,skill=43,status=93,targets=1,type="BlueMagic"}
        paladin.debufflist[592] = {id=592,en="Blank Gaze",ja="ブランクゲイズ",blu_points=2,cast_time=3,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=38},mp_cost=25,prefix="/magic",range=9,recast=10,recast_id=592,requirements=0,skill=43,targets=32,type="BlueMagic"}
    end

    for _, spell in pairs(paladin.bufflist) do
        windower.send_command('otto buff '..player.name..' '..spell.en..' on')
    end
end 


-- The pld main function.
function paladin.check_pld()
    if not user_settings.job.paladin.enabled then return end

    if os.clock() > paladin.next_tick then 
        paladin.next_tick = os.clock() + paladin.job_tick
    end
end


function paladin.pld_queue()
    if not user_settings.job.paladin.enabled then return end
    local now = os.clock()
    if now > paladin.next_tick  then return end
    paladin.next_tick = now + paladin.job_tick

    local target = windower.ffxi.get_mob_by_target('t')

    if not (target ~= nil and target.valid_target and target.claim_id > 0 and target.is_npc) then return end
    
    local pld_queue = ActionQueue.new()
    local player = windower.ffxi.get_player()
    local buffs = S(player.buffs)

    local sleep = {id=253,en="Sleep",ja="スリプル",cast_time=2.5,duration=60,element=7,icon_id=310,icon_id_nq=15,levels={[4]=20,[5]=25,[8]=30,[20]=30,[21]=35},mp_cost=19,prefix="/magic",range=12,recast=30,recast_id=253,requirements=6,skill=35,status=2,targets=32,type="BlackMagic"}
    -- can't cast this if youre slept
    if buffs:contains(sleep.status) then 
        print("JUST WOKE UP SLEEP ERASE ME")
        local cure = {id=1,en="Cure",ja="ケアル",cast_time=2,element=6,icon_id=86,icon_id_nq=6,levels={[3]=1,[5]=3,[7]=5,[20]=5},mp_cost=8,prefix="/magic",range=12,recast=5,recast_id=1,requirements=1,skill=33,targets=63,type="WhiteMagic"}
        pld_queue:enqueue_action('cure', cure, player.name)
        return
    end

    for _, ja in pairs(paladin.jalist) do
        local recast = windower.ffxi.get_ability_recasts()[ja.recast_id]

        if actor:can_use(ja) and recast == 0 and not actor:is_acting() and target ~= nil then
            if ja.range == 0 then
                pld_queue:enqueue_action('ability', ja, player.name)
            else 
                pld_queue:enqueue_action('ability', ja, target.name)
            end

        end
    end

    for _, spell in pairs(paladin.debufflist) do
        local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]

        if actor:can_use(spell) and recast == 0 and not actor:is_acting() then
            pld_queue:enqueue_action('debuff', spell, target.name)
        end
    end

    return pld_queue:getQueue()
end

return paladin