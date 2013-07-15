--[[
	Atanik Armband
	Copyright (C) 2012 Llapp
]]--

if (not StarGate.CheckModule("weapon")) then return end
if SERVER then
	AddCSLuaFile("shared.lua");
end
SWEP.PrintName = Language.GetMessage("weapon_misc_atanik");
SWEP.Category = Language.GetMessage("weapon_misc_cat");
SWEP.Author = "Llapp"
SWEP.Contact = "llapp612@googlemail.com"
SWEP.Purpose = "Atanik Armband"
SWEP.Instructions = "Makes you stronger and faster."
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Weapons/V_hands.mdl";
SWEP.WorldModel = "models/Weapons/w_bugbait.mdl";
SWEP.ViewModelFOV = 90
SWEP.AnimPrefix = "melee"
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);


SWEP.Primary.Delay			= 0.9
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize()
	if( SERVER ) then self:SetWeaponHoldType( "melee" ) end
	self.Hit = Sound( "player/pl_fallpain1.wav" );
	self.NextHit = 0;
end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.4 );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
	    local ent = tr.Entity
	 	-- thats prevent double playing sound in mp
	    if (SERVER) then
	   		self.Owner:EmitSound(self.Hit);
	    end
	    --self.Weapon:Hurt(55); -- And why this not working on dedicated server?!
	    bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(0.1, 0.1, 0)
		bullet.Tracer = 0
		bullet.Force  = 10
		bullet.Damage = 55
		self.Owner:FireBullets(bullet)
	end
end

function SWEP:SecondaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 1 );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		local ent = tr.Entity
		-- thats prevent double playing sound in mp
		if (SERVER) then
        	self.Owner:EmitSound(self.Hit);
        end
	    --self.Weapon:Hurt(200); -- And why this not working on dedicated server?!
	    bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Owner:GetShootPos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(0.1, 0.1, 0)
		bullet.Tracer = 0
		bullet.Force  = 10
		bullet.Damage = 200
		self.Owner:FireBullets(bullet)
	end
end

/*
function SWEP:Hurt(damage)
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.1, 0.1, 0)
	bullet.Tracer = 0
	bullet.Force  = 10
	bullet.Damage = damage
	self.Owner:FireBullets(bullet)
end */

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	draw.WordBox(8,ScrW()-315,ScrH()-50,"Melee mode: You are stronger and faster.","Default",Color(0,0,0,80),Color(255,220,0,220));
end
