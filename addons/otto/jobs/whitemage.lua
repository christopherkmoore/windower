

-- otto white mage by TC


-- support

-- add debuffs for specific targets (eg keep a monster silenced by name)
    -- maybe a lookup by name for my_targets

    -- add a debuff ignore list on job.white.debuffs.ignore = {}

local whitemage = { healing = {}, raises = T{} }
local player = windower.ffxi.get_player()

-- job check ticks
whitemage.check_interval = 0.4
whitemage.delay = 4
whitemage.counter = 0



local function start() 
    -- unused, but could do sweaty stuff here like mapping jp points or cure potency.
end

function whitemage.init()
    local defaults = T{ 
        settings = T{
            auto_raise = true,     -- tries to auto raise when party members die. Pretty low priority
            devotion = {
                enabled= true,
                target= 'Fivechix',    
            },
            blow_cooldowns = true,
        },
        debuffs = L {"Dia II","Slow","Paralyze", "Silence", "Addle"},
        buffs = L {"Protectra V", "Shellra V", "Auspice", "Aurorastorm"},
        buff = T {
            ["Chixslave"] = L{ 
                "Haste", "Reraise IV" },
            ["Fivechix"] = L { "Haste"},
            ["Fourchix"] = L {"Haste"},
            ["Onechix"] = L {"Haste"},
            ["Threechix"] = L {"Haste"},
            ["Twochix"] = L {"Haste"}
        }
    }

    if user_settings.job.whitemage == nil then
        user_settings.job.whitemage = defaults
        user_settings:save()
    end

    start()
    whitemage.create_bufflist()

    otto.assist.init()
    whitemage.check_whm:loop(whitemage.check_interval)
end

function whitemage.deinit() 
end

local function curaga_step_down(spellId, ally_id, times_tried)
    if times_tried >= 2 then
        return
    end 

    times_tried = times_tried + 1

    local spell = res.spells[spellId - times_tried]
    local target = otto.fight.my_allies[ally_id]
    local recast = windower.ffxi.get_spell_recasts()[spell.id]

    if spell and target and recast == 0 then
        otto.cast.spell(spell, target)
    else
        curaga_step_down(spellId, ally_id, times_tried)
    end
end

local function cure_step_down(spellId, ally_id, times_tried)
    if times_tried >= 2 then
        return
    end 

    times_tried = times_tried + 1

    local spell = res.spells[spellId - times_tried]
    local target = otto.fight.my_allies[ally_id]
    local recast = windower.ffxi.get_spell_recasts()[spell.id]
    if spell and target and recast == 0 then
        otto.cast.spell(spell, target)
    else
        cure_step_down(spellId, ally_id, times_tried)
    end
end


local function raise_step_down(ally_id, times_tried)
    if times_tried >= 3 then return end 

    times_tried = times_tried + 1
    local spell = {}
    local target = otto.fight.my_allies[ally_id]
    local recast = 5
    
    if times_tried == 1 then
        spell = res.spells[140]
        recast = windower.ffxi.get_spell_recasts()[spell.id]    
    elseif times_tried == 2 then
        spell = res.spells[13]
        recast = windower.ffxi.get_spell_recasts()[spell.id]    
    end
    
    print(' Riase step down!')
    if spell and target and recast == 0 then
        otto.cast.spell(spell, target)
    else
        raise_step_down(ally_id, times_tried)
    end

end

local function curaga(missingHps, ally_id)
    local spellId = 7

    if missingHps > 1000 and missingHps <=1200  then
        spellId = spellId + 1
    elseif missingHps > 1201 and missingHps <=2500 then
        spellId = spellId + 2
    elseif missingHps > 2501 and missingHps <=3900 then
        spellId = spellId + 3
    elseif missingHps > 5000 then 
        spellId = 11
    end

    local spell = res.spells[spellId]
    local target = otto.fight.my_allies[ally_id]
    local recast = windower.ffxi.get_spell_recasts()[spell.id]

    if spell and target and recast == 0 then
        otto.cast.spell(spell, target)
        return
    else
        curaga_step_down(spellId, ally_id, 0) --need aga target
    end
end

local function cure(ally_id, missingHps)
    local spellId = 1

    if missingHps > 100 and missingHps <=300  then
        spellId = spellId + 1
    elseif missingHps > 301 and missingHps <=500 then
        spellId = spellId + 2
    elseif missingHps > 501 and missingHps <=700 then
        spellId = spellId + 3
    elseif missingHps > 701 and missingHps <=1200 then
        spellId = spellId + 4
    elseif missingHps > 1201 then 
        spellId = 6
    end

    local spell = res.spells[spellId]
    local target = otto.fight.my_allies[ally_id]
    local recast = windower.ffxi.get_spell_recasts()[spell.id]

    if spell and target and recast == 0 then
        otto.cast.spell(spell, target)
        return
    else
        cure_step_down(spellId, ally_id, 0)
    end
end

local function raise(ally_id)
    local arise = res.spells[494]
    local target = otto.fight.my_allies[ally_id]
    local recast = windower.ffxi.get_spell_recasts()[arise.id]

    if arise and target and recast == 0 then
        local delay = otto.cast.spell(arise, target)
        whitemage.delay = delay / 2 -- 12 seconds is probably not really correct
        return
    else
        raise_step_down(arise, ally_id, 0)
    end
end

local function regen(ally_id) 
    local player = windower.ffxi.get_player()
    local ally = otto.fight.my_allies[ally_id]
    local regen_buff = res.buffs[42]
    local strategems_recast = windower.ffxi.get_ability_recasts()[231]
    local accession = res.job_abilities[218]

    if ally and ally.buffs and not ally.buffs[42] then 

        local target = otto.fight.my_allies[ally_id]
        local regenSpell = res.spells:with('name', 'Regen IV')
        local recast = windower.ffxi.get_spell_recasts()[regenSpell.id]
        if target and regenSpell and recast == 0 and player.sub_job == "SCH" and strategems_recast == 0 then
            local delay = otto.cast.spell_with_pre_action(regenSpell, accession, target)
            whitemage.delay = delay
            return true

        end
        if target and regenSpell and recast == 0 then
            local delay = otto.cast.spell(regenSpell, target)
            whitemage.delay = delay
            return true
        end
    end
    return false
end

local function remove_na(ally_id, debuff, try_aga) 
    local player = windower.ffxi.get_player()
    local ally = otto.fight.my_allies[ally_id]
    local strategems_recast = windower.ffxi.get_ability_recasts()[231]
    local accession = res.job_abilities[218]
    local target = otto.fight.my_allies[ally_id]
    local divine_seal = res.job_abilities[74]
    local divine_seal_recast = windower.ffxi.get_ability_recasts()[26]
    local divine_caress = res.job_abilities[270]
    local divine_caress_recast = windower.ffxi.get_ability_recasts()[32]

    local cure_name = otto.event_statics.debuff_to_dispel_map[debuff]
    local debuff_spell = res.spells:with('name', cure_name)

    -- divine seal + na for AoE Erase
    if target and debuff_spell and try_aga and debuff_spell.en == "Erase" and windower.ffxi.get_spell_recasts()[debuff_spell.id] == 0 and divine_seal_recast == 0 then
        local delay = otto.cast.spell_with_pre_action(debuff_spell, divine_seal, target)
        whitemage.delay = delay
        return true

    end

    -- Accesssion + na for AoE Erase
    if target and debuff_spell and try_aga and player.sub_job == "SCH" and strategems_recast == 0 and windower.ffxi.get_spell_recasts()[debuff_spell.id] == 0 then
        local delay = otto.cast.spell_with_pre_action(debuff_spell, accession, target)
        whitemage.delay = delay
        return true
    end

       -- divine caress + non AoE
    if target and debuff_spell and debuff_spell.en ~= "Erase" and windower.ffxi.get_spell_recasts()[debuff_spell.id] == 0 and divine_caress_recast == 0 then
        local delay = otto.cast.spell_with_pre_action(debuff_spell, divine_caress, target)
        whitemage.delay = delay
        return true
    end

    -- Okay fine just a regular old na... pray for Divine Viel Proc :P
    if target and debuff_spell and windower.ffxi.get_spell_recasts()[debuff_spell.id] == 0 then
        local delay = otto.cast.spell(debuff_spell, target)
        whitemage.delay = delay
        return true
    end

    return false
end


function whitemage.create_bufflist()
    -- unused, but could do sweaty stuff here like mapping jp points or cure potency.
end




local function cancel_buff(buff_id)
    -- Inject the cancel packet
    windower.packets.inject_outgoing(0xF1,string.char(0xF1,0x04,0,0,id%256,math.floor(id/256),0,0)) 
end

function whitemage.check_whm()
    if not user_settings.job.whitemage.enabled then return end
    if actor:is_moving() or otto.player.mage_disabled() then return end

    whitemage.counter = whitemage.counter + whitemage.check_interval

    if whitemage.counter >= whitemage.delay then

        whitemage.counter = 0
        whitemage.delay = whitemage.check_interval

        -- CKM TEST
        -- wake up sleeping allies
        for _, ally in pairs(otto.fight.my_allies) do
            if ally.debuffs['sleep'] then
                local curaga = res.spells[7]
                local delay = otto.cast.spell(curaga, ally.name)
                whitemage.delay = delay
            end 
        end
        local sortable_hps = T{}
        local sortable_hpps = T{}
        local aga_counter = 0
        local combined_missing_hp = 0
        local party_total_hp = 0
        local dead_allies = 0
        
        -- pre-cure setup
        for _, ally in pairs(otto.fight.my_allies) do
            if ally.hp ~= 0 then
                local missingHP = math.ceil((ally.hp/(ally.hpp/100))-ally.hp)
                if missingHP > 0 then
                    sortable_hps[ally.id] = missingHP
                    sortable_hpps[ally.id] = 100 - ally.hpp
                end

                if ally.hpp < 60 then
                    aga_counter = aga_counter + 1
                end
                party_total_hp = party_total_hp + (missingHP + ally.hp)
                combined_missing_hp = combined_missing_hp + missingHP
            end

            if ally.hp == 0 then
                dead_allies = dead_allies + 1
            end
        end 

        local needs_aga = aga_counter >= 3


        local counter = 0

        -- cures + regen 
        for k,v in spairs(sortable_hpps, function(t,a,b) return t[b] < t[a] end) do 
            if counter > 1 then break end
            
            -- Things are pretty fucked, maybe try a benediction
            if dead_allies >= 2 and needs_aga then
                local benediction = res.job_abilities[18]
                local bene_recast = windower.ffxi.get_ability_recasts()[0]

                if benediction and bene_recast == 0 then
                    otto.cast.job_ability(benediction, '<me>')
                end

            end 

            if needs_aga then curaga(combined_missing_hp, k) end

            if v >= 25 then
                local missing = sortable_hps[k]
                if otto.cast.is_ally_valid_target(k, 20) then 
                    cure(k, missing)
                end
            end

            if otto.cast.is_ally_valid_target(k, 20) then 
                if not regen(k) then break end
            end

            counter = counter + 1
        end
       
        -- debuff na
        local try_aga_debuffing = false
        local debuff_name = ''
        local sortable_debuffs = T{ }
        local sortable_debuffs_ids = S { }
        local aga_target

        -- remove na setup
        for k,v in pairs(otto.fight.my_allies) do
            if v.debuffs then
                for buff_id, v in pairs(v.debuffs) do
                    sortable_debuffs[k] = v
                    sortable_debuffs_ids:append(buff_id)
                end
            end
        end

        local times_appearing = 0
        local last = ''

        -- see if you can aga an ally debuff off using strategems
        for k,v in spairs(sortable_debuffs, function(t,a,b) return t[b] < t[a] end) do 
            
            if v == last then
                times_appearing = times_appearing + 1
            else
                times_appearing = 0
            end

            if times_appearing >= 3 then
                try_aga_debuffing = true
                debuff_name = v
                aga_target = k
                break
            end
            last = v
        end

        if try_aga_debuffing and debuff_name ~= '' then
            if otto.cast.is_ally_valid_target(aga_target, 20) then 
                if remove_na(aga_target, debuff_name, try_aga_debuffing) then return end
            end
        end

        for ally_id, debuff_name in pairs(sortable_debuffs) do
            if otto.cast.is_ally_valid_target(ally_id, 20) then 
                if remove_na(ally_id, debuff_name, false) then return end -- don't get caught trying to do all these debuffs
            end    
        end

        -- -- buffs
        otto.buffs.cast()
        otto.debug.create_log(otto.buffs.buff_list, 'debugger')

        --debuffs 
        otto.debuffs.cast() 

        -- check for KO, with raise already sent.
        -- and remove if a player is no longer KO'd
        for ally_id, _ in pairs(whitemage.raises) do
            if otto.fight.my_allies[ally_id].buffs then
                for buff_id, name in pairs(otto.fight.my_allies[ally_id].buffs) do
                    if name ~= "KO" then
                        whitemage.raises[ally_id] = nil
                    end
                end
            end
        end
        
        -- auto-raises
        for _, ally in pairs(otto.fight.my_allies) do
            if ally.buffs then
                for buff_id, name in pairs(ally.buffs) do

                    -- don't attemp to raise the same person
                    if name == "KO" and user_settings.job.whitemage.auto_raise then 
                        if not whitemage.raises:contains(ally.id) and ally.distance < 20 then
                            raise(ally.id)
                        end
                    end
                end
            end
        end

        -- blow_cooldowns
        -- Devotion
        -- Sacrosanctity   -- Enhanced magic defense
        -- Asylum          -- Enhanced resistance to enfeebling + Dispel effects
        -- abilities
            -- devotion

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
        
        if otto.event_statics.raise_spells:contains(action.top_level_param) then 
            local ally = otto.fight.my_allies[target.id]
            if ally then
                whitemage.raises[ally.id] = true
            end
        end

        -- CKM TEST -- this seems to happen quite often. (maybe fixed, if you don't see messages)
        -- you can remove
        if action.message == 283 or action.message == 423 or action.message == 659 or action.message == 75 then
                        
            if otto.event_statics.na_spells:contains(action.top_level_param) then
                print(" I could be stuck in a debuff na cycle, check ")
                local spell_cast = res.spells:with('recast_id', action.top_level_param)     --optional
                local buff_to_search = otto.event_statics.dispel_to_debuff_map[spell_cast.en]
                local buff = res.buffs:with('name', buff_to_search)
                local ally = otto.fight.my_allies[target.id]
                if spell_cast and buff and ally then
                    print("Manually removing "..buff_to_search..' from '..ally.name)

                    ally.buffs[buff.id] = nil
                end
            end
        end

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