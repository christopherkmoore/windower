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

wants
geo
bard
abilities
compound actions
dispels
pass / lot

Bugs

skillchains do not work well when multiple party members are fighting different mobs.
maybe otto off 
clean up vprint logs
sometimes puller thinks it has pulled when it hasn't?
weaponskill / magicburst carries to new target.
weaponskills will sometimes not close properly (action not being added to q in time?)
otto pull on - first target always makes everyone close in.
somethign wrong with targeting after long sessions. 'backline' roles will try to attack anything they target.
make queue more efficient
add checks -- aspir is targeting any target

TODO

aspir is targeting any target
add global on / off
add yalm range to monitored boxes
figure fucking targeting out
bug in assist for backline roles.
