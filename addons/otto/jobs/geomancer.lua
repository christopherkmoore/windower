-- otto geo by TC

local geomancer = { }

-- Idle bubbles should be recast whenever they dissapear or are out of range.
local idle_bubbles = S { 798, 800, 810, 812, 813, 814, 816 }

-- Active bubbles are ones where the spell's target should be engaged
local active_bubbles = S{ 801, 802, 803, 804, 805, 806, 807, 808, 809, 811, 815 }

local debuff_bubbles = S{ 799, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827 }


function geomancer.init()
    local defaults = { entrust = {}, bubble = {}}
    defaults.enabled = false
    defaults.cooldowns = false
    defaults.geo = 'Geo-Frailty'
    defaults.indi = 'Indi-Fury'
	defaults.entrust.target ='Twochix'
    defaults.entrust.indi = 'Indi-Precision'      -- entrust target and spell
    defaults.bubble.distance = 8
    defaults.bubble.target = 'Twochix'
   
    if user_settings.job.geomancer == nil then
        user_settings.job.geomancer = defaults
        user_settings:save()
    end
end

-- can get indi info from packets. geo is deduced from pets.
geomancer.indi = { latest = {}, info = {} }

geomancer.should_full_circle = false
geomancer.bubble_should_cast = false
geomancer.bubble_target = nil
geomancer.bubble_action = nil

geomancer.blaze_active = false
geomancer.ecliptic_attrition_active = false

function geomancer.check_geo()
    local action = utils.normalize_action(user_settings.job.geomancer.geo, 'spells')
    local loupan = windower.ffxi.get_mob_by_target('pet')
    local bubble_target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.bubble.target)

    if action and loupan == nil then
        if idle_bubbles:contains(action.id) then 
            geomancer.bubble_should_cast = true
            geomancer.bubble_target = user_settings.job.geomancer.bubble.target
            geomancer.bubble_action = action
        end

        if debuff_bubbles:contains(action.id) and bubble_target.status == 1 then
            geomancer.bubble_should_cast = true
            geomancer.bubble_target = '<t>' -- bug here... 
            geomancer.bubble_action = action
        end

        if active_bubbles:contains(action.id) and bubble_target.status == 1 then
            geomancer.bubble_should_cast = true
            geomancer.bubble_target = user_settings.job.geomancer.bubble.target
            geomancer.bubble_action = action
        end
    else
        geomancer.bubble_should_cast = false
        geomancer.bubble_target = nil
    end

    geomancer.check_bubble_out_of_range()
end

function geomancer.check_bubble_out_of_range() 
    if geomancer.should_full_circle then return end

    local bubble_target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.bubble.target)
    local loupan = windower.ffxi.get_mob_by_target('pet')

    if not loupan then geomancer.should_full_circle = false return end
    local distance_between_bubble_and_target = math.abs(loupan.x - bubble_target.x) -- this is not yalm perfect.

    if distance_between_bubble_and_target > (user_settings.job.geomancer.bubble.distance or 10)  then
        geomancer.should_full_circle = true
    end
end

-- maybe move this into queue?
function geomancer.check_buffs()
    if not user_settings.job.geomancer.enabled then return end
    geomancer.check_geo()
end

-- use Radial Arcana before FC
function geomancer.use_full_circle() 

    local radial_recast = windower.ffxi.get_ability_recasts()[252]
    local fc_recast = windower.ffxi.get_ability_recasts()[243]

    if radial_recast == 0 and user_settings.job.geomancer.cooldowns then
        return {id=355,en="Radial Arcana",ja="レイディアルアルカナ",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=10,recast_id=252,targets=1,tp_cost=0,type="JobAbility"} 
    elseif fc_recast == 0  then
        return {id=345,en="Full Circle",ja="フルサークル",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=243,targets=1,tp_cost=0,type="JobAbility"}
    end

    return nil
end

function geomancer.check_should_protect_bubble()
    local life_cycle = {id=349,en="Life Cycle",ja="ライフサイクル",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=246,targets=1,tp_cost=0,type="JobAbility"}
    local dematerialize = {id=351,en="Dematerialize",ja="デマテリアライズ",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=248,status=518,targets=1,tp_cost=0,type="JobAbility"}
    
    local loupan = windower.ffxi.get_mob_by_target('pet')

    local life_cycle_recast = windower.ffxi.get_ability_recasts()[life_cycle.recast_id]
    local dematerialize_recast = windower.ffxi.get_ability_recasts()[dematerialize.recast_id]

    if dematerialize_recast == 0 and user_settings.job.geomancer.cooldowns then
        return dematerialize
    end

    if loupan and loupan.hpp < 30 and life_cycle_recast == 0 and user_settings.job.geomancer.cooldowns then
        return life_cycle
    end

    return nil
end

local function toggle_fc()
    geomancer.should_full_circle = false
end

function geomancer.geo_geomancy_queue()
    if not user_settings.job.geomancer.enabled then return end

    local geo_queue = ActionQueue.new()

    local entrust_recast = windower.ffxi.get_ability_recasts()[93]
    local player = windower.ffxi.get_player()

    local buffs = S(player.buffs)

    local indi_action = utils.normalize_action(user_settings.job.geomancer.indi, 'spells') or {}

    -- check if the bubble is far from the target, if it is, FC and get a new one
    if geomancer.should_full_circle then 
        local action = geomancer.use_full_circle()
        geo_queue:enqueue_action('ability', action, player.name)

        coroutine.schedule(toggle_fc:prepare(), 5)
    end

    if not geomancer.indi.info.active  then
        geo_queue:enqueue_action('buff', indi_action, player.name) 
    end

    if geomancer.indi.info.active and (geomancer.indi.latest.spell ~= nil and geomancer.indi.latest.spell.en ~= indi_action.en) then
        geo_queue:enqueue_action('buff', indi_action, player.name) 
    end

    -- check for a buffed loupan that could use healing.
    if (geomancer.blaze_active or geomancer.ecliptic_attrition_active) and user_settings.job.geomancer.cooldowns then
        local protection_ability = geomancer.check_should_protect_bubble() 
        
        if protection_ability then
            geo_queue:enqueue_action('ability', protection_ability, player.name)
        end
    end

    -- check to see if the geo should use ecliptic on the loupan
    if not geomancer.ecliptic_attrition_active and user_settings.job.geomancer.cooldowns then
        local ecliptic_attrition_recast = windower.ffxi.get_ability_recasts()[244]
        local loupan = windower.ffxi.get_mob_by_target('pet')

        if ecliptic_attrition_recast == 0 and loupan ~= nil then
            local ecliptic_attrition = {id=347,en="Ecliptic Attrition",ja="サークルエンリッチ",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=244,targets=1,tp_cost=0,type="JobAbility"}

            geo_queue:enqueue_action('ability', ecliptic_attrition, player.name)
            geomancer.ecliptic_attrition_active = true
        end

    end

    -- check for entrust recast, and blow the cooldown.
    if user_settings.job.geomancer.entrust and user_settings.job.geomancer.entrust.target and user_settings.job.geomancer.entrust.indi then 
        local action = {id=386,en="Entrust",ja="エントラスト",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=93,status=584,targets=1,tp_cost=0,type="JobAbility"}

        if entrust_recast == 0 or buffs:contains(action.status) then 
            local action2 = utils.normalize_action(user_settings.job.geomancer.entrust.indi, 'spells')

            geo_queue:insert_with_preaction('preaction', action, action2, user_settings.job.geomancer.entrust.target)    
        end
    end

    local blaze_recast = windower.ffxi.get_ability_recasts()[247]
    
    if blaze_recast == 0 and not geomancer.blaze_active and user_settings.job.geomancer.cooldowns then
        geomancer.should_full_circle = true
    end
    -- cast the geo bubble, blowing blaze if you can
    if geomancer.bubble_should_cast and geomancer.bubble_action and geomancer.bubble_target then
        if blaze_recast == 0 and user_settings.job.geomancer.cooldowns then
            log('enqueuing buffed bubble')

            local blaze = {id=350,en="Blaze of Glory",ja="グローリーブレイズ",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=247,status=569,targets=1,tp_cost=0,type="JobAbility"}
            geo_queue:insert_with_preaction('preaction', blaze, geomancer.bubble_action, geomancer.bubble_target)    
            geomancer.blaze_active = true
        else
            log('enqueuing bubble')
            geo_queue:enqueue_action('bubble', geomancer.bubble_action, geomancer.bubble_target)
            geomancer.blaze_active = false
            geomancer.ecliptic_attrition_active = false
        end
    end


    if actions.has_bursting_spells() and user_settings.job.geomancer.cooldowns then
        local theurgic_focus = {id=352,en="Theurgic Focus",ja="タウマテルギフォカス",duration=60,element=7,icon_id=47,mp_cost=0,prefix="/jobability",range=0,recast_id=249,status=59,targets=1,tp_cost=0,type="JobAbility"}
        local collimated_ferver = {id=348,en="Collimated Fervor",ja="コリメイトファーバー",duration=60,element=7,icon_id=47,mp_cost=0,prefix="/jobability",range=0,recast_id=245,status=517,targets=1,tp_cost=0,type="JobAbility"}

        local theurgic_focus_recast = windower.ffxi.get_ability_recasts()[249]
        local collimated_ferver_recast = windower.ffxi.get_ability_recasts()[245]
    
        if theurgic_focus_recast == 0 and (not buffs:contains(theurgic_focus.status) or not buffs:contains(collimated_ferver.status)) then 
            geo_queue:enqueue_preaction('preaction', theurgic_focus, player.name)
        end

        if collimated_ferver_recast == 0 and (not buffs:contains(theurgic_focus.status) or not buffs:contains(collimated_ferver.status)) then
            geo_queue:enqueue_preaction('preaction', collimated_ferver, player.name)
        end
    end

    return geo_queue:getQueue()
end

return geomancer