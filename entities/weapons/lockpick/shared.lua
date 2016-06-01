if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Lock Pick"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Rickster"
SWEP.Instructions = "Left click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	if SERVER then
		self:SetWeaponHoldType("Crowbar")
	end
	util.PrecacheSound("physics/flesh/flesh_impact_bullet" .. math.random(3, 5) .. ".wav")
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .4)

	local trace = self.Owner:GetEyeTrace()
	local bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 1
	bullet.Damage = 0

	local e = trace.Entity
	if e ~= nil then
		if (trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 and not e:IsDoor() and not e:IsVehicle()) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:FireBullets(bullet)
			self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(3, 5) .. ".wav")
		elseif (IsValid(e) and (trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 and (e:IsDoor() or e:IsVehicle()))) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:FireBullets(bullet)
			self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(3, 5) .. ".wav")
			if (math.random(1, 100) < 6) then
				if trace.Entity.Fire then
					trace.Entity:Fire("unlock", "", .5)
					trace.Entity:Fire("open", "", .6)
				end
			end
		else
			self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
			self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		end
	end
end
