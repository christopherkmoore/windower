A note to anyone looking to add this.

This is not at all in a stable state. If you want to know the commands available at any given time, you'll have a better time
finding the most up-to-date version in otto_events until it stabilizes.

In order to run, this requires lor/libs  https://github.com/lorand-ffxi/lor_libs

Those should go one directory up into ../libs/lor_libs

Dunno who the guy is but he wrote a lot of extremely useful code. Same with Ivaar. If I get anywhere near a stable version for this, it will be mostly 
off of what he has done from those libs and healbot.

Available commands\
    'reload', 'r'               -> reloads and resets to default settings.                otto r\
    'tier', 't' + some tier     -> sets aspir tier.                                       otto t 3\
    'mp' + some mp              -> sets the mp percent threshhold to begin aspiring at.   otto mp 80\
    'on', 'enable', 'start',    -> starts otto.                                           otto on / otto enable / otto start\
    'off', 'disable', 'stop',   -> stops otto.                                            otto off / otto disable / otto stop\
    'all', 'single',            -> a single Aspir, or cast recursively 
                                   until they're all on cooldown. otto all                otto single\
    'assist' + some target      -> sets a battle assist target.                           otto assist twochix \



-- todo\ 
singer?\
    things I don't like about singer
    when you die it completely fucks everything
    very often gets out of whack from using timers
    doesn't know when buffs miss
    
    things I like about singer
    waits until everyone is in range.
    good support for using an ability + an action (pianissimo + ballad)

-- added\
aspir
magicburst
assist / targeting
pulling
buffs /debuffs
healing
weaponskill / skillchains
dispel
pre actions
jobs/geo

wants
sub-job
whm regens
rdm 
bard
pass / lot
add comments for names on the resists?

Bugs
dispel false isn't working for first time on new mobs
fix whm erase-ga (it's breaking buffs because of prioritization.) -- maybe fixed?
clean up vprint logs
weaponskill / magicburst carries to new target.
make queue more efficient
add checks -- aspir is targeting any target
maybe curaga deciding could use a bit of touch up?

TODO
aspir is targeting any target -- offensive action need better conditions for performing
add global on / off
bug in assist for backline roles. -- offensive action need better conditions for performing
gearswap not swapping rings.

ALTS 
always -
    Coalitions
    Ambu for a while
    XP
    Domain Invasion

Missions -
    Finish ZM
    Finish CoP
    FInish ToAH 
    finish Wings
    finish Adoulin 
    finish Rhapsodies
    Finish voracious 

Gear -
    RDM AF - Empy - Relic
    BLM AF - Empy - Relic - MB set

Weapons
    RDM - enspell sword, MB staff? Enfeeble + enhance weapon
    BLM - MB weapon
Accessories

Random-
    Finish Dyna


Later -
Dyna D
Ody
Omen
Lillith