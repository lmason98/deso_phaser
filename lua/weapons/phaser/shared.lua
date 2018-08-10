AddCSLuaFile()

SWEP.PrintName = "Phaser"
SWEP.Author = "MrRalgoman"
SWEP.Instructions = "Left click to Phase a fading door!"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "DesoWeps"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType = "rpg"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
--SWEP.Primary.Sound = Sound("ambient/energy/spark5.wav")
SWEP.Primary.Cooldown = 5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

/*---------------------------------------------------------
   Name: SWEP:SetupDataTables()
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsPhasing")
	self:NetworkVar("Entity", 0, "PhaseEnt")
	self:NetworkVar("Float", 0, "PhaseStartTime")
	self:NetworkVar("Float", 1, "PhaseEndTime")
end

/*---------------------------------------------------------
   Name: SWEP:Initialize()
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetIsPhasing(false)
	self:SetPhaseEnt(nil)
	self:SetPhaseStartTime(0)
	self:SetPhaseEndTime(0)
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: Begins phasing a prop
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()
	local ent, hitPos = trace.Entity, trace.HitPos

	if (ent && ent:IsValid()) then
		local selfPos = self.Owner:GetPos()
		dist = selfPos:Distance(hitPos)

		if (dist < 125 && ent:GetClass() == "prop_physics" && !deso.phase.IsInGround(ent) && !ent.phased) then
			self:SetIsPhasing(true)
			self:SetPhaseEnt(ent)
			self:SetPhaseStartTime(CurTime())
			self:SetPhaseEndTime(CurTime() + 1)
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
---------------------------------------------------------*/
function SWEP:Think()
	if (self:GetIsPhasing()) then
		local trace = self.Owner:GetEyeTrace()
		local ent, hitPos = trace.Entity, trace.HitPos

		if (ent && ent:IsValid()) then
			local selfPos = self.Owner:GetPos()
			dist = selfPos:Distance(hitPos)

			if (dist > 125 || ent:GetClass() != "prop_physics" || ent.phased) then
				self:Fail()
			elseif (self:GetPhaseEndTime() <= CurTime()) then
				self:Succeed()	
			end
		else
			self:Fail()
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:DrawHUD()
---------------------------------------------------------*/
if (CLIENT) then
	function SWEP:DrawHUD()
		print("cunt!")
		if (self:GetIsPhasing()) then
			local w = ScrW()
			local h = ScrH()
			local x, y, width, height = (w / 2) - 200, (h / 2) - 30, 400, 60
			local progress, col = 

			surface.SetDrawColor(deso.col.light)
			surface.DrawRect(x, y, width, height)

			surface.SetDrawColor(0, 255, 0)
			surface.DrawRect(x, y, width, height)

			surface.SetDrawColor(deso.col.outline)
			surface.DrawOutlinedRect(x, y, width, height)
			surface.DrawOutlinedRect(x + 1, y - 1, width - 2, height + 2)

			draw.SimpleText("Phasing", "deso_hud_reserve", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Succeed()
   Desc: Prop phase success
---------------------------------------------------------*/
function SWEP:Succeed()
	local ent = self:GetPhaseEnt()
	self:SetIsPhasing(false)
	self:SetPhaseEnt(nil)

	self:PhaseProp(ent)
	print("Succeed")
end

/*---------------------------------------------------------
   Name: SWEP:Fail()
   Desc: Prop phase fail
---------------------------------------------------------*/
function SWEP:Fail()
	self:SetIsPhasing(false)
	self:SetPhaseEnt(nil)
	print("Fail")
end

/*---------------------------------------------------------
   Name: SWEP:PhaseProp()
   Desc: Phases a prop
---------------------------------------------------------*/
function SWEP:PhaseProp(prop)
	local col = prop:GetColor()
	prop:SetColor(Color(col.r, col.g, col.b, 255))
	prop:SetColor(Color(col.r, col.g, col.b, 100))
	prop:SetSolid(SOLID_NONE)
	prop.phased = true

	timer.Simple(2, function() 
		prop:SetColor(Color(255, 255, 255)) 
		prop:SetSolid(SOLID_VPHYSICS)
		prop.phased = false
	end)
end