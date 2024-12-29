local Bookshelf = Classes.BlockObjectBase:Inherit( "Bookshelf" )


Bookshelf.interactionSet =
{
    Browse =    {
                    name = "STRING_INTERACTION_BOOKSHELF_BROWSE",
                    interactionClassName = "Bookshelf_Interaction_Browse",
                    icon = "uitexture-interaction-use",
                },

    OpenCheatMenu = {
                    name = "*Open Cheat Menu",
                    interactionClassName = "Debug_Interaction_ForceNPCUse",
                    actionKey = "db_menu",
                    icon = "uitexture-interaction-use",
                },

}
