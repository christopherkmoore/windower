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

wants
geo
bard
abilities
compound actions
pass / lot

Bugs

dispel is barfing on other pts claimed mobs because nuke q uses 't' to assign target.
skillchains do not work well when multiple party members are fighting different mobs.
maybe otto off 
clean up vprint logs
weaponskill / magicburst carries to new target.
weaponskills will sometimes not close properly (action not being added to q in time?)
make queue more efficient
add checks -- aspir is targeting any target

TODO
with the addition of dispelling, nuke queue now needs triage... or does it. Nuke queue is added to and ephemeral and always prioritized first so... maybe not.

aspir is targeting any target
add global on / off
figure fucking targeting out
bug in assist for backline roles.
gearswap not swapping rings.
sometimes na gets caught on repeat (maybe messages no effect needs to be packet handled.)