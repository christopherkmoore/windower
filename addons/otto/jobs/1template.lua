

-- otto pld by TC

local temp_job = { }
local player = windower.ffxi.get_player()
temp_job.timers = {buffs={}}

-- job check ticks
temp_job.check_interval = 0.4
temp_job.delay = 4
temp_job.counter = 0

function temp_job.init()
    local defaults = { enabled = true }
    defaults.enabled = true
    defaults.cooldowns = true

    if user_settings.job.temp_job == nil then
        user_settings.job.temp_job = defaults
        user_settings:save()
    end
    temp_job.create_bufflist()

    temp_job.check_pld:loop(temp_job.check_interval)
end

function temp_job.deinit() 
    utils.wipe_debufflist()
    utils.wipe_bufflist()
end



function temp_job.check_pld()
    if not user_settings.job.temp_job.enabled then return end
    temp_job.counter = temp_job.counter + temp_job.check_interval

    if temp_job.counter >= temp_job.delay then
        print(temp_job.delay)

        temp_job.counter = 0
        temp_job.delay = temp_job.check_interval

        -- start 
    end
end


        
function temp_job.action_handler(category, action, actor_id, add_effect, target)
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
        temp_job.delay = 5
    end

    if category == 'item_finish' then 
        temp_job.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            temp_job.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            temp_job.delay = 2.2
        end
    end

end


return temp_job