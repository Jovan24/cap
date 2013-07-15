/*
	Kawoosh hurt entity
	Copyright (C) 2012  by AlexALX
*/

--################# HEADER #################
if (not StarGate.CheckModule("base")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.NotTeleportable = true;
ENT.NoDissolve = true;
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

function ENT:KeyValue( key, value )
	if ( key == "Damage" ) then
		self.Damage = value;
	elseif ( key == "DamageType" ) then
		self.DamageType = value;
	elseif ( key == "DamageRadius" ) then
		self.Radius = value;
	end
end

function ENT:Initialize()
	self.Radius = self.Radius or 0;
	self.Damage = self.Damage or 0;
	self.DamageType = self.DamageType or 0;
end

function ENT:AcceptInput( name, activator, caller, data )
    if (name == "hurt") then
		-- damage
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( self.Damage )
		dmginfo:SetDamageType( self.DamageType )
		dmginfo:SetAttacker( self.Entity )
		dmginfo:SetInflictor( self.Entity )
		dmginfo:SetDamageForce( Vector( 0, 0, 1000 ) )

		local parent = self.Entity:GetParent();

		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Radius)) do
			if (IsValid(v)) then
				if(not (parent.Attached[v] or v.GateSpawnerSpawned or v.NoDissolve)) then
					if(not parent.Attached[v:GetParent()] and not parent.Attached[v:GetDerive()]) then
						v:TakeDamageInfo(dmginfo);
					end
				end
			end
		end
    elseif (name == "kill") then
        self.Entity:Remove();
    end
end