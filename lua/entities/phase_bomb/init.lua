AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_init.lua"

include "shared.lua"

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	self:SetModel("models/weapons/w_grenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetGravity(100)

	/* ----- Cfg ----- */
	self.phaseRadius = 50
	self.idleTime = 3.5 -- how many seconds after launch should it detonate
	self.phaseTime = 25 -- how many seconds a prop should be phased for
	/* --------------- */

	self.detonateTime = CurTime() + self.idleTime

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
end

/*---------------------------------------------------------
   Name: ENT:Think()
   Desc: Handles phase bomb detonation
---------------------------------------------------------*/
function ENT:Think()
	if (CurTime() >= self.detonateTime) then
		self:Detonate()
	end
end

/*---------------------------------------------------------
   Name: ENT:PhaseProp()
   Desc: Phases a prop
---------------------------------------------------------*/
function ENT:PhaseProp(prop)

end

/*---------------------------------------------------------
   Name: ENT:Detonate()
   Desc: Handles finding the props to phase
---------------------------------------------------------*/
function ENT:Detonate()
	self:Remove()
end