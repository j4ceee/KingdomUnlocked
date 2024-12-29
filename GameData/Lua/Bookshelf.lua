local Bookshelf = Classes.BlockObjectBase:Inherit( "Bookshelf" )


Bookshelf.interactionSet =
{
    OpenCheatsIslands = {
        name = "*Open Island Cheats",
        interactionClassName = "Debug_Interaction_ForceNPCUse",
        actionKey = "db_menu_islands",
        icon = "uitexture-interaction-leave",
    },

    OpenCheatsGeneral = {
                    name = "*Open General Cheats",
                    interactionClassName = "Debug_Interaction_ForceNPCUse",
                    actionKey = "db_menu",
                    icon = "uitexture-interaction-inspect",
                },

    Browse =    {
        name = "STRING_INTERACTION_BOOKSHELF_BROWSE",
        interactionClassName = "Bookshelf_Interaction_Browse",
        icon = "uitexture-interaction-use",
    },
}
