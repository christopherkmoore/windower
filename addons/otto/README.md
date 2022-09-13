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

buffs\
debuffs\

parse out follow from healbot
parse out ws from healbot
parse out the ability to send target

auto-geo\
priority queues from HB\

ws + skillchains\


auto magic burst\
auto convert\

send commands to gearswap\
send commands to hb?\
send commands to singer?\

-- added\

auto aspir\
assist\
