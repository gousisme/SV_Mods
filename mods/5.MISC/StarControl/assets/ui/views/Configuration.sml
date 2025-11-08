<frame layout="800px content[774..]"
       margin="0, 32, 0, 0"
	   background={@Mods/StardewUI/Sprites/MenuBackground}
       border={@Mods/StardewUI/Sprites/MenuBorder}
       border-thickness="36, 36, 40, 36"
       padding="8"
       border-size={>ContentPanelSize}
       button-press=|HandleButtonPress($Button)|
       click=|CancelBlockingAction()|>
    <frame *float="above; 0, 16"
           *context={:Pager}
           layout="stretch content"
           margin="36, 0"
           background={@Mods/StardewUI/Sprites/MenuSlotInset}
           padding="12, 10, 12, 4"
           pointer-events-enabled={IsNavigationEnabled}
           +state:disabled={IsNavigationDisabled}
           +state:disabled:background-tint="#999"
           +transition:background-tint="250ms EaseOutSine">
        <segments highlight={@Mods/StardewUI/Sprites/White}
                  highlight-tint="#39d"
                  highlight-transition="200ms EaseOutExpo"
                  selected-index={<>SelectedPageIndex}
                  +state:disabled={^IsNavigationDisabled}
                  +state:disabled:opacity="0.6"
                  +transition:opacity="250ms EaseOutSine">
            <nav-tab *repeat={Pages}
                     margin="12, 8"
                     bold={Selected}
                     text={:Name}
                     tooltip={:Description} />
        </segments>
    </frame>
    <panel *context={:Pager}
           layout="stretch content"
           margin="0, 0, 0, 4"
           clip-size="stretch">
        <frame *repeat={Pages}
               *if={Loaded}
               layout="stretch content"
               pointer-events-enabled={Selected}
               transform={Transform}
               +transition:transform="200ms EaseOutCubic"
               visibility={Visible}>
            <include name={:PageAssetName} />
        </frame>
    </panel>
    <lane *float="below; -24, -44"
          layout="stretch content"
          horizontal-content-alignment="end"
          vertical-content-alignment="middle">
        <action-button text={#Config.Action.Reset.Title}
                       description={#Config.Action.Reset.Description}
                       action="Reset" />
        <action-button text={#Config.Action.Cancel.Title}
                       description={#Config.Action.Cancel.Description}
                       tint="#f99"
                       action="Cancel" />
        <action-button text={#Config.Action.Save.Title}
                       description={#Config.Action.Save.Description}
                       bold="true"
                       tint="#9f9"
                       action="Save" />
    </lane>
    <frame *float="after; -16, -32"
           *context={:Preview}
           layout="content stretch"
           vertical-content-alignment="middle"
           clip-size="stretch">
        <frame background={@Mods/StardewUI/Sprites/White}
               background-tint="#111a"
               transform="translateX: -500"
               +state:visible={^IsPreviewVisible}
               +state:visible:transform=""
               +transition:transform="150ms EaseOutCubic">
            <lane orientation="vertical" horizontal-content-alignment="middle">
                <label margin="0, 8, 0, 0"
                       font="dialogue"
                       color="#d93"
                       shadow-alpha="0.6"
                       shadow-color="#666"
                       shadow-offset="-3, 3"
                       text={#Config.Preview.Heading} />
                <image sprite={:Texture} />
            </lane>
        </frame>
    </frame>
</frame>

<template name="nav-tab">
    <lane *switch={:Id}
          orientation="vertical"
          margin="12, 0"
          padding="8"
          horizontal-content-alignment="middle"
          focusable="true"
          click=|^SelectPage(Index)|>
        <!--
            Not the cleanest way to handle images per tab, but the alternative is hard-coding
            the source rectangles in code, because API code can't reference sprite assets.
        -->
        <nav-image *case="Controls" icon={@Mods/focustense.StarControl/Sprites/UI:Gamepad} />
        <nav-image *case="Style" icon={@Mods/focustense.StarControl/Sprites/UI:Paintbrush} />
        <nav-image *case="Actions" icon={@Mods/focustense.StarControl/Sprites/UI:Backpack} />
        <nav-image *case="Sound" icon={@Mods/focustense.StarControl/Sprites/UI:Music} />
        <nav-image *case="Mods" icon={@Mods/focustense.StarControl/Sprites/UI:Plug} />
        <nav-image *case="Debug" icon={@Mods/focustense.StarControl/Sprites/UI:BugNet} />
        <label margin="0, 8, 0, 0"
               bold={Selected}
               shadow-alpha="0.8"
               shadow-color="#999"
               shadow-layers="VerticalAndDiagonal"
               shadow-offset="-2, 2"
               text={:Title} />
    </lane>
</template>

<template name="nav-image">
    <image layout="64px"
           sprite={&icon}
           shadow-alpha="0.4"
           shadow-offset="-4, 4" />
</template>

<template name="action-button">
    <button layout="content[150..] content"
            margin="8, 0, 0, 0"
            default-background={@Mods/StardewUI/Sprites/ButtonDark}
            default-background-tint={&tint}
            hover-background={@Mods/StardewUI/Sprites/ButtonLight}
            shadow-visible="true"
            tooltip={&description}
            left-click=|PerformAction(&action)|>
        <label bold={&bold}
               shadow-alpha="0.5"
               shadow-color="#447"
               shadow-offset="-1, 1"
               text={&text} />
    </button>
</template>