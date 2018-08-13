if (SERVER) then
	deso = deso || {}
	deso.phase = deso.phase || {}

	AddCSLuaFile "desophaser/client/cl_fonts.lua"
	AddCSLuaFile "desophaser/client/cl_desophaser.lua"

	include "desophaser/server/sv_desophaser.lua"
	include "desophaser/sv_main.lua"
end

if (CLIENT) then
	deso = deso || {}
	deso.phase = deso.phase || {}

	include "desophaser/client/cl_fonts.lua"
	include "desophaser/client/cl_desophaser.lua"
end

game.AddAmmoType( {
	name = "phase_bomb",
	dmgtype = DMG_BLAST,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 1000,
	minsplash = 10,
	maxsplash = 5
} )