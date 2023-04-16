Init()
{
    level.nuke_command_on_cooldown = false;
    level.nuke_command_remaining_time = 15 * 60;

    level thread Commands();
}

Commands()
{
	level endon("end_game");
	for(;;){
		level waittill("say", message, player);
		message = toLower(message);
		print(message);
		if(message == ".nuke" || message == "!nuke"){
			if (level.nuke_command_on_cooldown)
            {
				timeString = ParseTime(level.nuke_command_remaining_time);
                player IPrintLnBold("^1You need to wait " + timeString + " before you can run the nuke command again");
            }
            else
            {
                player KillAllZombies();
                level thread KillAllZombiesCooldown();
            }
		}
	}
}

ParseTime(totalSeconds) {
	minutes = totalSeconds / 60;
	seconds = totalSeconds % 60;
	
	strMinutes = " minutes ";
	strSeconds = " seconds ";
	
	if (seconds < 2) {
		strSeconds = " second ";
	} else {
		strSeconds = " seconds ";
	}
	
	if (minutes < 2) {
		strMinutes = " minute ";
	} else {
		strMinutes = " minutes ";
	}
	
	str = Int(minutes) + strMinutes + seconds + strSeconds;
	
	return str;
}

KillAllZombiesCooldown()
{
    level.nuke_command_on_cooldown = true;

    while (level.nuke_command_on_cooldown)
    {
        wait 1;

        level.nuke_command_remaining_time--;

        if (level.nuke_command_remaining_time <= 0)
        {
            level.nuke_command_on_cooldown = false;
            level.nuke_command_remaining_time = 15 * 60;
        }
    }
}

KillAllZombies()
{
    zombs = getaiarray("axis");
	level.zombie_total = 0;
	if(isdefined(zombs))
	{
		for(i = 0; i < zombs.size; i++)
		{
			zombs[i] dodamage(zombs[i].health * 5000,  0, 0, 0, self);
			wait(0.05);
		}
		
		self dopnuke();
		self iprintlnbold("Round have been unstucked ! i = " + lever.timer["nuke_timer"]);
	} else {
		self iprintlnbold("No zombies found, are you trying to exploit ?");
	}
}

dopnuke()
{
	foreach(player in level.players)
	{
		level thread maps/mp/zombies/_zm_powerups::nuke_powerup(self, player.team);
		player maps/mp/zombies/_zm_powerups::powerup_vo("nuke");
		zombies = getaiarray(level.zombie_team);
		player.zombie_nuked = arraysort(zombies, self.origin);
		player notify("nuke_triggered");
	}
	self iprintlnbold("Nuke Bomb ^2Send");
}