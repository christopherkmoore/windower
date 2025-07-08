--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot utility functions that don't belong anywhere else
--]]

-- modified and edited by TC
--==============================================================================
--          Input Handling Functions
--==============================================================================

utils = { normalize={}, immunities=lor_settings.load('data/mob_immunities.lua')}
local lor_res = _libs.lor.resources
local lc_res = lor_res.lc_res
local ffxi = _libs.lor.ffxi


function utils.normalize_str(str)
    return str:lower():gsub(' ', '_'):gsub('%.', '')
end

-- Exchanges a weaponskill for a resouce from the weapon_skills res.
function utils.get_weaponskill(search)
    for k,v in pairs(res.weapon_skills) do 
        if v.name == search then
            return v
        end 
    end
end

-- Exchanges a weaponskill for a resouce from the weapon_skills res.
function utils.get_job_ability(search)
    for k,v in pairs(res.job_abilities) do 
        if v.name == search then
            return v
        end 
    end
end

function utils.normalize_action(action, action_type)
    -- atcf('utils.normalize_action(%s, %s)', tostring(action), tostring(action_type))
    if istable(action) then return action end
    if action_type == nil then return nil end
    if isstr(action) then

        if tonumber(action) == nil then
            local naction = res[action_type]:with('en', action)
            if naction ~= nil then
                --atcf("res.%s[%s] found for %s", action_type, naction.id, action)
                return naction
            end
            --atcf("Searching resources for normalized name for %s [%s]", action, action_type)
            return res[action_type]:with('enn', utils.normalize_str(action))
        end
        action = tonumber(action) 
    end
    if isnum(action) then
        return res[action_type][action]
    end
    --atcf("Unable to normalize: '%s'[%s] (%s)", tostring(action), type(action), tostring(action_type))
    return nil
end


function utils.strip_roman_numerals(str)
    --return str:sub(1, str:find('I*V?X?I*V?I*$')):trim()
    return str:match('^%s*(.-)%s*I*V?X?I*V?I*$')
end


--[[
    Add an 'enn' (english, normalized) entry to each relevant resource
--]]
local function normalize_action_names()
    local categories = {'spells', 'job_abilities', 'weapon_skills', 'buffs'}
    for _,cat in pairs(categories) do
        for id,entry in pairs(res[cat]) do
            res[cat][id].enn = utils.normalize_str(entry.en)
            res[cat][id].ja = nil
            res[cat][id].jal = nil
        end
    end
end
normalize_action_names()


utils.txtbox_cmd_map = {
    moveinfo = 'moveInfo',          actioninfo = 'actionInfo',
    showq = 'actionQueue',          showqueue = 'actionQueue',
    queue = 'actionQueue',          monitored = 'montoredBox',
    showmonitored = 'montoredBox',
}




-- not used?
function utils.normalized_mob(mob)
    if istable(mob) then
        return mob
    elseif isnum(mob) then
        return windower.ffxi.get_mob_by_id(mob)
    end
    return mob
end


function utils.register_immunity(mob, debuff)
    utils.immunities[mob.name] = S(utils.immunities[mob.name]) or S{}
    utils.immunities[mob.name]:add(debuff.id)
    utils.immunities:save()
end

function utils.posCommand(boxName, args)
    local cmd = args[2]:lower()
    if not S{'pos','posx','posy'}:contains(cmd) then
        return false
    end
    local x,y = tonumber(args[3]),tonumber(args[4])
    if (cmd == 'pos') then
        if (x == nil) or (y == nil) then return false end
        settings.textBoxes[boxName].x = x
        settings.textBoxes[boxName].y = y
    elseif (cmd == 'posx') then
        if (x == nil) then return false end
        settings.textBoxes[boxName].x = x
    elseif (cmd == 'posy') then
        if (y == nil) then return false end
        settings.textBoxes[boxName].y = y
    end
    return true
end

function utils.toggleVisible(boxName, cmd)
    cmd = cmd and cmd:lower() or (settings.textBoxes[boxName].visible and 'off' or 'on')
    if (cmd == 'on') then
        settings.textBoxes[boxName].visible = true
    elseif (cmd == 'off') then
        settings.textBoxes[boxName].visible = false
    else
        atc(123,'Invalid argument for changing text box settings: '..cmd)
    end
end

function utils.toggleX(tbl, field, cmd, msg, msgErr)
    if (tbl[field] == nil) then
        atcf(123, 'Error: Invalid mode to toggle: %s', field)
        return
    end
    cmd = cmd and cmd:lower() or (tbl[field] and 'off' or 'on')
    if (cmd == 'on') then
        tbl[field] = true
        atc(msg..' is now on.')
    elseif (cmd == 'off') then
        tbl[field] = false
        atc(msg..' is now off.')
    else
        atc(123,'Invalid argument for '..msgErr..': '..cmd)
    end
end

function toggleMode(mode, cmd, msg, msgErr)
    utils.toggleX(otto.modes, mode, cmd, msg, msgErr)
    _libs.lor.debug = otto.modes.debug
end

function utils.disableCommand(cmd, disable)
    local msg = ' is now '..(disable and 'disabled.' or 're-enabled.')
    if S{'cure','cures','curing'}:contains(cmd) then
        if (not disable) then
            if (user_settings.healer.healing.max.cure == 0) then
                atc(123,'Error: Unable to enable curing because you have no Cure spells available.')
                return
            end
        end
        atc('Curing'..msg)
    elseif S{'na','heal_debuff','cure_debuff'}:contains(cmd) then
        user_settings.healer.disable.na = disable
        atc('Removal of status effects'..msg)
    
    
    elseif S{'buff','buffs','buffing'}:contains(cmd) then
        settings.disable.buff = disable
        atc('Buffing'..msg)
    elseif S{'debuff','debuffs','debuffing'}:contains(cmd) then
        settings.disable.debuff = disable
        atc('Debuffing'..msg)
    elseif S{'spam','nuke','nukes','nuking'}:contains(cmd) then
        settings.disable.spam = disable
        atc('Spamming'..msg)
    elseif S{'ws','weaponskill','weaponskills','weaponskilling'}:contains(cmd) then
        settings.disable.ws = disable
        atc('Weaponskilling'..msg)
    else
        atc(123,'Error: Invalid argument for disable/enable: '..cmd)
    end
end


--==============================================================================
--          String Formatting Functions
--==============================================================================

function utils.formatActionName(text)
    if (type(text) ~= 'string') or (#text < 1) then return nil end
    
    
    local spell_from_lc = lc_res.spells[text:lower()]
    if spell_from_lc ~= nil then
        return spell_from_lc.en
    end
    
    local parts = text:split(' ')
    if #parts >= 2 then
        local name = formatName(parts[1])
        for p = 2, #parts do
            local part = parts[p]
            local tier = toRomanNumeral(part) or part:upper()
            if (roman2dec[tier] == nil) then
                name = name..' '..formatName(part)
            else
                name = name..' '..tier
            end
        end
        return name
    else
        local name = formatName(text)
        local tier = text:sub(-1)
        local rnTier = toRomanNumeral(tier)
        if (rnTier ~= nil) then
            return name:sub(1, #name-1)..' '..rnTier
        else
            return name
        end
    end
end

function formatName(text)
    if (text ~= nil) and (type(text) == 'string') then
        return text:lower():ucfirst()
    end
    return text
end

function toRomanNumeral(val)
    if type(val) ~= 'number' then
        if type(val) == 'string' then
            val = tonumber(val)
        else
            return nil
        end
    end
    return dec2roman[val]
end


--==============================================================================
--          Initialization Functions
--==============================================================================
function utils.refresh_config()
    local player = windower.ffxi.get_player()
    user_settings = lor_settings.load('data/'..player.name..'/user_settings.lua')
    atcc(262, 'Reloaded config files.')
end

function utils.load_configs()
    local defaults = {
        textBoxes = {
            actionQueue={x=-125,y=300,font='Arial',size=10,visible=true},
            moveInfo={x=0,y=18,visible=false},
            actionInfo={x=0,y=0,visible=true},
            montoredBox={x=-150,y=600,font='Arial',size=10,visible=true}
        }
    }
    local loaded = lor_settings.load('data/settings.lua', defaults)
    local player = windower.ffxi.get_player()
    user_settings = lor_settings.load('data/'..player.name..'/user_settings.lua')

    utils.update_settings(loaded)
    utils.refresh_textBoxes()
    
    local cure_potency_defaults = {
        cure = {94,207,469,880,1110,1395},  curaga = {150,313,636,1125,1510},
        waltz = {157,325,581,887,1156},     waltzga = {160,521}
    }

    
    otto.config = {
        
        mabil_debuffs = lor_settings.load('data/mabil_debuffs.lua'),
        priorities = lor_settings.load('data/priorities.lua'),
        cure_potency = lor_settings.load('data/cure_potency.lua', cure_potency_defaults),
        maspir_immunities = lor_settings.load('data/maspir_immunities.lua'),
        sleep_immunities = lor_settings.load('data/sleep_immunities.lua'),
        ipc_monitored_boxes = lor_settings.load('data/ipc_monitored_boxes.lua'),
        monster_ability_dispelables = lor_settings.load('data/monster_ability_dispelables.lua')
    }

    if otto.config.ipc_monitored_boxes:empty() or otto.config.ipc_monitored_boxes[player.name] == nil then
        otto.config.ipc_monitored_boxes[player.name] = true
        otto.config.ipc_monitored_boxes:save()
    end

    otto.config.priorities.players =        otto.config.priorities.players or {}
    otto.config.priorities.jobs =           otto.config.priorities.jobs or {}
    otto.config.priorities.status_removal = otto.config.priorities.status_removal or {}
    otto.config.priorities.buffs =          otto.config.priorities.buffs or {}
    otto.config.priorities.debuffs =        otto.config.priorities.debuffs or {}
    otto.config.priorities.dispel =         otto.config.priorities.dispel or {}     --not implemented yet
    otto.config.priorities.default =        otto.config.priorities.default or 5
    --process_mabil_debuffs()
    local msg = otto.configs_loaded and 'Rel' or 'L'
    otto.configs_loaded = true
    atcc(262, msg..'oaded config files.')
end


function process_mabil_debuffs()
    local debuff_names = table.keys(otto.config.mabil_debuffs)
    for _,abil_raw in pairs(debuff_names) do
        local abil_fixed = abil_raw:gsub('_',' '):capitalize()
        otto.config.mabil_debuffs[abil_fixed] = S{}
        local debuffs = otto.config.mabil_debuffs[abil_raw]
        for _,debuff in pairs(debuffs) do
            otto.config.mabil_debuffs[abil_fixed]:add(debuff)
        end
        otto.config.mabil_debuffs[abil_raw] = nil
    end
    otto.config.mabil_debuffs:save()
end

function utils.update_settings(loaded)
    for key,val in pairs(loaded) do
        if istable(val) then
            settings[key] = settings[key] or {}
            for skey,sval in pairs(val) do
                settings[key][skey] = sval
            end
        else
            settings[key] = settings[key] or val
        end
    end
    table.update_if_not_set(settings, {
        disable = {},
        follow = {delay = 0.08, distance = 3},
        healing = {minCure = 3, minCuraga = 1, minWaltz = 2, minWaltzga = 1},
        spam = {}
    })
end

function utils.refresh_textBoxes()
    local boxes = {'actionQueue','moveInfo','actionInfo','montoredBox'}
    for _,box in pairs(boxes) do
        local bs = settings.textBoxes[box]
        local bst = {pos={x=bs.x, y=bs.y}}
        bst.flags = {right=(bs.x < 0), bottom=(bs.y < 0)}
        if (bs.font ~= nil) then
            bst.text = {font=bs.font}
        end
        if (bs.size ~= nil) then
            bst.text = bst.text or {}
            bst.text.size = bs.size
        end
        
        if (otto.txts[box] ~= nil) then
            otto.txts[box]:destroy()
        end
        otto.txts[box] = texts.new(bst)
    end
end

function merge(a, b)
    local c = {}
    for k,v in pairs(a) do c[k] = v end
    for k,v in pairs(b) do c[k] = v end
    return c
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


--======================================================================================================================
--                      Misc.
--======================================================================================================================

function help_text()
    local t = '    '
    local ac,cc,dc = 262,263,1
    atcc(262,'HealBot Commands:')
    local cmds = {
        {'on | off','Activate / deactivate HealBot (does not affect follow)'},
        {'reload','Reload HealBot, resetting everything'},
        {'refresh','Reloads settings XMLs in addons/HealBot/data/'},
        {'fcmd','Sets a player to follow, the distance to maintain, or toggles being active with no argument'},
        {'buff <player> <spell>[, <spell>[, ...]]','Sets spell(s) to be maintained on the given player'},
        {'cancelbuff <player> <spell>[, <spell>[, ...]]','Un-sets spell(s) to be maintained on the given player'},
        {'blcmd','Sets the given list of spells to be maintained on the given player'},
        {'bufflists','Lists the currently configured spells/abilities in each bufflist'},
        {'spam [use <spell> | <bool>]','Sets the spell to be spammed on assist target\'s enemy, or toggles being active (default: Stone, off)'},
        {'dbcmd','Add/remove debuff spell to maintain on assist target\'s enemy, toggle on/off, or list current debuffs to maintain'},
        {'mincure <number>','Sets the minimum cure spell tier to cast (default: 3)'},
        {'disable <action type>','Disables actions of a given type (cure, buff, na)'},
        {'enable <action type>','Re-enables actions of a given type (cure, buff, na) if they were disabled'},
        {'reset [buffs | debuffs | both [on <player>]]','Resets the list of buffs/debuffs that have been detected, optionally for a single player'},
        {'ignore_debuff <player/always> <debuff>','Ignores when the given debuff is cast on the given player or everyone'},
        {'unignore_debuff <player/always> <debuff>','Stops ignoring the given debuff for the given player or everyone'},
        {'ignore <player>','Ignores the given player/npc so they will not be healed'},
        {'unignore <player>','Stops ignoring the given player/npc (=/= watch)'},
        {'watch <player>','Monitors the given player/npc so they will be healed'},
        {'unwatch <player>','Stops monitoring the given player/npc (=/= ignore)'},
        {'ascmd','Sets a player to assist, toggles whether or not to engage, or toggles being active with no argument'},
        {'wscmd1','Sets the weaponskill to use'},
        {'wscmd2','Sets when weaponskills should be used according to whether the mob HP is < or > the given amount'},
        {'wscmd3','Sets a weaponskill partner to open skillchains for, and the TP that they should have'},
        {'wscmd4','Removes a weaponskill partner so weaponskills will be performed independently'},
        {'queue [pos <x> <y> | on | off]','Moves action queue, or toggles display with no argument (default: on)'},
        {'actioninfo [pos <x> <y> | on | off]','Moves character status info, or toggles display with no argument (default: on)'},
        {'moveinfo [pos <x> <y> | on | off]','Moves movement status info, or toggles display with no argument (default: off)'},
        {'monitored [pos <x> <y> | on | off]','Moves monitored player list, or toggles display with no argument (default: on)'},
        {'help','Displays this help text'}
    }
    local acmds = {
        ['fcmd']=('f'):colorize(ac,cc)..'ollow [<player> | dist <distance> | off | resume]',
        ['ascmd']=('as'):colorize(ac,cc)..'sist [<player> | attack | off | resume]',
        ['wscmd1']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill use <ws name>',
        ['wscmd2']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill hp <sign> <mob hp%>',
        ['wscmd3']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill waitfor <player> <tp>',
        ['wscmd4']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill nopartner',
        ['dbcmd']=('d'):colorize(ac,cc)..'e'..('b'):colorize(ac,cc)..'uff [(use | rm) <spell> | on | off | ls]',
        ['blcmd']=('b'):colorize(ac,cc)..'uff'..('l'):colorize(ac,cc)..'ist <list name> (<player>)',
    }
    
    for _,tbl in pairs(cmds) do
        local cmd,desc = tbl[1],tbl[2]
        local txta = cmd
        if (acmds[cmd] ~= nil) then
            txta = acmds[cmd]
        else
            txta = txta:colorize(cc)
        end
        local txtb = desc:colorize(dc)
        atc(txta)
        atc(t..txtb)
    end
end

-- magic burst cast types
function utils.cast_types()
    return  T{'spell', 'helix', 'ga', 'ja', 'ra', 'jutsu', 'white', 'holy'}
end


--======================================================================================================================
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the
      following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
      following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
--]]
--======================================================================================================================
