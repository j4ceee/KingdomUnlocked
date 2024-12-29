local Bookshelf = Classes.BlockObjectBase:Inherit( "Bookshelf" )


Bookshelf.interactionSet =
{
    Browse =    {
                    name = "STRING_INTERACTION_BOOKSHELF_BROWSE",
                    interactionClassName = "Bookshelf_Interaction_Browse",
                    icon = "uitexture-interaction-use",
					menu_priority = 0,
    },

    OpenCheatsIslands = {
                    name = "*Open Island Cheats",
                    interactionClassName = "Unlocked_CheatMenu",
                    actionKey = "db_menu_islands",
                    icon = "uitexture-interaction-leave",
                    menu_priority = 2,
    },

    OpenCheatsGeneral = {
                    name = "*Open General Cheats",
                    interactionClassName = "Unlocked_CheatMenu",
                    actionKey = "db_menu",
                    icon = "uitexture-interaction-inspect",
                    menu_priority = 1,
                },
}
