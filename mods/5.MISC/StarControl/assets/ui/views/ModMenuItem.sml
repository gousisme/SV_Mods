<!-- Outer frame allows very slight vertical growth of window without repositioning. -->
<frame layout="content content[550..]" outer-size={>ContentSize}>
    <frame layout="600px content"
           padding="24"
           background={@Mods/StardewUI/Sprites/ControlBorder}>
        <frame *float="above; 0, -8" layout="stretch content" horizontal-content-alignment="middle">
            <frame background={@Mods/StardewUI/Sprites/ControlBorder} padding="24" shadow-alpha="0.25" shadow-offset="-8, 8">
                <lane layout="350px content" orientation="vertical" horizontal-content-alignment="middle">
                    <image layout="64px" horizontal-alignment="middle" vertical-alignment="middle" sprite={Icon} />
                    <label margin="0, 8, 0, 0"
                           font="dialogue"
                           horizontal-alignment="middle"
                           max-lines="1"
                           shadow-alpha="0.3"
                           shadow-color="#3339"
                           shadow-offset="-4, 4"
                           text={Name} />
                    <label margin="0, 8, 0, 0"
                           horizontal-alignment="middle"
                           max-lines="2"
                           text={Description} />
                </lane>
            </frame>
        </frame>
        <frame *float="after; 8, 0"
               layout="400px stretch"
               clip-size="450px stretch"
               pointer-events-enabled={IsGmcmSyncVisible}>
            <frame *context={GmcmSync}
                   padding="24"
                   background={@Mods/StardewUI/Sprites/ControlBorder}
                   opacity="0"
                   transform="translateX: -400"
                   +state:enabled={IsGmcmSyncVisible}
                   +state:enabled:opacity="1"
                   +state:enabled:transform=""
                   +transition:opacity="150ms"
                   +transition:transform="200ms EaseOutQuart">
                <lane layout="stretch content" orientation="vertical">
                    <label font="dialogue" text="GMCM Sync" shadow-alpha="0.5" shadow-offset="-3, 3" />
                    <horizontal-divider />
                    <lane vertical-content-alignment="middle">
                        <label margin="0, 0, 8, 0" text="Mod:" />
                        <dropdown options={:AvailableMods}
                                  option-format={:FormatModName}
                                  option-max-lines="3"
                                  selection-frame-layout="stretch content"
                                  selected-option={<>SelectedMod}
                                  tooltip={#Config.ModMenuItem.Gmcm.Mod.Description} />
                    </lane>
                    <checkbox margin="0, 4"
                              label-text={#Config.ModMenuItem.Gmcm.SyncName.Title}
                              tooltip={#Config.ModMenuItem.Gmcm.SyncName.Description}
                              is-checked={<>EnableTitleSync} />
                    <checkbox margin="0, 4"
                              label-text={#Config.ModMenuItem.Gmcm.SyncDetails.Title}
                              tooltip={#Config.ModMenuItem.Gmcm.SyncDetails.Description}
                              is-checked={<>EnableDescriptionSync} />
                    <horizontal-divider />
                    <frame layout="stretch content"
                           background={@Mods/StardewUI/Sprites/White}
                           background-tint="#8888"
                           border={@Mods/StardewUI/Sprites/WhiteBorder}
                           border-tint="#c60"
                           padding="8, 4">
                        <scrollable layout="stretch"
                                    peeking="64"
                                    scrollbar-margin="32, 0, 0, -32">
                            <lane layout="stretch content" orientation="vertical">
                                <lane *repeat={AvailableOptions}
                                      layout="stretch content"
                                      margin="0, 4"
                                      orientation="vertical">
                                    <lane vertical-content-alignment="middle">
                                        <image layout="48px 32px"
                                               sprite={@Mods/focustense.StarControl/Sprites/Cursors:TargetBlue}
                                               shadow-alpha="0.5"
                                               shadow-offset="-1, 2"
                                               opacity="0"
                                               +state:selected={Selected}
                                               +state:selected:opacity="1"
                                               +transition:opacity="100ms" />
                                        <label text={:DisplayName}
                                               focusable="true"
                                               +hover:bold="true"
                                               tooltip={MissingKeybindDescription}
                                               left-click=|^SelectOption(this)| />
                                    </lane>
                                    <lane *if={IsMissingKeybind}
                                          margin="48, 4, 0, 8"
                                          vertical-content-alignment="middle">
                                        <image layout="24px" margin="0, 0, 8, 0"
                                               sprite={@Mods/focustense.StarControl/Sprites/UI:Error}
                                               shadow-alpha="0.5"
                                               shadow-offset="-2, 2" />
                                        <label color="#c30" text={#Config.ModMenuItem.Gmcm.MissingKeybind.Title} />
                                    </lane>
                                </lane>
                            </lane>
                        </scrollable>
                    </frame>
                </lane>
            </frame>
        </frame>
        <lane layout="stretch content" orientation="vertical">
            <form-row title={#Config.ModMenuItem.SyncType.Title} description={#Config.ModMenuItem.SyncType.Description}>
                <enum-segments *context={:SyncType} />
            </form-row>
            <panel layout="stretch content" clip-size="stretch">
                <lane layout="stretch content"
                      orientation="vertical"
                      transform={MainEditorTransform}
                      pointer-events-enabled={IsMainEditorVisible}
                      +transition:transform="150ms EaseOutQuint">
                    <form-row title={#Config.ModMenuItem.Name.Title} description={#Config.ModMenuItem.Name.Description}>
                        <textinput layout="stretch 52px"
                                   margin="-6, 0, 0, 0"
                                   max-length="30"
                                   enabled={CanEditName}
                                   text={<>EditableName} />
                    </form-row>
                    <form-row title={#Config.ModMenuItem.Details.Title} description={#Config.ModMenuItem.Details.Description}>
                        <textinput layout="stretch 52px"
                                   margin="-6, 0, 0, 0"
                                   enabled={CanEditDescription}
                                   text={<>EditableDescription} />
                    </form-row>
                    <form-row title={#Config.ModMenuItem.Keybind.Title} description={#Config.ModMenuItem.Keybind.Description}>
                        <keybind-editor background-color="#863c"
                                        button-height="48"
                                        opacity="0.6"
                                        focusable="true"
                                        empty-text={#Config.ModMenuItem.Keybind.EmptyText}
                                        sprite-map={@Mods/focustense.StarControl/SpriteMaps/Kenney}
                                        keybind-list={<>Keybind}
                                        +state:enabled={CanEditKeybind}
                                        +state:enabled:background-color="#0000"
                                        +state:enabled:editable-type="SingleKeybind"
                                        +state:enabled:opacity="1" />
                    </form-row>
                    <form-row title={#Config.ModMenuItem.EnableActivationDelay.Title}
                              description={#Config.ModMenuItem.EnableActivationDelay.Description}>
                        <checkbox is-checked={<>EnableActivationDelay} />
                    </form-row>
                    <form-row title={#Config.ModMenuItem.IconType.Title} description={#Config.ModMenuItem.IconType.Description}>
                        <lane vertical-content-alignment="middle">
                            <enum-segments *context={:IconType} />
                            <spacer layout="stretch 0px" />
                            <button margin="16, 0, 0, 0"
                                    hover-background={@Mods/StardewUI/Sprites/ButtonLight}
                                    tooltip={#Config.ModMenuItem.RandomizeIcon.Description}
                                    transform-origin="0.5, 0.5"
                                    +hover:transform="scale: 1.1"
                                    +transition:transform="150ms EaseOutQuint"
                                    pointer-enter=|OnRandomizeButtonHover()|
                                    left-click=|PickRandomIcon()|>
                                <image layout="30px" sprite={@Mods/focustense.StarControl/Sprites/Cursors:LuckBuff} />
                            </button>
                        </lane>
                    </form-row>
                    <horizontal-divider />
                    <panel layout="stretch content" clip-size="stretch">
                        <lane layout="stretch content"
                              orientation="vertical"
                              pointer-events-enabled={IsStandardIcon}
                              transform="translateY: -180"
                              +state:enabled={IsStandardIcon}
                              +state:enabled:transform=""
                              +transition:transform="150ms EaseOutCubic">
                            <frame layout="stretch content"
                                   margin="100, 8, 100, 0"
                                   horizontal-content-alignment="middle">
                                <panel layout="stretch content"
                                       vertical-content-alignment="middle">
                                    <textinput layout="stretch 52px"
                                               margin="-6, 0, 0, 0"
                                               border-thickness="56, 12, 12, 12"
                                               placeholder={#Config.ModMenuItem.Search.Placeholder}
                                               text={<>SearchText} />
                                    <image layout="32px"
                                           margin="12, 2, 0, 0"
                                           sprite={@Mods/focustense.StarControl/Sprites/UI:MagnifyingGlass}
                                           shadow-alpha="0.25"
                                           shadow-offset="-2, 2" />
                                </panel>
                            </frame>
                            <lane *context={SearchResults}
                                  layout="stretch content"
                                  margin="0, 8, 0, 0"
                                  vertical-content-alignment="middle">
                                <image layout="64px"
                                       sprite={@Mods/StardewUI/Sprites/LargeLeftArrow}
                                       tooltip={#Config.ModMenuItem.Search.Previous}
                                       z-index="1"
                                       transform-origin="0.5, 0.5"
                                       +hover:transform="scale: 1.2"
                                       +transition:transform="150ms EaseOutCubic"
                                       click=|MovePrevious()| />
                                <panel layout="stretch content"
                                       horizontal-content-alignment="middle"
                                       vertical-content-alignment="middle"
                                       clip-origin="middle middle"
                                       clip-size="95% stretch"
                                       outer-size={>LayoutSize}
                                       button-press=|HandleButton($Button)|
                                       button-repeat=|HandleButton($Button)|
                                       left-click=|^^SetIconFromSearchResults($Position)|>
                                    <frame layout="80px"
                                           margin="2, 0, 0, 0"
                                           padding="8"
                                           background={@Mods/StardewUI/Sprites/MenuSlotInset}
                                           background-tint="#def"
                                           horizontal-content-alignment="end"
                                           vertical-content-alignment="end" />
                                    <image *repeat={VisibleItems}
                                           layout="64px"
                                           horizontal-alignment="middle"
                                           vertical-alignment="middle"
                                           sprite={:Data}
                                           transform={Transform}
                                           +transition:transform="120ms EaseOutCubic" />
                                    <spacer layout="24px" margin="48, 48, 0, 0" z-index="2" focusable="true" />
                                </panel>
                                <image layout="64px"
                                       sprite={@Mods/StardewUI/Sprites/LargeRightArrow}
                                       tooltip={#Config.ModMenuItem.Search.Next}
                                       z-index="1"
                                       transform-origin="0.5, 0.5"
                                       +hover:transform="scale: 1.2"
                                       +transition:transform="150ms EaseOutCubic"
                                       click=|MoveNext()| />
                            </lane>
                        </lane>
                        <lane layout="stretch content"
                              orientation="vertical"
                              pointer-events-enabled={IsCustomIcon}
                              transform="translateY: 180"
                              +state:enabled={IsCustomIcon}
                              +state:enabled:transform=""
                              +transition:transform="150ms EaseOutCubic">
                            <label layout="stretch content"
                                   margin="0, 0, 0, 8"
                                   horizontal-alignment="middle"
                                   bold="true"
                                   color="Maroon"
                                   text=">>> Advanced users only @@@"
                                   shadow-alpha="0.1"
                                   shadow-color="#3339"
                                   shadow-offset="-3, 3" />
                            <form-row title={#Config.ModMenuItem.CustomIcon.AssetPath.Title}
                                      description={#Config.ModMenuItem.CustomIcon.AssetPath.Description}>
                                <textinput layout="stretch 52px"
                                           margin="-6, 0, 0, 0"
                                           placeholder={#Config.ModMenuItem.CustomIcon.AssetPath.Placeholder}
                                           text={<>IconAssetPath} />
                            </form-row>
                            <form-row title={#Config.ModMenuItem.CustomIcon.SourceRectangle.Title}
                                      description={#Config.ModMenuItem.CustomIcon.SourceRectangle.Description}>
                                <textinput layout="280px 52px"
                                           margin="-6, 0, 0, 0"
                                           placeholder={#Config.ModMenuItem.CustomIcon.SourceRectangle.Placeholder}
                                           text={<>IconSourceRectText} />
                            </form-row>
                        </lane>
                    </panel>
                </lane>
                <lane layout="stretch content"
                      orientation="vertical"
                      transform={ApiPickerTransform}
                      pointer-events-enabled={IsApiPickerVisible}
                      visibility={IsApiPickerLoaded}
                      +transition:transform="150ms EaseOutQuart">
                    <horizontal-divider />
                    <label *if={IsApiPickerEmpty}
                           margin="0, 4, 0, 0"
                           color="#666"
                           text={#Config.ModMenuItem.Api.EmptyText} />
                    <grid layout="stretch content"
                          item-layout="length: 72+"
                          item-spacing="4, 4"
                          grid-alignment="middle"
                          horizontal-item-alignment="middle"
                          vertical-item-alignment="middle">
                        <library-item *repeat={ApiItems}
                                      sprite={Sprite}
                                      tooltip={Tooltip}
                                      selected={Selected} />
                    </grid>
                </lane>
            </panel>
        </lane>
    </frame>
</frame>

<template name="form-row">
    <lane margin="4" vertical-content-alignment="middle">
        <frame layout="200px content">
            <label text={&title} tooltip={&description} />
        </frame>
        <frame tooltip={&description}>
            <outlet />
        </frame>
    </lane>
</template>

<template name="enum-segments">
    <frame background={@Mods/StardewUI/Sprites/MenuSlotTransparent} padding="4" tooltip="">
        <segments balanced="true"
                  highlight={@Mods/StardewUI/Sprites/White}
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

<template name="horizontal-divider">
    <image layout="stretch 4px"
           margin="0, 8"
           fit="stretch"
           sprite={@Mods/StardewUI/Sprites/ThinHorizontalDivider}
           tint="#8888" />
</template>

<template name="library-item">
    <frame layout="stretch content"
           padding="4"
           background={@Mods/StardewUI/Sprites/White}
           background-tint="#0000"
           border={@Mods/StardewUI/Sprites/MenuSlotTransparent}
           border-thickness="4"
           focusable="true"
           tooltip={&tooltip}
           +hover:background-tint="#39d"
           +transition:background-tint="100ms"
           left-click=|^SelectApiItem(this)|>
        <panel>
            <image *if={&selected}
                   layout="stretch"
                   fit="stretch"
                   margin="-4, -4, -6, -4"
                   sprite={@Mods/StardewUI/Sprites/White}
                   tint="#3c6" />
            <image layout="64px"
                   horizontal-alignment="middle"
                   vertical-alignment="middle"
                   sprite={&sprite}
                   shadow-alpha="0.25"
                   shadow-offset="-2, 2" />
        </panel>
    </frame>
</template>