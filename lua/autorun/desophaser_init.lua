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