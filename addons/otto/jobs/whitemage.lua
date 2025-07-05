

-- otto pld by TC


-- support
-- create party in fights where centralized buffs are stored.
-- add debuffs for specific targets (eg keep a monster silenced by name)
    -- maybe a lookup by name for my_targets

-- white mage needs:
-- healing
-- debuffs
-- buffs
-- abilities
    -- devotion
-- auto raise?
-- regens
-- remove debuffs 


local whitemage = { }
local player = windower.ffxi.get_player()
whitemage.timers = {buffs={}}

-- job check ticks
whitemage.check_interval = 0.4
whitemage.delay = 4
whitemage.counter = 0

function whitemage.init()
    local defaults = { enabled = true }
    defaults.enabled = true

    if user_settings.job.whitemage == nil then
        user_settings.job.whitemage = defaults
        user_settings:save()
    end
    whitemage.create_bufflist()

    whitemage.check_pld:loop(whitemage.check_interval)
end

function whitemage.create_bufflist()

end


function whitemage.deinit() 
    utils.wipe_debufflist()
    utils.wipe_bufflist()
end



function whitemage.check_pld()
    if not user_settings.job.whitemage.enabled then return end
    whitemage.counter = whitemage.counter + whitemage.check_interval

    if whitemage.counter >= whitemage.delay then
        print(whitemage.delay)

        whitemage.counter = 0
        whitemage.delay = whitemage.check_interval
        
        if actor:is_moving() then return end 

        -- start 
    end
end


        
function whitemage.action_handler(category, action, actor_id, add_effect, target)
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
        whitemage.delay = 5
    end

    if category == 'item_finish' then 
        whitemage.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            whitemage.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            whitemage.delay = 2.2
        end
    end

end


return whitemage