class MutGroundedAmmo extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local UTAmmoPickup AmmoPickup;

    AmmoPickup = UTAmmoPickup(Other);
    if (Role == ROLE_Authority && AmmoPickup != None)
        GroundAmmoPickup(AmmoPickup);

    return Super.CheckReplacement(Other, bSuperRelevant);
}

function bool GroundAmmoPickup(UTAmmoPickup Pickup)
{
    local Actor HitActor;
    local vector HitLocation;
    local vector HitNormal;
    local vector TraceStart;
    local vector TraceEnd;
    local vector GroundLocation;
    local float TraceDistance;

    if (Pickup == None || Pickup.Base != None || Pickup.bDropped)
        return false;

    Pickup.RemoteRole = ROLE_DumbProxy;
    Pickup.bAlwaysRelevant = true;
    Pickup.bOnlyReplicateHidden = false;
    Pickup.bReplicateMovement = true;
    Pickup.NetUpdateFrequency = 0.100000;
    Pickup.NetPriority = 1.400000;

    TraceDistance = 256.0;
    TraceStart = Pickup.Location + vect(0,0,16);
    TraceEnd = Pickup.Location - TraceDistance * vect(0,0,1);
    HitActor = Pickup.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false);
    if (HitActor == None || HitNormal.Z < 0.5)
        return false;

    GroundLocation = Pickup.Location;
    GroundLocation.Z = HitLocation.Z + Pickup.CollisionHeight;
    if (Abs(GroundLocation.Z - Pickup.Location.Z) < 1.0)
        return false;

    return Pickup.SetLocation(GroundLocation);
}


defaultproperties
{
    bAddToServerPackages=True
    IconMaterialName="MutatorArt.nosym"
    ConfigMenuClassName=""
    GroupName="GroundedAmmo"
    FriendlyName="Grounded Ammo"
    Description="Snaps placed ammo pickups to the floor while preserving dropped ammo and mover-based pickups."
}
