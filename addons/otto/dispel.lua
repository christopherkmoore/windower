-- for the time being this is super primitive. Ideally i'm thinking action handlers for categories mob finsih tp or mob finish spell to scan for stuff
-- that needs to be edispelled. 

-- when dispel is added and resolved, scan to confirm removal. Then add to mob_ability_dispellables to track which can be dispelled.

local dispel = {}

local dispels = { 
    dispel = {id=260,en="Dispel",ja="ディスペル",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[5]=32,[20]=32},mp_cost=25,prefix="/magic",range=12,recast=10,recast_id=260,requirements=6,skill=35,targets=32,type="BlackMagic"},
    dispelga = {id=360,en="Dispelga",ja="ディスペガ",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[3]=99,[4]=99,[5]=99,[10]=99,[15]=99,[20]=99,[21]=99},mp_cost=200,prefix="/magic",range=12,recast=10,recast_id=360,requirements=0,skill=35,targets=32,type="BlackMagic",unlearnable=true},
    finale = {id=462,en="Magic Finale",ja="魔法のフィナーレ",cast_time=2,element=6,icon_id=-1,icon_id_nq=38,levels={[10]=33},mp_cost=0,prefix="/song",range=12,recast=24,recast_id=462,requirements=0,skill=40,targets=32,type="BardSong"},
    blank_gaze = {id=592,en="Blank Gaze",ja="ブランクゲイズ",blu_points=2,cast_time=3,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=38},mp_cost=25,prefix="/magic",range=9,recast=10,recast_id=592,requirements=0,skill=43,targets=32,type="BlueMagic"},
    geist_wall = {id=605,en="Geist Wall",ja="ガイストウォール",blu_points=3,cast_time=3,element=7,icon_id=-1,icon_id_nq=63,levels={[16]=46},mp_cost=35,prefix="/magic",range=4,recast=30,recast_id=605,requirements=0,skill=43,targets=32,type="BlueMagic"},
    dark_shot = {id=132,en="Dark Shot",ja="ダークショット",element=7,icon_id=495,mp_cost=1,prefix="/jobability",range=12,recast_id=195,targets=32,tp_cost=0,type="CorsairShot"},
}

local jobs_can_dispel = S{ 'BRD', 'RDM', 'BLU', 'COR'}


function dispel.init()

    local defaults = { }
	defaults.enabled = false       -- top level enable toggle. on | off

    if user_settings.dispel == nil then
        user_settings.dispel = defaults
        user_settings:save()
    end

end

function dispel.should_dispel(id)
    if not user_settings.dispel.enabled then return end

    local player = windower.ffxi.get_player()
    local can_dispel = jobs_can_dispel:contains(player.main_job) 

    if not can_dispel then return end

    if offense.dispel ~= nil and offense.dispel[id] ~= nil and offense.dispel[id] == true then
        table.vprint(offense.dispel)

        if player.main_job == 'BRD' and not offense.checkNukingQueueFor(dispels.finale) then
            offense.addToNukeingQueue(dispels.finale)
        elseif player.main_job == 'RDM' and not offense.checkNukingQueueFor(dispels.dispel) then
            offense.addToNukeingQueue(dispels.dispel)
        elseif player.main_job == 'BLU' and not offense.checkNukingQueueFor(dispels.blank_gaze) then
            offense.addToNukeingQueue(dispels.blank_gaze)
        elseif player.main_job == 'COR' and not offense.checkNukingQueueFor(dispels.dark_shot) then 
            offense.addToNukeingQueue(dispels.dark_shot)
        end

        offense.dispel[id] = nil -- proimitive removal (should scan messages or actions for removal confirmation.)
    end

end

return dispel