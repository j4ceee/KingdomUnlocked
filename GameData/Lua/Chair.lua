local Chair = Classes.BlockObjectBase:Inherit( "Chair" )

Chair.interactionSet =
{
    Sit =   {   name                    = "STRING_INTERACTION_CHAIR_SIT",
                interactionClassName    = "Chair_Interaction_Sit",
                icon = "uitexture-interaction-sit",
                menu_priority = 0,},
    
    Nap =   {
                name                    = "STRING_INTERACTION_CHAIR_NAP",
                interactionClassName    = "Chair_Interaction_Nap",
                icon = "uitexture-interaction-sleep",
                menu_priority = 1, },
    
    ForceNPCToUse =     {
        name = "*Force NPC to Use",
        interactionClassName = "Debug_Interaction_ForceNPCUse",
        actionKey = {"Sit", "Nap"},
        icon = "uitexture-interaction-sit",
        menu_priority = 2,
    },
}
