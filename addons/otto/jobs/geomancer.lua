-- otto geo by TC

local geomancer = { }

local player = windower.ffxi.get_player()

-- Idle bubbles should be recast whenever they dissapear or are out of range.
local idle_bubbles = S { 798, 800, 810, 812, 813, 814, 816 }

-- Active bubbles are ones where the spell's target should be engaged
local active_bubbles = S{ 801, 802, 803, 804, 805, 806, 807, 808, 809, 811, 815 }

local debuff_bubbles = S{ 799, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827 }

-- can get indi info from packets. geo is deduced from pets.
geomancer.indi = { latest = {}, info = {} }

geomancer.should_full_circle = false
geomancer.bubble_should_cast = false

geomancer.bubble_target = nil
geomancer.bubble_action = nil

geomancer.blaze_active = false
geomancer.ecliptic_attrition_active = false

-- job check ticks
geomancer.check_interval = 0.4
geomancer.delay = 4
geomancer.counter = 0

function geomancer.init()
    local defaults = { entrust = {}, bubble = {}}
    defaults.enabled = false
    defaults.cooldowns = false                    -- blow cooldowns (elicptic, blaze ect for strong bubbles) 
    defaults.geo = 'Geo-Frailty'
    defaults.indi = 'Indi-Fury'
	defaults.entrust.target ='Twochix'            -- Target for entrusted Indiclosures
    defaults.entrust.indi = 'Indi-Precision'      -- entrust target and spell
    defaults.bubble.distance = 8                  -- if the bubbles target is > the users yalm distance, dismiss the bubble.
    defaults.bubble.target = 'Twochix'            -- used to determine when a bubble should be dismissed.
   
    if user_settings.job.geomancer == nil then
        user_settings.job.geomancer = defaults
        user_settings:save()
    end

    if user_settings.aspir.enabled then
        otto.aspir.init()
    end

    otto.assist.init()
    geomancer.check_geo:loop(geomancer.check_interval)

end

function geomancer.deinit()
    -- empty for now but for clearing debuffs
    otto.aspir.deinit()
end


local function check_bubble_out_of_range() 
    if geomancer.should_full_circle then return end

    local bubble_target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.bubble.target)
    local loupan = windower.ffxi.get_mob_by_target('pet')

    if not loupan then geomancer.should_full_circle = false return end
    local target_coords = { x = bubble_target.x, y = bubble_target.y, z = bubble_target.z}
    local bubble_coords = { x = loupan.x, y = loupan.y, z = loupan.z }
    local distance_between_old_bubble_and_target = otto.cast.distance_between_points(target_coords, bubble_coords)

    if distance_between_old_bubble_and_target and distance_between_old_bubble_and_target > (user_settings.job.geomancer.bubble.distance or 10)  then
        geomancer.should_full_circle = true
    end
end


-- use Radial Arcana before FC
local function use_full_circle() 

    local radial_recast = windower.ffxi.get_ability_recasts()[252]
    local fc_recast = windower.ffxi.get_ability_recasts()[243]

    if radial_recast == 0 and user_settings.job.geomancer.cooldowns then
        return {id=355,en="Radial Arcana",ja="レイディアルアルカナ",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=10,recast_id=252,targets=1,tp_cost=0,type="JobAbility"} 
    elseif fc_recast == 0  then
        return {id=345,en="Full Circle",ja="フルサークル",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=243,targets=1,tp_cost=0,type="JobAbility"}
    end

    return nil
end

local function check_should_protect_bubble()
    local life_cycle = {id=349,en="Life Cycle",ja="ライフサイクル",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=246,targets=1,tp_cost=0,type="JobAbility"}
    local dematerialize = {id=351,en="Dematerialize",ja="デマテリアライズ",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=248,status=518,targets=1,tp_cost=0,type="JobAbility"}
    
    local loupan = windower.ffxi.get_mob_by_target('pet')
    local life_cycle_ready = otto.cast.is_off_cooldown(life_cycle)
    local dematerialize_ready = otto.cast.is_off_cooldown(dematerialize)

    if dematerialize_ready and user_settings.job.geomancer.cooldowns then
        return dematerialize
    end

    if loupan and loupan.hpp < 30 and life_cycle_ready  and user_settings.job.geomancer.cooldowns then
        return life_cycle
    end

    return nil
end


local function toggle_fc()
    geomancer.should_full_circle = false
end

local function check_aspir()
    if otto.aspir.ready.target and otto.aspir.ready.spell then
        local delay = otto.cast.spell(otto.aspir.ready.spell, otto.aspir.ready.target)
        geomancer.delay = delay
        return
    end

end
local function check_spells()
    local buffs = otto.player.my_buffs()

    if actor:is_moving() or otto.player.mage_disabled() then return end

    local entrust_recast = windower.ffxi.get_ability_recasts()[93]
    local indi_action = res.spells:with('name', user_settings.job.geomancer.indi)

    -- check if the bubble is far from the target, if it is, FC and get a new one
    if geomancer.should_full_circle then 
        local ja_ability = use_full_circle()
        if ja_ability then
            local delay = otto.cast.job_ability(ja_ability, '<me>')
            geomancer.delay = delay
            coroutine.schedule(toggle_fc:prepare(), 5)
            return        
        end
    end

    if not geomancer.indi.info.active  then
        -- print('indi, nocheck ')

        local delay = otto.cast.spell_no_check(indi_action, '<me>')
        geomancer.delay = delay
        return
    end

    -- check for a buffed loupan that could use healing.
    if (geomancer.blaze_active or geomancer.ecliptic_attrition_active) and user_settings.job.geomancer.cooldowns then
        local protection_ability = check_should_protect_bubble() 
        
        if protection_ability then
            local delay = otto.cast.job_ability(protection_ability, '<me>')
            geomancer.delay = delay
            return
        end
    end

    -- check to see if the geo should use ecliptic on the loupan
    if not geomancer.ecliptic_attrition_active and user_settings.job.geomancer.cooldowns then
        local ecliptic_attrition_recast = windower.ffxi.get_ability_recasts()[244]
        local loupan = windower.ffxi.get_mob_by_target('pet')

        if ecliptic_attrition_recast == 0 and loupan ~= nil then
            local ecliptic_attrition = {id=347,en="Ecliptic Attrition",ja="サークルエンリッチ",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=244,targets=1,tp_cost=0,type="JobAbility"}
            local delay = otto.cast.job_ability(ecliptic_attrition, '<me>')
            geomancer.delay = delay
            geomancer.ecliptic_attrition_active = true
            return
        end
    end

    -- check for entrust recast, and blow the cooldown.
    if user_settings.job.geomancer.entrust and user_settings.job.geomancer.entrust.target and user_settings.job.geomancer.entrust.indi then 
        local action = {id=386,en="Entrust",ja="エントラスト",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=93,status=584,targets=1,tp_cost=0,type="JobAbility"}
        local target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.entrust.target)

        if target and entrust_recast == 0 or buffs:contains(action.status) then 
            local spell = res.spells:with('name', user_settings.job.geomancer.indi)
            -- print('entrust pre-action ')
            local delay = otto.cast.spell_with_pre_action(spell, action, target)
            geomancer.delay = delay
            return
        end
    end

    local blaze_recast = windower.ffxi.get_ability_recasts()[247]
    
    if blaze_recast == 0 and not geomancer.blaze_active and user_settings.job.geomancer.cooldowns then
        geomancer.should_full_circle = true
    end

    -- cast the geo bubble, blowing blaze if you can
    if geomancer.bubble_should_cast and geomancer.bubble_action and geomancer.bubble_target then
        if blaze_recast == 0 and user_settings.job.geomancer.cooldowns then
            local blaze = {id=350,en="Blaze of Glory",ja="グローリーブレイズ",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=247,status=569,targets=1,tp_cost=0,type="JobAbility"}
            local delay = otto.cast.spell_with_pre_action(geomancer.bubble_action, blaze,  geomancer.bubble_target)
            geomancer.delay = delay
            geomancer.blaze_active = true
            return
        else
            local delay = otto.cast.spell(geomancer.bubble_action, geomancer.bubble_target)
            geomancer.delay = delay
            geomancer.blaze_active = false
            geomancer.ecliptic_attrition_active = false
            return
        end
    end

    -- redo bursting

    if otto.magic_burst.window_open_spell and otto.magic_burst.window_open_target then
        local theurgic_focus = {id=352,en="Theurgic Focus",ja="タウマテルギフォカス",duration=60,element=7,icon_id=47,mp_cost=0,prefix="/jobability",range=0,recast_id=249,status=59,targets=1,tp_cost=0,type="JobAbility"}
        local collimated_ferver = {id=348,en="Collimated Fervor",ja="コリメイトファーバー",duration=60,element=7,icon_id=47,mp_cost=0,prefix="/jobability",range=0,recast_id=245,status=517,targets=1,tp_cost=0,type="JobAbility"}

        local theurgic_focus_recast = windower.ffxi.get_ability_recasts()[249]
        local collimated_ferver_recast = windower.ffxi.get_ability_recasts()[245]
    
        if user_settings.job.geomancer.cooldowns and theurgic_focus_recast == 0 and (not buffs:contains(theurgic_focus.status) or not buffs:contains(collimated_ferver.status)) then 
            local delay = otto.cast.spell_with_pre_action(otto.magic_burst.window_open_spell, theurgic_focus, otto.magic_burst.window_open_target)
            geomancer.delay = delay
            return
        end

        if user_settings.job.geomancer.cooldowns and  collimated_ferver_recast == 0 and (not buffs:contains(theurgic_focus.status) or not buffs:contains(collimated_ferver.status)) then
            local delay = otto.cast.spell_with_pre_action(otto.magic_burst.window_open_spell, collimated_ferver, otto.magic_burst.window_open_target)
            geomancer.delay = delay
            return
        end

        local delay = otto.cast.spell(otto.magic_burst.window_open_spell, otto.magic_burst.window_open_target)
        geomancer.delay = delay
        return

    end

end

function geomancer.check_geo()
    if not user_settings.job.geomancer.enabled then return end
    if actor:is_moving() or otto.player.mage_disabled() then return end

    geomancer.counter = geomancer.counter + geomancer.check_interval

    if geomancer.counter >= geomancer.delay then
        geomancer.counter = 0
        geomancer.delay = geomancer.check_interval

        local action = res.spells:with('name', user_settings.job.geomancer.geo)
        local loupan = windower.ffxi.get_mob_by_target('pet')
        local bubble_target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.bubble.target)

        if action and loupan == nil then
             -- requires an ally target
            if idle_bubbles:contains(action.id) then
                geomancer.bubble_should_cast = true
                geomancer.bubble_target = otto.fight.ally_lookup(user_settings.job.geomancer.bubble.target, nil, nil)
                geomancer.bubble_action = action
            end

            -- requires an enemy target
            if bubble_target and debuff_bubbles:contains(action.id) then
                geomancer.bubble_should_cast = true
                geomancer.bubble_target = otto.cast.party_target()
                geomancer.bubble_action = action
            end

             -- requires an ally target
            if active_bubbles:contains(action.id) and bubble_target.status == 1 then
                geomancer.bubble_should_cast = true
                geomancer.bubble_target = otto.fight.ally_lookup(user_settings.job.geomancer.bubble.target, nil, nil)
                geomancer.bubble_action = action
            end
        else
            geomancer.bubble_should_cast = false
            geomancer.bubble_target = nil
        end

        check_bubble_out_of_range()
        
        if user_settings.aspir.enabled then
            check_aspir()

        end
        check_spells()
    end
end

function geomancer.action_handler(category, action, actor_id, add_effect, target)
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
        geomancer.delay = 5
    end

    if category == 'item_finish' then 
        geomancer.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            geomancer.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            geomancer.delay = 2.2
        end
    end

end

return geomancer