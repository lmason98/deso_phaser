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
		local top_cpy = top
		top = bottom
		bottom = top_cpy
	end

	if (top.z - (top.z / 2) > ground) then
		return false
	end
	
	return true
end

/*-------------------------------------------
	Name: deso.phase.CalcWidth(width, time, timeLeft)
	Desc: Calculates width for the phaser bar
	Return: Number
-------------------------------------------*/
function deso.phase.CalcWidth(width, time, timeLeft)
	local num = width / time

	return width - timeLeft * num
end

/*-------------------------------------------
	Name: deso.phase.CalcColor(width, time, timeLeft)
	Desc: Calculates color for the phaser bar
	Return: Color
-------------------------------------------*/
function deso.phase.CalcColor(width, time, timeLeft)
	local num = 255 / time

	print(timeLeft)

	return Color(timeLeft * num, 255 - timeLeft * num, 5)
end