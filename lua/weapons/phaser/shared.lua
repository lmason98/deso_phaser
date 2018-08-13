AddCSLuaFile()

SWEP.PrintName = "Phaser"
SWEP.Author = "MrRalgoman"
SWEP.Instructions = "Left click to Phase a propw!"
SWEP.Spawnable = true
SWEP.AdminOnly = false

/*----- Cfg -----*/
SWEP.phaseLength = 5  -- How long a prop should stay phased
SWEP.holdLength = 2  -- How long you have to look at the prop to phase
/*---------------*/

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
SWEP.Primary.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")
SWEP.Primary.Cooldown = 5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

local defaultRun, defaultWalk

/*---------------------------------------------------------
   Name: SWEP:SetupDataTables()
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsPhasing")
	self:NetworkVar("Entity", 0, "PhaseEnt")
	self:NetworkVar("Float", 0, "PhaseStartTime")
	self:NetworkVar("Float", 1, "PhaseEndTime")
	self:NetworkVar("Int", 0, "PhaseLength")
	self:NetworkVar("Int", 1, "HoldLength")
end

/*---------------------------------------------------------
   Name: SWEP:Initialize()
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetIsPhasing(false)
	self:SetPhaseEnt(nil)
	self:SetPhaseStartTime(0)
	self:SetPhaseEndTime(0)
	self:SetPhaseLength(self.phaseLength)
	self:SetHoldLength(self.holdLength)
	self:SetHoldType(self.HoldType)
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

		if (dist < 100 && ent:GetClass() == "prop_physics" && !deso.phase.IsInGround(ent) && !ent.phased && !self:GetIsPhasing()) then
			defaultRun = self.Owner:GetRunSpeed()
			defaultWalk = self.Owner:GetWalkSpeed()
			self.Owner:SetWalkSpeed(defaultWalk - 150)
			self.Owner:SetRunSpeed(defaultRun - 250)

			self.Weapon:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE)

			timer.Simple(self.holdLength, function()
				if (self:IsValid()) then
					self.Owner:SetWalkSpeed(defaultWalk)
					self.Owner:SetRunSpeed(defaultRun)
				end
			end)

			self:SetIsPhasing(true)
			self:SetPhaseEnt(ent)
			self:SetPhaseStartTime(CurTime())
			self:SetPhaseEndTime(CurTime() + self:GetHoldLength())
			self.AllowIdleAnimation = false
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
---------------------------------------------------------*/
local sparkTime

function SWEP:Think()
	if (self:GetIsPhasing()) then
		local trace = self.Owner:GetEyeTrace()
		local ent, hitPos = trace.Entity, trace.HitPos

		if (ent && ent:IsValid()) then
			local selfPos = self.Owner:GetPos()
			dist = selfPos:Distance(hitPos)

			if (!sparkTime || CurTime() >= sparkTime + 2) then
				sparkTime = CurTime() + 0.5
			end

			if (CurTime() >= sparkTime) then
				sparkTime = sparkTime + 0.5

				timer.Simple(0.01, function()
					local effect = EffectData()
					effect:SetOrigin(self:GetPos() + self:GetAngles():Forward() * 50)
					effect:SetScale(1)
					effect:SetRadius(4)
					effect:SetMagnitude(3)
					util.Effect("Sparks", effect)
				end)
			end

			if (dist > 100 || ent:GetClass() != "prop_physics" || ent.phased) then
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
   Name: SWEP:Deploy()
   Desc: Setting weapon anim
---------------------------------------------------------*/
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
end

/*---------------------------------------------------------
   Name: SWEP:DrawHUD()
   Desc: Draw's progress bar
---------------------------------------------------------*/
if (CLIENT) then
	function SWEP:DrawHUD()
		if (self:GetIsPhasing()) then
			local w = ScrW()
			local h = ScrH()
			local x, y, width, height = (w / 2) - 200, (h / 2) - 30, 400, 60
			local time =  self:GetPhaseEndTime() - self:GetPhaseStartTime()
			local timeLeft = self:GetPhaseEndTime() - CurTime()

			local progress = deso.phase.CalcWidth(width, time, timeLeft)
			local col = deso.phase.CalcColor(width, time, timeLeft)

			surface.SetDrawColor(deso.col.light)
			surface.DrawRect(x, y, width, height)

			surface.SetDrawColor(col)
			surface.DrawRect(x, y, progress, height)

			surface.SetDrawColor(deso.col.outline)
			surface.DrawOutlinedRect(x, y, width, height)
			surface.DrawOutlinedRect(x + 1, y - 1, width - 2, height + 2)

			draw.SimpleTextOutlined("Phasing", "deso_hud_reserve", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, deso.col.outline)
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

	self.Owner:SetWalkSpeed(defaultWalk)
	self.Owner:SetRunSpeed(defaultRun)

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	timer.Simple(0.5, function()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
	end)

	self:EmitSound(self.Primary.Sound)

	self:PhaseProp(ent)
end

/*---------------------------------------------------------
   Name: SWEP:Fail()
   Desc: Prop phase fail
---------------------------------------------------------*/
function SWEP:Fail()
	self.Owner:SetWalkSpeed(defaultWalk)
	self.Owner:SetRunSpeed(defaultRun)

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)

	self:SetIsPhasing(false)
	self:SetPhaseEnt(nil)
end

/*---------------------------------------------------------
   Name: SWEP:PhaseProp()
   Desc: Phases a prop
---------------------------------------------------------*/
function SWEP:PhaseProp(prop)
	local col = prop:GetColor()
	prop:SetRenderMode(RENDERMODE_TRANSALPHA)
	prop:SetColor(Color(col.r, col.g, col.b, 50))
	prop:SetSolid(SOLID_NONE)
	prop.phased = true

	timer.Simple(self:GetPhaseLength(), function() 
		prop:SetColor(Color(255, 255, 255)) 
		prop:SetSolid(SOLID_VPHYSICS)
		prop.phased = false
	end)
end