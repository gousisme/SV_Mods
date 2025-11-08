<lane margin="0, 0, 0, 20"
      orientation="vertical"
      horizontal-content-alignment="middle">
    <frame padding="24"
           background={@Mods/StardewUI/Sprites/ControlBorderUncolored}
           background-tint="#8cd">
        <lane>
            <remap-slot *repeat={:Slots} />
        </lane>
    </frame>
    <frame layout="950px 560px"
           margin="0, 16"
           padding="24"
           background={@Mods/StardewUI/Sprites/ControlBorder}>
        <scrollable peeking="64">
            <lane layout="stretch content" margin="0, 0, 0, -16" orientation="vertical">
                <item-group *repeat={:ItemGroups} />
            </lane>
        </scrollable>
    </frame>
    <panel horizontal-content-alignment="middle">
        <frame padding="32, 24"
               background={@Mods/StardewUI/Sprites/ControlBorderUncolored}
               background-tint="#8cd"
               opacity="0"
               +state:visible={IsItemHovered}
               +state:visible:opacity="1"
               +transition:opacity="300ms EaseOutSine">
            <lane vertical-content-alignment="middle">
                <label margin="0, 0, 16, 0" text={#Remapping.Assign.IntroText} />
                <label bold="true" text={#Remapping.Assign.TextBeforeButtons} />
                <image layout="32px" margin="8, 0" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadLeftTrigger} />
                <label text={#Remapping.Assign.TextBetweenButtons} />
                <image layout="32px" margin="8, 0" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadRightTrigger} />
                <label text={#Remapping.Assign.TextAfterButtons} />
            </lane>
        </frame>
        <frame padding="32, 24"
               background={@Mods/StardewUI/Sprites/ControlBorderUncolored}
               background-tint="#8cd"
               opacity="0"
               +state:visible={IsSlotHoveredAndAssigned}
               +state:visible:opacity="1"
               +transition:opacity="300ms EaseOutSine">
            <lane vertical-content-alignment="middle">
                <label text={#Remapping.Unassign.TextBeforeButton} />
                <image layout="32px" margin="8, 0" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadX} />
                <label text={#Remapping.Unassign.TextAfterButton} />
            </lane>
        </frame>
    </panel>
</lane>

<template name="remap-slot">
    <lane margin="4, 0"
          orientation="vertical"
          horizontal-content-alignment="middle"
          focusable="true"
          pointer-enter=|^SetSlotHovered(this)|
          pointer-leave=|^SetSlotHovered("null")|
          right-click=|^UnassignSlot(this)|>
        <frame background={@Mods/StardewUI/Sprites/MenuBackgroundUncolored}
               background-tint="#8bd"
               border={@Mods/StardewUI/Sprites/MenuSlotTransparentUncolored}
               border-thickness="4"
               border-tint="#6de"
               focusable="true"
               tooltip={Tooltip}>
            <lane margin="4, 0"
                  orientation="vertical"
                  horizontal-content-alignment="middle">
                <slotted-item icon={Sprite} enabled={IsItemEnabled} />
            </lane>
        </frame>
        <button-prompt layout="32px" button={:Button} />
    </lane>
</template>

<template name="item-group">
    <lane layout="stretch content" margin="0, 0, 0, 16" orientation="vertical">
        <banner text={Name} />
        <grid layout="stretch content"
              item-layout="count: 12"
              item-spacing="0, 8"
              horizontal-item-alignment="middle"
              vertical-item-alignment="middle">
            <frame *repeat={Items}
                   padding="4"
                   background={@Mods/StardewUI/Sprites/MenuSlotTransparent}
                   focusable="true"
                   tooltip={Tooltip}
                   button-press=|^^AssignToSlot($Button, this)|
                   pointer-enter=|^^SetItemHovered(this)|
                   pointer-leave=|^^SetItemHovered("null")|>
                <panel horizontal-content-alignment="middle" vertical-content-alignment="end">
                    <image *if={Hovered}
                           layout="stretch"
                           fit="stretch"
                           sprite={@Mods/StardewUI/Sprites/White}
                           tint="#4c4"
                           opacity="0"
                           +state:assignable={^^CanReassign}
                           +state:assignable:opacity="1"
                           +transition:opacity="250ms EaseOutSine" />
                    <slotted-item icon={Sprite} enabled="true" />
                    <frame margin="0, 0, 0, -12" pointer-events-enabled="false">
                        <button-prompt layout="24px" button={AssignedButton} />
                    </frame>
                </panel>
            </frame>
        </grid>
    </lane>
</template>

<template name="slotted-item">
    <panel layout="64px"
           margin="4"
           vertical-content-alignment="end"
           pointer-events-enabled="false">
        <image layout="stretch"
               horizontal-alignment="middle"
               vertical-alignment="middle"
               sprite={&icon}
               opacity="0.5"
               +state:enabled={&enabled}
               +state:enabled:opacity="1" />
        <lane layout="stretch content" vertical-content-alignment="end">
            <frame *switch={Quality} layout="24px" margin="-3, 0, 0, -3">
                <image *case="1"
                       layout="stretch"
                       sprite={@Mods/focustense.StarControl/Sprites/Cursors:QualityStarSilver} />
                <image *case="2"
                       layout="stretch"
                       sprite={@Mods/focustense.StarControl/Sprites/Cursors:QualityStarGold} />
                <image *case="4"
                       layout="stretch"
                       sprite={@Mods/focustense.StarControl/Sprites/Cursors:QualityStarIridium} />
            </frame>
            <spacer layout="stretch 0px" />
            <digits *if={IsCountVisible}
                    margin="0, 0, -6, -4"
                    number={Count}
                    scale="3" />
        </lane>
    </panel>
</template>

<template name="button-prompt">
    <frame *switch={&button} layout={&layout} margin="0, -8, 0, 0">
        <image *case="DPadLeft" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadLeft} />
        <image *case="DPadUp" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadUp} />
        <image *case="DPadRight" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadRight} />
        <image *case="DPadDown" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadDown} />
        <image *case="ControllerA" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadA} />
        <image *case="ControllerB" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadB} />
        <image *case="ControllerX" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadX} />
        <image *case="ControllerY" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadY} />
        <image *case="LeftTrigger" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadLeftTrigger} />
        <image *case="LeftShoulder" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadLeftButton} />
        <image *case="RightTrigger" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadRightTrigger} />
        <image *case="RightShoulder" layout="stretch" sprite={@Mods/focustense.StarControl/Sprites/UI:GamepadRightButton} />
    </frame>
</template>