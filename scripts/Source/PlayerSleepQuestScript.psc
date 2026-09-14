ScriptName PlayerSleepQuestScript extends Quest

Spell Property Rested Auto
Spell Property WellRested Auto
Spell Property MarriageSleepAbility Auto
Spell Property BYOHAdoptionSleepAbilityMale Auto
Spell Property BYOHAdoptionSleepAbilityFemale Auto
ReferenceAlias Property LoveInterest Auto
LocationAlias Property CurrentHomeLocation Auto
LocationAlias Property CurrentHomeLocation2 Auto
LocationAlias Property CurrentHomeLocation3 Auto
LocationAlias Property CurrentHomeLocation4 Auto
LocationAlias Property CurrentHomeLocation5 Auto
LocationAlias Property CurrentHomeLocation6 Auto
LocationAlias Property CurrentHomeLocation7 Auto
LocationAlias Property CurrentHomeLocation8 Auto
LocationAlias Property CurrentHomeLocation9 Auto
LocationAlias Property CurrentHomeLocation10 Auto
Keyword Property LocTypeInn Auto
Keyword Property LocTypePlayerHouse Auto
Quest Property RelationshipMarriageFIN Auto
Quest Property BYOHRelationshipAdoption Auto
Spell Property pDoomLoverAbility Auto
CompanionsHousekeepingScript Property CHScript Auto
Function RemoveRested()

	;remove all previous rested states
	Game.GetPlayer().RemoveSpell(Rested)
	Game.GetPlayer().RemoveSpell(WellRested)
	Game.GetPlayer().RemoveSpell(MarriageSleepAbility)

EndFunction

Function RemoveAdoptionRested()
	Game.GetPlayer().RemoveSpell(BYOHAdoptionSleepAbilityMale)
	Game.GetPlayer().RemoveSpell(BYOHAdoptionSleepAbilityFemale)
EndFunction

Event OnSleepStop(bool abInterrupted)

; 	debug.trace(self + "Player is sleeping")
	If CHScript.PlayerHasBeastBlood == 1
; 		Debug.Trace(Self + "Player is werewolf; no restedness on sleep.")
		RemoveRested()
		BeastBloodMessage.Show()
	ElseIf Game.GetPlayer().HasSpell(pDoomLoverAbility) == 0
		;don't run this if player has the Lover sign

		;USKP 2.0.1 - Check for a None location first so the game doesn't spit a bunch of errors instead.
		if( Game.GetPlayer().GetCurrentLocation() == None )
; 			debug.trace(Self + "Giving player the Rested spell for sleeping")	
			RestedMessage.Show()
			RemoveRested()
			Game.GetPlayer().AddSpell(Rested, abVerbose = false)
		ElseIf RelationshipMarriageFIN.IsRunning() == True && RelationshipMarriageFIN.GetStage() >= 10 && Game.GetPlayer().GetCurrentLocation() == LoveInterest.GetActorReference().GetCurrentLocation()
 			;debug.trace(Self + "Giving player the Lover's Comfort spell on Sleep End")
			MarriageRestedMessage.Show()
			RemoveRested()
			Game.GetPlayer().AddSpell(MarriageSleepAbility, abVerbose = false)
		ElseIf Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypeInn) == True
 			;debug.trace(Self + "Giving player the Well Rested spell for sleeping in an Inn")	
			WellRestedMessage.Show()
			RemoveRested()
			Game.GetPlayer().AddSpell(WellRested, abVerbose = false)
		ElseIf Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypePlayerHouse) == True
 			;debug.trace(Self + "Giving player the Well Rested spell for sleeping in Player House")	
			WellRestedMessage.Show()		; Added by USKP 1.0
			RemoveRested()				; Added by USKP 1.0
			Game.GetPlayer().AddSpell(WellRested, abVerbose = false)
		Else
 			;debug.trace(Self + "Giving player the Rested spell for sleeping")	
			RestedMessage.Show()
			RemoveRested()
			Game.GetPlayer().AddSpell(Rested, abVerbose = false)
		EndIf
     EndIf

     if (CHScript.PlayerHasBeastBlood != 1)
		;Additionally, for Adoption...
		Actor playerRef = Game.GetPlayer()
		If (BYOHRelationshipAdoption.IsRunning() && (playerRef.GetCurrentLocation() == CurrentHomeLocation.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation2.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation3.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation4.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation5.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation6.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation7.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation8.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation9.GetLocation() || playerRef.GetCurrentLocation() == CurrentHomeLocation10.GetLocation() ) )
; 			;Debug.Trace("Adding Adoption Sleep Ability.")
			RemoveAdoptionRested()
			If (Game.GetPlayer().GetActorBase().GetSex() == 0)
				;Player is a father.
				BYOHAdoptionRestedMessageMale.Show()
				Game.GetPlayer().AddSpell(BYOHAdoptionSleepAbilityMale, False)
				
			Else
				;Player is a mother.
				BYOHAdoptionRestedMessageFemale.Show()
				Game.GetPlayer().AddSpell(BYOHAdoptionSleepAbilityFemale, False)
			EndIf
		EndIf
	EndIf
	
EndEvent

Message Property RestedMessage  Auto  

Message Property WellRestedMessage  Auto  

Message Property MarriageRestedMessage  Auto  

Message Property BeastBloodMessage  Auto



Message Property BYOHAdoptionRestedMessageMale  Auto  
Message Property BYOHAdoptionRestedMessageFemale  Auto  

