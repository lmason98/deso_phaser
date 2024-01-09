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
SWEP.Primary.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")
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
   Name: SWEP:PrimaryAttack()
   Desc: Begins warmup for the Super Phaser
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.5 )	
	self:Shoot()
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

-- A custom function we added. When you call this the player will fire a chair!
function SWEP:Shoot()
	local owner = self:GetOwner()
    print("Shoot !")

	-- Make sure the weapon is being held before trying to throw a chair
	if ( not owner:IsValid() ) then return end

	-- Play the shoot sound we precached earlier!
	self:EmitSound( self.Primary.Sound )
 
	-- If we're the client then this is as much as we want to do.
	-- We play the sound above on the client due to prediction.
	-- ( if we didn't they would feel a ping delay during multiplayer )
	if ( CLIENT ) then return end

	-- Create a prop_physics entity
	local ent = ents.Create( "phase_bomb" )

	-- Always make sure that created entities are actually created!
	if ( not ent:IsValid() ) then return end

	-- This is the same as owner:EyePos() + (self:GetOwner():GetAimVector() * 16)
	-- but the vector methods prevent duplicitous objects from being created
	-- which is faster and more memory efficient
	-- AimVector is not directly modified as it is used again later in the function
	local aimvec = owner:GetAimVector()
	local pos = aimvec * 16 -- This creates a new vector object
	pos:Add( owner:EyePos() ) -- This translates the local aimvector to world coordinates

	-- Set the position to the player's eye position plus 16 units forward.
	ent:SetPos( pos )

	-- Set the angles to the player'e eye angles. Then spawn it.
	ent:SetAngles( owner:EyeAngles() )
	ent:Spawn()
 
	-- Now get the physics object. Whenever we get a physics object
	-- we need to test to make sure its valid before using it.
	-- If it isn't then we'll remove the entity.
	local phys = ent:GetPhysicsObject()
	if ( not phys:IsValid() ) then ent:Remove() return end
 
	-- Now we apply the force - so the chair actually throws instead 
	-- of just falling to the ground. You can play with this value here
	-- to adjust how fast we throw it.
	-- Now that this is the last use of the aimvector vector we created,
	-- we can directly modify it instead of creating another copy
	aimvec:Mul( 10000 )
	aimvec:Add( VectorRand( -10, 10 ) ) -- Add a random vector with elements [-10, 10)
	phys:ApplyForceCenter( aimvec )
 
end