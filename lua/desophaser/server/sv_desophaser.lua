local ground = -203

/*-------------------------------------------
	Name: deso.phase.IsInGround()
	Desc: Determines whether a prop is halfway in the ground or not.
	Return: Bool
-------------------------------------------*/
function deso.phase.IsInGround(prop)
	local top = prop:LocalToWorld(prop:OBBMaxs())
	local bottom = prop:LocalToWorld(prop:OBBMins())
	local height = (-top.z + bottom.z)

	if (bottom.z > top.z) then
		top_cpy = top
		top = bottom
		bottom = top_cpy
	end

	if (top.z - (top.z / 2) > ground) then
		return false
	end
	
	return true
end