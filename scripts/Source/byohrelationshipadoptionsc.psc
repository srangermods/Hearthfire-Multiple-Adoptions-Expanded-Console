Scriptname BYOHRelationshipAdoptionSc extends Quest
{Quest script for BYOHRelationshipAdoptionScheduler. Primarily handles updates for the Child's Chest system.}

;---This is NOT the main Adoption Script. If you're looking for that, you want BYOHRelationshipAdoptionScript. :) ---
;
;This script is responsible for periodically refilling the chest in the children's bedroom and performing some utility functions.
; - It lives on the Scheduler subquest because it's the Scheduler that has the chest alias for the current house.
; - It calls back to RelationshipAdoption to fill the chest in order to keep that functionality in one place.
;
;Note that, after filling the chest, we only start the timer to refill it after the player has interacted with it.
;This keeps the chest from 'overflowing', and prevents us from having to remove items from the chest as new ones are added
;(since other Adoption events push things into it, and we don't want to remove items from containers in the player's house).

Quest property BYOHRelationshipAdoption Auto	;Main Adoption quest.
ReferenceAlias property ChildChest Auto			;Child's chest in the current house.
ReferenceAlias property ChildChest2 Auto	
ReferenceAlias property ChildChest3 Auto	
ReferenceAlias property ChildChest4 Auto
ReferenceAlias property ChildChest5 Auto
ReferenceAlias property ChildChest6 Auto
ReferenceAlias property ChildChest7 Auto
ReferenceAlias property ChildChest8 Auto
ReferenceAlias property ChildChest9 Auto
ReferenceAlias property ChildChest10 Auto			
bool waitForPlayerInteraction = False			;Are we waiting for the player to interact with this chest before refilling it?
ReferenceAlias property Child1 Auto				;Alias of Child 1 on this quest.
ReferenceAlias property Child2 Auto				;Alias of Child 2 on this quest.
ReferenceAlias property Child3 Auto				;Alias of Child 3 on this quest.
ReferenceAlias property Child4 Auto				;Alias of Child 4 on this quest.
ReferenceAlias property Child5 Auto				;Alias of Child 5 on this quest.
ReferenceAlias property Child6 Auto				;Alias of Child 6 on this quest.
ReferenceAlias property Child7 Auto
ReferenceAlias property Child8 Auto
ReferenceAlias property Child9 Auto
ReferenceAlias property Child10 Auto

;Called by the chest when the player activates it.
;If we were waiting for the player to interact with it, start the timer to refill the chest.
Function PlayerChestInteraction()
	;Debug.Trace("Player/Chest Interaction")
	if (waitForPlayerInteraction)
		waitForPlayerInteraction = False
		RegisterForChestUpdate()
	EndIf
EndFunction

;Schedules an update to refill the chest.
Function RegisterForChestUpdate()
	;Debug.Trace("Registering for Chest Update")
	Self.UnRegisterForUpdateGameTime()
	Self.RegisterForSingleUpdateGameTime(120) ;5d Cooldown Timer
EndFunction

;Fill the chest, then wait for the player to interact with it before starting the cooldown again.
Event OnUpdateGameTime()
	;Debug.Trace("Scheduler OnUpdate. Refilling Chest.")
	(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest.GetReference())
	if ChildChest2.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest2.GetReference())
	endif
	if ChildChest3.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest3.GetReference())
	endif
	if ChildChest4.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest4.GetReference())
	endif
	if ChildChest5.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest5.GetReference())
	endif
	if ChildChest6.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest6.GetReference())
	endif
	if ChildChest7.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest7.GetReference())
	endif
	if ChildChest8.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest8.GetReference())
	endif
	if ChildChest9.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest9.GetReference())
	endif
	if ChildChest10.GetReference()
		(BYOHRelationshipAdoption as BYOHRelationshipAdoptionScript).RefillChest(ChildChest10.GetReference())
	endif
	waitForPlayerInteraction = True
EndEvent

Function SwapChildren(int idOther = 2)
	;Swap the children in their aliases.
	ReferenceAlias ChildAlias
	if (idOther <= 1)
		; child 1 was to be swapped with itself, no need to do that
		return
	elseif (idOther == 2)
		ChildAlias = Child2
	elseif (idOther == 3)
		ChildAlias = Child3
	elseif (idOther == 4)
		ChildAlias = Child4
	elseif (idOther == 5)
		ChildAlias = Child5
	elseif (idOther == 6)
		ChildAlias = Child6
	elseif (idOther == 7)
		ChildAlias = Child7
	elseif (idOther == 8)
		ChildAlias = Child8
	elseif (idOther == 9)
		ChildAlias = Child9
	elseif (idOther == 10)
		ChildAlias = Child10
	endif	
	Actor tempChild = Child1.GetActorRef()
	Child1.ForceRefTo(ChildAlias.GetActorRef())
	ChildAlias.ForceRefTo(tempChild)
EndFunction