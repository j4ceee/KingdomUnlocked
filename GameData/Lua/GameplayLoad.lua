require "Common"
require "KeybindUtils"
require "Constants"
require "Inventory"
require "ScriptObjectBase"
require "CharacterBase"
require "Player"
require "LuaToHAL_Strings"
require "InteractionUtils"
require "EffectBase"
require "DayNTime"
require "BuildableRegion"

require "Job_PlayAnimation"
require "Job_PlayIdleAnimation"
require "Job_RouteToPosition"
require "Job_RouteToPosition3D"
require "Job_RotateToFaceObject"
require "Job_RotateToFacePos"
require "Job_RouteToFootprint"
require "Job_RouteToWorld"
require "Job_RouteCloseToPosition"
require "Job_RouteToObject"
require "Job_RouteToSlot"
require "Job_Teleport"
require "Job_TeleportThroughPortal"
require "Job_WorldChange"
require "Job_Sleep"
require "Job_SpawnObject"
require "Job_EnterMetaState"
require "Job_ReplaceModelAndRig"
require "Job_Wander"
require "Job_RequestCharacterControl"
require "Job_InputListener"
require "Job_ShowTextMessage"
require "Job_RunInteractionQueue"
require "Job_Fade"

require "Job_RouteToScheduleBlock"
require "Job_RouteToCutscene"
require "Job_PlayAnimation_CutsceneTalk"
require "Job_PerFrameFunctionCallback"
require "Job_PropellResource"

require "Job_InteractionBase"
require "Job_InteractionState"

require "Tutorial"
require "TutorialController"
require "Tutorial_CAP_Start"
require "Tutorial_CAP_Camera"
require "Tutorial_CAP_PostCamera"
-- require "Tutorial_CAP_TalkToSims"
require "Tutorial_CAP_WaitForTaskBook"
require "Tutorial_CAP_TaskBook"
require "Tutorial_CAP_Jump"
require "Tutorial_CAP_TaskHUD"
require "Tutorial_CAP_WaitForTeleportToTutorial"
require "Tutorial_TX_Save"
require "Tutorial_TX_WaitForTask1"
require "Tutorial_TX_Task1Intro"
require "Tutorial_TX_WaitForTask2"
require "Tutorial_TX_Task2Intro"
-- require "Tutorial_TX_WaitForTask3"
-- require "Tutorial_TX_Task3Intro"
require "Tutorial_TX_WaitForTask4"
require "Tutorial_TX_Task4Intro"
require "Tutorial_TX_WaitForTaskHouse"
require "Tutorial_TX_TaskHouseIntro"
require "Tutorial_TX_WaitForTask5"
require "Tutorial_TX_Task5Intro"
require "Tutorial_TX_WaitForTask6"
require "Tutorial_TX_Task6Intro"
require "Tutorial_TX_WaitForTeleportToCAP"
require "Tutorial_CAP_SocializeWait"
require "Tutorial_CAP_Socialize"
require "Tutorial_CAP_SocializeSuccess"
require "Tutorial_CAP_TreeChopWait"
require "Tutorial_CAP_TreeChop"
require "Tutorial_Mining"
require "Tutorial_CAP_WaitForBarneyBuildHouse"
require "Tutorial_CAP_BarneyBuildHouse"
require "Tutorial_CAP_WaitForBarneyInterior"
require "Tutorial_CAP_BarneyInterior"
require "Tutorial_CAP_WaitForProspecting"
require "Tutorial_Prospecting"
require "Tutorial_CAP_OffToAdventure"
require "Tutorial_CJ_BoatCAS"
require "Tutorial_Trade"
require "Tutorial_Fishing"

require "CJWorld"
require "RJWorld"

require "CASInitialWorld"

require "ResourceBase"

require "ResourceFishingTest"

require "Task"

require "BlockObjectBase"

require "Debug_Interaction_ForceNPCUse"

require "CouchBench"
require "CouchBench_Interaction_Sit"
require "Couch"
require "Couch_Interaction_Sit"
require "Couch_Interaction_Sleep"
require "Couch_Interaction_SleepTillDay"
require "Couch_Interaction_SleepTillNight"
require "Couch_Interaction_JumpOn"

require "Chair"
require "Chair_Interaction_Sit"
require "Chair_Interaction_Nap"

require "Refrigerator"
require "Refrigerator_Interaction_GetSnack"

require "Stereo"
require "Stereo_Interaction_TurnOn"
require "Stereo_Interaction_TurnOff"
require "Stereo_Interaction_Dance"

require "PizzaOven"
require "PizzaOven_Interaction_Bake"
require "PizzaOven_Interaction_Bellows"

require "Podium"
require "Podium_Interaction_GiveSpeech"

require "Tent"
require "Tent_Interaction_TakeNap"

require "Tree"
require "Tree_Interaction_Chop"
require "Tree_Interaction_Plant"
require "Tree_Interaction_Stomp"
require "Tree_Interaction_Water"
require "Tree_Interaction_Harvest"

require "Rocket"
require "Rocket_Interaction_Launch"

require "Boat"
require "Boat_Interaction_LeaveIsland"
require "Boat_Interaction_ChangeOutfit"
require "BoatWheel"

require "Job_SocialBase"
require "Social_Talk"
require "Social_Trade"
require "Social_BuySell"
require "Social_Socialize"
require "Social_AskForHelp"
require "Social_BeNiceBeMean"
require "UISocialize"

require "CharacterBase_Interaction_FollowWaypoints"
require "CharacterBase_Interaction_Idle"
require "CharacterBase_Interaction_SequenceProcessor"
require "CharacterBase_Interaction_Social"
require "CharacterBase_Interaction_Talk"
require "CharacterBase_Interaction_TaskPendingComplain"
require "CharacterBase_Interaction_TaskRewardAdvertise"
require "CharacterBase_Interaction_Wander"
require "CharacterBase_Interaction_FacePlayer"
require "CharacterBase_Interaction_Interrupted"
require "CharacterBase_Interaction_Move"
require "CharacterBase_Interaction_TeleportToSafePosition"

require "CharacterBase_Debug_AdvanceSchedule"
require "CharacterBase_Debug_PushSim"

require "NPC_Declarations"
require "NPC_IdleData"
require "NPC_TalkData"
require "NPC_WanderData"

require "Schedule"
require "GenericScheduleData"

require "Credits_Generated"

require "UICASMenu"
require "UILetterbox"
require "DatabaseEULA1"
require "DatabaseEULA2"
require "UIMainMenu"
require "UILoadMenu"
require "UIModalDialog"
require "UIModalEULADialog"
require "UITalkDialog"
require "UIRewardDialog"
require "UITalkDialogCinematic"
require "HUDMenu"
require "UIKeyboard"
require "UIKeyboardJapan"
require "UIConstructionBlock"
require "UICharacter"
require "UIStoreventory"
require "UIFadeScreen"
require "UICallouts"
require "UIInventory"
require "UIPaintMode"
require "UIRelationshipBook"
require "UIRelationshipCard"
require "UIWorldMap"
require "UIModalPopUpDialog"
require "UIModalPopUpCinematic"
require "UIInitCASMenu"
require "UIIslandMap"
require "UITradeScreen"
require "UITradeResourceSelect"
require "UILangSelect"
require "UIPlanting"
require "UIMinigame"
require "UIInteriorExteriorLoadScreen"
require "UIMinigameLoadScreen"
require "Interest_CommonCode"
require "UINunchuk"
require "UIControllerDisconnect"
require "UICASContextPicker"
require "UISpinningFish"
require "UITutorialScreen"
require "UITransitionScreen"
require "UICredits"
require "UIBackStory"
require "UIBackStoryEnd"
require "UIOptionsScreen"
require "UITravelogueScreen"
require "UISavingDialog"
require "UICreditsMainMenu"

require "Task_Scrolls"
require "Task_Scrolls_Academy"
require "Task_Scrolls_Animal"
require "Task_Scrolls_Candy"
require "Task_Scrolls_Capital"
require "Task_Scrolls_CowboyJunction"
require "Task_Scrolls_Cutopia"
require "Task_Scrolls_Gonk"
require "Task_Scrolls_Leaf"
require "Task_Scrolls_RocketReef"
require "Task_Scrolls_Spookane"
require "Task_Scrolls_Trevor"
require "Task_Scrolls_King_Points"

require "Task_CJ_Gabby"
require "Task_CJ_Gino"
require "Task_CJ_Ginny"
require "Task_CJ_Roxie"
require "Task_CJ_Rusty"
require "Task_RR_Alexa"
require "Task_RR_Tobor"
require "Task_RR_Vic"
require "Task_CAP_Pigman"
require "Task_CAP_Buddy"
require "Task_CAP_Linzey"
require "Task_CAP_Barney"
require "Task_CAP_Butter"
require "Task_Leaf_Petal"
require "Task_Leaf_Hopper"
require "Task_Leaf_Leaf"
require "Task_TR_Trevor"
require "Task_tutorial_Marlin"
require "Task_Candy_DJCandy"
require "Task_Candy_Raver1"
require "Task_Candy_Raver2"
require "Task_GI_Linzey"
require "Task_GI_Buddy"
require "Task_GI_Gonk"
require "Task_Animal_Renee"

require "Task_SP_GothBoy"
require "Task_SP_Yuki"
require "Task_SP_Carl"
require "Task_SP_Ruthie"

require "Task_Academy_Rosalyn"
require "Task_Academy_Travis"
require "Task_Academy_Liberty"
require "Task_Academy_Summer"
require "Task_Academy_Chaz"

require "Task_Cute_Beverly"
require "Task_Cute_Daniel"
require "Task_Cute_Poppy"
require "Task_Cute_Violet"
require "Task_Cute_Spencer"

require "Task_Generic_RouteFailure"

require "Task_DayTwo_Academy"
require "Task_DayTwo_Animal"
require "Task_DayTwo_Candy"
require "Task_DayTwo_Capital"
require "Task_DayTwo_CJ"
require "Task_DayTwo_Cute"
require "Task_DayTwo_Leaf"
require "Task_DayTwo_RR"
require "Task_DayTwo_Spooky"
require "Task_DayTwo_Trevor"
require "Task_DayTwo_GonkIsland"

require "UITasksList"
require "UITaskCard"

require "FlourMill"
require "FlourMill_Interaction_MillFlour"

require "TomatoPlant"
require "TomatoPlant_Interaction_PickTomatoes"
require "FlowerPlant"
require "FlowerPlant_Interaction_PickFlowers"

require "Flower"
require "Flower_Interaction_Pick"

require "BulletinBoard"
require "BulletinBoard_Interaction_ReadFlyer"
require "BulletinBoard_Interaction_PostFlyer"

require "PortalBase"
require "DoorBase"

require "Job_CutsceneController"
require "Cutscene_Generic_Social"
require "Cutscene_Generic_KingPoints"

require "Cutscene_Transition_CJ"
require "Cutscene_Transition_Animal"
require "Cutscene_Transition_Candy"
require "Cutscene_Transition_Rocket"
require "Cutscene_Transition_Leaf"
require "Cutscene_Transition_Spookane"
require "Cutscene_Transition_Academy"
require "Cutscene_Transition_Cutopia"
require "Cutscene_Transition_Gonk"
require "Cutscene_Transition_Trevor"

require "Cutscene_Transition_Grabbag1"

require "Cutscene_Special_KingPoints01"
require "Cutscene_Special_KingPoints02"
require "Cutscene_Special_KingPoints03"
require "Cutscene_Special_KingPoints04"
require "Cutscene_Special_KingPoints05"


require "Clue"
require "Clue_Interaction_Inspect"

require "Letter"
require "ToborPart"
require "CrabCage"
require "ShinyThing"



require "HerdableScriptObjectBase"
require "Cow"
require "Cow_Interaction_Milk"
require "Pig"
require "Frog"
require "PercyPig"
require "Bunny"
require "Bunny_Interaction_Fluff"
require "Raccoon"
require "HerdableTrevor"
require "ToborLegs"
require "Crab"
require "Panda_Cub"
require "CatAnimal"
require "Bobaboo"
require "Unicorn"
require "Bear"
require "Spider"
require "Hedgehog"
require "HedgehogLarge"
require "Dog"

require "EffectScript"
require "EffectDummy"
require "Trigger"

require "FoodBase"
require "FoodBase_Interaction_Eat"
require "FoodPlacesetting"
require "FoodPlacesetting_Interaction_Serve"


require "FishingBucket"
require "FishingBucket_Interaction_FishingMiniGame"
require "FishingCursor"

require "Bed"
require "Bed_Interaction_Sleep"
require "Bed_Interaction_SleepTillDay"
require "Bed_Interaction_SleepTillNight"

require "Job_Prospecting"
require "ProspectingCrystal"

require "Sink"
require "Sink_Interaction_WashHands"

require "Stove"
require "Stove_Interaction_Cook"

require "Computer"
require "Computer_Interaction_Work"
require "Computer_Interaction_Play"

require "ArcadeMachine"
require "ArcadeMachine_Interaction_Play"

require "TreasureChest"
require "TreasureChest_Interaction_Open"

require "StoneTomb"
require "StoneTomb_Interaction_View"
require "StoneTomb_Interaction_Peek"

require "Job_Mining"
require "MiningRock"
require "MiningRock_Interaction_Mine"

require "Treadmill"
require "Treadmill_Interaction_Run"

require "MechanicalBull"
require "MechanicalBull_Interaction_Ride"

require "ChemicalTank"
require "ChemicalTank_Interaction_Use"
require "ChemicalTank_Interaction_PoweredUse"

require "AmbientCritter"
require "AmbientBird"
require "AmbientBee"
require "AmbientBadger"
require "AmbientBunny"
require "AmbientCrab"
require "AmbientSpider"
require "AmbientGhost"
require "AmbientRaccoon"

require "Bookshelf"
require "Bookshelf_Interaction_Browse"

require "DJBooth"
require "DJBooth_Interaction_DJ"
require "DJBooth_Interaction_Dance"

require "Guitar"
require "Guitar_Interaction_RockOut"
require "Guitar_Interaction_Watch"

require "Bathtub"
require "Bathtub_Interaction_TakeBath"

require "Hottub"
require "Hottub_Interaction_Relax"

require "Fountain"
require "Fountain_Interaction_Splash"

require "Grass"
require "Grass_Interaction_Pick"

require "DummyScript"
require "SoundDummyScript"

require "Centrifuge"
require "Centrifuge_Interaction_Ride"

require "Television"
require "Television_Interaction_TurnOn"
require "Television_Interaction_TurnOff"
require "Television_Interaction_Watch"

require "Campfire"
require "Campfire_Interaction_RoastMarshmallows"
require "Campfire_Interaction_WarmHands"

require "Dresser"
require "Dresser_Interaction_RifleThroughClothes"


require "ElectroDanceSphere"
require "EDS_Interaction_Ride"

require "Hypnodisc"
require "Hypnodisc_Interaction_watch"

require "PicnicBlanket"
require "PicnicBlanket_Interaction_Eat"

require "Piano"
require "Piano_Interaction_Play"
require "Piano_Interaction_Listen"

require "GabbyShack"

require "JackInTheBox"
require "JackInTheBox_Interaction_Open"

require "Speaker"

require "DanceFloor"
require "DanceFloor_Interaction_Dance"

require "SummoningCircle"
require "SummoningCircle_Interaction_seance"

require "TransitionWorld"

require "Job_ConstructionController"

require "MysticStatue"
require "MysticStatue_Interaction_Listen"

require "GeyserLarge"
require "GeyserMed"
require "GeyserSmall"

require "Unlocked_CheatMenu"
require "Unlocked_SocialMenu"
require "Unlocked_I_Tree_PickAll"
require "Unlocked_I_Mine_Skip"
require "Unlocked_I_Fishing_Skip"
require "Unlocked_I_DanceFl_Toggle"
require "Unlocked_I_DJBooth_Toggle"
require "Unlocked_I_Campfire_Toggle"
require "Unlocked_J_Mining_Skip"
require "Unlocked_AnimalMenu"
require "Unlocked_ModelMenu"
require "Unlocked_Generics"