Scriptname BYOHRelationshipAdoptionScript extends Quest Conditional
{Quest Script for RelationshipAdoption, responsible for handling all of the post-Adoption behaviors.}

;----------------------------------------------------------------------------------------------------
;STANDARD VARIABLES
;----------------------------------------------------------------------------------------------------
;RelationshipAdoption makes extensive use of Actor Values Variable06-07 for package conditionals and state-tracking. Values are:
;
;******************************
; Variable06 - Child State: Primarily used for package conditionals to override the child's standard schedule.
;   - -2 - Just Adopted, block packages until the child moves to their new home.
;   - -1 - Just Adopted, travel to home, then trigger the scheduler.
;   -  0 -  Normal
;   -  1 - Override Behaviors: Small overrides to the child's schedule that don't trump real Orders. Used to make the child feel more responsive.
;      - 1.0 - Child was recently adopted and sandboxes in their new house for an hour.
;	   - 1.1 - Child was given a weapon and spars with it for an hour.
;	   - 1.2 - Child was given a doll and plays with it for an hour.
;      - 1.3 - Child runs off crying and sandboxes in their room for an hour.
;   -  2 - Override Orders: Child ordered outside (Inside, 6am-9pm)
;   -  3 - Override Orders: Child ordered inside (Outside, any time)
;   -  4 - Override Orders: Child ordered to do chores (Anywhere, 6am-9pm)
;   -  5 - Override Orders: Child ordered to bed (Anywhere, 6pm-8am)
;   - 10 - Override Behavior: Child will "Never Speak to You Again" due to a hostile action. This lasts for 24h.
;******************************
; Variable07 - Forcegreet State: Determines which forcegreet to run when the player 'comes home' after an absence.
;   -  0 - [NOT INITIALIZED]
;   -  1 - DLG: Thanks for Adopting	  - First FG after Adoption, Dirty Move.
;   -  2 - DLG: Thanks and Chest	  - First FG after Adoption, Clean Move.
;   -  3 - DLG: Check the Chest       - First Clean Move after Adoption.
;   -  4 - Adopt a Pet				  - Player has an Animal Companion, child asks to keep it.
;   -  5 - Adopt a Critter			  - Child brings home a critter. 10% chance (plus other conditions).
;   -  6 - Name Calling 1             - Scene: Children call each other names, then play tag. 10% chance (plus other conditions).
;   -  7 - Name Calling 2             - Scene: Children call each other names, one runs off crying. 10% chance (plus other conditions).
;   -    -
;   - 10 - Ask for Allowance          - Generic, 25% Chance
;   - 11 - Give Gift to Player        - Generic, 25% Chance
;   - 12 - Ask for a Present		  - Generic, 25% Chance
;   - 13 - Suggest a Game			  - Generic, 25% Chance
;
;******************************
;----------------------------------------------------------------------------------------------------
;PROPERTIES & VARIABLES
;-------------------------------------

;Total number of children adopted.
int property numChildrenAdopted = 0 Auto Conditional Hidden

;Aliases for the family.
ReferenceAlias property Player Auto
ReferenceAlias property Spouse Auto
ReferenceAlias property Child1 Auto
ReferenceAlias property Child2 Auto
ReferenceAlias property Child3 Auto
ReferenceAlias property Child4 Auto
ReferenceAlias property Child5 Auto
ReferenceAlias property Child6 Auto
ReferenceAlias property Child7 Auto
ReferenceAlias property Child8 Auto
ReferenceAlias property Child9 Auto
ReferenceAlias property Child10 Auto

;Aliases on this quest representing the family's location. Copied from the Scheduler subquest, used by dialogue.
LocationAlias property CurrentHomeHouse Auto
LocationAlias property CurrentHomeHouse2 Auto
LocationAlias property CurrentHomeHouse3 Auto
LocationAlias property CurrentHomeHouse4 Auto
LocationAlias property CurrentHomeHouse5 Auto
LocationAlias property CurrentHomeHouse6 Auto
LocationAlias property CurrentHomeHouse7 Auto
LocationAlias property CurrentHomeHouse8 Auto
LocationAlias property CurrentHomeHouse9 Auto
LocationAlias property CurrentHomeHouse10 Auto

LocationAlias property CurrentHomeExterior Auto
LocationAlias property CurrentHomeExterior2 Auto
LocationAlias property CurrentHomeExterior3 Auto
LocationAlias property CurrentHomeExterior4 Auto
LocationAlias property CurrentHomeExterior5 Auto
LocationAlias property CurrentHomeExterior6 Auto
LocationAlias property CurrentHomeExterior7 Auto
LocationAlias property CurrentHomeExterior8 Auto
LocationAlias property CurrentHomeExterior9 Auto
LocationAlias property CurrentHomeExterior10 Auto

;Aliases on the Scheduler subquest representing the family's location. Used to copy them into this quest.
LocationAlias property SchedulerCurrentHomeHouse Auto
LocationAlias property SchedulerCurrentHomeHouse2 Auto
LocationAlias property SchedulerCurrentHomeHouse3 Auto
LocationAlias property SchedulerCurrentHomeHouse4 Auto
LocationAlias property SchedulerCurrentHomeHouse5 Auto
LocationAlias property SchedulerCurrentHomeHouse6 Auto
LocationAlias property SchedulerCurrentHomeHouse7 Auto
LocationAlias property SchedulerCurrentHomeHouse8 Auto
LocationAlias property SchedulerCurrentHomeHouse9 Auto
LocationAlias property SchedulerCurrentHomeHouse10 Auto

LocationAlias property SchedulerCurrentHomeExterior Auto
LocationAlias property SchedulerCurrentHomeExterior2 Auto
LocationAlias property SchedulerCurrentHomeExterior3 Auto
LocationAlias property SchedulerCurrentHomeExterior4 Auto
LocationAlias property SchedulerCurrentHomeExterior5 Auto
LocationAlias property SchedulerCurrentHomeExterior6 Auto
LocationAlias property SchedulerCurrentHomeExterior7 Auto
LocationAlias property SchedulerCurrentHomeExterior8 Auto
LocationAlias property SchedulerCurrentHomeExterior9 Auto
LocationAlias property SchedulerCurrentHomeExterior10 Auto

ReferenceAlias Property SchedulerOutsideSandbox Auto
ReferenceAlias Property SchedulerOutsideSandbox2 Auto
ReferenceAlias Property SchedulerOutsideSandbox3 Auto
ReferenceAlias Property SchedulerOutsideSandbox4 Auto
ReferenceAlias Property SchedulerOutsideSandbox5 Auto
ReferenceAlias Property SchedulerOutsideSandbox6 Auto
ReferenceAlias Property SchedulerOutsideSandbox7 Auto
ReferenceAlias Property SchedulerOutsideSandbox8 Auto
ReferenceAlias Property SchedulerOutsideSandbox9 Auto
ReferenceAlias Property SchedulerOutsideSandbox10 Auto

;Aliases on the Scheduler subquest representing scene markers.
ReferenceAlias property SchedulerSceneMarker1 Auto
ReferenceAlias property SchedulerSceneMarker2 Auto

GlobalVariable Property GVDisableMoveNotification Auto
GlobalVariable Property GVCritterEventChance Auto

Faction Property petChildOwnerFaction Auto

;Associated quests.
Quest property BYOHRelationshipAdoptionScheduler Auto				;Scheduler subquest. Handles packaging for the kids and pets in their 'current' house.
Quest property RelationshipMarriageFIN Auto						;Player Marriage Quest. Handles the spouse.
Quest property BYOHRelationshipAdoptable Auto						;Pre-Adoption functions, behaviors, and house tracking.
Quest property BYOHRelationshipAdoptableOrphanage Auto			;Pre-Adoption Orphanage Manager.
Quest property BYOHRelationshipAdoptableUrchins Auto				;Pre-Adoption Urchin Manager.
Quest property BYOHRelationshipAdoptionCWSiegeHandler Auto		;Handles Civil War Siege override behavior.
Quest property BYOHRelationshipAdoptionNewAdoptionHandler Auto	;Handles New Adoption override behavior.
Quest property WIGamesTag Auto										;Game: Tag
Quest property WIGamesHideAndSeek Auto								;Game: Hide and Seek
Quest property WIKill05 Auto											;WI: Related actor has been killed. We need for force-shutdown this in some cases.
CCHouseQuestScript property CCHouse Auto						; CC House Quest
Quest property PHX_CustomHomeManager Auto  ; quest that handles custom homes

;Associated factions
Faction property BYOHRelationshipAdoptableFaction Auto
Faction property CurrentFollowerFaction Auto

;House Data
int property currentHome = 0 Auto Conditional Hidden	;Int representing which house the child is currently living in.
int property currentHome2 = 0 Auto Conditional Hidden
int property currentHome3 = 0 Auto Conditional Hidden
int property currentHome4 = 0 Auto Conditional Hidden
int property currentHome5 = 0 Auto Conditional Hidden
int property currentHome6 = 0 Auto Conditional Hidden	
int property currentHome7 = 0 Auto Conditional Hidden
int property currentHome8 = 0 Auto Conditional Hidden
int property currentHome9 = 0 Auto Conditional Hidden
int property currentHome10 = 0 Auto Conditional Hidden

int property newHome = 0 Auto Conditional Hidden		;Int representing which house the child has been told to move to.
int property newHome2 = 0 Auto Conditional Hidden
int property newHome3 = 0 Auto Conditional Hidden
int property newHome4 = 0 Auto Conditional Hidden
int property newHome5 = 0 Auto Conditional Hidden
int property newHome6 = 0 Auto Conditional Hidden
int property newHome7 = 0 Auto Conditional Hidden
int property newHome8 = 0 Auto Conditional Hidden
int property newHome9 = 0 Auto Conditional Hidden
int property newHome10 = 0 Auto Conditional Hidden

Actor petOwnerChild = None

ObjectReference property HouseSolitudeMarker Auto		;Markers representing the center point of each house.
ObjectReference property HouseWindhelmMarker Auto
ObjectReference property HouseMarkarthMarker Auto
ObjectReference property HouseRiftenMarker Auto
ObjectReference property HouseWhiterunMarker Auto
ObjectReference property HouseFalkreathMarker Auto
ObjectReference property HouseHjaalmarchMarker Auto
ObjectReference property HousePaleMarker Auto
Location property SolitudeLocation Auto					;Locations corresponding to each home city/exterior.
Location property WindhelmLocation Auto
Location property MarkarthLocation Auto
Location property RiftenLocation Auto
Location property WhiterunLocation Auto
Location property FalkreathHouseLocation Auto
Location property HjaalmarchHouseLocation Auto
Location property PaleHouseLocation Auto
Location property SolitudeProudspireManorLocation Auto	;Locations corresponding to each home interior.
Location property WindhelmHjerimLocation Auto
Location property MarkarthVlindrelHallLocation Auto
Location property RiftenHoneysideLocation Auto
Location property WhiterunBreezehomeLocation Auto
Location property FalkreathHouseInteriorLocation Auto
Location property HjaalmarchHouseInteriorLocation Auto
Location property PaleHouseInteriorLocation Auto

;Newly-Adopted Child Handling
ReferenceAlias property NewAdoptionHandlerChild1 Auto				;Family Aliases on the NAH quest.
ReferenceAlias property NewAdoptionHandlerChild2 Auto
ReferenceAlias property NewAdoptionHandlerChild3 Auto				;Family Aliases on the NAH quest.
ReferenceAlias property NewAdoptionHandlerChild4 Auto
ReferenceAlias property NewAdoptionHandlerChild5 Auto				;Family Aliases on the NAH quest.
ReferenceAlias property NewAdoptionHandlerChild6 Auto
ReferenceAlias property NewAdoptionHandlerSpouse Auto
Keyword property BYOHAdoptionNewAdoptionEvent Auto				;Keyword for NAH Story Manager Event
bool child1NewlyAdopted = False										;Keep track of whether the children have been recently adopted.
bool child2NewlyAdopted = False										;   the system handles moving them a little differently to avoid delays, which felt strange.
bool child3NewlyAdopted = False										;   the system handles moving them a little differently to avoid delays, which felt strange.
bool child4NewlyAdopted = False										;   the system handles moving them a little differently to avoid delays, which felt strange.
bool child5NewlyAdopted = False										;   the system handles moving them a little differently to avoid delays, which felt strange.
bool child6NewlyAdopted = False										;   the system handles moving them a little differently to avoid delays, which felt strange.
bool child7NewlyAdopted = False
bool child8NewlyAdopted = False	
bool child9NewlyAdopted = False	
bool child10NewlyAdopted = False		
float property lastChildAdoptedTimestamp Auto Conditional Hidden	;Timestamp of when we last adopted a child + 3 days. Used to conditionalize some dialogue.

;Moving System Properties
bool moveQueued = False														;Has the player (or a system) requested a move?
bool moveQueued2 = False
bool moveQueued3 = False
bool moveQueued4 = False
bool moveQueued5 = False
bool moveQueued6 = False
bool moveQueued7 = False
bool moveQueued8 = False
bool moveQueued9 = False
bool moveQueued10 = False

bool initialMoveDone = False													;Has the family moved before?
bool property FirstMoveWithSpouse = True Auto Hidden						;Is this the first time you're moving with your spouse?
bool property AllowSpouseToMove = True Auto Hidden							;Should RelationshipMarriageFIN's quest script allow the spouse to actually move?
bool property MovingTogglePackageOn = False Auto Conditional Hidden		;Should the children's temporary toggle package be turned on?
ObjectReference newHomeRef													;Where are we moving to?

bool schedulerHasFailed = False												;Did the Scheduler fail the last time we tried to move the children?

;CW Siege handler Properties
Quest property CWSiege Auto					;CW Siege quest.
LocationAlias property CWSiegeCity Auto		;Location under siege.

;Orders System Properties
float property OrderToConfirm = 0.0 Auto Hidden		;Holding variable for an order the player has requested, but not yet confirmed.

;Gift system Properties
Formlist property BYOHRelationshipAdoptionPlayerGiftChildMale Auto		;List of gifts that can be given to children.
Formlist property BYOHRelationshipAdoptionPlayerGiftChildFemale Auto
int property GiftReaction Auto Hidden Conditional			;Child's "emotional" reaction to the gift, based on its gold value.
int property GiftStoredValueChild1 Auto Hidden				;Value of 'consumed' gifts to be added to Child1's gold.
int property GiftStoredValueChild2 Auto Hidden				;Value of 'consumed' gifts to be added to Child2's gold.
int property GiftStoredValueChild3 Auto Hidden				;Value of 'consumed' gifts to be added to Child3's gold.
int property GiftStoredValueChild4 Auto Hidden				;Value of 'consumed' gifts to be added to Child4's gold.
int property GiftStoredValueChild5 Auto Hidden				;Value of 'consumed' gifts to be added to Child5's gold.
int property GiftStoredValueChild6 Auto Hidden				;Value of 'consumed' gifts to be added to Child6's gold.
int property GiftStoredValueChild7 Auto Hidden
int property GiftStoredValueChild8 Auto Hidden
int property GiftStoredValueChild9 Auto Hidden
int property GiftStoredValueChild10 Auto Hidden

;Games System Properties
Keyword property WIGamesTagStart Auto			;Keywords for WIGames Story Manager Events
Keyword property WIGamesHideAndSeekStart Auto
Faction property WINeverFillAliasesFaction Auto	;Adding children to this faction prohibits them from being added to WIChangeLocation games.

;Pet System Properties
ReferenceAlias property AnimalCompanion Auto										;The player's current Animal Companion, as tracked by the DialogueFollower quest.
ReferenceAlias property FamilyPet Auto												;The family's Pet: A designated Animal Companion who lives in the player's house.
ReferenceAlias property Scheduler_FamilyPet Auto									;Scheduler Quest copy of the pet.
ReferenceAlias property TransientPet Auto												;A temporary alias to hold pets that haven't been 'approved' for adoption yet. Needed for dialogue conditions.
Faction property BYOHRelationshipPotentialPetFaction Auto						;Faction, applied via the TransientPet alias, whose rank represents the pet's suitability for adoption.
Formlist property BYOHRelationshipAdoption_PetAllowedRacesList Auto				;Races of pets that any kid can adopt.
Formlist property BYOHRelationshipAdoption_PetDogsList Auto						;Races of pets that are also dogs.
float petRetryTime																	;Limits frequency of Pet-related Forcegreet events. If (GetCurrentGameTime < petRetryTime), they won't occur.

;Critter System Properties
ReferenceAlias property FamilyCritter Auto				;The family's Critter: A creature created for one of the children.
ReferenceAlias property FamilyCritter2 Auto
ReferenceAlias property FamilyCritter3 Auto
ReferenceAlias property FamilyCritter4 Auto
ReferenceAlias property FamilyCritter5 Auto

ReferenceAlias property Scheduler_FamilyCritter Auto		;Scheduler Quest copy of the critter.
ReferenceAlias property Scheduler_FamilyCritter2 Auto
ReferenceAlias property Scheduler_FamilyCritter3 Auto
ReferenceAlias property Scheduler_FamilyCritter4 Auto
ReferenceAlias property Scheduler_FamilyCritter5 Auto

ReferenceAlias property TransientCritter Auto				;A temporary alias to hold critters that haven't been 'approved' for adoption yet. Needed for dialogue conditions.
ReferenceAlias property Scheduler_TransientCritter Auto	;Scheduler Quest copy of the transient critter.
FormList property BYOHRelationshipAdoption_CrittersMale Auto		;The list of critters boys will bring home.
FormList property BYOHRelationshipAdoption_CrittersFemale Auto	;The list of critters girls will bring home.
float critterRetryTime									;Limits frequency of Critter Forcegreet events. If (GetCurrentGameTime < critterRetryTime), they won't occur.
Actor rejectedCritter										;The last critter the children brought home, if it has been rejected by the player.
ActorBase rejectedCritterBase							;Base Object for the last critter the children brought home, if it has been rejected by the player.
int critterChance = 10									;Base chance that a critter event will occur.


;'Welcome Home' Forcegreet System Properties
int property WelcomeHomeDelay = 1 Auto Hidden							;The minimum time that must elapse before a Welcome Home Forcegreet triggers (1 day).
bool property ForcegreetEventReady = False Auto Hidden Conditional	;Is a Welcome Home Event queued up?
Actor property ForceGreetChild = None Auto Hidden
float property playerLastSeen = 0.0 Auto Hidden Conditional			;Timestamp of when we last 'saw' the player.
float property PlayerLastSeen2 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen3 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen4 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen5 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen6 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen7 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen8 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen9 = 0.0 Auto Hidden Conditional
float property PlayerLastSeen10 = 0.0 Auto Hidden Conditional

bool ChildChestIntroduced = False										;Has one of the children mentioned the chest (enqueued Event 2 or 3)?
MiscObject property Gold001 Auto
int property WeArePoorCount = 0 Auto Hidden Conditional				;Tracking for 'poverty' counter.
FormList property BYOHRelationshipAdoptionGifts_Poor Auto			;Formlists of gifts the child can give.
FormList property BYOHRelationshipAdoptionGifts_Junk Auto
FormList property BYOHRelationshipAdoptionGifts_0000 Auto
FormList property BYOHRelationshipAdoptionGifts_0025 Auto
FormList property BYOHRelationshipAdoptionGifts_0050 Auto
FormList property BYOHRelationshipAdoptionGifts_0100 Auto
FormList property BYOHRelationshipAdoptionGifts_0250 Auto
FormList property BYOHRelationshipAdoptionGifts_0500 Auto
FormList property BYOHRelationshipAdoptionGifts_1000 Auto

;'Welcome Home' name-calling scenes and properties.
Scene property RelationshipAdoption_SceneNameCalling01 Auto				;Name-Calling Scene 1. Ends with the children playing tag.
Scene property RelationshipAdoption_SceneNameCalling02 Auto				;Name-Calling Scene 2. Ends with one child sulking off to their room.
Formlist property BYOHRelationshipAdoption_NameCallingWinnersList Auto		;A prioritized list of children who always 'win' the name-calling forcegreets.
bool NameCalling1Done															;Has Name Calling Scene 1 triggered before? If so, we won't use it again.
bool NameCalling2Done															;Has Name Calling Scene 2 triggered before? If so, we won't use it again.
bool NameCallingUsedLast														;Was the last forcegreet event a Name-Calling Scene? If so, don't do another one.
int nameCallingChance = 10													;Base chance that a name-calling event will occur.

Actor NWSAnimalFollower = None

;-----------------------------------------------------------------------------------
;UHFP 2.0.4 - For reassignment of child bed ownership when there is no bedroom wing.
;-----------------------------------------------------------------------------------
ObjectReference Property Wing1Bed Auto
ObjectReference Property Wing2Bed Auto
ObjectReference Property Wing3Bed Auto
ObjectReference Property Wing4Bed Auto
ObjectReference Property Wing5Bed Auto
ObjectReference Property Wing6Bed Auto
ObjectReference Property HFBed1 Auto
ObjectReference Property HFBed2 Auto
ObjectReference Property HFBed3 Auto
ObjectReference Property HFBed4 Auto
ObjectReference Property HFBed5 Auto
ObjectReference Property HFBed6 Auto
Faction Property BYOHRelationshipAdoptionChildOwnedFaction Auto 

Function UHFP_ReassignBedOwnerships( int Destination )
	;Somewhat messy business here to hand over the child beds in the main hall to the kids if the bedroom wing beds don't exist.
	;This relies on the crafting side of things to have gotten the beds into the right enable states and for the variables to enable child adoption support to be correct.
	;When the bedroom wing gets built, this won't run, and the ownerships on the beds gets handled by the UHFP changes to BuildHouseInteriorPart in BYOHHouseScript.
	if( Destination == 6 ) ;Falkreath
		if( Wing1Bed.IsDisabled() )
			HFBed1.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
			HFBed3.SetFactionOwner(None)
			HFBed5.SetFactionOwner(None)
		EndIf
		
		if( Wing2Bed.IsDisabled() )
			HFBed2.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
			HFBed4.SetFactionOwner(None)
			HFBed6.SetFactionOwner(None)
		EndIf
	elseif( Destination == 7 ) ;Hjaalmarch
		if( Wing3Bed.IsDisabled() )
			HFBed1.SetFactionOwner(None)
			HFBed3.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
			HFBed5.SetFactionOwner(None)
		EndIf
		
		if( Wing4Bed.IsDisabled() )
			HFBed2.SetFactionOwner(None)
			HFBed4.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
			HFBed6.SetFactionOwner(None)
		EndIf
	elseif( Destination == 8 ) ;Pale
		if( Wing5Bed.IsDisabled() )
			HFBed1.SetFactionOwner(None)
			HFBed3.SetFactionOwner(None)
			HFBed5.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
		EndIf
		
		if( Wing6Bed.IsDisabled() )
			HFBed2.SetFactionOwner(None)
			HFBed4.SetFactionOwner(None)
			HFBed6.SetFactionOwner(BYOHRelationshipAdoptionChildOwnedFaction)
		EndIf
	EndIf
EndFunction

;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
;NEW ADOPTIONS
;-------------

;Pass this function a child to adopt them.
Function AdoptChild(Actor childToAdopt)
	;Debug.Trace("Now Adopting: " + childToAdopt)
	
	;Block activation on the child until we get everything sorted out.
	childToAdopt.BlockActivation(True)
	
	;Remove the child from all prior factions, then reinstate their Crime Faction.
	Faction oldCrimeFaction = childToAdopt.GetCrimeFaction()
	childToAdopt.RemoveFromAllFactions()
	childToAdopt.SetCrimeFaction(oldCrimeFaction)
	
	;Remove the child from interfering World Interactions. This has to be brute-forced in many cases since
	;most of these have a huge number of aliases and no clean way to abort if and only if this specific actor is in them.
	;Stop any running games.
	StopGames()
	;Stop WIKill05 (Run Home & Mourn)
	if (WIKill05.IsRunning())
		WIKill05.Stop()
	EndIf
	
	;Determine where we're moving the child to. The Adoptable system passes this to us by storing it in the child's Variable07.
	int childDestination = ValidateMoveDestinationChild(childToAdopt.GetActorValue("Variable07") as int, childToAdopt)
	Location childDestinationLoc = TranslateHouseIntToLoc(childDestination)
	Location childCurrentLoc = childToAdopt.GetCurrentLocation()
	Debug.Trace("Child to move to: " + childDestination + " " + childDestinationLoc)
	
	;Which child is this?
	ReferenceAlias ChildAlias = getAdoptedChild()

	
	;Ping the Adoptable-Orphanage quest so it updates if you've adopted one of its children.
	if (BYOHRelationshipAdoptableOrphanage.IsRunning())
		(BYOHRelationshipAdoptableOrphanage as BYOHRelationshipAdoptableOrphanageSc).CheckAdoptOrphanageChild(childToAdopt, numChildrenAdopted)
	EndIf
	
	;Ping the Adoptable-Urchin quest so it updates if you've adopted one of its children. 
	if (BYOHRelationshipAdoptableUrchins.IsRunning())
		(BYOHRelationshipAdoptableUrchins as BYOHRelationshipAdoptableUrchinScript).CheckAdoptUrchinChild(childToAdopt, numChildrenAdopted)
	EndIf

	;Add the child to this quest.
	ChildAlias.ForceRefTo(childToAdopt)
	
	;Clear out the child's Actor Variables.
	childToAdopt.SetActorValue("Variable06", 0.0)
	childToAdopt.SetActorValue("Variable07", 0.0)
	childToAdopt.SetActorValue("Variable08", 0.0)
	
	;Reset RelationshipRank to 0 to dodge some inappropriate dialogue.
	childToAdopt.SetRelationshipRank(Game.GetPlayer(), 0)
	
	;Decide what to do with the newly-adopted child.
	;The child's packages expect Variable06 to be -1 for the child to run home (same city), or -2 for the child to wait around (different city).
	Debug.Trace("Running Behavior Setup")
	;Debug.Trace("Behavior setup: " + childDestination + " " + childDestinationLoc == childCurrentLoc + " " + childDestinationLoc.IsChild(childCurrentLoc))
	if (childDestination <= 5 && \
		(childDestinationLoc == childCurrentLoc || childDestinationLoc.IsChild(childCurrentLoc)))
		childToAdopt.SetActorValue("Variable06", -1.0)
	Else
		childToAdopt.SetActorValue("Variable06", -2.0)
	EndIf
	
	;Start the NewAdoptionHandler quest to get the child to execute that behavior.
	Debug.Trace("STARTING: " + BYOHRelationshipAdoptionNewAdoptionHandler.IsRunning() + " " + BYOHAdoptionNewAdoptionEvent + " " + childToAdopt)
	
	;Queue up a clean move to happen when the player leaves the area.	
	QueueMoveFamilyChild(childToAdopt, childDestination, True)
	
	;Adjust the adoption timestamp, setting it to the current time plus 3d.
	lastChildAdoptedTimestamp = Utility.GetCurrentGameTime() + 3
	
	;Update the child's faction rank in the Adoptable quest to make sure the correct dialogue is active.
	;This has to be run on both children, because adopting Child2 sometimes kicks Child1 from the rank.
	(Child1.GetReference() as Actor).SetFactionRank(BYOHRelationshipAdoptableFaction, 25)
	int i = 1
	Actor[] childArray = getChildArray()
	while i < childArray.length
		if childArray[i]
			childArray[i].SetFactionRank(BYOHRelationshipAdoptableFaction, 25)
			setPlayerLastSeen(childArray[i])
		endif
		i = i + 1
	endwhile
	
	;EVP the child to see what they should do next.
	childToAdopt.EvaluatePackage()
	
	;Initialize the 'last seen' timestamp.
	playerLastSeen = Utility.GetCurrentGameTime()
	
	;Release activation block.
	childToAdopt.BlockActivation(False)
	
	;Award 'Proud Parent' Achievement for adopting a child.
	Game.AddAchievement(61)
	
	;UHFP 2.0.4 - Adjust bed ownerships.
	UHFP_ReassignBedOwnerships( childDestination )

	;Whew! :)
	Debug.Trace("Adoption successful.")
EndFunction



;----------------------------------------------------------------------------------------------------
;MOVING SYSTEM
;-------------

;old function, doesn't do anything anymore
Function QueueMoveFamily(int destination, bool forceQueue = False)
EndFunction

;Queue up the family to move at the next opportunity.
Function QueueMoveFamilyChild(Actor child, int destination, bool forceQueue = False)
	Debug.Trace("PHX - QUEUE MOVE")
	If (PHX_CustomHomeManager == None)
		PHX_CustomHomeManager = Game.GetFormFromFile(0x00009A15, "HearthfireMultiKid.esp") As Quest
	EndIf


	queueMoveHelper(destination, child, forceQueue)

EndFunction


;Move the family to the queued location.
Function MoveFamily(Actor child)
	
	;Switch to a temporary package to prevent the Scheduler's packages from continuing to use obsolete data.
	MovingTogglePackageOn = True
	
	;Turn off the NewAdoptionHandler if it's running. MoveFamily can take it from here.
	if (BYOHRelationshipAdoptionNewAdoptionHandler.IsRunning())
		;Debug.Trace("New Adoption Handler was running. SHUT IT DOWN.")
		BYOHRelationshipAdoptionNewAdoptionHandler.Stop()
	EndIf
	
	;Stop any running critter events.
	QuashCritterEvents()

	int[] newHomeArray = getNewHomeArray()
	Actor[] childArray = getChildArray()
	int i = 0
	int childIndex = -1
	while (i < childArray.length)
		if child == childArray[i]
			childIndex = i
			newHomeRef = TranslateHouseIntToObj(newHomeArray[i])
			if (newHomeArray[i] == 9)
	      		(PHX_CustomHomeManager as PHX_HomeManagerScript).makeNewHomeCurrent()
			EndIf
			i = childArray.length ;break
		endif
		i = i + 1
	endwhile
	ReferenceAlias[] familyCritterAliasArray = getCritterAliasArray()
	Actor FamilyCritterREF = (familyCritterAliasArray[childIndex]).GetReference() as Actor
	if (FamilyCritterREF != None)
		int critterOwnerId = FamilyCritterREF.getActorValue("Variable06") as int
		if critterOwnerId == (childIndex + 1)
			FamilyCritterREF.MoveTo(newHomeRef)
			FamilyCritterREF.EvaluatePackage()
		endif
	EndIf

	if (child.GetCurrentLocation() != Game.GetPlayer().GetCurrentLocation())
		child.MoveTo(newHomeRef)
		child.EvaluatePackage()
	EndIf

	if child == petOwnerChild
		if (FamilyPet.GetActorRef() != None && !FamilyPet.GetActorRef().IsInFaction(CurrentFollowerFaction) && !FamilyPet.GetActorRef().Is3DLoaded())
			FamilyPet.GetActorRef().MoveTo(newHomeRef)
			FamilyPet.GetActorRef().EvaluatePackage()
		EndIf
	endif

	;Shut down the Scheduler Quest, if it was running.
	BYOHRelationshipAdoptionScheduler.Stop()
	While (BYOHRelationshipAdoptionScheduler.IsRunning())
		Utility.Wait(0.2)
	EndWhile
	
	int[] currentHomeArray = getCurrentHomeArray()
	i = 0
	ObjectReference existingChildHomeRef
	;make sure the other children who aren't being moved are inside their homes in case they were wandering outside
	while i < currentHomeArray.length
		if i != childIndex
			existingChildHomeRef = TranslateHouseIntToObj(currentHomeArray[i])
			childArray[i].MoveTo(existingChildHomeRef)
		endif
		i = i + 1
	endwhile

	;Move everyone again, in case delays in package evaluation or the Scheduler shutdown have caused them to leave the cell, which happens sometimes.
	if (FamilyCritterREF != None)
		int critterOwnerId = FamilyCritterREF.getActorValue("Variable06") as int
		if critterOwnerId == (childIndex + 1)
			FamilyCritterREF.MoveTo(newHomeRef)
			FamilyCritterREF.EvaluatePackage()
		endif
	EndIf


	debug.trace("child's location: " + child.GetCurrentLocation() )
	if (child.GetCurrentLocation() != Game.GetPlayer().GetCurrentLocation())
		child.MoveTo(newHomeRef)
		child.EvaluatePackage()
		debug.trace("child's location: " + child.GetCurrentLocation() )
	EndIf

	Actor FamilyPetREF = FamilyPet.GetReference() as Actor
	if child == petOwnerChild
		if (FamilyPetREF != None && !FamilyPetREF.IsInFaction(CurrentFollowerFaction) && !FamilyPetREF.Is3DLoaded())
			FamilyPetREF.MoveTo(newHomeRef)
			FamilyPetREF.EvaluatePackage()
		EndIf
	endif

	
	;Restart the Scheduler Quest in the new home.
	int schedulerFailCount = 0
	BYOHRelationshipAdoptionScheduler.SetStage(0)

	While (!BYOHRelationshipAdoptionScheduler.IsRunning() && schedulerFailCount < 10)
		schedulerFailCount = schedulerFailCount + 1
		Utility.Wait(0.5)
		;The most common cause of Scheduler failures is Child1 leaving the house AGAIN. Move them back and retry.
		;changed to move all the kids to their new homes
		i = 0
		while i < childArray.length
			newHomeRef = TranslateHouseIntToObj(newHomeArray[i])
			childArray[i].MoveTo(newHomeRef)
			Utility.wait(0.1)
			i = i + 1
		endwhile
		BYOHRelationshipAdoptionScheduler.SetStage(0)
	EndWhile



	if (!BYOHRelationshipAdoptionScheduler.IsRunning() && schedulerFailCount >= 10)
		;Uh-oh... this means the markers in the selected house are in a bad state (something probably didn't get enabled).
		Debug.Trace("THE ADOPTION SCHEDULER HAS FAILED TO START.")
		Debug.Notification("Scheduler failure.")
		if (!schedulerHasFailed)
			;Try to move the children back to their previous home. That's better than leaving them in their new home and broken.
			schedulerHasFailed = True
			QueueMoveFamilyChild(child,currentHomeArray[childIndex], True)
			MoveFamily(child)
			Return
		Else		
			;If the scheduler failed on our last move attempt as well, queue up an emergency move to somewhere. Hopefully somewhere else.
			Debug.Trace("THE ADOPTION SCHEDULER HAS FAILED TO START AGAIN. QUEUING EMERGENCY MOVE.")
			QueueMoveFamilyChild(child,-1, False)
			Return
		EndIf
	EndIf
	

	LocationAlias[] schedulerCurrentHomeHouseArray = getSchedulerCurrentHomeHouseArray()
	if schedulerCurrentHomeHouseArray[childIndex].getLocation() != None
	else
		;it didn't work
		MovingTogglePackageOn = False
		child.EvaluatePackage()
		return
	endif
	;Update our copy of the Scheduler's Aliases.
	updateHomeReferenceAliases()

	;need to check if spouse's home is also the custom Home
	if newHomeArray[childIndex] == 9
		LocationAlias[] currentHomeHouseArray = getCurrentHomeHouseArray()
		if (PHX_CustomHomeManager as PHX_HomeManagerScript).CurrentHomeLocation.GetLocation() ==  currentHomeHouseArray[childIndex].GetLocation()
			ReferenceAlias[] schedulerOutsideSandboxArray = getSchedulerOutsideSandboxArray()
    		;(PHX_CustomHomeManager as PHX_HomeManagerScript).updateSpouseOutsideSandbox()
    		((PHX_CustomHomeManager as PHX_HomeManagerScript).SandboxOutsideSpouse).ForceRefTo(schedulerOutsideSandboxArray[childIndex].getRef())
    	endif
    endif

    LocationAlias[] currentHomeExteriorArray = getCurrentHomeExteriorArray()
    ; PHX - restart CW siege handler to reset target location
	if (CWSiege.IsRunning() && CWSiege.getCurrentStageID() > 0 && \
		currentHomeExteriorArray[childIndex].GetLocation() != None && CWSiegeCity.GetLocation() == currentHomeExteriorArray[childIndex].GetLocation())
		;Debug.Trace("CW Flee Package Triggered")
		if (BYOHRelationshipAdoptionCWSiegeHandler.IsRunning())
	    	BYOHRelationshipAdoptionCWSiegeHandler.Stop()
		EndIf
		BYOHRelationshipAdoptionCWSiegeHandler.setCurrentStageID(0)
	EndIf


	;Clear Variable06 on the children to cancel any prior orders and the Just-Adopted override behaviors.
	Child.SetActorValue("Variable06", 0.0)

	;Reevaluate all packages relative to the new home.
	Child.EvaluatePackage()
	
	;Return to regularly-scheduled packaged behavior.
	MovingTogglePackageOn = False
	
	
	if (FamilyPet.GetActorRef() != None)
		FamilyPet.GetActorRef().EvaluatePackage()
	EndIf
	if (FamilyCritterRef != None)
		FamilyCritterRef.EvaluatePackage()
	EndIf
	
	;After the first clean move, and only the first clean move, fill the Child's Chest so it starts with something.
	if (!initialMoveDone)
		initialMoveDone = True
		;Debug.Trace("Now Refilling.")
		(BYOHRelationshipAdoptionScheduler as BYOHRelationshipAdoptionSc).OnUpdateGameTime()
	EndIf
	
	;Move completed successfully. Fixup variables.
	fixUpVariables(childIndex)
	
	;(PHX_CustomHomeManager as PHX_HomeManagerScript).updateCustomHomeStatus()	
	schedulerHasFailed = False
	

	;If a newly-adopted child has just moved in with us, decide which Forcegreet event they should play.
	handleNewGreet(child)
	;Debug.Trace("Move completed.")
EndFunction


;A 'dirty move' occurs in one very specific but unfortunately all-too-common case: the player adopts a child,
;sends them to their home in the same city, races home ahead of them, and expects the child to behave
;normally once they arrive.
;
;Since we can't teleport the family while the player is watching, we instead perform a 'dirty' move,
;one with no teleports. The spouse and any other children will begin walking home (which this system
;otherwise tries to avoid). We leave the clean move queued so it can run as soon as possible.
Function DirtyMoveFamily(Actor child)
	;Debug.Trace("Performing a Dirty Move.")
	
	;Switch to a temporary package to prevent the Scheduler's packages from continuing to use obsolete data.
	;Then force package evaluation to make sure everyone picks up the new package.
	MovingTogglePackageOn = True

	if (child != None)
		child.EvaluatePackage()
	EndIf
	
	if (FamilyPet.GetActorRef() != None)
		FamilyPet.GetActorRef().EvaluatePackage()
	EndIf
	
	;Turn off the NewAdoptionHandler if it's running. DirtyMoveFamily can take it from here.
	if (BYOHRelationshipAdoptionNewAdoptionHandler.IsRunning())
		;Debug.Trace("New Adoption Handler was running. SHUT IT DOWN.")
		BYOHRelationshipAdoptionNewAdoptionHandler.Stop()
	EndIf

	;Shut down the old Scheduler Quest, if it was running.
	BYOHRelationshipAdoptionScheduler.Stop()
	While (BYOHRelationshipAdoptionScheduler.IsRunning())
		Utility.Wait(0.5)
	EndWhile

	int[] newHomeArray = getNewHomeArray()
	Actor[] childArray = getChildArray()
	int[] currentHomeArray = getCurrentHomeArray()
	int i = 0
	Actor c = None
	int localNewHome = 0
	int localCurrentHome = 0
	int childIndex = -1

	while (i < childArray.length)
		c = childArray[i]
		if c == child
			childIndex = i
			localNewHome = newHomeArray[i]
			localCurrentHome = currentHomeArray[i]
			if (localNewHome == 9)
      			(PHX_CustomHomeManager as PHX_HomeManagerScript).makeNewHomeCurrent()
			EndIf
			i = childArray.length ;break
		endif
		i = i + 1
	endwhile
	
	;If the player just adopted their second child, but their first child isn't at home, we have a problem:
	;the Scheduler can't start unless Child1 is in the house, and by defintion, the player is there, so we
	;can't warp them in. So pull some sleight-of-hand...\
	Actor Child1Ref = Child1.GetReference() as Actor
	if (Child1Ref.GetCurrentLocation() != TranslateHouseIntToInteriorLoc(newHome))
		if (Child2.getReference() as Actor == None)
			;This is an error case: Child 1 is not home, and there isn't a Child 2. Teleport Child 1 just to get this to work.
			;Debug.Trace("Dirty move warps children.")
			Child1Ref.MoveTo(TranslateHouseIntToObj(newHome))
		Else
			;Debug.Trace("Dirty Move swaps children.")
			;SwapChildren(numChildrenAdopted)
			;If (Child1.GetActorRef().GetCurrentLocation() != TranslateHouseIntToInteriorLoc(newHome))
				; may be caused by new kid being adopted, while kid one was not at home.
			;	Child1.GetActorRef().MoveTo(TranslateHouseIntToObj(newHome))
			;Endif
		EndIf
	EndIf
	
	;Restart the Scheduler Quest in the new home.
	int schedulerFailCount = 0
	BYOHRelationshipAdoptionScheduler.SetStage(0)
	While (!BYOHRelationshipAdoptionScheduler.IsRunning() && schedulerFailCount < 10)
		Debug.Trace("Adoption: Waiting for Scheduler to start...")
		schedulerFailCount = schedulerFailCount + 1
		Utility.Wait(0.5)
		BYOHRelationshipAdoptionScheduler.SetStage(0)
	EndWhile
	if (!BYOHRelationshipAdoptionScheduler.IsRunning() && schedulerFailCount >= 10)
		;Uh-oh... this means the markers in the selected house are in a bad state (something probably didn't get enabled).
		Debug.Trace("THE ADOPTION SCHEDULER HAS FAILED TO START.")
		if (!schedulerHasFailed)
			;Try to move the children back to their previous home. That's better than leaving them in their new home and broken.
			schedulerHasFailed = True
			QueueMoveFamilyChild(child, localCurrentHome, True)
			MoveFamily(child)
			Return
		Else		
			;If the scheduler failed on our last move attempt as well, queue up an emergency move to somewhere. Hopefully somewhere else.
			Debug.Trace("THE ADOPTION SCHEDULER HAS FAILED TO START AGAIN. QUEUING EMERGENCY MOVE.")
			QueueMoveFamilyChild(child, -1, False)
			Return
		EndIf
	EndIf
	

	;Update our copy of the Scheduler's Aliases.

	updateHomeReferenceAliases()

	if newHomeArray[childIndex] == 9
		LocationAlias[] currentHomeHouseArray = getCurrentHomeHouseArray()
		if (PHX_CustomHomeManager as PHX_HomeManagerScript).CurrentHomeLocation.GetLocation() ==  currentHomeHouseArray[childIndex].GetLocation()
			ReferenceAlias[] schedulerOutsideSandboxArray = getSchedulerOutsideSandboxArray()
    		;(PHX_CustomHomeManager as PHX_HomeManagerScript).updateSpouseOutsideSandbox()
    		((PHX_CustomHomeManager as PHX_HomeManagerScript).SandboxOutsideSpouse).ForceRefTo(schedulerOutsideSandboxArray[childIndex].getRef())
    	endif
    endif
	
	;Clear Variable06 on the children to cancel any prior orders and the Just-Adopted override behaviors.
	child.SetActorValue("Variable06", 0)	
	
	;Return to regularly-scheduled packaged behavior.
	MovingTogglePackageOn = False
	
	Child.EvaluatePackage()
	if (FamilyPet.GetActorRef() != None)
		FamilyPet.GetActorRef().EvaluatePackage()
	EndIf
	
	;Dirty move completed successfully. Fixup variables.

	if childIndex == 0
		currentHome = newHome
	elseif childIndex == 1
		currentHome2 = newHome2
	elseif childIndex == 2
		currentHome3 = newHome3
	elseif childIndex == 3
		currentHome4 = newHome4
	elseif childIndex == 4
		currentHome5 = newHome5
	elseif childIndex == 5
		currentHome6 = newHome6
	elseif childIndex == 6
		currentHome7 = newHome7
	endif


	;(PHX_CustomHomeManager as PHX_HomeManagerScript).updateCustomHomeStatus()
	schedulerHasFailed = False
	
	;If a newly-adopted child has just moved in with us, decide which Forcegreet event they should play.
	handleNewGreet(child)
	
	;Debug.Trace("Dirty Move completed.")
EndFunction


;----------------------------------------------------------------------------------------------------
;GAMES SYSTEM
;------------

;Starts one of the WI Games. 1 = Tag, 2 = HideAndSeek
Function StartGame(int gameToPlay, Actor childToPlay)
	;Cleanup any previous games to make sure the new one starts sucessfully.
	StopGames()
	;Unblock games for this child, if they were blocked.
	UnblockGames(childToPlay)
	;Run the game.
	;@TODO get the right currenthomeexterior
	LocationAlias[] currentHomeExteriorArray = getCurrentHomeExteriorArray()
	Actor[] childArray = getChildArray()
	LocationAlias homeExterior = None
	int i = 0
	while (i < childArray.length)
		if childToPlay == childArray[i]
			homeExterior = currentHomeExteriorArray[i]
			i = childArray.length ; break
		endif	
		i = i + 1
	endwhile

	if gameToPlay == 1
		WIGamesTagStart.SendStoryEvent(homeExterior.GetLocation(), Game.GetPlayer(), childToPlay)
	else
		WIGamesHideAndSeekStart.SendStoryEvent(homeExterior.GetLocation(), Game.GetPlayer(), childToPlay)
	EndIf
EndFunction

;Stop any active WI Games.
Function StopGames()
	WIGamesTag.Stop()
	WIGamesHideAndSeek.Stop()
EndFunction

;Block the child from being added to any new WE Games.
;Used to avoid problems when they're in a scene or forcegreet we don't want them to be pulled out of.
Function BlockGames(Actor child)
	child.AddToFaction(WINeverFillAliasesFaction)
EndFunction

;Release the block, allowing children to be added to new WE Games.
Function UnblockGames(Actor child)
	child.RemoveFromFaction(WINeverFillAliasesFaction)
EndFunction


;----------------------------------------------------------------------------------------------------
;ORDERS SYSTEM
;-------------

;Player issues an order to their child.
;All orders received from dialogue have an standard duration of 3h.
Function IssueOrder(ObjectReference child)
	IssueOrderWithDuration(child, 3)
EndFunction

;Player issues an order to their child.
Function IssueOrderWithDuration(ObjectReference child, float duration)
	;Debug.Trace("Received order " + OrderToConfirm + " for " + child)
	
	;Remove the child from any running games.
	StopGames()
	ReferenceAlias[] childAliasArray = getChildAliasArray()
	int i = 0
	;Check whether this order is safe to execute.
	;Really only an issue for the gift-driven orders, since we don't want both kids using the same marker at the same time.
	if ( (OrderToConfirm == 1.1 || OrderToConfirm == 1.2) )
		;If not safe, just void it.
		while i < childAliasArray.length
			if childAliasArray[i].getActorRef() != None && childAliasArray[i].getActorRef().getAV("Variable06") == OrderToConfirm
				;Debug.Trace("Voided unsafe order " + OrderToConfirm)
				OrderToConfirm = 0
				i = childAliasArray.length ; break
			endif
			i = i + 1
		endwhile
	Else
		while i < childAliasArray.length
			if child == childAliasArray[i].getActorRef()
				(childAliasArray[i] as BYOHRelationshipAdoptionChildScript).IssueOrder(OrderToConfirm, duration)
				i = childAliasArray.length
			endif
			i = i + 1
		endwhile
	EndIf
	
	i = 0
	;For the 'Never Speak to You Again' order, void any outstanding Forcegreet Events.
	if (OrderToConfirm == 10)
		;Debug.Trace("Order was: Never Speak to You Again, so voiding Forcegreets.")
		ForcegreetEventReady = False
		while i < childAliasArray.length
			if child == childAliasArray[i].getActorRef()
				childAliasArray[i].GetActorRef().SetAV("Variable07", 0)
				i = childAliasArray.length
			endif
			i = i + 1
		endwhile
	EndIf	
EndFunction

;Issue the 'Never Speak to You Again' order, which causes both kids to flee to their rooms and lasts for 24h.
Function IssueOrderNeverSpeakToYouAgain(ObjectReference child)
	OrderToConfirm = 10
	IssueOrderWithDuration(child, 24)
EndFunction


;----------------------------------------------------------------------------------------------------
;GIFT-GIVING SYSTEM
;------------------

;Display the gift menu, process the results, and return control to dialogue when done.
Function GiveChildGift(Actor child)
	;Clear the variable that stores the child's immediate response.
	GiftReaction = 0

	;Determine which gift list to use based on the child's gender.
	Formlist giftList
	if (child.GetActorBase().GetSex() == 0)
		giftList = BYOHRelationshipAdoptionPlayerGiftChildMale
	Else
		giftList = BYOHRelationshipAdoptionPlayerGiftChildFemale
	EndIf
	
	ReferenceAlias[] childAliasArray = getChildAliasArray()
	int i = 0

	;Alert the child to pay attention to items being given to them.
	while i < childAliasArray.length
		if child == childAliasArray[i].getActorRef()
			(childAliasArray[i] as BYOHRelationshipAdoptionChildScript).SetGiftState(True)
			i = childAliasArray.length
		endif
		i = i + 1
	endwhile

	
	;Debug.Trace("Now Giving Gifts...")
	
	;Player gives gifts to the child.
	;As the player gives gifts, BYOHRelationshipAdoptionChildScript's OnItemAdded event will process them and call the secondary functions below.
	bool gaveAnyGift = child.ShowGiftMenu(True, giftlist)
	
	;Exit gift-giving state on the child.
	(childAliasArray[i] as BYOHRelationshipAdoptionChildScript).SetGiftState(False)
	
	;Debug.Trace("Gift giving completed. Response is: Any:" + gaveAnyGift + ", Value:" + GiftReaction)
EndFunction


;Called by BYOHRelationshipAdoptionChildScript to store off the gold and emotional value of the gifts.
Function UpdateGiftValues(Actor child, int EmotionalValue, int RealValue)
	;Debug.Trace("Updating Gift Value: " + child + " " + EmotionalValue + " " + RealValue)
	;Regardless of which child this is, GiftReaction increments.
	GiftReaction = GiftReaction + EmotionalValue

	UpdateGiftValueHelper(child, RealValue)
EndFunction



;----------------------------------------------------------------------------------------------------
;CHILD CHEST SYSTEM
;------------------

;When requested by the Scheduler, refill the child's chest. This is handled like a give player gift event, using similar formlists.
Function RefillChest(ObjectReference childChest)
	;Debug.Trace("RefillChest refills chest.")
	;Generate 1-3 instances of 3-5 items from the Junk list.
	int roll = Utility.RandomInt(3, 5)
	int random
	;Debug.Trace("Level 1 Items: " + roll)
	While (roll > 0)
		random = Utility.RandomInt(0, BYOHRelationshipAdoptionGifts_Junk.GetSize() - 1)
		childChest.AddItem(BYOHRelationshipAdoptionGifts_Junk.GetAt(random), Utility.RandomInt(1,3))
		roll = roll - 1
	EndWhile
	
	;Generate 1-3 items from the 0025 list.
	roll = Utility.RandomInt(1, 3)
	;Debug.Trace("Level 2 Items: " + roll)
	While (roll > 0)
		random = Utility.RandomInt(0, BYOHRelationshipAdoptionGifts_0025.GetSize() - 1)
		childChest.AddItem(BYOHRelationshipAdoptionGifts_0025.GetAt(random), 1)
		roll = roll - 1
	EndWhile
	
	;Generate one item from a higher-level list if the child's gold supports it, deducting accordingly.
	Actor[] childArray = getChildArray()
	Actor child
	int moneyCount = 0;
	int tempCount = 0;
	int i = 0
	while i < childArray.length
		if childArray[i] != None
			tempCount = child.GetItemCount(Gold001)
			if (tempCount > moneyCount || (child == None))
				child = childArray[i]
				moneyCount = tempCount
			endif
		endif
		i = i + 1
	endwhile
	
	if (child.GetItemCount(Gold001) > 25)
		;Debug.Trace("Level 3 Item Added")
		Formlist list = PickGiftList(child.GetItemCount(Gold001))
		roll = Utility.RandomInt(0, list.GetSize() - 1) ;UHFP 2.0.2 - GetSize() -1 or you go off the end of the list.
		childChest.AddItem(list.GetAt(roll), 1)
		int deduction = PickDeduction(child.GetItemCount(Gold001))
		deduction = (deduction / 2) + Utility.RandomInt(0, deduction / 2)
		;Debug.Trace("Deducting: " + deduction)
		child.RemoveItem(Gold001, deduction)
	EndIf	
EndFunction



;----------------------------------------------------------------------------------------------------
;PET EVENTS
;----------
;Reminder: Pets are player follower animals (dogs), Critters are kid animals (hares, foxes, etc.).

;Adopt the pet under consideration into the family.
Function AdoptPet(Actor child)
	;Debug.Trace("Adopting " + TransientPet.GetActorRef())
	Actor newPet = TransientPet.GetActorRef()
	TransientPet.Clear()
	Actor[] childArray = getChildArray()
	int i = 0
	int childIndex = 0
	while i < childArray.length
		if childArray[i] == child
			childIndex = i
			i = childArray.length ; break
		endif
		i = i + 1
	endwhile
	newPet.setFactionRank(petChildOwnerFaction, (childIndex + 1))

	FamilyPet.ForceRefTo(newPet)
	Scheduler_FamilyPet.ForceRefTo(newPet)
	FamilyPet.GetActorRef().EvaluatePackage()
	petOwnerChild = child	
EndFunction

;Reject the pet under consideration, preventing further pet events for 15d.
Function RejectPet()
	;Debug.Trace("Rejecting " + TransientPet.GetActorRef())
	petRetryTime = petRetryTime + 15
EndFunction

;We 'ban' future pet and critter events by dramatically increasing the timer.
Function BanPet()
	;Debug.Trace("Now banning pets and critters")
	petRetryTime = petRetryTime + 100000
	critterRetryTime = critterRetryTime + 100000
EndFunction

;When a pet unloads, if it has been dismissed by the player (not at home, not in follower faction), warp it home.
Function PetUnloaded()
	;Debug.Trace("Pet detached.")
	int ChildIndex = petOwnerChild.getFactionRank(petChildOwnerFaction) 
	ChildIndex = ChildIndex - 1
	LocationAlias[] currentHomeHouseArray = getCurrentHomeHouseArray()
	int[] currentHomeArray = getCurrentHomeArray()
	if FamilyPet.GetActorRef().GetCurrentLocation() != currentHomeHouseArray[ChildIndex].GetLocation() && \
		Game.GetPlayer().GetCurrentLocation() != currentHomeHouseArray[ChildIndex].GetLocation() && \
		!FamilyPet.GetActorRef().IsInFaction(CurrentFollowerFaction)

		FamilyPet.GetActorRef().MoveTo(TranslateHouseIntToObj(currentHomeArray[ChildIndex]))

	endif
EndFunction

;When a pet is killed:
; - Remove them from their Adoption aliases to allow pets to be adopted in the future.
; - If the player killed the pet, put the children into the "Never Speak to You Again" behavior.
Function PetDeath(Actor akKiller)
	;Debug.Trace("Pet has died.")
	FamilyPet.Clear()
	Scheduler_FamilyPet.Clear()
	if (akKiller == Game.GetPlayer())
		Actor[] childArray = getChildArray()
		;Debug.Trace("Player killed pet, so putting children into 'Never Speak to You Again'.")
		int ChildIndex = petOwnerChild.getFactionRank(petChildOwnerFaction)
		ChildIndex = ChildIndex - 1
		IssueOrderNeverSpeakToYouAgain(childArray[ChildIndex])
	EndIf
EndFunction



;----------------------------------------------------------------------------------------------------
;CRITTER EVENTS
;--------------
;Reminder: Pets are player follower animals (dogs), Critters are kid animals (hares, foxes, etc.).


Bool Function alreadyHaveCritter(Actorbase critterActorBase, ReferenceAlias[] critterAliasArray)
	int i = 0
	Actor critterActor
	while i < critterAliasArray.length
		critterActor = critterAliasArray[i].getActorRef()
		if (critterActor.getActorBase() ) == critterActorBase
			;you already have this kind of critter
			return true
		endif
		i = i + 1
	endwhile
	return false
EndFunction

;Spawn a new critter the child will ask to keep.
Function SetupCritter(Actor child)
	;Debug.Trace("Now setting up the critter.")
	
	;Pick a critter from the formlist. Anything but the last one we rejected will do.
	; Build a flat list of all candidates, shuffle it, pick the first valid one
	ActorBase critterBase = None
	ReferenceAlias[] critterAliasArray = getCritterAliasArray()

	; Collect all candidates into one array
	int maleCount   = BYOHRelationshipAdoption_CrittersMale.GetSize()
	int femaleCount = BYOHRelationshipAdoption_CrittersFemale.GetSize()
	int totalCount  = maleCount + femaleCount
	ActorBase[] candidates = new ActorBase[5]  ; Papyrus arrays are fixed-size

	int i = 0
	While i < maleCount
	    candidates[i] = BYOHRelationshipAdoption_CrittersMale.GetAt(i) as ActorBase
	    i += 1
	EndWhile
	While i < totalCount
	    candidates[i] = BYOHRelationshipAdoption_CrittersFemale.GetAt(i - maleCount) as ActorBase
	    i += 1
	EndWhile

	; Fisher-Yates shuffle, randomize the array
	int j = totalCount - 1
	While j > 0
	    int k = Utility.RandomInt(0, j)
	    ActorBase tmp = candidates[j]
	    candidates[j] = candidates[k]
	    candidates[k] = tmp
	    j -= 1
	EndWhile

	; Pick first valid candidate — bounded, guaranteed to terminate
	int idx = 0
	While idx < totalCount && critterBase == None
	    ActorBase candidate = candidates[idx]
	    if candidate != rejectedCritterBase && !alreadyHaveCritter(candidate, critterAliasArray)
	        critterBase = candidate
	    endif
	    idx += 1
	EndWhile
	; critterBase is None only if every single critter is already owned — handle gracefully
	if !critterBase
		return
	endif

	;Create the critter and force it into aliases.
	;Debug.Trace("Spawning: " + critterBase)
	Actor newCritter = child.PlaceActorAtMe(critterBase)
	j = 0
	if !TransientCritter
		TransientCritter.ForceRefTo(newCritter)
		Scheduler_TransientCritter.ForceRefTo(newCritter)
	else
		
		ReferenceAlias[] critterSchedulerAliasArray = getCritterSchedulerAliasArray()
		while j < critterAliasArray.length
			if !( critterAliasArray[j].getActorRef() ) ; empty
				;
				(critterAliasArray[j]).ForceRefTo(newCritter)
				critterSchedulerAliasArray[j].ForceRefTo(newCritter)
				j = critterAliasArray.length ;break
			endif 
			j = j + 1
		endWhile
	endif
	
	
	Actor[] childArray = getChildArray()
	i = 0
	while i < childArray.length
		if childArray[i] == child
			newCritter.SetAV("Variable06", i + 1)
			i = childArray.length ; break
		endif
		i = i + 1
	endwhile
	
	;EVP Child and Critter, then move them to their scene locations.
	child.EvaluatePackage()
	child.MoveToPackageLocation()
	newCritter.EvaluatePackage()
	newCritter.MoveToPackageLocation()
EndFunction

;If a critter event is running, and we need to stop it, this function will do the job.
Function QuashCritterEvents()
	Actor[] childArray = getChildArray()
	int i = 0
	;Debug.Trace("Quashing Critter Events.")
	while i < childArray.length
		if childArray[i] != None
			if childArray[i].getAV("Variable07") == 5
				childArray[i].SetAV("Variable07", 0)
			endif
		endif
		i = i + 1
	endwhile
	
	if (TransientCritter.GetActorRef() != None)
		RejectCritter()
	EndIf	
EndFunction


;Adopt the critter under consideration into the family.
Function AdoptCritter()
	;Debug.Trace("Adopting " + TransientCritter.GetActorRef())
	Actor newCritter = TransientCritter.GetActorRef()
	TransientCritter.Clear()
	Scheduler_TransientCritter.Clear()
	ReferenceAlias[] critterArray = getCritterAliasArray()
	int i = 0
	int critterIndex = 0
	while i < critterArray.length
		if critterArray[i].getActorRef() ;not filled
			critterIndex = i
			i = 5
		else
			i = i + 1
		endif
	endwhile
	ReferenceAlias[] critterSchedulerArray = getCritterSchedulerAliasArray()
	critterArray[critterIndex].ForceRefTo(newCritter)
	critterSchedulerArray[critterIndex].ForceRefTo(newCritter)
	
	;EVP the critter.
	critterArray[critterIndex].GetActorRef().EvaluatePackage()
EndFunction

;Reject the critter under consideration, preventing further critter events for 15d.
Function RejectCritter()
	;Debug.Trace("Rejecting " + TransientCritter.GetActorRef())
	rejectedCritter = TransientCritter.GetActorRef()
	rejectedCritterBase = TransientCritter.GetActorRef().GetActorBase()
	critterRetryTime = critterRetryTime + 15
	
	;Disable the critter. A bit ugly, since most of them don't fade.
	rejectedCritter.Disable(True)
	
	;Debug.Trace("Deleting rejected critter.")
	TransientCritter.Clear()
	Scheduler_TransientCritter.Clear()
	rejectedCritter.Disable()
	rejectedCritter.Delete()
	rejectedCritter = None
EndFunction

;We 'ban' future pet and critter events by dramatically increasing the timer.
Function BanCritters()
	;Debug.Trace("Now banning pets and critters")
	petRetryTime = petRetryTime + 100000
	critterRetryTime = critterRetryTime + 100000
	
	;A ban also rejects the current critter.
	RejectCritter()
EndFunction

;When a critter is killed:
; - Remove them from their Adoption aliases to allow critters to be adopted in the future.
; - Block new critter events for 15d.
; - If the player killed the pet, put the children into the "Never Speak to You Again" behavior.
Function CritterDeath(Actor akKiller)
	;Debug.Trace("Critter has died.")

	critterRetryTime = Utility.GetCurrentGameTime() + 15
	if (akKiller == Game.GetPlayer())
		Actor[] childArray = getChildArray()
		int i = 0
		;Debug.Trace("Player killed critter, so putting children into 'Never Speak to You Again'.")
		while i < childArray.length
			if childArray[i] && FamilyCritter.getActorRef().getAV("Variable06") == (i+1)
				IssueOrderNeverSpeakToYouAgain(childArray[i])
				i = childArray.length ; break
			endif
			i = i + 1
		endwhile
	EndIf
	FamilyCritter.Clear()
	Scheduler_FamilyCritter.Clear()
EndFunction



;----------------------------------------------------------------------------------------------------
;WELCOME HOME SYSTEM
;-------------------


;Set up a Forcegreet Event when requested by a Location Change event.
Function ReadyForcegreetEvent(Actor child = None)
	;Debug.Trace("Attempting to ready Forcegreet Event")
	if (!ForcegreetEventReady)
		ForcegreetEventReady = True
		if child
			ForceGreetChild = child
		endif
		;Make sure the children aren't in any games.
		StopGames()
		
		;Declare some local variables.
		int eventNumber
		Actor eventChild
		bool[] childNewlyAdoptedArray = getChildNewlyAdoptedArray()
		Actor[] childArray = getChildArray()
		int i = 0
		;Select the event.
		;EVENT 1 - CHILD THANKS PLAYER FOR ADOPTION, NO CHEST INTRO
		;Occurs if: Child newly adopted, Initial Move is a Dirty Move
		;Debug.Trace("New Adoption: " + (Child1NewlyAdopted || Child2NewlyAdopted) + "  Initial Move: " + initialMoveDone + "  Chest Intro'd: " + ChildChestIntroduced)
		If (isAnyChildNewlyAdopted() && (!initialMoveDone || ChildChestIntroduced))
			eventNumber = 1
			while i < childNewlyAdoptedArray.length
				if childNewlyAdoptedArray[i] && (!initialMoveDone || ChildChestIntroduced)
					eventChild = childArray[i]
					i = childArray.length ; break
				endif
				i = i + 1
			endwhile
		;EVENT 2 - CHILD THANKS PLAYER FOR ADOPTION, INCLUDES CHEST INTRO
		;Occurs if: Child newly adopted, Initial Move is a Clean Move
		ElseIf (isAnyChildNewlyAdopted() && initialMoveDone && !ChildChestIntroduced)
			ChildChestIntroduced = True
			eventNumber = 2
			while i < childNewlyAdoptedArray.length
				if childNewlyAdoptedArray[i] && (!initialMoveDone || ChildChestIntroduced)
					eventChild = childArray[i]
					i = childArray.length ; break
				endif
				i = i + 1
			endwhile
		
		;EVENT 3 - CHILD INTRODUCES CHEST SYSTEM
		;Occurs if: Child previously performed 
		ElseIf (initialMoveDone && !ChildChestIntroduced)
			ChildChestIntroduced = True
			eventNumber = 3
			eventChild = child
			
		;EVENT 4 - ADOPT A PET
		;Occurs if: FamilyPet is empty, Player has an Animal Companion, time > petRetryTime
		ElseIf ( (FamilyPet.GetActorRef() == None) && isAnimalPetRefAliasFilled() && Utility.GetCurrentGameTime() > petRetryTime)
			int suitability
			if  (Game.GetFormFromFile(0x0000434F, "nwsFollowerFramework.esp") as bool )
				TransientPet.ForceRefTo(NWSAnimalFollower)
				suitability = EvaluatePetSuitability()
				NWSAnimalFollower = None
			else
				TransientPet.ForceRefTo(AnimalCompanion.GetActorRef())
				suitability = EvaluatePetSuitability()
			endif

			eventNumber = 4
			eventChild = child
		
		;EVENT 5 - ADOPT A CRITTER
		;Occurs if: FamilyCritter Alias Array is not full, time > critterRetryTime, 10% Chance
		ElseIf (!isCritterArrayFull() && !doesChildHaveCritter(childArray, child) && (Utility.GetCurrentGameTime()> critterRetryTime) &&  (Utility.RandomInt(1, 100) <= GVCritterEventChance.getValueInt() && Child) )
			ReferenceAlias[] critterAliasArray = getCritterAliasArray()
			
			;need to check if child already has a critter following
			eventNumber = 5
			eventChild = child
			;We'll create the new Critter here. Set Variable07 early so SetupCritter can use it.
			eventChild.SetActorValue("Variable07", eventNumber)
			SetupCritter(eventChild)

		;EVENT 6 - NAME CALLING 1
		;Occurs if: Player has two children, they haven't played this scene before, they didn't do a Name Calling Scene last time, 10% chance.
		;check if kids are in same home
		;currently only works in CurrentHomeLocation1
		ElseIf (Child2.GetActorRef() != None && !NameCalling1Done && (!moveQueued && !moveQueued2) && !NameCallingUsedLast && Utility.RandomInt(1, 100) < nameCallingChance && CurrentHomeHouse.getLocation() == CurrentHomeHouse2.getLocation() && Game.GetPlayer().GetCurrentLocation() == CurrentHomeHouse.getLocation())
			eventNumber = 6
			eventChild = Child1.GetActorRef() ;PickRandomChild()	;Doesn't matter, since we're just going to override the usual behavior...
			NameCalling1Done = True
			NameCallingUsedLast = True
			ResortChildrenForNameCalling()
			BlockGames(Child1.GetActorRef())
			BlockGames(Child2.GetActorRef())
			Child1.GetActorRef().SetActorValue("Variable07", eventNumber)
			Child2.GetActorRef().SetActorValue("Variable07", eventNumber)

			Child1.GetActorRef().MoveTo(SchedulerSceneMarker1.GetReference()) ;scene marker 1 of CurrentHomeLocation, child 1's home.  child 1 and child 2's home is the same
			Child2.GetActorRef().MoveTo(SchedulerSceneMarker2.GetReference())
			RelationshipAdoption_SceneNameCalling01.Start()
		
			
		;EVENT 7 - NAME CALLING 2
		;Occurs if: Player has two children, they haven't played this scene before, they didn't do a Name Calling Scene last time, 10% chance.
		;check if kids are in same home
		;currently only works in CurrentHomeLocation1
		ElseIf (Child2.GetActorRef() != None && !NameCalling2Done && (!moveQueued && !moveQueued2) && !NameCallingUsedLast && Utility.RandomInt(1, 100) < nameCallingChance && CurrentHomeHouse.getLocation() == CurrentHomeHouse2.getLocation() && Game.GetPlayer().GetCurrentLocation() == CurrentHomeHouse.getLocation())
			eventNumber = 7
			eventChild = Child1.GetActorRef() ;PickRandomChild()	;Doesn't matter, since we're just going to override the usual behavior...
			NameCalling2Done = True
			NameCallingUsedLast = True
			ResortChildrenForNameCalling()
			BlockGames(Child1.GetActorRef())
			BlockGames(Child2.GetActorRef())
			Child1.GetActorRef().SetActorValue("Variable07", eventNumber)
			Child2.GetActorRef().SetActorValue("Variable07", eventNumber)

			Child1.GetActorRef().MoveTo(SchedulerSceneMarker1.GetReference())
			Child2.GetActorRef().MoveTo(SchedulerSceneMarker2.GetReference())
			RelationshipAdoption_SceneNameCalling02.Start()
		
		;EVENT 10-13 - GENERIC EVENTS
		;Randomly select from one of the other events.
		Else
			if (Game.GetFormFromFile(0x00000800, "IDE Hearthfire.esp") as bool )
				eventChild = child
				Quest aaHFChildren = Game.getFormFromFile(0x00000800, "IDE Hearthfire.esp") as Quest
				ReferenceAlias EventChild1 = aaHFChildren.GetAlias(26) as ReferenceAlias
				ReferenceAlias EventChild2 = aaHFChildren.GetAlias(27) as ReferenceAlias
				EventChild1.ForceRefTo(eventChild)

				Int Random
				Int VanillaOrIDE = Utility.RandomInt(1, 10)

				if VanillaOrIDE <= 2
					Random = Utility.RandomInt(10, 13)
				elseif VanillaOrIde >= 3
					if Child2.GetActorRef() != None
						Random = Utility.RandomInt(14, 17)
						if eventChild == Child1.GetActorRef()
							EventChild2.ForceRefTo(Child2.GetActorRef())
						elseif eventChild == Child2.GetActorRef()
							EventChild2.ForceRefTo(Child1.GetActorRef())
						endif
					elseif Child2.GetActorRef() == None
						Random = Utility.RandomInt(14, 15)
					endif
				endif

				GlobalVariable aaHFQuestioningOverused = Game.GetFormFromFile(0x00000B3F, "IDE Hearthfire.esp") as GlobalVariable
				Faction aaHFPensiveFaction = Game.GetFormFromFile(0x00000805, "IDE Hearthfire.esp") as Faction
				Faction aaHFCuriousFaction = Game.GetFormFromFile(0x00000806, "IDE Hearthfire.esp") as Faction

				if Random == 15 && aaHFQuestioningOverused.Value > 1
					aaHFQuestioningOverused.Value -= 1
					Random = Utility.RandomInt(10, 14)
				elseif Random == 15 && aaHFQuestioningOverused.Value == 1
					aaHFQuestioningOverused.Value = 3
				endif

				if Random == 16
					if (Child1.GetActorRef().IsInFaction(aaHFPensiveFaction) && Child2.GetActorRef().IsInFaction(aaHFPensiveFaction)) || (Child1.GetActorRef().IsInFaction(aaHFCuriousFaction) && Child2.GetActorRef().IsInFaction(aaHFCuriousFaction))
						Random = Utility.RandomInt(10, 14)
						if Random == 14
							Random = 17
						endif
					endif
				endif
				
				eventNumber = Random

				if Random == 17
					if (CurrentHomeHouse.getLocation() == CurrentHomeHouse2.getLocation() && Game.GetPlayer().GetCurrentLocation() == CurrentHomeHouse.getLocation())
						Scene ChildStarterScene = Game.GetFormFromFile(0x0000090E, "IDE Hearthfire.esp") as Scene
						ChildStarterScene.Start()
					else
						;child 1 and 2 arent at same home, terminate
						ForcegreetEventReady = false
						return
					endif
				endif

			else
				eventNumber = Utility.RandomInt(10, 13)
				eventChild = child
			endif
		EndIf
		
		;For all of the non-Generic Forcegreets, block games on the selected child to prevent interference.
		if (eventNumber < 10)
			BlockGames(eventChild)
		EndIf
		
		;If we used a Name Calling scene last time around, but we're doing something different this time, clear the flag.
		if (NameCallingUsedLast && eventNumber != 6 && eventNumber != 7)
			NameCallingUsedLast = False
		EndIf

		;Trigger the selected event.
		;Debug.Trace("Forcegreet: " + eventChild + " " + eventNumber)
		eventChild.SetActorValue("Variable07", eventNumber)
		eventChild.EvaluatePackage()
		setPlayerLastSeen(child)
	EndIf
EndFunction



;Evaluate the pet in the TransientPet alias to determine whether it's suitable for adoption, and whether it's a dog.
;Returns the int (Faction Rank) representing the suitability. Stores the 'dog' status as AV06=1.
int Function EvaluatePetSuitability()
	int suitability = 1	;1=None, 2=UNUSED, 3=All Children
	
	Race transient = TransientPet.GetActorRef().GetRace()
	Race current
	
	;Is this pet a dog? If so, store it as AV06=0.
	int i = 0
	While (i < BYOHRelationshipAdoption_PetDogsList.GetSize())
		current = BYOHRelationshipAdoption_PetDogsList.GetAt(i) as Race
		;Debug.Trace("Comparing: " + transient + " : " + current)
		if (current == transient)
			;Debug.Trace("Pet is a dog.")
			TransientPet.GetActorRef().SetAV("Variable06", 1)
			i = BYOHRelationshipAdoption_PetDogsList.GetSize()
		EndIf
		i = i + 1	
	EndWhile
	
	;Is this pet adoptable by any child?
	i = 0
	While (i < BYOHRelationshipAdoption_PetAllowedRacesList.GetSize())
		current = BYOHRelationshipAdoption_PetAllowedRacesList.GetAt(i) as Race
		;Debug.Trace("Comparing: " + transient + " : " + current)
		if (current == transient)
			;Debug.Trace("EvalPetSuitability found pet in General list.")
			suitability = 3
			i = BYOHRelationshipAdoption_PetAllowedRacesList.GetSize()
		EndIf
		i = i + 1	
	EndWhile
	
	;Update the faction rank to store this result for use as a dialogue condition.
	TransientPet.GetActorRef().SetFactionRank(BYOHRelationshipPotentialPetFaction, suitability)
	
	;Return the rank so we can decide which child to use for this event.
	;Debug.Trace("EvalPetSuitability returns: " + suitability)
	return suitability
EndFunction


;Name-Calling Events (6 & 7)
;Resort the player's children for the name-calling scene.
Function ResortChildrenForNameCalling()
	ActorBase current
	int i = 0
	While (i < BYOHRelationshipAdoption_NameCallingWinnersList.GetSize())
		current = (BYOHRelationshipAdoption_NameCallingWinnersList.GetAt(i) as ActorBase)
		;Debug.Trace("Resort checking: " + current)
		if (current == Child1.GetActorRef().GetActorBase())
			;Debug.Trace("Swap Children: " + current)
			SwapChildren(2)
			Return
		ElseIf (current == Child2.GetActorRef().GetActorBase())
			;Debug.Trace("Quick Return: " + current)
			Return
		EndIf
		i = i + 1	
	EndWhile
EndFunction

;Name-Calling Events (6 & 7)
;Player cuts off the Name-calling event.
Function BreakNameCalling(bool orderToRoom, Actor childToOrder)
	ForcegreetEventReady = False
	RelationshipAdoption_SceneNameCalling01.Stop()
	RelationshipAdoption_SceneNameCalling02.Stop()
	Child1.GetActorRef().SetActorValue("Variable07", 0)
	Child2.GetActorRef().SetActorValue("Variable07", 0)
	UnblockGames(Child1.GetActorRef())
	UnblockGames(Child2.GetActorRef())
	if (orderToRoom)
		OrderToConfirm = 1.3
		IssueOrder(childToOrder)
	EndIf
	Child1.GetActorRef().EvaluatePackage()
	Child2.GetActorRef().EvaluatePackage()
EndFunction

;Allowance Event: Add to the Poor Count if no allowance is given.
;When WeArePoorCount >= 3, the gift forcegreet has some unique dialogue.
Function IncrementPoorCount()
	WeArePoorCount = WeArePoorCount + 1
EndFunction

;Allowance Event: Decrement the Poor Count if an allowance is given.
;WeArePoorCount decrements faster if you give the child more money.
Function DecrementPoorCount(int amount)
	WeArePoorCount = WeArePoorCount - amount
	if (WeArePoorCount < 0)
		WeArePoorCount = 0
	EndIf
EndFunction

;Give Player Gift Event: Roll up a poor gift if appropriate.
Function FGReceivePoorGift(Actor child)
	Formlist temp = BYOHRelationshipAdoptionGifts_Poor
	int roll = Utility.RandomInt(0, temp.GetSize() - 1)
	Game.GetPlayer().AddItem(temp.GetAt(roll), 1)
	DecrementPoorCount(2)
EndFunction

;Give Player Gift Event: Roll up a gift, give it, and deduct the cost.
Function FGReceiveGift(Actor child)
	Formlist list = PickGiftList(child.GetItemCount(Gold001))	;Decide which list of gifts to use.
	int roll = Utility.RandomInt(0, list.GetSize() - 1)			;Roll for a gift on the list. [UHFP 2.0.2 - Need to use GetSize() -1 or you're going to run off the end of the list.]
	int luck = 1												;Small chance of giving two of an item.
	if (Utility.RandomInt() > 90)
		luck = 2
	EndIf
	Game.GetPlayer().AddItem(list.GetAt(roll), luck)						;Give the gift
	int deduction = PickDeduction(child.GetItemCount(Gold001))			;Determine how much to 'charge' the child for the gift.
	deduction = (deduction / 2) + Utility.RandomInt(0, deduction / 2)
	;Debug.Trace("Deducting: " + deduction)
	child.RemoveItem(Gold001, deduction * luck)
EndFunction

;Give Player Gift Event: Helper Function to select the appropriate formlist.
FormList Function PickGiftList(int gold)
	if (gold < 25)
		return BYOHRelationshipAdoptionGifts_0000
	ElseIf (gold < 50)
		;Debug.Trace("Pick gift from list 0025")
		return BYOHRelationshipAdoptionGifts_0025
	ElseIf (gold < 100)
		;Debug.Trace("Pick gift from list 050")
		return BYOHRelationshipAdoptionGifts_0050
	ElseIf (gold < 250)
		;Debug.Trace("Pick gift from list 0100")
		return BYOHRelationshipAdoptionGifts_0100
	ElseIf (gold < 500)
		;Debug.Trace("Pick gift from list 0250")
		return BYOHRelationshipAdoptionGifts_0250
	ElseIf (gold < 1000)
		;Debug.Trace("Pick gift from list 500")
		return BYOHRelationshipAdoptionGifts_0500
	EndIf
	;Else case...
	;Debug.Trace("Pick gift from list 1000")
	return BYOHRelationshipAdoptionGifts_1000
EndFunction

;Give Player Gift Event: Helper Function to select the appropriate deduction.
int Function PickDeduction(int gold)
	if (gold < 25)
		return 1
	ElseIf (gold < 50)
		return 25
	ElseIf (gold < 100)
		return 50
	ElseIf (gold < 250)
		return 100
	ElseIf (gold < 500)
		return 250
	ElseIf (gold < 1000)
		return 500
	EndIf
	;Else case...
	return 1000
EndFunction


;----------------------------------------------------------------------------------------------------
;LOCATION CHANGED EVENTS
;-----------------------

;Respond to Player LocationChanged events. This includes things like:
; - Starting or stopping the Civil War Siege handler quest.
; - Moving the player's family to a new home.
; - Triggering Return Home events.
Function PlayerLocationChanged(Location newLoc, Location oldLoc)
	;Debug.Trace("LOCATION CHANGE: " + newLoc)
	;Debug.Trace("CW SIEGE IS RUNNING?" + CWSiege.IsRunning())
	

	LocationAlias[] currentHomeExteriorArray = getCurrentHomeExteriorArray()
	int i = 0
	;Edge Case Handling: If a CW Siege is running, move the family inside.
	while (i < currentHomeExteriorArray.length)
		if (!BYOHRelationshipAdoptionCWSiegeHandler.IsRunning() && CWSiege.IsRunning() && CWSiege.getCurrentStageID() > 0 && \
			currentHomeExteriorArray[i].GetLocation() != None && CWSiegeCity.GetLocation() == currentHomeExteriorArray[i].GetLocation())
			;Debug.Trace("CW Flee Package Triggered")
			BYOHRelationshipAdoptionCWSiegeHandler.setCurrentStageID(0)
			i = currentHomeExteriorArray.length; break
		EndIf
		i = i + 1
	endwhile
	
	;Edge Case Handling: If the CW Siege has ended, shut off the CW Siege Handler quest.
	if (BYOHRelationshipAdoptionCWSiegeHandler.IsRunning() && !CWSiege.IsRunning())
		;Debug.Trace("CW Flee Package Ended")
		BYOHRelationshipAdoptionCWSiegeHandler.Stop()
	EndIf
	
	LocationAlias[] currentHomeHouseArray  = getCurrentHomeHouseArray()
	int[] currentHomeArray = getCurrentHomeArray()
	;Edge Case Handling: If we've adopted a Critter, but it got out of the house, move it back inside.
	Actor FamilyCritterREF = FamilyCritter.GetReference() as Actor

	if FamilyCritterREF
		int critterOwnerId = FamilyCritterREF.getActorValue("Variable06") as int
	endif
	;if (FamilyCritter.GetActorRef() != None && !FamilyCritter.GetActorRef().IsDead() && FamilyCritter.GetActorRef().GetCurrentLocation() != currentHomeHouseArray[critterOwnerId - 1].GetLocation())
	;	Debug.Trace("Critter moved back.")
	;	FamilyCritter.GetActorRef().MoveTo(TranslateHouseIntToObj(currentHomeArray[critterOwnerId - 1]))
	;EndIf
	

	bool[] moveQueuedArray = getMoveQueuedArray()
	ReferenceAlias[] childAliasArray = getChildAliasArray()
	int[] newHomeArray = getNewHomeArray()
	i = 0
	bool childMoved = false
	while i < moveQueuedArray.length
		if moveQueuedArray[i]
			;Player in None means they're not in the city anymore. So you can go ahead and do your off screen move now.
			Actor childActor = childAliasArray[i].GetReference() as Actor
			if( newLoc == None )		
				MoveFamily(childActor)
			;Debug.Trace("Children are not in the player's new location.")
			elseif (newLoc != childActor.GetCurrentLocation() || childActor == None  )

				;Debug.Trace("Children are not in the parent of the player's new location.")
				if (!childActor.GetCurrentLocation().IsChild(newLoc) || childActor == None )

					;Debug.Trace("Player's new location is the new home city, OR player is not in the parent of the children's location.")
					if ( ( newLoc == TranslateHouseIntToLoc(newHomeArray[i]) && (!oldLoc|| !newLoc.IsChild(oldLoc) ) ) || \
					( !newLoc.IsChild( childActor.GetCurrentLocation() ) ) )
						if newHomeArray[i] == 9
							;new location's parent is not the new home's parent's parent
							if ( (TranslateHouseIntToInteriorLoc(newHomeArray[i]).getParent().getParent() ) != newLoc.getParent() && newLoc.getParent() )
								;old loc isn't new home's parent parent
								if oldLoc.getParent() != (TranslateHouseIntToInteriorLoc(newHomeArray[i]).getParent().getParent() )
									MoveFamily(childActor)
									childMoved = true
								endif
							endif
						else
							MoveFamily(childActor)
						endif
					endif
				endif
			endif
		endif
		i = i + 1
		if childMoved
			Utility.wait(0.9)
			childMoved = false
		endif
	endwhile
	
	;Determine whether to trigger a Welcome Home event.


	float[] playerLastSeenArray = getPlayerLastSeenArray()
    int[] giftStoredValueChildArray = getGiftStoredValueChildArray()

    ; Build shuffled index permutation
    int n = childAliasArray.length
    int[] shuffledIndices = MakeShuffledIndices()

    ; Build shuffled copies — originals are untouched
    ReferenceAlias[] sChildAliasArray        = new ReferenceAlias[10]
    float[]          sPlayerLastSeenArray    = new float[10]
    int[]            sGiftStoredValueChildArray = new int[10]
    LocationAlias[] sCurrentHomeHouseArray   = new LocationAlias[10]
    LocationAlias[] sCurrentHomeExteriorArray = new LocationAlias[10]

    int k = 0
    while (k < n)
        int src = shuffledIndices[k]
        sChildAliasArray[k]             = childAliasArray[src]
        sPlayerLastSeenArray[k]         = playerLastSeenArray[src]
        sGiftStoredValueChildArray[k]   = giftStoredValueChildArray[src]
        sCurrentHomeHouseArray[k]       = currentHomeHouseArray[src]
        sCurrentHomeExteriorArray[k]    = currentHomeExteriorArray[src]
        k = k + 1
    endwhile

    ; Now iterate over the shuffled copies
    i = 0
    while (i < n)
        Actor childActor = sChildAliasArray[i].GetReference() as Actor
        if childActor != None
            Location currentIdxLoc    = sCurrentHomeHouseArray[i].GetLocation()
            Location currentIdxExtLoc = sCurrentHomeExteriorArray[i].GetLocation()
            if ((newLoc == currentIdxLoc || newLoc == currentIdxExtLoc) && \
            (oldLoc != currentIdxLoc  && oldLoc != currentIdxExtLoc))
                if (Utility.GetCurrentGameTime() - sPlayerLastSeenArray[i] > WelcomeHomeDelay)
                    if (sGiftStoredValueChildArray[i] > 0)
                        childActor.AddItem(Gold001, sGiftStoredValueChildArray[i])
                        resetChildGold(childActor)
                    EndIf
                    ReadyForcegreetEvent(childActor)
                    return
                endif
            endif
        endif
        i = i + 1
    endwhile
EndFunction

; Builds a shuffled index permutation of length n.
int[] Function MakeShuffledIndices()
    int[] indices = new int[10]
    int i = 0
    while (i < 10)
        indices[i] = i
        i = i + 1
    endwhile

    ; Fisher-Yates on the index array
    i = 10 - 1
    while (i > 0)
        int j = Utility.RandomInt(0, i)
        int temp = indices[i]
        indices[i] = indices[j]
        indices[j] = temp
        i = i - 1
    endwhile

    return indices
EndFunction

;Respond to Child LocationChanged events. This includes things like:
; - Triggering a 'dirty' move for newly-adopted children when they reach their new home.
Function ChildLocationChanged(Actor child, Location newLoc, Location oldLoc)

	UnblockGames(child)
EndFunction


;----------------------------------------------------------------------------------------------------
;UTILITY FUNCTIONS
;------------------------

ReferenceAlias Function getAdoptedChild()
	ReferenceAlias ChildAlias
	if (Child1.GetReference() == None)
		ChildAlias = Child1
		child1NewlyAdopted = True
		numChildrenAdopted = 1
	ElseIf (Child2.GetReference() == None)
		ChildAlias = Child2
		child2NewlyAdopted = True
		numChildrenAdopted = 2
		;Stop RelationshipAdoptable from adopting anyone else.
		;BYOHRelationshipAdoptable.SetStage(255)
	ElseIf (Child3.GetReference() == None)
		ChildAlias = Child3
		child3NewlyAdopted = True
		numChildrenAdopted = 3
		;Stop RelationshipAdoptable from adopting anyone else.
		;BYOHRelationshipAdoptable.SetStage(255)
	ElseIf (Child4.GetReference() == None)
		ChildAlias = Child4
		child4NewlyAdopted = True
		numChildrenAdopted = 4
		;Stop RelationshipAdoptable from adopting anyone else.
		;BYOHRelationshipAdoptable.SetStage(255)
	ElseIf (Child5.GetReference() == None)
		ChildAlias = Child5
		child5NewlyAdopted = True
		numChildrenAdopted = 5
		;Stop RelationshipAdoptable from adopting anyone else.
		;BYOHRelationshipAdoptable.SetStage(255)
	ElseIf (Child6.GetReference() == None)
		ChildAlias = Child6
		child6NewlyAdopted = True
		numChildrenAdopted = 6
		;Stop RelationshipAdoptable from adopting anyone else.
		;BYOHRelationshipAdoptable.SetStage(255)
	ElseIf (Child7.GetReference() == None)
		ChildAlias = Child7
		child7NewlyAdopted = True
		numChildrenAdopted = 7
	ElseIf (Child8.GetReference() == None)
		ChildAlias = Child8
		child8NewlyAdopted = True
		numChildrenAdopted = 8
	ElseIf (Child9.GetReference() == None)
		ChildAlias = Child9
		child9NewlyAdopted = True
		numChildrenAdopted = 9
	ElseIf (Child10.GetReference() == None)
		ChildAlias = Child10
		child10NewlyAdopted = True
		numChildrenAdopted = 10
	Else
		Debug.Trace("BYOHRelationshipAdoptionScript ERROR: REFERENCES ALREADY FILLED")
		return None
	EndIf
	return ChildAlias
EndFunction
Function UpdateGiftValueHelper(Actor child, int RealValue)
	;Then store the value of the gift to subsequently be added to the child's gold supply.
	if (child == Child1.GetReference() as Actor)
		GiftStoredValueChild1 = GiftStoredValueChild1 + RealValue
	Elseif (child == Child2.GetReference() as Actor)
		GiftStoredValueChild2 = GiftStoredValueChild2 + RealValue
	Elseif (child == Child3.GetReference() as Actor)
		GiftStoredValueChild3 = GiftStoredValueChild3 + RealValue
	Elseif (child == Child4.GetReference() as Actor)
		GiftStoredValueChild4 = GiftStoredValueChild4 + RealValue
	Elseif (child == Child5.GetReference() as Actor)
		GiftStoredValueChild5 = GiftStoredValueChild5 + RealValue
	Elseif (child == Child6.GetReference() as Actor)
		GiftStoredValueChild6 = GiftStoredValueChild6 + RealValue
	Elseif (child == Child7.GetReference() as Actor)
		GiftStoredValueChild7 = GiftStoredValueChild7 + RealValue
	Elseif (child == Child8.GetReference() as Actor)
		GiftStoredValueChild8 = GiftStoredValueChild8 + RealValue
	Elseif (child == Child9.GetReference() as Actor)
		GiftStoredValueChild9 = GiftStoredValueChild9 + RealValue
	Elseif (child == Child10.GetReference() as Actor)
		GiftStoredValueChild10 = GiftStoredValueChild10 + RealValue
	EndIf
EndFunction
Function queueMoveHelper(int destination, Actor child, bool forceQueue)
	if child == Child1.GetReference() as Actor
		newHome = ValidateMoveDestinationChild(destination, child)
		moveQueued =  enableMoveQueueHelper( newHome, currentHome, forceQueue)
	elseif child == Child2.GetReference() as Actor
		newHome2 = ValidateMoveDestinationChild(destination, child)
		moveQueued2 =  enableMoveQueueHelper( newHome2, currentHome2, forceQueue)
	elseif child == Child3.GetReference() as Actor
		newHome3 = ValidateMoveDestinationChild(destination, child)
		moveQueued3 =  enableMoveQueueHelper( newHome3, currentHome3, forceQueue)
	elseif child == Child4.GetReference() as Actor
		newHome4 = ValidateMoveDestinationChild(destination, child)
		moveQueued4 =  enableMoveQueueHelper( newHome4, currentHome4, forceQueue)
	elseif child == Child5.GetReference() as Actor
		newHome5 = ValidateMoveDestinationChild(destination, child)
		moveQueued5 =  enableMoveQueueHelper( newHome5, currentHome5, forceQueue)
	elseif child == Child6.GetReference() as Actor
		newHome6 = ValidateMoveDestinationChild(destination, child)
		moveQueued6 =  enableMoveQueueHelper( newHome6, currentHome6, forceQueue)
	elseif child == Child7.GetReference() as Actor
		newHome7 = ValidateMoveDestinationChild(destination, child)
		moveQueued7 =  enableMoveQueueHelper( newHome7, currentHome7, forceQueue)
	elseif child == Child8.GetReference() as Actor
		newHome8 = ValidateMoveDestinationChild(destination, child)
		moveQueued8 =  enableMoveQueueHelper( newHome8, currentHome8, forceQueue)
	elseif child == Child9.GetReference() as Actor
		newHome9 = ValidateMoveDestinationChild(destination, child)
		moveQueued9 =  enableMoveQueueHelper( newHome9, currentHome9, forceQueue)
	elseif child == Child10.GetReference() as Actor
		newHome10 = ValidateMoveDestinationChild(destination, child)
		moveQueued10 =  enableMoveQueueHelper( newHome10, currentHome10, forceQueue)
	endif
EndFunction
Function fixUpVariables(int childIndex)
	if childIndex == 0
		moveQueued = False
		currentHome = newHome
	elseif childIndex == 1
		moveQueued2 = false
		currentHome2 = newHome2	
	elseif childIndex == 2
		moveQueued3 = false
		currentHome3 = newHome3
	elseif childIndex == 3
		moveQueued4 = false
		currentHome4 = newHome4
	elseif childIndex == 4
		moveQueued5 = false
		currentHome5 = newHome5
	elseif childIndex == 5
		moveQueued6 = false
		currentHome6 = newHome6	
	elseif childIndex == 6
		moveQueued7 = false
		currentHome7 = newHome7
	elseif childIndex == 7
		moveQueued8 = false
		currentHome8 = newHome8
	elseif childIndex == 8
		moveQueued9 = false
		currentHome9 = newHome9
	elseif childIndex == 9
		moveQueued10 = false
		currentHome10 = newHome10					
	endif
EndFunction

bool Function isAnyChildNewlyAdopted()
	return (Child1NewlyAdopted || Child2NewlyAdopted || Child3NewlyAdopted || Child4NewlyAdopted || Child5NewlyAdopted || Child6NewlyAdopted || child7NewlyAdopted || child8NewlyAdopted || child9NewlyAdopted || child10NewlyAdopted)
endFunction

bool Function isAnimalPetRefAliasFilled()
	if  (Game.GetFormFromFile(0x0000434F, "nwsFollowerFramework.esp") as bool ) &&  ((FamilyPet.GetActorRef() == None))
		;nether follower framework doesnt use animal refalias
		if NetherFollowerCheckAnimalHelper()
			return true
		else
			return false
		endif
	else
		if AnimalCompanion.GetActorRef() != None
			return True
		endif
	endif
	return false	
EndFunction

Actor Function NetherFollowerCheckAnimalHelper()
	Quest DialogueFollower = Game.GetFormFromFile(0x000750BA, "Skyrim.esm") as Quest
	int countAlias = 2
	int j = 12
	ReferenceAlias FollowerExtra
	Race current
	Race transientRace
	Actor FollowerExtraActor
	int i = 0
	while countAlias < j
		FollowerExtra = (DialogueFollower.getAlias(countAlias)) as ReferenceAlias
		FollowerExtraActor = FollowerExtra.GetActorRef()
		transientRace = FollowerExtraActor.getRace()
		i = 0
		While (i < BYOHRelationshipAdoption_PetDogsList.GetSize())
			current = (BYOHRelationshipAdoption_PetDogsList.GetAt(i)) as Race
			;Debug.Trace("Comparing: " + transient + " : " + current)
			if (current == transientRace)
				NWSAnimalFollower = FollowerExtraActor
				return FollowerExtraActor
			EndIf
			i = i + 1
		endwhile
		countAlias = countAlias + 1	
	EndWhile
	return None
EndFunction

Function handleNewGreet(actor child)
	;If a newly-adopted child has just moved in with us, decide which Forcegreet event they should play.
	If (child1NewlyAdopted && child == Child1.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 1 Only newly adopted.")
		;Queue up Forcegreet Event #2 (Child 1 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 1 is no longer Newly Adopted.
		child1NewlyAdopted = False	
		;Child 1 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(child, 1)
	
	elseIf (child2NewlyAdopted && child == Child2.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 2 Only newly adopted.")
		;Queue up Forcegreet Event #1 (Child 2 Thanks) or 2 (Child 2 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 2 is no longer Newly Adopted.
		child2NewlyAdopted = False	
		;Child 2 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(child, 1)
	
	elseIf (child3NewlyAdopted  && child == Child3.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 3 Only newly adopted.")
		;Queue up Forcegreet Event #1 (Child 3 Thanks) or 2 (Child 3 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 3 is no longer Newly Adopted.
		child3NewlyAdopted = False	
		;Child 3 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(child, 1)
	elseIf (child4NewlyAdopted  && child == Child4.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 4 Only newly adopted.")
		;Queue up Forcegreet Event #1 (Child 4 Thanks) or 2 (Child 4 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 4 is no longer Newly Adopted.
		child4NewlyAdopted = False	
		;Child 4 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	elseIf (child5NewlyAdopted  && child == Child5.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 5 Only newly adopted.")
		;Queue up Forcegreet Event #1 (Child 5 Thanks) or 2 (Child 5 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 5 is no longer Newly Adopted.
		child5NewlyAdopted = False	
		;Child 5 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(child, 1)
	elseIf (child6NewlyAdopted  && child == Child6.GetReference() as Actor)
		;Debug.Trace("Clean Move Readies Forcegreet, Child 6 Only newly adopted.")
		;Queue up Forcegreet Event #1 (Child 6 Thanks) or 2 (Child 6 Thanks w/ Chest Intro)
		ReadyForcegreetEvent()
		;Child 6 is no longer Newly Adopted.
		child6NewlyAdopted = False	
		;Child 6 now sandboxes at home for an hour.
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	elseIf (child7NewlyAdopted  && child == Child7.GetReference() as Actor)
		ReadyForcegreetEvent()
		child7NewlyAdopted = False	
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	elseIf (child8NewlyAdopted  && child == Child8.GetReference() as Actor)
		ReadyForcegreetEvent()
		child8NewlyAdopted = False	
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	elseIf (child9NewlyAdopted  && child == Child9.GetReference() as Actor)
		ReadyForcegreetEvent()
		child9NewlyAdopted = False	
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	elseIf (child10NewlyAdopted  && child == Child10.GetReference() as Actor)
		ReadyForcegreetEvent()
		child10NewlyAdopted = False	
		OrderToConfirm = 1.0
		IssueOrderWithDuration(Child, 1)
	EndIf
EndFunction

int[] function getNewHomeArray()
	int[] NewHomeArray = new int[10]
	NewHomeArray[0] = newHome
	NewHomeArray[1] = newHome2
	NewHomeArray[2] = newHome3
	NewHomeArray[3] = newHome4
	NewHomeArray[4] = newHome5
	NewHomeArray[5] = newHome6
	NewHomeArray[6] = newHome7
	NewHomeArray[7] = newHome8
	NewHomeArray[8] = newHome9
	NewHomeArray[9] = newHome10
	return NewHomeArray
EndFunction

int[] function getCurrentHomeArray()
	int[] currentHomeArray = new int[10]
	currentHomeArray[0] = currentHome
	currentHomeArray[1] = currentHome2
	currentHomeArray[2] = currentHome3
	currentHomeArray[3] = currentHome4
	currentHomeArray[4] = currentHome5
	currentHomeArray[5] = currentHome6
	currentHomeArray[6] = currentHome7
	currentHomeArray[7] = currentHome8
	currentHomeArray[8] = currentHome9
	currentHomeArray[9] = currentHome10
	return currentHomeArray
EndFunction

Actor[] function getChildArray()
	Actor[] childArray = new Actor[10]
	childArray[0] = Child1.GetReference() as Actor
	childArray[1] = Child2.GetReference() as Actor
	childArray[2] = Child3.GetReference() as Actor
	childArray[3] = Child4.GetReference() as Actor
	childArray[4] = Child5.GetReference() as Actor
	childArray[5] = Child6.GetReference() as Actor
	childArray[6] = Child7.GetReference() as Actor
	childArray[7] = Child8.GetReference() as Actor
	childArray[8] = Child9.GetReference() as Actor
	childArray[9] = Child10.GetReference() as Actor
	return childArray
EndFunction

ReferenceAlias[] Function getChildAliasArray()
	ReferenceAlias[] childAliasArray = new ReferenceAlias[10]
	childAliasArray[0] = Child1
	childAliasArray[1] = Child2
	childAliasArray[2] = Child3
	childAliasArray[3] = Child4
	childAliasArray[4] = Child5
	childAliasArray[5] = Child6
	childAliasArray[6] = Child7
	childAliasArray[7] = Child8
	childAliasArray[8] = Child9
	childAliasArray[9] = Child10
	return childAliasArray
EndFunction

bool[] Function getChildNewlyAdoptedArray()
	bool[] childNewlyAdoptedArray = new bool[10]
	childNewlyAdoptedArray[0] = child1NewlyAdopted
	childNewlyAdoptedArray[1] = child2NewlyAdopted
	childNewlyAdoptedArray[2] = child3NewlyAdopted
	childNewlyAdoptedArray[3] = child4NewlyAdopted
	childNewlyAdoptedArray[4] = child5NewlyAdopted
	childNewlyAdoptedArray[5] = child6NewlyAdopted
	childNewlyAdoptedArray[6] = child7NewlyAdopted
	childNewlyAdoptedArray[7] = child8NewlyAdopted
	childNewlyAdoptedArray[8] = child9NewlyAdopted
	childNewlyAdoptedArray[9] = child10NewlyAdopted
	return childNewlyAdoptedArray
EndFunction

bool[] Function getMoveQueuedArray()
	bool[] moveQueuedArray = new bool[10]
	moveQueuedArray[0] = moveQueued
	moveQueuedArray[1] = moveQueued2
	moveQueuedArray[2] = moveQueued3
	moveQueuedArray[3] = moveQueued4
	moveQueuedArray[4] = moveQueued5
	moveQueuedArray[5] = moveQueued6
	moveQueuedArray[6] = moveQueued7
	moveQueuedArray[7] = moveQueued8
	moveQueuedArray[8] = moveQueued9
	moveQueuedArray[9] = moveQueued10
	return moveQueuedArray
EndFunction

bool Function doesChildHaveCritter(Actor[] childArray, Actor Child)
	if !Child
		return true
	endif

	int i = 0
	int childIndex = -1
	while (i < childArray.length)
		if child == childArray[i]
			childIndex = i
			i = childArray.length ;break
		endif
		i = i + 1
	endwhile
	i = 0
	bool skipCritterEvent = false
	ReferenceAlias[] critterAliasArray = getCritterAliasArray()
	Actor critterActor
	while i < critterAliasArray.length
		critterActor = critterAliasArray[i].getActorRef()
		if critterActor
			int critterVarChild = critterActor.getActorValue("Variable06") as int
			if critterVarChild == (childIndex + 1)
				;child already has a critter
				return true
			endif
		endif
		i = i + 1
	endwhile
	return false

EndFunction

bool Function isCritterArrayFull()
	ReferenceAlias[] critterAliasArray = getCritterAliasArray()
	int i = 0
	while i < critterAliasArray.length
		if !( (critterAliasArray[i]).getActorRef() as Actor)
			;empty slot, not full
			return false
		endif
		i = i + 1
	endwhile
	return true
EndFunction

ReferenceAlias[] Function getCritterAliasArray()
	ReferenceAlias[] critterAliasArray = new ReferenceAlias[5]
	critterAliasArray[0] = FamilyCritter
	critterAliasArray[1] = FamilyCritter2
	critterAliasArray[2] = FamilyCritter3
	critterAliasArray[3] = FamilyCritter4
	critterAliasArray[4] = FamilyCritter5
	return critterAliasArray
endFunction

ReferenceAlias[] Function getCritterSchedulerAliasArray()
	ReferenceAlias[] critterSchedulerAliasArray = new ReferenceAlias[5]
	critterSchedulerAliasArray[0] = Scheduler_FamilyCritter
	critterSchedulerAliasArray[1] = Scheduler_FamilyCritter2
	critterSchedulerAliasArray[2] = Scheduler_FamilyCritter3
	critterSchedulerAliasArray[3] = Scheduler_FamilyCritter4
	critterSchedulerAliasArray[4] = Scheduler_FamilyCritter5
	return critterSchedulerAliasArray
EndFunction
LocationAlias[] Function getCurrentHomeExteriorArray()
	LocationAlias[] CurrentHomeExteriorArray = new LocationAlias[10]
	CurrentHomeExteriorArray[0] = CurrentHomeExterior
	CurrentHomeExteriorArray[1] = CurrentHomeExterior2
	CurrentHomeExteriorArray[2] = CurrentHomeExterior3
	CurrentHomeExteriorArray[3] = CurrentHomeExterior4
	CurrentHomeExteriorArray[4] = CurrentHomeExterior5
	CurrentHomeExteriorArray[5] = CurrentHomeExterior6
	CurrentHomeExteriorArray[6] = CurrentHomeExterior7
	CurrentHomeExteriorArray[7] = CurrentHomeExterior8
	CurrentHomeExteriorArray[8] = CurrentHomeExterior9
	CurrentHomeExteriorArray[9] = CurrentHomeExterior10
	return CurrentHomeExteriorArray
EndFunction

LocationAlias[] Function getCurrentHomeHouseArray()
	LocationAlias[] CurrentHomeHouseArray = new LocationAlias[10]
	CurrentHomeHouseArray[0] = CurrentHomeHouse
	CurrentHomeHouseArray[1] = CurrentHomeHouse2
	CurrentHomeHouseArray[2] = CurrentHomeHouse3
	CurrentHomeHouseArray[3] = CurrentHomeHouse4
	CurrentHomeHouseArray[4] = CurrentHomeHouse5
	CurrentHomeHouseArray[5] = CurrentHomeHouse6
	CurrentHomeHouseArray[6] = CurrentHomeHouse7
	CurrentHomeHouseArray[7] = CurrentHomeHouse8
	CurrentHomeHouseArray[8] = CurrentHomeHouse9
	CurrentHomeHouseArray[9] = CurrentHomeHouse10
	return CurrentHomeHouseArray
EndFunction

ReferenceAlias[] Function getSchedulerOutsideSandboxArray()
	ReferenceAlias[] SchedulerOutsideSandboxArray = new ReferenceAlias[10]
	SchedulerOutsideSandboxArray[0] = SchedulerOutsideSandbox
	SchedulerOutsideSandboxArray[1] = SchedulerOutsideSandbox2
	SchedulerOutsideSandboxArray[2] = SchedulerOutsideSandbox3
	SchedulerOutsideSandboxArray[3] = SchedulerOutsideSandbox4
	SchedulerOutsideSandboxArray[4] = SchedulerOutsideSandbox5
	SchedulerOutsideSandboxArray[5] = SchedulerOutsideSandbox6
	SchedulerOutsideSandboxArray[6] = SchedulerOutsideSandbox7
	SchedulerOutsideSandboxArray[7] = SchedulerOutsideSandbox8
	SchedulerOutsideSandboxArray[8] = SchedulerOutsideSandbox9
	SchedulerOutsideSandboxArray[9] = SchedulerOutsideSandbox10
	return SchedulerOutsideSandboxArray
EndFunction

int[] Function getGiftStoredValueChildArray()
	int[] GiftStoredValueChildArray = new int[10]
	GiftStoredValueChildArray[0] = GiftStoredValueChild1
	GiftStoredValueChildArray[1] = GiftStoredValueChild2
	GiftStoredValueChildArray[2] = GiftStoredValueChild3
	GiftStoredValueChildArray[3] = GiftStoredValueChild4
	GiftStoredValueChildArray[4] = GiftStoredValueChild5
	GiftStoredValueChildArray[5] = GiftStoredValueChild6
	GiftStoredValueChildArray[6] = GiftStoredValueChild7
	GiftStoredValueChildArray[7] = GiftStoredValueChild8
	GiftStoredValueChildArray[8] = GiftStoredValueChild9
	GiftStoredValueChildArray[9] = GiftStoredValueChild10
	return GiftStoredValueChildArray
EndFunction

LocationAlias[] Function getSchedulerCurrentHomeHouseArray()
	LocationAlias[] schedulerCurrentHomeHouseArray = new LocationAlias[10]
	schedulerCurrentHomeHouseArray[0] = SchedulerCurrentHomeHouse
	schedulerCurrentHomeHouseArray[1] = SchedulerCurrentHomeHouse2
	schedulerCurrentHomeHouseArray[2] = SchedulerCurrentHomeHouse3
	schedulerCurrentHomeHouseArray[3] = SchedulerCurrentHomeHouse4
	schedulerCurrentHomeHouseArray[4] = SchedulerCurrentHomeHouse5
	schedulerCurrentHomeHouseArray[5] = SchedulerCurrentHomeHouse6
	schedulerCurrentHomeHouseArray[6] = SchedulerCurrentHomeHouse7
	schedulerCurrentHomeHouseArray[7] = SchedulerCurrentHomeHouse8
	schedulerCurrentHomeHouseArray[8] = SchedulerCurrentHomeHouse9
	schedulerCurrentHomeHouseArray[9] = SchedulerCurrentHomeHouse10
	return schedulerCurrentHomeHouseArray
EndFunction

LocationAlias[] Function getSchedulerCurrentHomeExteriorArray()
	LocationAlias[] schedulerCurrentHomeExteriorArray = new LocationAlias[10]
	schedulerCurrentHomeExteriorArray[0] = SchedulerCurrentHomeExterior
	schedulerCurrentHomeExteriorArray[1] = SchedulerCurrentHomeExterior2
	schedulerCurrentHomeExteriorArray[2] = SchedulerCurrentHomeExterior3
	schedulerCurrentHomeExteriorArray[3] = SchedulerCurrentHomeExterior4
	schedulerCurrentHomeExteriorArray[4] = SchedulerCurrentHomeExterior5
	schedulerCurrentHomeExteriorArray[5] = SchedulerCurrentHomeExterior6
	schedulerCurrentHomeExteriorArray[6] = SchedulerCurrentHomeExterior7
	schedulerCurrentHomeExteriorArray[7] = SchedulerCurrentHomeExterior8
	schedulerCurrentHomeExteriorArray[8] = SchedulerCurrentHomeExterior9
	schedulerCurrentHomeExteriorArray[9] = SchedulerCurrentHomeExterior10
	return schedulerCurrentHomeExteriorArray
EndFunction

float[] Function getPlayerLastSeenArray()
	float[] playerLastSeenArray = new float[10]
	playerLastSeenArray[0] = playerLastSeen
	playerLastSeenArray[1] = playerLastSeen2
	playerLastSeenArray[2] = playerLastSeen3
	playerLastSeenArray[3] = playerLastSeen4
	playerLastSeenArray[4] = playerLastSeen5
	playerLastSeenArray[5] = playerLastSeen6
	playerLastSeenArray[6] = playerLastSeen7
	playerLastSeenArray[7] = playerLastSeen8
	playerLastSeenArray[8] = playerLastSeen9
	playerLastSeenArray[9] = playerLastSeen10
	return playerLastSeenArray
EndFunction

Function resetChildGold(Actor child)
	if child == child1.GetReference() as Actor
		GiftStoredValueChild1 = 0
	elseif child == child2.GetReference() as Actor
		GiftStoredValueChild2 = 0
	elseif child == child3.GetReference() as Actor
		GiftStoredValueChild3 = 0
	elseif child == child4.GetReference() as Actor
		GiftStoredValueChild4 = 0
	elseif child == child5.GetReference() as Actor
		GiftStoredValueChild5 = 0
	elseif child == child6.GetReference() as Actor
		GiftStoredValueChild6 = 0
	elseif child == child7.GetReference() as Actor
		GiftStoredValueChild7 = 0
	elseif child == child8.GetReference() as Actor
		GiftStoredValueChild8 = 0
	elseif child == child9.GetReference() as Actor
		GiftStoredValueChild9 = 0
	elseif child == child10.GetReference() as Actor
		GiftStoredValueChild10 = 0
	endif
EndFunction

Function setPlayerLastSeen(Actor child)
	if child == child1.GetReference() as Actor
		playerLastSeen = Utility.GetCurrentGameTime()
	elseif child == child2.GetReference() as Actor
		playerLastSeen2 = Utility.GetCurrentGameTime()
	elseif child == child3.GetReference() as Actor
		playerLastSeen3 = Utility.GetCurrentGameTime()
	elseif child == child4.GetReference() as Actor
		playerLastSeen4 = Utility.GetCurrentGameTime()
	elseif child == child5.GetReference() as Actor
		playerLastSeen5 = Utility.GetCurrentGameTime()
	elseif child == child6.GetReference() as Actor
		playerLastSeen6 = Utility.GetCurrentGameTime()
	elseif child == child7.GetReference() as Actor
		playerLastSeen7 = Utility.GetCurrentGameTime()
	elseif child == child8.GetReference() as Actor
		playerLastSeen8 = Utility.GetCurrentGameTime()
	elseif child == child9.GetReference() as Actor
		playerLastSeen9 = Utility.GetCurrentGameTime()
	elseif child == child10.GetReference() as Actor
		playerLastSeen10 = Utility.GetCurrentGameTime()
	endif
EndFunction

;Swap Child1 and Child with idOther (was Child2).
Function SwapChildren(int idOther)
	;Swap the children in their aliases.
	ReferenceAlias ChildAlias
	int otherGold
	bool newlyAdopted
	; child 1 values:
	int tempValue = GiftStoredValueChild1	
	bool tempNewlyAdopted = child1NewlyAdopted	
	Actor tempChild
	ReferenceAlias[] critterAliasArray = getCritterAliasArray()
	int i = 0
	Actor Child1Critter
	Actor ChildSwapCritter
	Actor currCritter
	int assignedChildCritterVar
	while i < critterAliasArray.length
		currCritter =  (critterAliasArray[i].getActorRef() )
		assignedChildCritterVar = currCritter.getAV("Variable06") as int
		if assignedChildCritterVar == 1
			;child 1 does have a critter
			Child1Critter = currCritter
		elseif assignedChildCritterVar == idOther
			;swapped child has a critter
			ChildSwapCritter = currCritter
		endif
		i = i + 1
	endwhile

	ReferenceAlias critterAlias
	if (idOther <= 1)
		; child 1 was to be swapped with itself, no need to do that
		return
	elseif (idOther == 2)
		ChildAlias = Child2
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild2
		newlyAdopted = child2NewlyAdopted
		GiftStoredValueChild2 = tempValue
		child2NewlyAdopted = tempNewlyAdopted		
	elseif (idOther == 3)
		ChildAlias = Child3
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild3
		newlyAdopted = child3NewlyAdopted
		GiftStoredValueChild3 = tempValue
		child3NewlyAdopted = tempNewlyAdopted				
	elseif (idOther == 4)
		ChildAlias = Child4
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild4
		newlyAdopted = child4NewlyAdopted
		GiftStoredValueChild4 = tempValue
		child4NewlyAdopted = tempNewlyAdopted				
	elseif (idOther == 5)
		ChildAlias = Child5
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild5
		newlyAdopted = child5NewlyAdopted
		GiftStoredValueChild5 = tempValue
		child5NewlyAdopted = tempNewlyAdopted
	elseif (idOther == 6)
		ChildAlias = Child6
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild6
		newlyAdopted = child6NewlyAdopted
		GiftStoredValueChild6 = tempValue
		child6NewlyAdopted = tempNewlyAdopted
	elseif (idOther == 7)
		ChildAlias = Child7
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild7
		newlyAdopted = child7NewlyAdopted
		GiftStoredValueChild7 = tempValue
		child7NewlyAdopted = tempNewlyAdopted
	elseif (idOther == 8)
		ChildAlias = Child8
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild8
		newlyAdopted = child8NewlyAdopted
		GiftStoredValueChild8 = tempValue
		child8NewlyAdopted = tempNewlyAdopted
	elseif (idOther == 9)
		ChildAlias = Child9
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild9
		newlyAdopted = child9NewlyAdopted
		GiftStoredValueChild9 = tempValue
		child9NewlyAdopted = tempNewlyAdopted
	elseif (idOther == 10)
		ChildAlias = Child10
		tempChild = ChildAlias.GetReference() as Actor
		otherGold = GiftStoredValueChild10
		newlyAdopted = child10NewlyAdopted
		GiftStoredValueChild10 = tempValue
		child10NewlyAdopted = tempNewlyAdopted			
	endif
	Actor tempChildSwap = Child1.GetReference() as Actor
	Child1.ForceRefTo(ChildAlias.GetReference() as Actor)
	ChildAlias.ForceRefTo(tempChildSwap)

	if Child1Critter
		Child1Critter.setAV("Variable06", idOther)
		Child1Critter.evaluatePackage()
	endif
	if ChildSwapCritter
		ChildSwapCritter.setAV("Variable06", 1.0)
		ChildSwapCritter.evaluatePackage()
	endif

	;If the Scheduler is running, swap them there, too.
	if (BYOHRelationshipAdoptionScheduler.IsRunning())
		(BYOHRelationshipAdoptionScheduler as BYOHRelationshipAdoptionSc).SwapChildren(idOther)
	EndIf
	
	;Swap the childrens' gold pools.
	GiftStoredValueChild1 = otherGold
	
	;Swap the childrens' 'Newly Adopted' flags.
	child1NewlyAdopted = newlyAdopted
	

	;swap Pet owner as well
	Actor fPet = FamilyPet.GetReference() as Actor 
	if (fPet != None)
		if petOwnerChild == Child1.GetReference() as Actor
			petOwnerChild = tempChild
			fPet.setFactionRank(petChildOwnerFaction, idOther )
		elseif petOwnerChild == tempChild
			petOwnerChild = Child1.GetReference() as Actor
			fPet.setFactionRank(petChildOwnerFaction, 1 )
		endif
	endif
EndFunction

bool Function IsAdoptedChild(Actor child)
	if (child != None)
		int i = 0
		Actor[] childArray = getChildArray()
		while i < childArray.length
			if (childArray[i] == child)
		  		return true;
		  	endif
			i = i + 1
		endwhile
	endif
	return false;
EndFunction

Function updateHomeReferenceAliases()
	int i = 0
	LocationAlias[] currentHomeHouseArray = getCurrentHomeHouseArray()
	LocationAlias[] schedulerCurrentHomeHouseArray = getSchedulerCurrentHomeHouseArray()
	LocationAlias[] currentHomeExteriorArray = getCurrentHomeExteriorArray()
	LocationAlias[] schedulerCurrentHomeExteriorArray = getSchedulerCurrentHomeExteriorArray()
	while i < currentHomeExteriorArray.length
		currentHomeHouseArray[i].ForceLocationTo(schedulerCurrentHomeHouseArray[i].GetLocation())
		currentHomeExteriorArray[i].ForceLocationTo(schedulerCurrentHomeExteriorArray[i].GetLocation())
		i = i + 1
	endwhile
EndFunction

bool function enableMoveQueueHelper(int tempHome, int tempCurrHome,bool forceQueue)
	bool moveChildQueue = False
	if (tempCurrHome == tempHome && !forceQueue)
		moveChildQueue = False
		;Debug.Trace("De-queuing move.")
	Else
		moveChildQueue = True
		;Debug.Trace("Queuing Move to: " + destination)
	EndIf

	if (tempHome == 9)
	  Debug.Trace("PHX - QUEUE MOVE - VALIDATED CUSTOM HOME!")		
      (PHX_CustomHomeManager as PHX_HomeManagerScript).makeNewHomeCurrent()
      if (tempCurrHome == 9)
        forceQueue = True
      endif
	EndIf
	return moveChildQueue
EndFunction

;Determine if a move destination is valid, with help from RelationshipAdoptable.
;Returns an int representing a valid move destination.
int Function ValidateMoveDestination(int destination)
	Debug.Trace("phx - validating dest: " + destination)
	if (destination == 0)
		return currentHome
	EndIf
	;Debug.Trace("Adoption Validation: " + destination + " " + CurrentHomeExterior.GetLocation() + " " + CurrentHomeExterior.GetLocation())
	
	Location secondaryLoc = CurrentHomeExterior.GetLocation()
	if (secondaryLoc == None)
		secondaryLoc = CurrentHomeExterior.GetLocation()
	EndIf
	int secondary = TranslateLocationToHouseInt(secondaryLoc)
	
	;If destination = -1, the Scheduler has failed and the current location is probably bad. Don't move the children there again.
	if (destination == -1)
		secondary = -1
	EndIf
	
	if (CCHouse.IsCCHouseDestination(destination))
		return CCHouse.ValidateCCHouseMoveDestination(destination, secondary)
	else
		;Debug.Trace("Handoff to Adoptable Validation with: " + destination + " " + secondary)
		return (BYOHRelationshipAdoptable as BYOHRelationshipAdoptableScript).ValidateMoveDestination(destination, secondary)
	endif
EndFunction

;Determine if a move destination is valid, with help from RelationshipAdoptable.
;Returns an int representing a valid move destination.
int Function ValidateMoveDestinationChild(int destination, Actor child)
	Debug.Trace("phx - validating dest: " + destination)
	Actor[] childArray = getChildArray()
	int i = 0
	if (destination == 0)
		int[] currentHomeArray = getCurrentHomeArray()
		while i < childArray.length
			if childArray[i] == child
				return currentHomeArray[i]
			endif
			i = i + 1
		endwhile

	EndIf
	;Debug.Trace("Adoption Validation: " + destination + " " + CurrentHomeExterior.GetLocation() + " " + CurrentHomeExterior.GetLocation())
	
	i = 0
	Location secondaryLoc = None
	LocationAlias[] currentHomeExteriorArray = getCurrentHomeExteriorArray()
	while i < childArray.length
		if child == childArray[i]
			secondaryLoc = currentHomeExteriorArray[i].GetLocation()
			if (secondaryLoc == None)
				secondaryLoc = currentHomeExteriorArray[i].GetLocation()
			EndIf
			i = childArray.length ; break
		endif
		i = i + 1
	endWhile
	int secondary = TranslateLocationToHouseInt(secondaryLoc)
	
	;If destination = -1, the Scheduler has failed and the current location is probably bad. Don't move the children there again.
	if (destination == -1)
		secondary = -1
	EndIf
	if (CCHouse.IsCCHouseDestination(destination))
		return CCHouse.ValidateCCHouseMoveDestination(destination, secondary)
	else
		;Debug.Trace("Handoff to Adoptable Validation with: " + destination + " " + secondary)
		return (BYOHRelationshipAdoptable as BYOHRelationshipAdoptableScript).ValidateMoveDestination(destination, secondary)
	endif
EndFunction


;Given a location, return the corresponding int.
int Function TranslateLocationToHouseInt(Location newLoc)
	if (newLoc == SolitudeLocation)
		return 1
	ElseIf (newLoc == WindhelmLocation)
		return 2
	ElseIf (newLoc == MarkarthLocation)
		return 3
	ElseIf (newLoc == RiftenLocation)
		return 4
	ElseIf (newLoc == WhiterunLocation)
		return 5
	ElseIf (newLoc == FalkreathHouseLocation)
		return 6
	ElseIf (newLoc == HjaalmarchHouseLocation)
		return 7
	ElseIf (newLoc == PaleHouseLocation)
		return 8
	ElseIf (newLoc != None && newLoc == (PHX_CustomHomeManager as PHX_HomeManagerScript).getCurrentHomeHold())
		return 9
	ElseIf (newLoc == None)
		return -1
	EndIf

	; Check CC Houses
	int newLocId = CCHouse.TranslateCCHouseExteriorLocToInt(newLoc)
	if newLocId > 0
		return newLocId
	endif

	;Debug.Trace("RelationshipAdoptionScript Loc Translation Error!")
	return 0
EndFunction
	
	
;Given an int, return the corresponding center marker.
ObjectReference Function TranslateHouseIntToObj(int newHouse)
	if (newHouse == 1)
		return HouseSolitudeMarker
	ElseIf (newHouse == 2)
		return HouseWindhelmMarker
	ElseIf (newHouse == 3)
		return HouseMarkarthMarker
	ElseIf (newHouse == 4)
		return HouseRiftenMarker
	ElseIf (newHouse == 5)
		return HouseWhiterunMarker
	ElseIf (newHouse == 6)
		return HouseFalkreathMarker
	ElseIf (newHouse == 7)
		return HouseHjaalmarchMarker
	ElseIf (newHouse == 8)
		return HousePaleMarker
	ElseIf (newHouse == 9)
		Debug.Trace("PHX - retrievingCurrentHomeMarker - let's hope it's the right one!")
		return (PHX_CustomHomeManager as PHX_HomeManagerScript).getCurrentHomeMarker()
	EndIf

	; Check CC Houses
	if (CCHouse.IsCCHouseDestination(newHouse))
		return CCHouse.TranslateCCHouseIntToObj(newHouse)
	endif

	;Debug.Trace("RelationshipAdoptionScript Int Translation Error!")
	return None
EndFunction

;Given an int, return the corresponding exterior location.
Location Function TranslateHouseIntToLoc(int newHouse)
	if (newHouse == 1)
		return SolitudeLocation
	ElseIf (newHouse == 2)
		return WindhelmLocation
	ElseIf (newHouse == 3)
		return MarkarthLocation
	ElseIf (newHouse == 4)
		return RiftenLocation
	ElseIf (newHouse == 5)
		return WhiterunLocation
	ElseIf (newHouse == 6)
		return FalkreathHouseLocation
	ElseIf (newHouse == 7)
		return HjaalmarchHouseLocation
	ElseIf (newHouse == 8)
		return PaleHouseLocation
	Elseif (newHouse == 9)
		return (PHX_CustomHomeManager as PHX_HomeManagerScript).getCurrentHomeHold()
	EndIf

	; Check CC Houses
	if (CCHouse.IsCCHouseDestination(newHouse))
		return CCHouse.TranslateCCHouseIntToExteriorLoc(newHouse)
	endif

	;Debug.Trace("RelationshipAdoptionScript Int Translation Error 2!")
	return None
EndFunction

;Given an int, return the corresponding interior location.
Location Function TranslateHouseIntToInteriorLoc(int newHouse)
	if (newHouse == 1)
		return SolitudeProudspireManorLocation
	ElseIf (newHouse == 2)
		return WindhelmHjerimLocation
	ElseIf (newHouse == 3)
		return MarkarthVlindrelHallLocation
	ElseIf (newHouse == 4)
		return RiftenHoneysideLocation
	ElseIf (newHouse == 5)
		return WhiterunBreezehomeLocation
	ElseIf (newHouse == 6)
		return FalkreathHouseInteriorLocation
	ElseIf (newHouse == 7)
		return HjaalmarchHouseInteriorLocation
	ElseIf (newHouse == 8)
		return PaleHouseInteriorLocation
	Elseif (newHouse == 9)
		return (PHX_CustomHomeManager as PHX_HomeManagerScript).getCurrentHomeLocation()
	EndIf

	; Check CC Houses
	if (CCHouse.IsCCHouseDestination(newHouse))
		return CCHouse.TranslateCCHouseIntToExteriorLoc(newHouse)
	endif
	
	;Debug.Trace("RelationshipAdoptionScript Int Translation Error 3!")
	return None
EndFunction

int Function numberAdopted()
  return numChildrenAdopted
EndFunction

Bool Function isHMAExpandedInstalled()
	return true
EndFunction