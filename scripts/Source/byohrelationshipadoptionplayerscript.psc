Scriptname BYOHRelationshipAdoptionPlayerScript extends ReferenceAlias
{Notifies BYOHRelationshipAdoptionScript that the player has moved to a new location.}

Quest property BYOHRelationshipAdoption Auto
Quest property BYOHRelationshipAdoptionScheduler Auto
float expanded_ver = 1.0
bool first_time_installed = false

;After adopting a child, whenever the player's location changes, notify the Adoption Quest.
;This is used for a variety of things: moving the family, triggering 'Welcome Home' forcegreets, etc.
Event OnLocationChange(Location oldLoc, Location newLoc)
	;Debug.Trace("Player OnLocationChange")
	if (newLoc != None)
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).PlayerLocationChanged(newLoc, oldLoc)
	endif
EndEvent

Event OnInit()
	;first time expanded installed
	if !first_time_installed
		FirstTimeInstallation()
		first_time_installed = true
	endif 
EndEvent

Event OnPlayerLoadGame()
	if !first_time_installed
		FirstTimeInstallation()
		first_time_installed = true
	endif 
  	
EndEvent

Function FirstTimeInstallation()

	;update the aliases by re-running the scheduler quest

    ;Shut down the Scheduler Quest, if it was running.
    if BYOHRelationshipAdoptionScheduler.IsRunning()
    	debug.notification("Setting up HMA Expanded!")
		BYOHRelationshipAdoptionScheduler.Stop()
		While (BYOHRelationshipAdoptionScheduler.IsRunning())
			Utility.Wait(0.5)
		EndWhile

		BYOHRelationshipAdoptionScheduler.SetStage(0)
		((BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript)).updateHomeReferenceAliases()
		int[] newHomeArray = ((BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript)).getNewHomeArray()
		Actor[] childArray = ((BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript)).getChildArray()
		
		int schedulerFailCount = 0
		int i = 0
		ObjectReference newHomeRef = ((BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript)).TranslateHouseIntToObj(newHomeArray[0])
		While (!BYOHRelationshipAdoptionScheduler.IsRunning() && schedulerFailCount < 10)
			;Debug.Trace("Adoption: Waiting for Scheduler to start...")
			schedulerFailCount = schedulerFailCount + 1
			Utility.Wait(0.5)
			;The most common cause of Scheduler failures is Child1 leaving the house AGAIN. Move them back and retry.
			;changed to move all the kids to their new homes
			while i < childArray.length
				
				childArray[i].MoveTo(newHomeRef)
				Utility.wait(0.1)
				i = i + 1
			endwhile
			BYOHRelationshipAdoptionScheduler.SetStage(0)
		EndWhile
		((BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript)).updateHomeReferenceAliases()
	endif
EndFunction

