<frame padding="24, 24, 32, 32"
       background={@Mods/StardewUI/Sprites/ControlBorder}>
    <lane orientation="vertical">
        <lane *!if={ReopenOnHoldDisabled} orientation="vertical">
            <form-heading title={#Config.Menus.Heading} />
            <form-row title={#Config.Menus.ReopenOnHold.Title} description={#Config.Menus.ReopenOnHold.Description}>
                <checkbox margin="0, 4" is-checked={<>ReopenOnHold} />
            </form-row>
            <form-row title={#Config.Selection.Remember.Title} description={#Config.Selection.Remember.Description}>
                <checkbox margin="0, 4" is-checked={<>RememberSelection} />
            </form-row>
        </lane>
        
        <form-heading title={#Config.Patches.Heading} />
        <form-row title={#Config.Patches.SuppressRightStickChatBox.Title}
                  description={#Config.Patches.SuppressRightStickChatBox.Description}>
            <checkbox margin="0, 4" is-checked={<>SuppressRightStickChatBox} />
        </form-row>

        <form-heading title={#Config.Sensitivity.Heading} />
        <form-row title={#Config.Sensitivity.TriggerDeadZone.Title}
                  description={#Config.Sensitivity.TriggerDeadZone.Description}>
            <slider track-width="300"
                    min="0"
                    max="1"
                    interval="0.01"
                    value={<>TriggerDeadZone}
                    value-format={:FormatDeadZone} />
        </form-row>
        <form-row title={#Config.Sensitivity.ThumbstickDeadZone.Title}
                  description={#Config.Sensitivity.ThumbstickDeadZone.Description}>
            <slider track-width="300"
                    min="0"
                    max="1"
                    interval="0.01"
                    value={<>ThumbstickDeadZone}
                    value-format={:FormatDeadZone} />
        </form-row>
    </lane>
</frame>

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