<lane *context={:~ConfigurationViewModel.Debug} layout="stretch content" orientation="vertical">
    <form-heading title={#Config.Logging.Heading} />
    <lane layout="stretch content" margin="16, 0, 0, 0" orientation="vertical">
        <label margin="0, 0, 0, 16" color="#666" text={#Config.Logging.Help} />
        <checkbox margin="0, 8"
                  label-text={#Config.Logging.All.Title}
                  tooltip={#Config.Logging.All.Description}
                  is-checked={<>EnableAllLogging} />
        <logging-setting title={#Config.Logging.Input.Title}
                         description={#Config.Logging.Input.Description}
                         checked={<>EnableInputLogging} />
        <logging-setting title={#Config.Logging.MenuInteraction.Title}
                         description={#Config.Logging.MenuInteraction.Description}
                         checked={<>EnableMenuInteractionLogging} />
        <logging-setting title={#Config.Logging.QuickSlots.Title}
                         description={#Config.Logging.QuickSlots.Description}
                         checked={<>EnableQuickSlotLogging} />
        <logging-setting title={#Config.Logging.ItemActivation.Title}
                         description={#Config.Logging.ItemActivation.Description}
                         checked={<>EnableItemActivationLogging} />
        <logging-setting title={#Config.Logging.GmcmSync.Title}
                         description={#Config.Logging.GmcmSync.Description}
                         checked={<>EnableGmcmSyncLogging} />
        <logging-setting title={#Config.Logging.GmcmDetailed.Title}
                         description={#Config.Logging.GmcmDetailed.Description}
                         checked={<>EnableGmcmDetailedLogging} />
    </lane>
</lane>

<template name="form-heading">
    <banner margin="0, 8, 0, 8" text={&title} />
</template>

<template name="logging-setting">
    <checkbox margin="0, 4"
              label-text={&title}
              tooltip={&description}
              is-checked={&checked}
              +state:disabled={EnableAllLogging}
              +state:disabled:opacity="0.6"
              +state:disabled:pointer-events-enabled="false" />
</template>