ScriptName HMAExpandedTrackerAliasScript extends ReferenceAlias

float version = 1.99
Faction Property petChildOwnerFaction Auto
ReferenceAlias Property FamilyPet Auto

Event OnInit()
	HandleUpdates()
EndEvent


Event OnPlayerLoadGame()
	HandleUpdates()
EndEvent

Function HandleUpdates()
	if version < 2.00
		;add pet faction
		Actor pet = FamilyPet.getActorReference()
		if pet && !(pet.isInFaction(petChildOwnerFaction))
			pet.setFactionRank(petChildOwnerFaction, 1)
			debug.notification("Family pet will now be attached to child 1.")
		endif
		debug.notification("HMA Expanded Version upgrade to 2.00 complete.")
		version = 2.00
	endif
EndFunction