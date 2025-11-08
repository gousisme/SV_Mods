<lane orientation="vertical" horizontal-content-alignment="middle">
    <frame layout="660px content[660..]"
           padding="24, 24, 24, 16"
           background={@Mods/StardewUI/Sprites/ControlBorder}
           button-press=|HandleButtonPress($Button)|>
        <frame *float="after; 4, 0"
               *context={:Slot}
               padding="24"
               background={@Mods/StardewUI/Sprites/ControlBorder}>
            <lane layout="content[105..] content" orientation="vertical" horizontal-content-alignment="middle">
                <image layout="64px"
                       horizontal-alignment="middle"
                       vertical-alignment="middle"
                       sprite={Icon}
                       tint={Tint}
                       tooltip={Tooltip} />
                <label margin="0, 8, 0, 0"
                       color={CurrentAssignmentColor}
                       text={CurrentAssignmentLabel}
                       shadow-alpha="0.9"
                       shadow-offset="-2, 2" />
            </lane>
        </frame>
        <lane layout="stretch content" orientation="vertical">
            <form-row title={#Config.QuickSlot.ItemSource.Title} description={#Config.QuickSlot.ItemSource.Description}>
                <lane vertical-content-alignment="middle">
                    <enum-segments *context={:ItemSource} />
                    <spacer layout="stretch 0px" />
                    <button layout="48px"
                            hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                            tooltip={#Config.QuickSlot.Unassign.Description}
                            left-click=|ClearAssignment()|>
                        <image sprite={@Mods/StardewUI/Sprites/TinyTrashCan} scale="3" />
                    </button>
                </lane>
            </form-row>
            <image layout="stretch content" margin="0, 8" fit="stretch" sprite={@Mods/StardewUI/Sprites/ThinHorizontalDivider} tint="#8888" />
            <panel *context={:Pager}
                   layout="stretch content"
                   margin="0, 8, 0, 4"
                   clip-size="stretch"
                   outer-size={>ContentPanelSize}>
                <page *repeat={Pages} *switch={Index}>
                    <lane *case="0" layout="stretch content" margin="8, 0" orientation="vertical">
                        <label *if={:^^HasLoadedGame}
                               margin="0, -4, 0, 16"
                               color="#666"
                               text={#Config.QuickSlot.Inventory.Description} />
                        <item-grid *if={:^^HasLoadedGame} items={:^^InventoryItems} />
                        <label *!if={:^^HasLoadedGame} text={#Config.QuickSlot.Inventory.Unavailable} />
                    </lane>
                    <lane *case="1" layout="stretch content" margin="8, 0" orientation="vertical">
                        <panel layout="stretch content"
                               margin="0, 0, 0, 16"
                               vertical-content-alignment="middle">
                            <textinput layout="stretch 52px"
                                       border-thickness="56, 12, 12, 12"
                                       placeholder={#Config.ModMenuItem.Search.Placeholder}
                                       text={<>^^SearchText} />
                            <image layout="32px"
                                   margin="18, 2, 0, 0"
                                   sprite={@Mods/focustense.StarControl/Sprites/UI:MagnifyingGlass}
                                   shadow-alpha="0.25"
                                   shadow-offset="-2, 2" />
                        </panel>
                        <item-grid items={^^SearchResults} />
                        <label *if={^^HasMoreSearchResults}
                               margin="0, 8, 0, 8"
                               color="#666"
                               text={^^MoreResultsMessage} />
                    </lane>
                    <lane *case="2" layout="stretch content" orientation="vertical">
                        <form-row title={#Config.ModMenu.Pages.Title}>
                            <lane vertical-content-alignment="middle">
                                <button layout="content 48px"
                                        margin="2, 0"
                                        default-background-tint={^^AllModPagesTint}
                                        hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                                        left-click=|^^SelectModMenuPage("-1")|>
                                    <label color="#fff" text="ALL" shadow-offset="-2, 2" shadow-alpha="0.8" shadow-color="#333" />
                                </button>
                                <button *repeat={:^^ModMenuPages}
                                        layout="48px"
                                        margin="2, 0"
                                        default-background-tint={ButtonTint}
                                        hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                                        left-click=|^^^^SelectModMenuPage(Index)|>
                                    <digits number={:DisplayIndex} scale="3" />
                                </button>
                            </lane>
                        </form-row>
                        <item-grid margin="8, 8, 8, 0" items={^^ModMenuItems} />
                        <label *if={^^HasMoreModItems}
                               margin="0, 8, 0, 8"
                               color="#666"
                               text={^^MoreModItemsMessage} />
                    </lane>
                </page>
            </panel>
        </lane>
    </frame>
    <frame *context={:Slot}
           margin="0, 4, 0, 0"
           padding="24"
           background={@Mods/StardewUI/Sprites/ControlBorder}>
        <lane padding="4">
            <checkbox margin="0, 0, 32, 0"
                      label-text={#Config.QuickSlot.RequireConfirmation.Title}
                      tooltip={#Config.QuickSlot.RequireConfirmation.Description}
                      is-checked={<>RequireConfirmation} />
            <checkbox label-text={#Config.QuickSlot.SecondaryAction.Title}
                      tooltip={#Config.QuickSlot.SecondaryAction.Description}
                      is-checked={<>UseSecondaryAction}
                      +state:disabled={^SecondaryActionProhibited}
                      +state:disabled:opacity="0.5"
                      +state:disabled:pointer-events-enabled="false"
                      +transition:opacity="150ms EaseOutSine" />
        </lane>
    </frame>
</lane>

<template name="form-row">
    <lane margin="4" vertical-content-alignment="middle">
        <frame layout="130px content">
            <label text={&title} tooltip={&description} />
        </frame>
        <frame tooltip={&description}>
            <outlet />
        </frame>
    </lane>
</template>

<template name="enum-segments">
    <frame background={@Mods/StardewUI/Sprites/MenuSlotTransparent} padding="4" tooltip="">
        <segments highlight={@Mods/StardewUI/Sprites/White}
                  highlight-tint="#39d"
                  highlight-transition="150ms EaseOutQuart"
                  separator={@Mods/StardewUI/Sprites/White}
                  separator-tint="#c99"
                  separator-width="2"
                  selected-index={<>SelectedIndex}>
            <label *repeat={Segments}
                   margin="12, 8"
                   bold={Selected}
                   text={:Name}
                   tooltip={:Description} />
        </segments>
    </frame>
</template>

<template name="page">
    <frame layout="stretch content"
           pointer-events-enabled={Selected}
           transform={Transform}
           +transition:transform="200ms EaseOutCubic"
           visibility={Visible}>
        <outlet />
    </frame>
</template>

<template name="item-grid">
    <grid layout="stretch content"
          margin={&margin}
          item-layout="length: 72+"
          item-spacing="4, 4"
          grid-alignment="middle"
          horizontal-item-alignment="middle"
          vertical-item-alignment="middle">
        <item *repeat={&items} />
    </grid>
</template>

<template name="item">
    <frame layout="stretch content"
           padding="4"
           background={@Mods/StardewUI/Sprites/White}
           background-tint="#0000"
           border={@Mods/StardewUI/Sprites/MenuSlotTransparent}
           border-thickness="4"
           focusable="true"
           tooltip={:Tooltip}
           +hover:background-tint="#39d"
           +transition:background-tint="100ms"
           left-click=|~QuickSlotPickerViewModel.AssignItem(this)|>
        <panel>
            <image layout="64px"
                   horizontal-alignment="middle"
                   vertical-alignment="middle"
                   sprite={:Sprite}
                   tint={:SpriteColor}
                   shadow-alpha="0.25"
                   shadow-offset="-2, 2" />
            <image *if={:HasTintSprite}
                   horizontal-alignment="middle"
                   vertical-alignment="middle"
                   sprite={:TintSprite}
                   tint={:TintSpriteColor} />
        </panel>
    </frame>
</template>