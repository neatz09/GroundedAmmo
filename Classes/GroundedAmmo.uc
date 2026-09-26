class GroundedAmmo extends Mutator;

var array<class<Weapon> > StockWeaponClasses;
var transient array<class<AmmoPickup> > StockAmmoPickupClasses;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.1, false);
}

function Timer()
{
	BuildStockAmmoPickupClasses();
	GroundStockAmmoPickups();
}

function BuildStockAmmoPickupClasses()
{
	local int WeaponIndex;
	local int FireModeIndex;
	local class<Weapon> WeaponClass;
	local class<AmmoPickup> AmmoPickupClass;

	StockAmmoPickupClasses.Length = 0;

	for (WeaponIndex = 0; WeaponIndex < StockWeaponClasses.Length; ++WeaponIndex)
	{
		WeaponClass = StockWeaponClasses[WeaponIndex];
		if (WeaponClass == None)
		{
			continue;
		}

		for (FireModeIndex = 0; FireModeIndex < ArrayCount(WeaponClass.default.FireModeClass); ++FireModeIndex)
		{
			if (WeaponClass.default.FireModeClass[FireModeIndex] == None
				|| WeaponClass.default.FireModeClass[FireModeIndex].default.AmmoClass == None
				|| WeaponClass.default.FireModeClass[FireModeIndex].default.AmmoClass.default.PickupClass == None)
			{
				continue;
			}

			AmmoPickupClass = class<AmmoPickup>(WeaponClass.default.FireModeClass[FireModeIndex].default.AmmoClass.default.PickupClass);
			if (AmmoPickupClass == None)
			{
				continue;
			}

			AddStockAmmoPickupClass(AmmoPickupClass);
		}
	}
}

function AddStockAmmoPickupClass(class<AmmoPickup> AmmoPickupClass)
{
	local int PickupClassIndex;

	for (PickupClassIndex = 0; PickupClassIndex < StockAmmoPickupClasses.Length; ++PickupClassIndex)
	{
		if (StockAmmoPickupClasses[PickupClassIndex] == AmmoPickupClass)
		{
			return;
		}
	}

	StockAmmoPickupClasses.Length = StockAmmoPickupClasses.Length + 1;
	StockAmmoPickupClasses[StockAmmoPickupClasses.Length - 1] = AmmoPickupClass;
}

function GroundStockAmmoPickups()
{
	local AmmoPickup AmmoPickup;

	foreach AllActors(class'AmmoPickup', AmmoPickup)
	{
		if (ShouldGroundAmmoPickup(AmmoPickup.Class))
		{
			GroundAmmoPickup(AmmoPickup);
		}
	}
}

function bool ShouldGroundAmmoPickup(class<AmmoPickup> AmmoPickupClass)
{
	local int PickupClassIndex;

	for (PickupClassIndex = 0; PickupClassIndex < StockAmmoPickupClasses.Length; ++PickupClassIndex)
	{
		if (ClassIsChildOf(AmmoPickupClass, StockAmmoPickupClasses[PickupClassIndex]))
		{
			return true;
		}
	}

	return false;
}

function GroundAmmoPickup(AmmoPickup AmmoPickup)
{
	local actor HitActor;
	local vector HitLocation;
	local vector HitNormal;
	local vector StartTrace;
	local vector EndTrace;
	local vector NewLocation;

	if (AmmoPickup == None)
	{
		return;
	}

	StartTrace = AmmoPickup.Location + (vect(0,0,1) * (AmmoPickup.CollisionHeight + 1.0));
	EndTrace = AmmoPickup.Location - vect(0,0,4096);
	HitActor = AmmoPickup.Trace(HitLocation, HitNormal, EndTrace, StartTrace);
	if (HitActor == None)
	{
		return;
	}

	NewLocation = HitLocation + (vect(0,0,1) * (AmmoPickup.CollisionHeight + 1.0));
	if (VSize(NewLocation - AmmoPickup.Location) < 1.0)
	{
		return;
	}

	AmmoPickup.SetLocation(NewLocation);
}

defaultproperties
{
	FriendlyName="Grounded Ammo"
	Description="Moves stock UT2004 weapon ammo pickups down onto the ground when the map loads."

	StockWeaponClasses(0)=Class'XWeapons.AssaultRifle'
	StockWeaponClasses(1)=Class'XWeapons.BioRifle'
	StockWeaponClasses(2)=Class'XWeapons.ShockRifle'
	StockWeaponClasses(3)=Class'XWeapons.LinkGun'
	StockWeaponClasses(4)=Class'XWeapons.Minigun'
	StockWeaponClasses(5)=Class'XWeapons.FlakCannon'
	StockWeaponClasses(6)=Class'XWeapons.RocketLauncher'
	StockWeaponClasses(7)=Class'XWeapons.SniperRifle'
	StockWeaponClasses(8)=Class'Onslaught.ONSAVRiL'
	StockWeaponClasses(9)=Class'Onslaught.ONSGrenadeLauncher'
	StockWeaponClasses(10)=Class'Onslaught.ONSMineLayer'
	StockWeaponClasses(11)=Class'UTClassic.ClassicBioRifle'
	StockWeaponClasses(12)=Class'UTClassic.ClassicFlakCannon'
	StockWeaponClasses(13)=Class'UTClassic.ClassicMinigun'
	StockWeaponClasses(14)=Class'UTClassic.ClassicRocketLauncher'
	StockWeaponClasses(15)=Class'UTClassic.ClassicShockRifle'
	StockWeaponClasses(16)=Class'UTClassic.ClassicSniperRifle'
}
