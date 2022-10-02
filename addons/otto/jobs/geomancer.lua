-- Currently under construction.
-- TODO
-- I would like to add a new queue for geomancy since so many of the spells require actions. 
-- a geomancer should user the actors time at pos to know when it's a good idea to burn cooldowns.
-- loupan should almost always be fraily or malaise since the bonuses with coupled abilities are so good, and you're basically already at att cap with bard.

-- needs entrust, Queue, priority, q action triage based on priority, blow protection CDS on buffed loupan. Maybe send gs c ProtectLoupan  that locks certain gear in place while
-- a buffed loupan is active?


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
	defaults.entrust.target ='Twochix'
    defaults.entrust.indi = 'Indi-Precision'      -- entrust target and spell
    defaults.bubble.distance = 8
    defaults.bubble.target = 'Twochix'
   
    if user_settings.job.geomancer == nil then
        user_settings.job.geomancer = defaults
        user_settings:save()
    end
end

geomancer.indi = { latest = {}, info = {} }
geomancer.geo = { latest = {} }

geomancer.should_full_circle = false
geomancer.bubble_should_cast = false
geomancer.bubble_target = nil
geomancer.bubble_action = nil

function geomancer.check_indi()
    local player = windower.ffxi.get_player()
    otto.buffs.register_buff(player, geomancer.indi.latest, geomancer.indi.info.active)
end

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
    local bubble_target = windower.ffxi.get_mob_by_name(user_settings.job.geomancer.bubble.target)
    local loupan = windower.ffxi.get_mob_by_target('pet')

    if not loupan then geomancer.should_full_circle = false return end
    local distance_between_bubble_and_target = math.abs(loupan.x - bubble_target.x) -- this is not yalm perfect.

    -- if bubble target is further than 15 away
    log(distance_between_bubble_and_target)
    if distance_between_bubble_and_target > (user_settings.job.geomancer.bubble.distance or 10)  then
        geomancer.should_full_circle = true
        return
    end

    geomancer.should_full_circle = false
end

-- main
function geomancer.check_buffs()
    if not user_settings.job.geomancer.enabled then return end
    geomancer.check_indi()
    geomancer.check_geo()
end

-- use Radial Arcana before FC
function geomancer.use_full_circle() 

    local radial_recast = windower.ffxi.get_ability_recasts()[252]
    local fc_recast = windower.ffxi.get_ability_recasts()[243]

    if radial_recast == 0 then
        return {id=355,en="Radial Arcana",ja="レイディアルアルカナ",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=10,recast_id=252,targets=1,tp_cost=0,type="JobAbility"} 
    elseif fc_recast == 0  then
        return {id=345,en="Full Circle",ja="フルサークル",element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=243,targets=1,tp_cost=0,type="JobAbility"}
    end

    return nil
end

function geomancer.geo_geomancy_queue()
    local geo_queue = ActionQueue.new()

    local entrust_recast = windower.ffxi.get_ability_recasts()[93]
    local player = windower.ffxi.get_player()

    local buffs = S(player.buffs)

    if user_settings.job.geomancer.entrust and user_settings.job.geomancer.entrust.target and user_settings.job.geomancer.entrust.indi then 
        local action = {id=386,en="Entrust",ja="エントラスト",duration=60,element=6,icon_id=46,mp_cost=0,prefix="/jobability",range=0,recast_id=93,status=584,targets=1,tp_cost=0,type="JobAbility"}

        if entrust_recast == 0 or buffs:contains(action.status) then 
            local action2 = utils.normalize_action(user_settings.job.geomancer.entrust.indi, 'spells')

            geo_queue:insert_with_preaction('preaction', action, action2, user_settings.job.geomancer.entrust.target)    
        end
    end

    if geomancer.should_full_circle then 
        local action = geomancer.use_full_circle()
        geo_queue:enqueue_action('ability', action, player.name)

        geomancer.should_full_circle = false
        -- otto.buffs.register_buff(player, geomancer.geo.latest, false)
    end

    if geomancer.bubble_should_cast and geomancer.bubble_action and geomancer.bubble_target then
        log('enqueuing bubble')
        geo_queue:enqueue_action('bubble', geomancer.bubble_action, geomancer.bubble_target)
    end

    return geo_queue:getQueue()
end
return geomancer