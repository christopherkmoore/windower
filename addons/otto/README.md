A note to anyone looking to add this.

This is not at all in a stable state. If you want to know the commands available at any given time, you'll have a better time
finding the most up-to-date version in otto_events until it stabilizes.

In order to run, this requires lor/libs  https://github.com/lorand-ffxi/lor_libs

Those should go one directory up into ../libs/lor_libs

Dunno who the guy is but he wrote a lot of extremely useful code. Same with Ivaar. If I get anywhere near a stable version for this, it will be mostly 
off of what he has done from those libs and healbot.




wants
sub-job
rdm 
pass / lot

TEST
test updated moving and replace actor calls

Bugs
add debuff immunity check to debuffs
pld also can use buffs and debuffs now, remove old code. + update scripts
Bards song get messed up.
I think cure step down maybe not working?
fight can't update allies when zoning so add a tick and a piece of code that knows when they're zoning, and set up delays like other jobs

TODO
- Now that I have this shining one, It might be time for step based skill chains.
- maybe it should be like otto job on and otto on (top level enabled and job enabled.)
- something that parses if my target casts spells and uses it for silence
- add to assist, so it will have a new command (which is the fight style)
    - fight - master is free to move, people follow master.
    - trash, Have people auto-fight and free kill mobs. DD's take unique targets.
    - planted (everyone just stays still, good for xp)
    - boss (maybe you wanna have the tank target one mob and dds another?)
    - target master target (to fix my targetnpc script)
- draw something that shows actions taken?
- I could move job delays into player.delay.. and use a single action handler to update the delays.
- find a way to use coroutines for job ticks, that way you could clean them up when the job is off.
- The dispel monster immunities is wrong...
- AutoCOR? Dunno seems pretty simple... buffs i guess?
- get rid of indiviual job on's in the script. can just be otto on now and start does init for 
everyones job. The individual commands will still work tho


Finish EMPY
SAM, PLD, COR
Dyna D          -- 60 hour ( 3 day lock)   - farm Neck RP + shards for upgrades, prog for waves
Sortie          -- 20 hour                 - farm gal + earing + stones for +3 empy
Odys            -- 20 hour                 - farm segs and progress gaol
Card Farm       -- 20 hours (stax 3)       - Boss drops, plus gil drops

Gil
Ambuscade
Sparks


ALTS 
always -
    Coalitions
    Ambu for a while
    XP
    Domain Invasion

Missions -
    FInish ToAH 
    finish Wings
    Finish voracious 

Gear -
https://www.bg-wiki.com/ffxi/Deacon_Sword
    RDM AF - Empy - Relic
    BLM AF - Empy - Relic - MB set

Weapons
    RDM - enspell sword, MB staff? Enfeeble + enhance weapon
    BLM - MB weapon

    WHM / RDM Oranyan -> Enhancing magic +10% Duration
Accessories

Random-
    Finish Dyna
    -> Outlands + tav 

Finish Omen stuff. 
BLM
Nefarious Collar +1
Halasz earring
Niobid strap

JSE Cape GEO => Indi Duration (percent bonus is better than duration bonus, maybe?)
JSE Cape RDM -> Enhancing magic duration.

*do af quests COR, PLD, BRD (feet), SAM