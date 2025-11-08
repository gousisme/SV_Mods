<lane *context={:~ConfigurationViewModel.Items} layout="stretch content" orientation="vertical" clip-size="stretch">
    <lane layout="stretch content"
              orientation="vertical"
              +state:disabled={IsReordering}
              +state:disabled:opacity="0.4"
              +state:disabled:pointer-events-enabled="false"
              +transition:opacity="250ms EaseOutSine">
        <form-heading title={#Config.Inventory.Heading} />
        <form-row title={#Config.Inventory.PageSize.Title} description={#Config.Inventory.PageSize.Description}>
            <slider track-width="300" min="4" max="24" interval="1" value={<>InventoryPageSize} />
        </form-row>
        <form-row title={#Config.Inventory.ShowBlanks.Title} description={#Config.Inventory.ShowBlanks.Description}>
            <checkbox is-checked={<>ShowInventoryBlanks} />
        </form-row>
    </lane>
    <form-heading title={#Config.ModMenu.Heading} />
    <lane *context={:Pager} margin="16, 4, 0, 4" vertical-content-alignment="middle">
        <label margin="0, 0, 8, 0" text={#Config.ModMenu.Pages.Title} tooltip={#Config.ModMenu.Pages.Description} />
        <button *repeat={Pages}
                layout="48px"
                margin="2, 0"
                default-background-tint={ButtonTint}
                hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                tooltip={#Config.ModMenu.Pages.Description}
                left-click=|^SelectPage(Index)|>
            <digits number={:DisplayIndex} scale="3" />
        </button>
        <button layout="48px"
                margin="2, 0"
                hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                tooltip={#Config.ModMenu.AddPage.Description}
                left-click=|^AddPage()|>
            <label color="#fff" text="+" shadow-offset="-2, 2" shadow-alpha="0.8" shadow-color="#333" />
        </button>
    </lane>
    <label margin="16, 4, 0, 4" color="#666" text={#Config.ModMenu.Items.Help} />
    <panel *context={:Pager} margin="16, 4">
        <grid *repeat={Pages}
              layout="stretch content"
              item-layout="length: 80+"
              item-spacing="0, 8"
              horizontal-item-alignment="middle"
              pointer-events-enabled={Selected}
              transform={Transform}
              +transition:transform="100ms EaseOutCubic"
              visibility={Visible}>
            <mod-menu-slot *repeat={Items} id={:Id} highlight={IsReordering} />
            <panel>
                <frame pointer-events-enabled={~ItemsConfigurationViewModel.CanAddItem}
                       +state:hidden={~ItemsConfigurationViewModel.CanRemoveItem}
                       +state:hidden:opacity="0"
                       +transition:opacity="150ms EaseOutSine"
                       left-click=|~ItemsConfigurationViewModel.AddNewItem()|>
                    <item-slot tooltip={~ItemsConfigurationViewModel.AddButtonTooltip}>
                        <slotted-item icon={@Mods/focustense.StarControl/Sprites/Cursors:BigPlus}
                                      +state:disabled={~ItemsConfigurationViewModel.IsPageFull}
                                      +state:disabled:opacity="0.5"
                                      +transition:opacity="150ms" />
                    </item-slot>
                </frame>
                <frame opacity="0"
                       pointer-events-enabled={~ItemsConfigurationViewModel.CanRemoveItem}
                       +state:visible={~ItemsConfigurationViewModel.CanRemoveItem}
                       +state:visible:opacity="1"
                       +transition:opacity="150ms EaseOutSine"
                       click=|~ItemsConfigurationViewModel.RemoveGrabbedItem()|
                       pointer-enter=|~ItemsConfigurationViewModel.HoverTrashCan()|
                       pointer-leave=|~ItemsConfigurationViewModel.LeaveTrashCan()|>
                    <item-slot tint="#f66" tooltip={#Config.ModMenu.RemoveItem.Description}>
                        <panel layout="64px"
                               margin="4"
                               horizontal-content-alignment="middle">
                            <image layout="52px"
                                   margin="4, 6, 0, 0"
                                   horizontal-alignment="middle"
                                   sprite={@Mods/focustense.StarControl/Sprites/Cursors:TrashCan} />
                            <image layout="36px"
                                   margin="0, 6, 0, 0"
                                   horizontal-alignment="middle"
                                   sprite={@Mods/focustense.StarControl/Sprites/Cursors:TrashCanLid}
                                   transform-origin="0.9, 0.5"
                                   +state:open={~ItemsConfigurationViewModel.IsTrashCanHovered}
                                   +state:open:transform="rotate: 45"
                                   +transition:transform="200ms" />
                        </panel>
                    </item-slot>
                </frame>
            </panel>
        </grid>
    </panel>
    <lane layout="stretch content"
          orientation="vertical"
          +state:disabled={IsReordering}
          +state:disabled:opacity="0.4"
          +state:disabled:pointer-events-enabled="false"
          +transition:opacity="250ms EaseOutSine">
        <form-heading title={#Config.QuickActions.Heading} />
        <label margin="16, 4, 0, 4" color="#666" text={#Config.QuickActions.Items.Help} />
        <lane *context={QuickSlots} layout="stretch content" margin="12, 4, 12, 4">
            <quick-slot slot={DPadLeft} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadLeft} />
            <quick-slot slot={DPadUp} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadUp} />
            <quick-slot slot={DPadRight} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadRight} />
            <quick-slot slot={DPadDown} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadDown} />
            <spacer layout="stretch 0px" />
            <quick-slot slot={West} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadX} />
            <quick-slot slot={North} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadY} />
            <quick-slot slot={East} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadB} />
            <quick-slot slot={South} prompt={@Mods/focustense.StarControl/Sprites/UI:GamepadA} />
        </lane>
    </lane>
</lane>

<template name="form-heading">
    <banner margin="0, 8, 0, 4" text={&title} />
</template>

<template name="form-row">
    <lane margin="16, 4, 0, 4" vertical-content-alignment="middle">
        <frame layout="350px content">
            <label text={&title} tooltip={&description} />
        </frame>
        <frame tooltip={&description}>
            <outlet />
        </frame>
    </lane>
</template>

<template name="quick-slot">
    <lane *context={&slot}
          margin="4, 0"
          orientation="vertical"
          horizontal-content-alignment="middle"
          focusable="true"
          left-click=|~ItemsConfigurationViewModel.EditQuickSlot(&slot)|>
        <item-slot tooltip={Tooltip}>
            <slotted-item icon={Icon} tint={Tint} />
        </item-slot>
        <image layout="32px" margin="0, -8, 0, 0" sprite={&prompt} />
    </lane>
</template>

<template name="mod-menu-slot">
    <frame click=|~ItemsConfigurationViewModel.EndReordering(this)|
           left-click=|~ItemsConfigurationViewModel.EditModMenuItem(this)|
           right-click=|~ItemsConfigurationViewModel.BeginReordering(this)|>
        <item-slot tooltip={Tooltip}>
            <panel>
                <frame layout="stretch"
                       opacity="0"
                       +state:visible={~ItemsConfigurationViewModel.IsReordering}
                       +state:visible:opacity="1">
                    <image layout="stretch"
                           sprite={@Mods/StardewUI/Sprites/White}
                           tint="#9e9"
                           opacity="0"
                           +state:highlight={IsReordering}
                           +state:highlight:opacity="1"
                           +hover:opacity="1"
                           +hover:tint="#9ee"
                           +transition:opacity="150ms"
                           +transition:tint="150ms" />
                </frame>
                <slotted-item icon={Icon} />
                <image *!if={Enabled}
                       layout="stretch"
                       sprite={@Item/Error_Invalid}
                       pointer-events-enabled="false" />
            </panel>
        </item-slot>
    </frame>
</template>

<template name="item-slot">
    <frame background={@Mods/StardewUI/Sprites/MenuBackground}
           background-tint={&tint}
           border={@Mods/StardewUI/Sprites/MenuSlotTransparent}
           border-thickness="4"
           focusable="true"
           tooltip={&tooltip}>
        <outlet />
    </frame>
</template>

<template name="slotted-item">
    <image layout="64px"
           margin="4"
           horizontal-alignment="middle"
           vertical-alignment="middle"
           sprite={&icon}
           tint={&tint}
           pointer-events-enabled="false" />
</template>