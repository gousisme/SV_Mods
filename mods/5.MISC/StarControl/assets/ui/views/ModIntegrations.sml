<lane *context={:~ConfigurationViewModel.Mods} layout="stretch content" orientation="vertical" clip-size="stretch">
    <form-heading title={#Config.ModPriorities.Heading} />
    <label margin="16, 0, 8, 16" color="#666" text={#Config.ModPriorities.Help} />
    <lane layout="stretch content"
          margin="16, 0"
          orientation="vertical"
          button-press=|HandleListButton($Button)|>
        <frame *repeat={Priorities}
               layout="stretch content"           
               padding="8, 0"
               vertical-content-alignment="middle"
               background={@Mods/StardewUI/Sprites/White}
               background-tint="#0000"
               border={@Mods/StardewUI/Sprites/MenuSlotTransparent}
               border-thickness="4"
               outer-size={>LayoutSize}
               +state:dragging={Dragging}
               +state:dragging:background-tint="#39d"
               +transition:background-tint="100ms EaseOutSine"
               button-press=|^HandleItemButton(this, $Button)|
               button-repeat=|^HandleItemButton(this, $Button)|>
            <lane vertical-content-alignment="middle">
                <checkbox margin="0, 4"
                          label-text={Name}
                          tooltip={Description}
                          is-checked={<>Enabled}
                          +state:disabled={:Required}
                          +state:disabled:opacity="0.5" />
                <spacer layout="stretch"
                        pointer-style="Hand"
                        draggable="true"
                        drag-start=|^BeginDrag(this)|
                        drag-end=|^EndDrag(this)|
                        drag=|^Drag(this, $Position)|/>
            </lane>
        </frame>
    </lane>
</lane>

<template name="form-heading">
    <banner margin="0, 8, 0, 8" text={&title} />
</template>