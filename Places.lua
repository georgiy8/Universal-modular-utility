local Voxlblade = {
    Repo = "https://raw.githubusercontent.com/georgiy8/Voxlblade/main/",
    Modules = {
        { Name = "Movement", Order = 30 },
        { Name = "Visual", Order = 35 },
        { Name = "Misc", Order = 40 },
        { Name = "Autofarm", Order = 15 },
    },
}

local Pilgrammed = {
    Repo = "https://raw.githubusercontent.com/georgiy8/Pilgrammed/main/",
    Modules = {
        { Name = "Weapons", Order = 17 },
        { Name = "Fishing", Order = 18 },
    },
}

return {
    [8651781069] = Voxlblade,   -- main game
    [10562022172] = Voxlblade,  -- Hive dungeon
    [6735572261] = Pilgrammed,  -- Pilgrammed
}
