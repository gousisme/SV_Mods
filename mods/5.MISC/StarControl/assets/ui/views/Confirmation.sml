<frame layout="800px content"
       padding="24, 24, 24, 16"
       background={@Mods/StardewUI/Sprites/ControlBorder}>
    <lane layout="stretch content" orientation="vertical">
        <lane margin="0, 0, 0, 16" vertical-content-alignment="middle">
            <image *if={:HasSprite} layout="64px" margin="0, 0, 16, 0" sprite={:Sprite} />
            <label font="dialogue"
                   color="#933"
                   shadow-alpha="0.1"
                   shadow-color="#300"
                   shadow-offset="-3, 3"
                   text={:DialogTitle} />
        </lane>
        <label margin="4, 0, 4, 16" text={:DialogDescription} />
        <option title={:SaveTitle} description={:SaveDescription} result="Yes" />
        <option title={:RevertTitle} description={:RevertDescription} result="No" />
        <option title={:CancelTitle} description={:CancelDescription} result="Cancel" />
    </lane>
</frame>

<template name="option">
    <frame layout="stretch content"
           margin="0, 8"
           padding="8"
           background={@Mods/StardewUI/Sprites/White}
           background-tint="#0000"
           border={@Mods/StardewUI/Sprites/MenuSlotTransparent}
           border-thickness="4"
           focusable="true"
           +hover:background-tint="#39d"
           +transition:background-tint="100ms"
           left-click=|Confirm(&result)|>
        <lane layout="stretch content" orientation="vertical">
            <banner text={&title} />
            <label color="#666"
                   shadow-alpha="0.9"
                   shadow-layers="VerticalAndDiagonal"
                   shadow-offset="-2, 2"
                   text={&description} />
        </lane>
    </frame>
</template>