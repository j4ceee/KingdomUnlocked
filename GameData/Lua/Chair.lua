local Chair = Classes.BlockObjectBase:Inherit( "Chair" )

Chair.interactionSet =
{
    Sit =   {   name                    = "STRING_INTERACTION_CHAIR_SIT",
                interactionClassName    = "Chair_Interaction_Sit",
                icon = "uitexture-interaction-sit", },
    
    Nap =   {
                name                    = "STRING_INTERACTION_CHAIR_NAP",
                interactionClassName    = "Chair_Interaction_Nap",
                icon = "uitexture-interaction-sleep", },
    
    ForceNPCToUse =     {
        name = "*Force NPC to Use",
        interactionClassName = "Debug_Interaction_ForceNPCUse",
        actionKey = {"Sit", "Nap"},
        icon = "uitexture-interaction-sit",
    },
}
