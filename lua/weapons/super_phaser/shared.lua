AddCSLuaFile()

SWEP.PrintName = "Super Phaser"
SWEP.Author = "MrRalgoman"
SWEP.Instructions = "Left click to shoot a phase grenade!"
SWEP.Spawnable = true
SWEP.AdminOnly = false

/*----- Cfg -----*/
SWEP.prepareTime = 5  -- How long the super phaser has to warm up for
SWEP.reloadTime = 1 -- How long it takes to reload
SWEP.blipTime = 1 -- How many seconds inbetween blips
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

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "phase_bomb"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

local defaultRun, defaultWalk = 240, 160
local usingRun, usingWalk = 80, 80
local reloadCooldown = false

local blipSound = Sound("buttons/blip1.wav")
local reloadSound = Sound("weapons/ar2/ar2_reload.wav")
local shootSound = Sound("physics/wood/wood_box_impact_hard3.wav")

/*---------------------------------------------------------
   Name: SWEP:SetupDataTables()
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsPhasing")
	self:NetworkVar("Bool", 1, "IsDown")
	self:NetworkVar("Float", 0, "PhaseStartTime")
	self:NetworkVar("Float", 1, "PhaseEndTime")
	self:NetworkVar("Int", 0, "WarmUp")
end

/*---------------------------------------------------------
   Name: SWEP:Initialize()
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetIsPhasing(false)
	self:SetPhaseStartTime(0)
	self:SetPhaseEndTime(0)
	self:SetWarmUp(self.prepareTime)
	self:SetHoldType(self.HoldType)
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Setting weapon anim
---------------------------------------------------------*/
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
	self:SetIsDown(true)
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: Begins warmup for the Super Phaser
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if (!self:GetIsPhasing() && !self:GetIsDown() && self:Clip1() > 0) then
		self:SetIsPhasing(true)

		self:SetPhaseStartTime(CurTime())
		self:SetPhaseEndTime(CurTime() + self:GetWarmUp())
	end
end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: Toggles whether the super phaser is up or down
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if (self:GetIsDown()) then
		self:Raise()
	else
		self:Lower(true)
	end
end

/*---------------------------------------------------------
   Name: SWEP:Reload()
   Desc: Handles reloading the Super Phaser
---------------------------------------------------------*/
function SWEP:Reload()
	if (self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 && !reloadCooldown) then
		reloadCooldown = true
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self.Owner:RemoveAmmo(1, self:GetPrimaryAmmoType())

		timer.Simple(0.5, function() self:SetClip1(1) self:EmitSound(reloadSound) end)
		timer.Simple(2, function() self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED) reloadCooldown = false end)
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Handles launching the phase grenade
---------------------------------------------------------*/
function SWEP:Think()
	if (self:GetIsPhasing() && self:GetPhaseEndTime() != 0) then
		if (CurTime() >= self:GetPhaseEndTime()) then
			self:Launch()
		end

		if (!blipTime || CurTime() >= blipTime + 2) then
			blipTime = CurTime() + self.blipTime
		end

		if (CurTime() >= blipTime) then
			blipTime = blipTime + self.blipTime

			self:EmitSound(blipSound)
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Launch()
   Desc: Launches the phase grenade
---------------------------------------------------------*/
function SWEP:Launch()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
	self:EmitSound(shootSound)

	if (SERVER) then
		local ent = ents.Create("phase_bomb")

		if (ent:IsValid() && !justLaunched) then
			ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
			ent:SetAngles(self.Owner:EyeAngles())
			ent:Spawn()

			local phys = ent:GetPhysicsObject()

			if (IsValid(phys)) then
				local velocity = self.Owner:GetAimVector()
				velocity = velocity * 750
				phys:ApplyForceCenter(velocity)
			end
		end
	end
	
	self:Lower(false)
	timer.Simple(0.5, function() self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED) end)
end

/*---------------------------------------------------------
   Name: SWEP:Raise()
   Desc: Raises the Super Phaser
---------------------------------------------------------*/
function SWEP:Raise()
	if (self:GetIsDown()) then
		self:SetIsDown(false)
		self:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE)
		
		self.Owner:SetWalkSpeed(usingWalk)
		self.Owner:SetRunSpeed(usingRun)
	end
end

/*---------------------------------------------------------
   Name: SWEP:Lower()
   Desc: Lowers the Super Phaser
---------------------------------------------------------*/
function SWEP:Lower(sendAnim)
	if (!self:GetIsDown()) then
		self:SetIsDown(true)
		if (sendAnim) then self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED) end
		self:SetIsPhasing(false)
		self:SetPhaseStartTime(0)
		self:SetPhaseEndTime(0)

		self.Owner:SetWalkSpeed(defaultWalk)
		self.Owner:SetRunSpeed(defaultRun)
	end
end

if (CLIENT) then
	/*---------------------------------------------------------
	Name: SWEP:DrawHUD()
	Desc: Draws progress bar
	---------------------------------------------------------*/
	function SWEP:DrawHUD()
		if (self:GetIsPhasing()) then
			local w = ScrW()
			local h = ScrH()
			local x, y, width, height = (w / 2) - 200, (h / 2) - 30, 400, 60
			local time =  self:GetPhaseEndTime() - self:GetPhaseStartTime()
			local timeLeft = self:GetPhaseEndTime() - CurTime()

			local progress = deso.phase.CalcWidth(width, time, timeLeft)
			local col = deso.phase.CalcColor(width, time, timeLeft)

			surface.SetDrawColor(deso.col.dark)
			surface.DrawRect(x, y, width, height)

			surface.SetDrawColor(col)
			surface.DrawRect(x, y, progress, height)

			surface.SetDrawColor(deso.col.outline)
			surface.DrawOutlinedRect(x, y, width, height)
			surface.DrawOutlinedRect(x + 1, y - 1, width - 2, height + 2)

			draw.SimpleTextOutlined("Preparing", "deso_hud_reserve", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, deso.col.outline)
		end
	end
end