AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_init.lua"

include "shared.lua"

local explodeSound = "npc/assassin/ball_zap1.wav"

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
	self.phaseRadius = 250
	self.idleTime = 3.5 -- how many seconds after launch should it detonate
	self.phaseTime = 5 -- how many seconds a prop should be phased for
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
	local col = prop:GetColor()
	prop:SetRenderMode(RENDERMODE_TRANSALPHA)
	prop:SetColor(Color(col.r, col.g, col.b, 50))
	prop:SetSolid(SOLID_NONE)
	prop.phased = true

	timer.Simple(self.phaseTime, function() 
		prop:SetColor(Color(255, 255, 255)) 
		prop:SetSolid(SOLID_VPHYSICS)
		prop.phased = false
	end)
end

/*---------------------------------------------------------
   Name: ENT:Detonate()
   Desc: Handles finding the props to phase
---------------------------------------------------------*/
function ENT:Detonate()
	for i = 1, 3 do
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		effect:SetScale(3)
		effect:SetRadius(5)
		effect:SetMagnitude(4)
		util.Effect("Sparks", effect)
	end

	for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.phaseRadius)) do
		if (ent:GetClass() == "prop_physics") then
			self:PhaseProp(ent)
		end
	end

	self:EmitSound(explodeSound)

	self:Remove()
end