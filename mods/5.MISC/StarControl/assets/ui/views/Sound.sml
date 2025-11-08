<lane *context={:~ConfigurationViewModel.Sound} layout="stretch content" orientation="vertical">
    <form-heading title={#Config.Sound.Heading} />
</lane>

<template name="form-heading">
    <banner margin="0, 8, 0, 0" text={&title} />
    <form-row title={#Config.Sound.Enabled.Title}>
        <checkbox checked-sprite={@Mods/focustense.StarControl/Sprites/UI:SoundOn}
                  unchecked-sprite={@Mods/focustense.StarControl/Sprites/UI:SoundOff}
                  tooltip={#Config.Sound.Enabled.Description}
                  is-checked={<>EnableUiSounds}
                  transform-origin="0.5, 0.5"
                  +hover:transform="scale: 1.4"
                  +transition:transform="100ms EaseOutCubic" />
    </form-row>
    <image layout="stretch 4px"
           margin="16, 12, 2, 12"
           fit="stretch"
           sprite={@Mods/StardewUI/Sprites/ThinHorizontalDivider} tint="#8888" />
    <lane layout="stretch content"
          orientation="vertical"
          opacity="0.5"
          pointer-events-enabled="false"
          +state:enabled={EnableUiSounds}
          +state:enabled:opacity="1"
          +state:enabled:pointer-events-enabled="true"
          +transition:opacity="120ms EaseOutSine">
        <form-row title={#Config.Sound.MenuOpen.Title}>
            <cue-editor cue={:MenuOpenSound} />
        </form-row>
        <form-row title={#Config.Sound.MenuClose.Title}>
            <cue-editor cue={:MenuCloseSound} />
        </form-row>
        <form-row title={#Config.Sound.NextPage.Title}>
            <cue-editor cue={:NextPageSound} />
        </form-row>
        <form-row title={#Config.Sound.PreviousPage.Title}>
            <cue-editor cue={:PreviousPageSound} />
        </form-row>
        <form-row title={#Config.Sound.Focus.Title}>
            <cue-editor cue={:ItemFocusSound} />
        </form-row>
        <form-row title={#Config.Sound.ActivateDefault.Title}>
            <cue-editor cue={:ItemActivationSound} />
        </form-row>
        <form-row title={#Config.Sound.ActivateDelayed.Title}>
            <cue-editor cue={:ItemDelaySound} />
        </form-row>
        <form-row title={#Config.Sound.ActivateError.Title}>
            <cue-editor cue={:ItemErrorSound} />
        </form-row>
    </lane>
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

<template name="cue-editor">
    <lane *context={&cue} vertical-content-alignment="middle">
        <image layout="32px"
               sprite={@Mods/StardewUI/Sprites/CaretLeft}
               tooltip={#Config.Sound.PreviousSound.Description}
               focusable="true"
               transform-origin="0.5, 0.5"
               +hover:transform="scale: 1.2"
               +transition:transform="100ms EaseOutCubic"
               pointer-enter=|^ButtonHover()|
               click=|PreviousSound()| />
        <textinput layout="stretch 52px"
                   margin="0, 0, 12, 0"
                   max-length="30"
                   placeholder={#Config.Sound.NoSound}
                   tooltip={#Config.Sound.Entry.Description}
                   text={<>CueName} />
        <image layout="32px"
               sprite={@Mods/StardewUI/Sprites/CaretRight}
               tooltip={#Config.Sound.NextSound.Description}
               focusable="true"
               transform-origin="0.5, 0.5"
               +hover:transform="scale: 1.2"
               +transition:transform="100ms EaseOutCubic"
               pointer-enter=|^ButtonHover()|
               click=|NextSound()| />
        <image layout="48px"
               margin="8, 0"
               sprite={@Mods/focustense.StarControl/Sprites/Cursors:PlayButton}
               tooltip={#Config.Sound.Preview.Description}
               focusable="true"
               transform-origin="0.5, 0.5"
               +hover:transform="scale: 1.15"
               +transition:transform="100ms EaseOutCubic"
               pointer-enter=|^ButtonHover()|
               left-click=|PlaySound()| />
    </lane>
</template>