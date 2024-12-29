local Bed = Classes.BlockObjectBase:Inherit( "Bed" )

Bed.interactionSet =
{
    Sleep =             {
                            name                    = "STRING_INTERACTION_BED_SLEEP",
                            interactionClassName    = "Bed_Interaction_Sleep", 
                            icon = "uitexture-interaction-sleep",
                        },

    SleepTillDay =      {   
                            name                    = "STRING_INTERACTION_BED_SLEEPTILLDAY",
                            interactionClassName    = "Bed_Interaction_SleepTillDay",
                            icon = "uitexture-interaction-sleep",
                        },
                         
    SleepTillNight =    {   
                            name                    = "STRING_INTERACTION_BED_SLEEPTILLNIGHT",
                            interactionClassName    = "Bed_Interaction_SleepTillNight",
                            icon = "uitexture-interaction-sleep",
                        },
                           
    ForceNPCToUse =     {   
                            name = "*Force NPC to Sleep",
                            interactionClassName = "Debug_Interaction_ForceNPCUse",
                            actionKey = "Sleep",
                            icon = "uitexture-interaction-sleep",
                        },
                          
}
