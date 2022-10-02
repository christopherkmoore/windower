-- dispels by TC

local dispel = { monster_ability_dispelables = {},}

local dispels = { 
    dispel = {id=260,en="Dispel",ja="ディスペル",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[5]=32,[20]=32},mp_cost=25,prefix="/magic",range=12,recast=10,recast_id=260,requirements=6,skill=35,targets=32,type="BlackMagic"},
    dispelga = {id=360,en="Dispelga",ja="ディスペガ",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[3]=99,[4]=99,[5]=99,[10]=99,[15]=99,[20]=99,[21]=99},mp_cost=200,prefix="/magic",range=12,recast=10,recast_id=360,requirements=0,skill=35,targets=32,type="BlackMagic",unlearnable=true},
    finale = {id=462,en="Magic Finale",ja="魔法のフィナーレ",cast_time=2,element=6,icon_id=-1,icon_id_nq=38,levels={[10]=33},mp_cost=0,prefix="/song",range=12,recast=24,recast_id=462,requirements=0,skill=40,targets=32,type="BardSong"},
    blank_gaze = {id=592,en="Blank Gaze",ja="ブランクゲイズ",blu_points=2,cast_time=3,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=38},mp_cost=25,prefix="/magic",range=9,recast=10,recast_id=592,requirements=0,skill=43,targets=32,type="BlueMagic"},
    geist_wall = {id=605,en="Geist Wall",ja="ガイストウォール",blu_points=3,cast_time=3,element=7,icon_id=-1,icon_id_nq=63,levels={[16]=46},mp_cost=35,prefix="/magic",range=4,recast=30,recast_id=605,requirements=0,skill=43,targets=32,type="BlueMagic"},
    dark_shot = {id=132,en="Dark Shot",ja="ダークショット",element=7,icon_id=495,mp_cost=1,prefix="/jobability",range=12,recast_id=195,targets=32,tp_cost=0,type="CorsairShot"},
}

local dispel_jobs = S{ 'BRD', 'RDM', 'BLU', 'COR'}

local dispel_ids = S{ 260, 360, 462, 592, 605, 132 }
local action_messages = S{ 186, 194, 205, 230, 266, 280, 319 }
local dispel_message_successful = S { 341, 342}

function dispel.init()

    local defaults = { }
	defaults.enabled = false       -- top level enable toggle. on | off

    if user_settings.dispel == nil then
        user_settings.dispel = defaults
        user_settings:save()
    end

end

-- evaluate if a dispel action should be added to the queue.
function dispel.should_dispel(id)
    if not user_settings.dispel.enabled then return end

    local player = windower.ffxi.get_player()
    local can_dispel = dispel_jobs:contains(player.main_job) 

    if not can_dispel then return end

    if offense.dispel ~= nil and offense.dispel[id] ~= nil then
        if player.main_job == 'BRD' and not offense.checkNukingQueueFor(dispels.finale) then
            offense.addToNukeingQueue(dispels.finale)
        elseif player.main_job == 'RDM' and not offense.checkNukingQueueFor(dispels.dispel) then
            offense.addToNukeingQueue(dispels.dispel)
        elseif player.main_job == 'BLU' and not offense.checkNukingQueueFor(dispels.blank_gaze) then
            offense.addToNukeingQueue(dispels.blank_gaze)
        elseif player.main_job == 'COR' and not offense.checkNukingQueueFor(dispels.dark_shot) then 
            offense.addToNukeingQueue(dispels.dark_shot)
        end
    end
end

function dispel.action_handler(category, action, actor_id, target, monitored_ids, basic_info)

	if not user_settings.dispel.enabled then return end

	local categories = S{     
    	'mob_tp_finish',
        'spell_finish',
    	'avatar_tp_finish',
	 }

    if not categories:contains(category) or action.param == 0 then
        return
    end

    if monitored_ids[target.raw.id] == nil and monitored_ids[actor_id] == nil then
        local mob = windower.ffxi.get_mob_by_id(actor_id)

        if mob and mob.spawn_type == 16 and monitored_ids[mob.claim_id] ~= nil then
            for _, action in pairs(target.raw.actions) do
                if action_messages:contains(action.message) then 

                    -- stub a false dispel in the config. check later as dispel resovles if it can be saved as dispelable
                    if otto.config.monster_ability_dispelables == nil or otto.config.monster_ability_dispelables[action.top_level_param] == nil then
                        otto.config.monster_ability_dispelables[action.top_level_param] = false
                        otto.config.monster_ability_dispelables.save(otto.config.monster_ability_dispelables)
                        offense.dispel[target.raw.id] = action.top_level_param
                    end

                    -- immediately add for known dispelables
                    if otto.config.monster_ability_dispelables[action.top_level_param] == true then
                        offense.dispel[target.raw.id] = action.top_level_param
                    end
                end
            end
        end 
    end


    if dispel_ids:contains(basic_info.spell_id) then
        -- log('basic info')
        -- table.vprint(basic_info)
        -- log('action')
        -- table.vprint(action)
        
        if dispel_message_successful:contains(action.message) then
            -- log('targets')
            -- table.vprint(offense.dispel)
            if offense.dispel[target.raw.id] ~= nil then
                local monster_buff = offense.dispel[target.raw.id]

                -- save new dispellable abilities
                if otto.config.monster_ability_dispelables[monster_buff] == false then 
                    otto.config.monster_ability_dispelables[monster_buff] = true
                    otto.config.monster_ability_dispelables.save(otto.config.monster_ability_dispelables)
                end
                
                offense.dispel[target.raw.id] = nil 
                
                -- cleanup queue if someone else dispeled
                for _, spell_to_remove in pairs(dispels) do
                    if offense.checkNukingQueueFor(spell_to_remove) then
                        actions.remove_offensive_action(spell_to_remove.id)
                    end
                end
            end
        end 
    end 

    dispel.should_dispel(target.raw.id)
end

return dispel