--- fixed v2
getgenv().GG = {}
GG.SelectedLanguage = GG.SelectedLanguage or "en"
local SelectedLanguage = GG.SelectedLanguage
function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end
    return result
end
function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end
local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))
local mouse = Players.LocalPlayer:GetMouse()
local Theme = {
    brand = "RONI",
    icon = "rbxassetid://107819132007001",
    arrow = "rbxassetid://84232453189324",
    show_keybind_list = false,
    colors = {
        background = Color3.fromRGB(10, 10, 10),
        sidebar = Color3.fromRGB(12, 12, 12),
        surface = Color3.fromRGB(15, 15, 15),
        surfaceRaised = Color3.fromRGB(22, 22, 22),
        surfaceHover = Color3.fromRGB(28, 28, 28),
        control = Color3.fromRGB(38, 38, 38),
        controlHover = Color3.fromRGB(48, 48, 48),
        stroke = Color3.fromRGB(44, 44, 44),
        divider = Color3.fromRGB(30, 30, 30),
        text = Color3.fromRGB(245, 245, 245),
        textMuted = Color3.fromRGB(185, 185, 185),
        textDim = Color3.fromRGB(115, 115, 115),
        accent = Color3.fromRGB(255, 255, 255),
        shadow = Color3.fromRGB(0, 0, 0),
    },
    transparency = {
        window = 0,
        panel = 0.08,
        stroke = 0.55,
        muted = 0.35,
        disabled = 0.58,
    },
}
function Theme.font(weight: Enum.FontWeight)
    if SelectedLanguage == "th" then
        return Font.new("rbxasset://fonts/families/NotoSansThai.json", weight, Enum.FontStyle.Normal)
    end
    return Font.new("rbxasset://fonts/families/GothamSSm.json", weight, Enum.FontStyle.Normal)
end
local Metrics = {
    window_width = 656,
    window_height = 426,
    minimized_width = 104,
    minimized_height = 52,
    sidebar_width = 132,
    tab_width = 112,
    tab_height = 34,
    section_width = 242,
    section_height = 386,
    module_width = 234,
    module_header_height = 78,
    option_width = 202,
    radius_window = 8,
    radius_panel = 7,
    radius_control = 4,
    radius_pill = 999,
}
local Motion = {
    hover = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    control = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    expand = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    open = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    notify = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}
local function add_corner(object: GuiObject, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius == Metrics.radius_pill and UDim.new(1, 0) or UDim.new(0, radius)
    corner.Parent = object
    return corner
end
local function add_stroke(object: GuiObject, color: Color3?, transparency: number?)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.colors.stroke
    stroke.Transparency = transparency or Theme.transparency.stroke
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = object
    return stroke
end
local function apply_font(label: TextLabel | TextButton | TextBox, weight: Enum.FontWeight, size: number)
    label.FontFace = Theme.font(weight)
    label.TextSize = size
end
local function normalize_flag(settings: any, fallback: string)
    settings.flag = settings.flag or settings.name or settings.title or fallback
    return settings.flag
end
for _, gui in pairs((gethui and gethui():GetChildren()) or CoreGui:GetChildren()) do
    if gui:FindFirstChild('RoniSignature') then
        Debris:AddItem(gui, 0)
    end
end
local old_Allusive = CoreGui:FindFirstChild('roni')
if old_Allusive then
    Debris:AddItem(old_Allusive, 0)
end
if not isfolder("roni") then
    makefolder("roni")
end
local ConfigFolder = "Allusive"
if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end
local Connections = {}
Connections.disconnect = function(self, connection)
    if not self[connection] then
        return
    end
    if typeof(self[connection]) == 'RBXScriptConnection' then
        self[connection]:Disconnect()
    end
    self[connection] = nil
end
Connections.disconnect_all = function(self)
    for key, value in pairs(self) do
        if typeof(value) == 'RBXScriptConnection' then
            value:Disconnect()
            self[key] = nil
        end
    end
end
local Util = {}
Util.map = function(self: any, value: number, in_minimum: number, in_maximum: number, out_minimum: number, out_maximum: number)
    return (value - in_minimum) * (out_maximum - out_minimum) / (in_maximum - in_minimum) + out_minimum
end
Util.viewport_point_to_world = function(self: any, location: any, distance: number)
    local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
    return unit_ray.Origin + unit_ray.Direction * distance
end
Util.get_offset = function(self: any)
    local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y
    return self:map(viewport_size_Y, 0, 2560, 8, 56)
end
Util.random_string = function(self: any)
    local array = {}
    for i = 1, math.random(10, 20) do
        array[i] = string.char(math.random(97, 122))
    end
    return table.concat(array)
end
Util.is_mouse_over_frame = function(self: any, frame: Frame)
    local abs_pos, abs_size = frame.AbsolutePosition, frame.AbsoluteSize
    if mouse.X >= abs_pos.X and mouse.X <= abs_pos.X + abs_size.X and mouse.Y >= abs_pos.Y and mouse.Y <= abs_pos.Y + abs_size.Y then
        return true
    end
    return false
end
Util.rounding = function(self: any, num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
Util.new_input = function(self: any, frame: Frame, callback)
    local btn = Instance.new('TextButton', frame)
    btn.ZIndex = frame.ZIndex + 10
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.TextTransparency = 1
    btn.Text = ""
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
function AcrylicBlur.new(object: GuiObject)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)
    self:setup()
    return self
end
function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')
    if old_folder then
        Debris:AddItem(old_folder, 0)
    end
    local folder = Instance.new('Folder')
    folder.Name = 'AcrylicBlur'
    folder.Parent = workspace.CurrentCamera
    self._folder = folder
end
function AcrylicBlur:create_depth_of_fields()
    local depth_of_fields = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = 'AcrylicBlur'
    depth_of_fields.Parent = Lighting
    return depth_of_fields
end
function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object
    self._frame = frame
end
function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)  
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder
    local specialMesh = Instance.new('SpecialMesh')
    specialMesh.MeshType = Enum.MeshType.Brick  
    specialMesh.Offset = Vector3.new(0, 0, -0.000001)  
    specialMesh.Parent = part
    self._root = part  
end
function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
    self:check_quality_level()
end
function AcrylicBlur:render(distance: number)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }
    local function update_positions(size: any, position: any)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right
        local top_left3D = Util:viewport_point_to_world(top_left, distance)
        local top_right3D = Util:viewport_point_to_world(top_right, distance)
        local bottom_right3D = Util:viewport_point_to_world(bottom_right, distance)
        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude
        if not self._root then
            return
        end
        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end
    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        update()
    end
    local id = tostring(self)
    local function bind_camera()
        Connections.disconnect(Connections, 'cframe_update_' .. id)
        Connections.disconnect(Connections, 'viewport_size_update_' .. id)
        Connections.disconnect(Connections, 'field_of_view_update_' .. id)
        Connections['cframe_update_' .. id] = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
        Connections['viewport_size_update_' .. id] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
        Connections['field_of_view_update_' .. id] = workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    end
    Connections['camera_change_' .. id] = workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
        bind_camera()
        update()
    end)
    bind_camera()
    Connections['frame_absolute_position_' .. id] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['frame_absolute_size_' .. id] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)
    update()
end
function AcrylicBlur:check_quality_level()
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value
    if quality_level < 8 then
        self:change_visiblity(false)
    end
    Connections['quality_level'] = game_settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        local game_settings = UserSettings().GameSettings
        local quality_level = game_settings.SavedQualityLevel.Value
        self:change_visiblity(quality_level >= 8)
    end)
end
function AcrylicBlur:change_visiblity(state: boolean)
    self._root.Transparency = state and 0.98 or 1
end
local function deep_copy_serialize(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            copy[k] = deep_copy_serialize(v)
        elseif typeof(v) == 'Color3' then
            copy[k] = {v.R, v.G, v.B}
        elseif typeof(v) == 'Vector2' then
            copy[k] = {v.X, v.Y}
        else
            copy[k] = v
        end
    end
    return copy
end
local Config = setmetatable({
    VERSION = 4,
    save = function(self: any, file_name: any, config: any)
        config = config or {}
        config._flags = config._flags or {}
        config._keybinds = config._keybinds or {}
        config._library = config._library or {}
        config._version = self.VERSION
        local success_save, result = pcall(function()
            local encoded = HttpService:JSONEncode(deep_copy_serialize(config))
            writefile(ConfigFolder..'/'..file_name..'.json', encoded)
        end)
        if not success_save then
            warn('failed to save config', result)
        end
    end,
    load = function(self: any, file_name: any, config: any)
        local default_config = config or {
            _version = self.VERSION,
            _flags = {},
            _keybinds = {},
            _library = {}
        }
        local result
        local success_load, decoded = pcall(function()
            if not isfile(ConfigFolder..'/'..file_name..'.json') then
                return nil
            end
            return HttpService:JSONDecode(readfile(ConfigFolder..'/'..file_name..'.json'))
        end)
        if not success_load then
            warn('failed to load config (corrupt JSON):', decoded)
            result = default_config
        elseif type(decoded) ~= 'table' then
            result = default_config
        else
            result = decoded
        end
        result._flags = (type(result._flags) == 'table') and result._flags or {}
        result._keybinds = (type(result._keybinds) == 'table') and result._keybinds or {}
        result._library = (type(result._library) == 'table') and result._library or {}
        local saved_version = result._version
        if saved_version ~= self.VERSION then
            result = self:migrate(result, saved_version) or result
            result._version = self.VERSION
            self:save(file_name, result)
        end
        return result
    end,
    migrate = function(self: any, data: any, _from_version: any)
        return nil
    end
}, Config)
local Library = {
    Theme = Theme,
    Metrics = Metrics,
    Motion = Motion,
    _config = Config:load(game.GameId),
    _choosing_keybind = false,
    _device = nil,
    _ui_open = true,
    _ui_scale = 1,
    _ui_loaded = false,
    _ui = nil,
    _dragging = false,
    _drag_start = nil,
    _container_position = nil,
    _registered_flags = {}
}
Library.__index = Library
function Library.new()
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
        _keybind_entries = {},
    }, Library)
    self:create_ui()
    if Theme.show_keybind_list and UserInputService.KeyboardEnabled then
        local KeybindsWidget = Instance.new("Frame")
        KeybindsWidget.Name = "KeybindsWidget"
        KeybindsWidget.Size = UDim2.fromOffset(176, 30)
        KeybindsWidget.Position = UDim2.new(0.035, 0, 0.34, 0)
        KeybindsWidget.BackgroundColor3 = Theme.colors.surface
        KeybindsWidget.BackgroundTransparency = Theme.transparency.panel
        KeybindsWidget.BorderSizePixel = 0
        KeybindsWidget.AutomaticSize = Enum.AutomaticSize.Y
        KeybindsWidget.Parent = self._ui
        local KeybindsUIScale = Instance.new("UIScale")
        KeybindsUIScale.Parent = KeybindsWidget
        Library._keybinds_uiscale = KeybindsUIScale
        add_corner(KeybindsWidget, Metrics.radius_panel)
        add_stroke(KeybindsWidget, Theme.colors.stroke, Theme.transparency.stroke)
        local KBTitle = Instance.new("TextLabel")
        KBTitle.Size = UDim2.new(1, 0, 0, 30)
        KBTitle.Position = UDim2.new(0, 0, 0, 0)
        KBTitle.BackgroundTransparency = 1
        KBTitle.Text = "Keybinds"
        KBTitle.TextColor3 = Theme.colors.text
        KBTitle.FontFace = Theme.font(Enum.FontWeight.SemiBold)
        KBTitle.TextSize = 11
        KBTitle.Parent = KeybindsWidget
        local KBLayout = Instance.new("UIListLayout")
        KBLayout.SortOrder = Enum.SortOrder.LayoutOrder
        KBLayout.Padding = UDim.new(0, 5)
        KBLayout.Parent = KeybindsWidget
        local KBPadding = Instance.new("UIPadding")
        KBPadding.PaddingTop = UDim.new(0, 30)
        KBPadding.PaddingBottom = UDim.new(0, 10)
        KBPadding.PaddingLeft = UDim.new(0, 9)
        KBPadding.PaddingRight = UDim.new(0, 9)
        KBPadding.Parent = KeybindsWidget
        local dragToggle, dragStart, startPos
        KeybindsWidget.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = true
                dragStart = input.Position
                startPos = KeybindsWidget.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
                local delta = input.Position - dragStart
                KeybindsWidget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        Library._keybinds_widget = KeybindsWidget
    end
    return self
end
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "RobloxCoreGuis"
NotificationContainer.Size = UDim2.new(0, math.min(320, workspace.CurrentCamera.ViewportSize.X - 20), 0, 0)
NotificationContainer.AnchorPoint = Vector2.new(1, 0)
NotificationContainer.Position = UDim2.new(1, -12, 0, 12)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ClipsDescendants = false;
NotificationContainer.Parent = game:GetService("CoreGui").RobloxGui:FindFirstChild("RobloxCoreGuis") or Instance.new("ScreenGui", game:GetService("CoreGui").RobloxGui)
NotificationContainer.AutomaticSize = Enum.AutomaticSize.Y
local NotificationUIScale = Instance.new("UIScale")
NotificationUIScale.Parent = NotificationContainer
Library._notification_uiscale = NotificationUIScale
Library._notification_container = NotificationContainer
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = NotificationContainer
local NOTIFICATION_ACCENTS = {
    success = Color3.fromRGB(76, 175, 80),   
    warn    = Color3.fromRGB(255, 193, 7),   
    error   = Color3.fromRGB(244, 67, 54),   
    info    = Theme.colors.accent, 
}
local NOTIFICATION_GLYPHS = {
    success = "OK",
    warn = "!",
    error = "X",
    info = "i",
}
function Library.SendNotification(settings)
    settings = settings or {}
    local dismissed = false
    local duration = settings.duration or 5
    local Notification = Instance.new("TextButton")
    Notification.Size = UDim2.new(1, 0, 0, 72)
    Notification.BackgroundTransparency = 1
    Notification.BorderSizePixel = 0
    Notification.Text = ""
    Notification.Name = "Notification"
    Notification.Parent = NotificationContainer
    Notification.AutomaticSize = Enum.AutomaticSize.Y
    local InnerFrame = Instance.new("Frame")
    InnerFrame.Size = UDim2.new(1, 0, 0, 72)
    InnerFrame.Position = UDim2.new(1, 0, 0, 0)
    InnerFrame.BackgroundColor3 = Theme.colors.surfaceRaised
    InnerFrame.BackgroundTransparency = 0
    InnerFrame.BorderSizePixel = 0
    InnerFrame.Name = "InnerFrame"
    InnerFrame.Parent = Notification
    InnerFrame.AutomaticSize = Enum.AutomaticSize.Y
    add_corner(InnerFrame, Metrics.radius_panel)
    add_stroke(InnerFrame, Theme.colors.stroke, Theme.transparency.stroke)
    local accentColor = NOTIFICATION_ACCENTS[settings.type] or Theme.colors.accent
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 3, 1, -14)
    AccentLine.Position = UDim2.new(0, 6, 0, 7)
    AccentLine.BackgroundColor3 = accentColor
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = InnerFrame
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = AccentLine
    local IconBubble = Instance.new("Frame")
    IconBubble.Size = UDim2.fromOffset(24, 24)
    IconBubble.Position = UDim2.fromOffset(16, 12)
    IconBubble.BackgroundColor3 = accentColor
    IconBubble.BackgroundTransparency = 0.82
    IconBubble.BorderSizePixel = 0
    IconBubble.Parent = InnerFrame
    add_corner(IconBubble, Metrics.radius_pill)
    local IconMark = Instance.new("TextLabel")
    IconMark.Size = UDim2.fromScale(1, 1)
    IconMark.BackgroundTransparency = 1
    IconMark.Text = NOTIFICATION_GLYPHS[settings.type] or NOTIFICATION_GLYPHS.info
    IconMark.TextColor3 = accentColor
    IconMark.FontFace = Theme.font(Enum.FontWeight.SemiBold)
    IconMark.TextSize = 10
    IconMark.TextXAlignment = Enum.TextXAlignment.Center
    IconMark.TextYAlignment = Enum.TextYAlignment.Center
    IconMark.Parent = IconBubble
    local Title = Instance.new("TextLabel")
    Title.Text = settings.title or "Notification Title"
    Title.TextColor3 = Theme.colors.text
    Title.FontFace = Theme.font(Enum.FontWeight.SemiBold)
    Title.TextSize = 13
    Title.Size = UDim2.new(1, -60, 0, 18)
    Title.Position = UDim2.new(0, 46, 0, 9)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.TextWrapped = true
    Title.AutomaticSize = Enum.AutomaticSize.Y
    Title.Parent = InnerFrame
    local Body = Instance.new("TextLabel")
    Body.Text = settings.text or "This is the body of the notification."
    Body.TextColor3 = Theme.colors.textMuted
    Body.FontFace = Theme.font(Enum.FontWeight.Regular)
    Body.TextSize = 11
    Body.Size = UDim2.new(1, -60, 0, 32)
    Body.Position = UDim2.new(0, 46, 0, 29)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = InnerFrame
    local ProgressTrack = Instance.new("Frame")
    ProgressTrack.Size = UDim2.new(1, -58, 0, 2)
    ProgressTrack.Position = UDim2.new(0, 46, 1, -9)
    ProgressTrack.BackgroundColor3 = Theme.colors.control
    ProgressTrack.BackgroundTransparency = 0.25
    ProgressTrack.BorderSizePixel = 0
    ProgressTrack.Parent = InnerFrame
    add_corner(ProgressTrack, Metrics.radius_pill)
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.fromScale(1, 1)
    ProgressFill.BackgroundColor3 = accentColor
    ProgressFill.BackgroundTransparency = 0.1
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressTrack
    add_corner(ProgressFill, Metrics.radius_pill)
    task.spawn(function()
        task.wait(0.1)
        if dismissed or not InnerFrame:IsDescendantOf(game) then return end
        local totalHeight = math.max(68, Title.TextBounds.Y + Body.TextBounds.Y + 36)
        InnerFrame.Size = UDim2.new(1, 0, 0, totalHeight)
        Notification.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    local function dismiss()
        if dismissed or not Notification.Parent then
            return
        end
        dismissed = true
        local tweenOut = TweenService:Create(InnerFrame, Motion.notify, {
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        TweenService:Create(Title, Motion.notify, {TextTransparency = 1}):Play()
        TweenService:Create(Body, Motion.notify, {TextTransparency = 1}):Play()
        TweenService:Create(AccentLine, Motion.notify, {BackgroundTransparency = 1}):Play()
        TweenService:Create(IconBubble, Motion.notify, {BackgroundTransparency = 1}):Play()
        TweenService:Create(IconMark, Motion.notify, {TextTransparency = 1}):Play()
        TweenService:Create(ProgressTrack, Motion.notify, {BackgroundTransparency = 1}):Play()
        TweenService:Create(ProgressFill, Motion.notify, {BackgroundTransparency = 1}):Play()
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if Notification.Parent then
                Notification:Destroy()
            end
        end)
    end
    Notification.MouseButton1Click:Connect(dismiss)
    task.spawn(function()
        local tweenIn = TweenService:Create(InnerFrame, Motion.notify, {
            Position = UDim2.new(0, 0, 0, 0)
        })
        tweenIn:Play()
        TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()
        task.wait(duration)
        dismiss()
    end)
end
function Library:get_screen_scale()
    local viewport_size = workspace.CurrentCamera.ViewportSize
    self._viewport_size = viewport_size
    local width_scale = (viewport_size.X - 20) / Metrics.window_width
    local height_scale = (viewport_size.Y - 20) / Metrics.window_height
    self._ui_scale = math.clamp(math.min(width_scale, height_scale), 0.45, 1)
end
function Library:apply_mobile_scale()
    if self._container_uiscale then
        self._container_uiscale.Scale = self._ui_scale
    end
    if self._mobile_toggle_uiscale then
        self._mobile_toggle_uiscale.Scale = self._ui_scale
    end
    if self._keybinds_uiscale then
        self._keybinds_uiscale.Scale = self._ui_scale
    end
    if self._notification_uiscale then
        self._notification_uiscale.Scale = self._ui_scale
    end
    if self._notification_container and self._viewport_size then
        self._notification_container.Size = UDim2.new(0, math.min(320, self._viewport_size.X - 20), 0, 0)
    end
end
function Library:get_device()
    local device = 'Unknown'
    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        device = 'PC'
    elseif UserInputService.TouchEnabled then
        device = 'Mobile'
    elseif UserInputService.GamepadEnabled then
        device = 'Console'
    end
    if device == 'Unknown' then
        local viewport = workspace.CurrentCamera.ViewportSize
        if viewport.X > 0 and viewport.X < 700 then
            device = 'Mobile'
        end
    end
    self._device = device
end
function Library:removed(action: any)
    self._ui.AncestryChanged:Once(action)
end
function Library:register_flag(flag: any, expected_type: any)
    if not flag or not expected_type then
        return
    end
    self._registered_flags[flag] = expected_type
    local saved = self._config._flags[flag]
    if saved ~= nil and typeof(saved) ~= expected_type then
        self._config._flags[flag] = nil
        Config:save(game.GameId, self._config)
    end
end
function Library:flag_type(flag: any, flag_type: any)
    if Library._config._flags[flag] == nil then
        return
    end
    return typeof(Library._config._flags[flag]) == flag_type
end
function Library:remove_table_value(__table: any, table_value: string)
    for index, value in __table do
        if value ~= table_value then
            continue
        end
        table.remove(__table, index)
    end
end
function Library:get_keybind_name(flag: any)
    if not flag or not self._config or not self._config._keybinds then
        return nil
    end
    local keybind = self._config._keybinds[flag]
    if not keybind then
        return nil
    end
    local key_name = tostring(keybind):gsub("Enum.KeyCode.", "")
    if key_name == "" or key_name == "Unknown" or key_name == "None" then
        return nil
    end
    return key_name
end
function Library:set_keybind(flag: any, key_code: any)
    if not flag then
        return nil
    end
    self._config._keybinds = self._config._keybinds or {}
    if not key_code or key_code == Enum.KeyCode.Unknown then
        self._config._keybinds[flag] = nil
        return nil
    end
    local key_name = tostring(key_code):gsub("Enum.KeyCode.", "")
    if key_name == "" or key_name == "Unknown" or key_name == "None" then
        self._config._keybinds[flag] = nil
        return nil
    end
    self._config._keybinds[flag] = "Enum.KeyCode." .. key_name
    return key_name
end
function Library:set_toggle_keybind(key_code: any)
    self._toggle_keybind = key_code
end
function Library:load()
end
function Library:clear_keybind(flag: any)
    if self._config and self._config._keybinds then
        self._config._keybinds[flag] = nil
    end
end
function Library:keybind_matches(flag: any, input: InputObject)
    local key_name = self:get_keybind_name(flag)
    return key_name ~= nil and input.KeyCode.Name == key_name
end
function Library:update_keybind_entry(flag: any)
    if not self._keybind_entries or not self._keybind_entries[flag] then
        return
    end
    local entry = self._keybind_entries[flag]
    local key_name = self:get_keybind_name(flag) or "..."
    if entry.frame then
        entry.frame.Visible = (key_name ~= "..." and key_name ~= "None" and key_name ~= "")
    end
    if entry.bind then
        entry.bind.Text = "[ " .. key_name .. " ]"
    end
    if entry.state then
        if entry.action then
            entry.state.Text = "[ Action ]"
            entry.state.TextColor3 = Theme.colors.textMuted
        else
            local enabled = entry.get_state and entry.get_state() or false
            entry.state.Text = enabled and "[ Enabled ]" or "[ Disabled ]"
            entry.state.TextColor3 = enabled and Theme.colors.accent or Theme.colors.textDim
        end
    end
end
function Library:begin_keybind_widget_capture(flag: any)
    if self._choosing_keybind or not UserInputService.KeyboardEnabled or not self._keybind_entries or not self._keybind_entries[flag] then
        return
    end
    self._choosing_keybind = true
    local entry = self._keybind_entries[flag]
    if entry.bind then
        entry.bind.Text = "[ ... ]"
    end
    Connections:disconnect("keybind_widget_capture_" .. flag)
    Connections["keybind_widget_capture_" .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        local key_name = nil
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
            self._choosing_keybind = false
            self:update_keybind_entry(flag)
            Connections:disconnect("keybind_widget_capture_" .. flag)
            return
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Unknown then
                return
            end
            if input.KeyCode ~= Enum.KeyCode.Backspace then
                key_name = self:set_keybind(flag, input.KeyCode)
            else
                self:clear_keybind(flag)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
            self:clear_keybind(flag)
        else
            return
        end
        Config:save(game.GameId, self._config)
        if entry.on_changed then
            entry.on_changed(key_name)
        end
        self._choosing_keybind = false
        self:update_keybind_entry(flag)
        Connections:disconnect("keybind_widget_capture_" .. flag)
    end)
end
function Library:register_keybind_entry(flag: any, title: string, get_state: any, on_changed: any, action: boolean)
    if not flag or not self._keybinds_widget then
        return
    end
    self._keybind_entries = self._keybind_entries or {}
    if self._keybind_entries[flag] then
        self._keybind_entries[flag].title = title
        self._keybind_entries[flag].get_state = get_state
        self._keybind_entries[flag].on_changed = on_changed
        self._keybind_entries[flag].action = action
        self:update_keybind_entry(flag)
        return
    end
    local entry = Instance.new("Frame")
    entry.Name = "KB_" .. tostring(flag)
    entry.Size = UDim2.new(1, 0, 0, 20)
    entry.BackgroundTransparency = 1
    entry.Parent = self._keybinds_widget
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -125, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = title or tostring(flag)
    nameLabel.TextColor3 = Theme.colors.textMuted
    nameLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = entry
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "State"
    stateLabel.Size = UDim2.new(0, 70, 1, 0)
    stateLabel.Position = UDim2.new(1, -70, 0, 0)
    stateLabel.BackgroundTransparency = 1
    stateLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
    stateLabel.TextSize = 12
    stateLabel.TextXAlignment = Enum.TextXAlignment.Right
    stateLabel.Parent = entry
    local bindLabel = Instance.new("TextButton")
    bindLabel.Name = "Bind"
    bindLabel.Size = UDim2.new(0, 50, 1, 0)
    bindLabel.Position = UDim2.new(1, -125, 0, 0)
    bindLabel.BackgroundTransparency = 1
    bindLabel.TextColor3 = Theme.colors.accent
    bindLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
    bindLabel.TextSize = 12
    bindLabel.TextXAlignment = Enum.TextXAlignment.Right
    bindLabel.Parent = entry
    self._keybind_entries[flag] = {
        frame = entry,
        bind = bindLabel,
        state = stateLabel,
        title = title,
        get_state = get_state,
        on_changed = on_changed,
        action = action
    }
    bindLabel.MouseButton1Click:Connect(function()
        self:begin_keybind_widget_capture(flag)
    end)
    self:update_keybind_entry(flag)
end
function Library:create_ui()
    local old_Allusive = CoreGui:FindFirstChild('roni')
    if old_Allusive then
        Debris:AddItem(old_Allusive, 0)
    end
    local protect_gui = protect_gui or protectgui or (syn and syn.protect_gui) or function() end
    local Allusive = Instance.new('ScreenGui')
    Allusive.ResetOnSpawn = false
    Allusive.Name = Util:random_string()
    
    local signature = Instance.new('StringValue')
    signature.Name = 'RoniSignature'
    signature.Parent = Allusive

    Allusive.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if RunService:IsStudio() then
        Allusive.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        protect_gui(Allusive)
        Allusive.Parent = (gethui and gethui()) or CoreGui
        local hooking = hookfunc or hookfunction
        if hooking then
            pcall(function()
                hooking(ContentProvider.PreloadAsync, function(...) return 1 end)
                hooking(ContentProvider.Preload, function(...) return 2 end)
                hooking(ContentProvider.GetAssetFetchStatus, function(...) return 3 end)
            end)
        end
    end
    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.BorderColor3 = Theme.colors.shadow
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = Theme.transparency.window
    Container.BackgroundColor3 = Theme.colors.background
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.Parent = Allusive
    add_corner(Container, Metrics.radius_window)
    add_stroke(Container, Theme.colors.stroke, Theme.transparency.stroke)
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.BorderColor3 = Theme.colors.shadow
    Handler.Size = UDim2.fromOffset(Metrics.window_width, Metrics.window_height)
    Handler.BorderSizePixel = 0
    Handler.BackgroundColor3 = Theme.colors.background
    Handler.Parent = Container
    local Sidebar = Instance.new('Frame')
    Sidebar.Name = 'Sidebar'
    Sidebar.Size = UDim2.fromOffset(Metrics.sidebar_width, Metrics.window_height)
    Sidebar.Position = UDim2.fromOffset(0, 0)
    Sidebar.BackgroundColor3 = Theme.colors.sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Handler
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.fromOffset(Metrics.tab_width, Metrics.window_height - 72)
    Tabs.Selectable = false
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.fromOffset(10, 58)
    Tabs.BorderColor3 = Theme.colors.shadow
    Tabs.BackgroundColor3 = Theme.colors.sidebar
    Tabs.BorderSizePixel = 0
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Tabs.Parent = Handler
    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Tabs
    local ClientName = Instance.new('TextLabel')
    ClientName.FontFace = Theme.font(Enum.FontWeight.SemiBold)
    ClientName.TextColor3 = Theme.colors.text
    ClientName.TextTransparency = 0
    ClientName.Text = Theme.brand
    ClientName.Name = 'ClientName'
    ClientName.Size = UDim2.fromOffset(82, 16)
    ClientName.AnchorPoint = Vector2.new(0, 0.5)
    ClientName.Position = UDim2.fromOffset(34, 22)
    ClientName.BackgroundTransparency = 1
    ClientName.TextXAlignment = Enum.TextXAlignment.Left
    ClientName.BorderSizePixel = 0
    ClientName.BorderColor3 = Theme.colors.shadow
    ClientName.TextSize = 12
    ClientName.BackgroundColor3 = Theme.colors.accent
    ClientName.Parent = Handler
    local Pin = Instance.new('Frame')
    Pin.Name = 'Pin'
    Pin.Position = UDim2.fromOffset(10, 66)
    Pin.BorderColor3 = Theme.colors.shadow
    Pin.Size = UDim2.fromOffset(2, 16)
    Pin.BorderSizePixel = 0
    Pin.BackgroundColor3 = Theme.colors.accent
    Pin.Parent = Handler
    add_corner(Pin, Metrics.radius_pill)
    local Icon = Instance.new('ImageLabel')
    Icon.ImageColor3 = Theme.colors.accent
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.BorderColor3 = Theme.colors.shadow
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Image = Theme.icon
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.fromOffset(16, 22)
    Icon.Name = 'Icon'
    Icon.Size = UDim2.fromOffset(14, 14)
    Icon.BorderSizePixel = 0
    Icon.BackgroundColor3 = Theme.colors.accent
    Icon.Parent = Handler
    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0
    Divider.Position = UDim2.fromOffset(Metrics.sidebar_width, 0)
    Divider.BorderColor3 = Theme.colors.shadow
    Divider.Size = UDim2.fromOffset(1, Metrics.window_height)
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 = Theme.colors.divider
    Divider.Parent = Handler
    local Sections = Instance.new('Folder')
    Sections.Name = 'Sections'
    Sections.Parent = Handler
    local Minimize = Instance.new('TextButton')
    Minimize.FontFace = Theme.font(Enum.FontWeight.Regular)
    Minimize.TextColor3 = Theme.colors.shadow
    Minimize.BorderColor3 = Theme.colors.shadow
    Minimize.Text = ''
    Minimize.AutoButtonColor = true
    Minimize.Name = 'Minimize'
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.fromOffset(6, 8)
    Minimize.Size = UDim2.fromOffset(22, 22)
    Minimize.BorderSizePixel = 0
    Minimize.TextSize = 14
    Minimize.BackgroundColor3 = Theme.colors.accent
    Minimize.Parent = Handler
    local UIScale = Instance.new('UIScale')
    UIScale.Parent = Container
    self._container_uiscale = UIScale
    self._ui = Allusive
    local active_drag_input = nil
    local function on_drag(input: InputObject, process: boolean)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not self._dragging then 
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position
            active_drag_input = input
            if Connections['container_input_ended'] then Connections['container_input_ended']:Disconnect() end
            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then
                    return
                end
                if Connections['container_input_ended'] then
                    Connections['container_input_ended']:Disconnect()
                    Connections['container_input_ended'] = nil
                end
                self._dragging = false
                active_drag_input = nil
            end)
        end
    end
    local function update_drag(input: any)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)
        Container.Position = position
    end
    local function drag(input: InputObject, process: boolean)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch and input ~= active_drag_input then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
    end
    Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)
    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)
    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = Theme.transparency.window;
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(a);
            end);
        end;
    end;
    function self:UIVisiblity()
        Allusive.Enabled = not Allusive.Enabled;
    end;
    function self:change_visiblity(state: boolean)
        if state then
            TweenService:Create(Container, Motion.open, {
                Size = UDim2.fromOffset(Metrics.window_width, Metrics.window_height)
            }):Play()
        else
            TweenService:Create(Container, Motion.open, {
                Size = UDim2.fromOffset(Metrics.minimized_width, Metrics.minimized_height)
            }):Play()
        end
    end
    function self:load()
        local content = {}
        for _, object in Allusive:GetDescendants() do
            if not object:IsA('ImageLabel') then
                continue
            end
            table.insert(content, object)
        end
        task.spawn(function()
            pcall(function() ContentProvider:PreloadAsync(content) end)
        end)
        self:get_device()
        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            self:apply_mobile_scale()
            Connections['ui_scale'] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                self:apply_mobile_scale()
            end)
        end
        TweenService:Create(Container, Motion.open, {
            Size = UDim2.fromOffset(Metrics.window_width, Metrics.window_height)
        }):Play()
        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end
    function self:update_tabs(tab: TextButton)
        for index, object in Tabs:GetChildren() do
            if object.Name ~= 'Tab' then
                continue
            end
            if object == tab then
                if object.BackgroundTransparency ~= 0 then
                    local offset = object.LayoutOrder * (Metrics.tab_height + 4)
                    TweenService:Create(Pin, Motion.hover, {
                        Position = UDim2.fromOffset(10, 66 + offset)
                    }):Play()    
                    TweenService:Create(object, Motion.hover, {
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Theme.colors.surfaceRaised
                    }):Play()
                    TweenService:Create(object.TextLabel, Motion.hover, {
                        TextTransparency = 0,
                        TextColor3 = Theme.colors.text
                    }):Play()
                    TweenService:Create(object.Icon, Motion.hover, {
                        ImageTransparency = 0.15,
                        ImageColor3 = Theme.colors.text
                    }):Play()
                end
                continue
            end
            if object.BackgroundTransparency ~= 1 then
                TweenService:Create(object, Motion.hover, {
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(object.TextLabel, Motion.hover, {
                    TextTransparency = Theme.transparency.disabled,
                    TextColor3 = Theme.colors.textMuted
                }):Play()
                TweenService:Create(object.Icon, Motion.hover, {
                    ImageTransparency = 0.65,
                    ImageColor3 = Theme.colors.textMuted
                }):Play()
            end
        end
    end
    function self:update_sections(left_section: ScrollingFrame, right_section: ScrollingFrame)
        for _, object in Sections:GetChildren() do
            if object == left_section or object == right_section then
                object.Visible = true
                continue
            end
            object.Visible = false
        end
    end
    function self:create_tab(title: string, icon: string)
        title = title or "Tab"
        icon = icon or Theme.icon
        local TabManager = {}
        local LayoutOrder = 0;
        local font_params = Instance.new('GetTextBoundsParams')
        font_params.Text = title
        font_params.Font = Theme.font(Enum.FontWeight.SemiBold)
        font_params.Size = 13
        font_params.Width = 10000
        local font_size = Vector2.new(#title * 8, 13)
        pcall(function()
            font_size = TextService:GetTextBoundsAsync(font_params)
        end)
        local first_tab = not Tabs:FindFirstChild('Tab')
        local Tab = Instance.new('TextButton')
        Tab.FontFace = Theme.font(Enum.FontWeight.Regular)
        Tab.TextColor3 = Theme.colors.shadow
        Tab.BorderColor3 = Theme.colors.shadow
        Tab.Text = ''
        Tab.AutoButtonColor = true
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.fromOffset(Metrics.tab_width, Metrics.tab_height)
        Tab.BorderSizePixel = 0
        Tab.TextSize = 14
        Tab.BackgroundColor3 = Theme.colors.surface
        Tab.Parent = Tabs
        Tab.LayoutOrder = self._tab
        add_corner(Tab, Metrics.radius_panel)
        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
        TextLabel.TextColor3 = Theme.colors.textMuted
        TextLabel.TextTransparency = Theme.transparency.disabled
        TextLabel.Text = title
        TextLabel.Size = UDim2.fromOffset(math.min(font_size.X, Metrics.tab_width - 34), 16)
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.Position = UDim2.new(0, 28, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BorderSizePixel = 0
        TextLabel.BorderColor3 = Theme.colors.shadow
        TextLabel.TextSize = 12
        TextLabel.BackgroundColor3 = Theme.colors.accent
        TextLabel.Parent = Tab
        local Icon = Instance.new('ImageLabel')
        Icon.ScaleType = Enum.ScaleType.Fit
        Icon.ImageTransparency = 0.65
        Icon.BorderColor3 = Theme.colors.shadow
        Icon.AnchorPoint = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 10, 0.5, 0)
        Icon.Name = 'Icon'
        Icon.Image = icon
        Icon.Size = UDim2.fromOffset(12, 12)
        Icon.BorderSizePixel = 0
        Icon.BackgroundColor3 = Theme.colors.accent
        Icon.Parent = Tab
        local LeftSection = Instance.new('ScrollingFrame')
        LeftSection.Name = 'LeftSection'
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.fromOffset(Metrics.section_width, Metrics.section_height)
        LeftSection.Selectable = false
        LeftSection.AnchorPoint = Vector2.new(0, 0)
        LeftSection.ScrollBarImageTransparency = 1
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.fromOffset(Metrics.sidebar_width + 18, 22)
        LeftSection.BorderColor3 = Theme.colors.shadow
        LeftSection.BackgroundColor3 = Theme.colors.background
        LeftSection.BorderSizePixel = 0
        LeftSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSection.Visible = false
        LeftSection.Parent = Sections
        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 12)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = LeftSection
        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 0)
        UIPadding.Parent = LeftSection
        local RightSection = Instance.new('ScrollingFrame')
        RightSection.Name = 'RightSection'
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.fromOffset(Metrics.section_width, Metrics.section_height)
        RightSection.Selectable = false
        RightSection.AnchorPoint = Vector2.new(0, 0)
        RightSection.ScrollBarImageTransparency = 1
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.fromOffset(Metrics.sidebar_width + 18 + Metrics.section_width + 16, 22)
        RightSection.BorderColor3 = Theme.colors.shadow
        RightSection.BackgroundColor3 = Theme.colors.background
        RightSection.BorderSizePixel = 0
        RightSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSection.Visible = false
        RightSection.Parent = Sections
        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 12)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = RightSection
        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 0)
        UIPadding.Parent = RightSection
        self._tab += 1
        if first_tab then
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end
        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end)
        function TabManager:create_module(settings: any)
            settings = settings or {}
            normalize_flag(settings, "module_" .. tostring(LayoutOrder))
            if Library._config._flags[settings.flag] == nil and settings.default ~= nil then
                Library._config._flags[settings.flag] = settings.default == true
            end
            local LayoutOrderModule = 0;
            local ModuleManager = {
                _state = false,
                _size = 0,
                _multiplier = 0
            }
            if settings.section == 'right' then
                settings.section = RightSection
            else
                settings.section = LeftSection
            end
            local Module = Instance.new('Frame')
            Module.ClipsDescendants = true
            Module.BorderColor3 = Theme.colors.shadow
            Module.BackgroundTransparency = Theme.transparency.panel
            Module.Position = UDim2.fromOffset(0, 0)
            Module.Name = 'Module'
            Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height)
            Module.BorderSizePixel = 0
            Module.BackgroundColor3 = Theme.colors.surface
            Module.Parent = settings.section
            Module.LayoutOrder = LayoutOrder
            LayoutOrder += 1
            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Module
            add_corner(Module, Metrics.radius_panel)
            local ModuleStroke = add_stroke(Module, Theme.colors.stroke, Theme.transparency.stroke)
            local Header = Instance.new('TextButton')
            Header.FontFace = Theme.font(Enum.FontWeight.Regular)
            Header.TextColor3 = Theme.colors.shadow
            Header.BorderColor3 = Theme.colors.shadow
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height)
            Header.BorderSizePixel = 0
            Header.TextSize = 14
            Header.BackgroundColor3 = Theme.colors.surface
            Header.Parent = Module
            local Icon = Instance.new('ImageLabel')
            Icon.ImageColor3 = Theme.colors.textMuted
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.ImageTransparency = 0.25
            Icon.BorderColor3 = Theme.colors.shadow
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.Image = settings.icon or Theme.icon
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.fromOffset(14, Metrics.module_header_height - 19)
            Icon.Name = 'Icon'
            Icon.Size = UDim2.fromOffset(14, 14)
            Icon.BorderSizePixel = 0
            Icon.BackgroundColor3 = Theme.colors.accent
            Icon.Parent = Header
            local ModuleName = Instance.new('TextLabel')
            ModuleName.FontFace = Theme.font(Enum.FontWeight.SemiBold)
            ModuleName.TextColor3 = Theme.colors.text
            ModuleName.TextTransparency = 0
            if not settings.rich then
                ModuleName.Text = settings.title or "Module"
            else
                ModuleName.RichText = true
                ModuleName.Text = settings.richtext or "<font color='rgb(255,0,0)'>Allusive</font> user"
            end;
            ModuleName.Name = 'ModuleName'
            ModuleName.Size = UDim2.fromOffset(Metrics.option_width, 17)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.fromOffset(14, 19)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.BorderSizePixel = 0
            ModuleName.BorderColor3 = Theme.colors.shadow
            ModuleName.TextSize = 13
            ModuleName.BackgroundColor3 = Theme.colors.accent
            ModuleName.Parent = Header
            local Description = Instance.new('TextLabel')
            Description.FontFace = Theme.font(Enum.FontWeight.Medium)
            Description.TextColor3 = Theme.colors.textMuted
            Description.TextTransparency = 0
            Description.Text = settings.description or ""
            Description.Name = 'Description'
            Description.Size = UDim2.fromOffset(Metrics.option_width, 15)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.fromOffset(14, 39)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BorderSizePixel = 0
            Description.BorderColor3 = Theme.colors.shadow
            Description.TextSize = 11
            Description.BackgroundColor3 = Theme.colors.accent
            Description.Parent = Header
            local Toggle = Instance.new('Frame')
            Toggle.Name = 'Toggle'
            Toggle.BackgroundTransparency = 0
            Toggle.Position = UDim2.fromOffset(Metrics.module_width - 48, Metrics.module_header_height - 26)
            Toggle.BorderColor3 = Theme.colors.shadow
            Toggle.Size = UDim2.fromOffset(32, 16)
            Toggle.BorderSizePixel = 0
            Toggle.BackgroundColor3 = Theme.colors.control
            Toggle.Parent = Header
            add_corner(Toggle, Metrics.radius_pill)
            local Circle = Instance.new('Frame')
            Circle.BorderColor3 = Theme.colors.shadow
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0
            Circle.Position = UDim2.new(0, 2, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.fromOffset(12, 12)
            Circle.BorderSizePixel = 0
            Circle.BackgroundColor3 = Theme.colors.textMuted
            Circle.Parent = Toggle
            add_corner(Circle, Metrics.radius_pill)
            local Divider = Instance.new('Frame')
            Divider.BorderColor3 = Theme.colors.shadow
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0
            Divider.Position = UDim2.new(0.5, 0, 1, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.fromOffset(Metrics.module_width - 24, 1)
            Divider.BorderSizePixel = 0
            Divider.BackgroundColor3 = Theme.colors.divider
            Divider.BackgroundTransparency = 0.15
            Divider.Parent = Header
            local Options = Instance.new('Frame')
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.BorderColor3 = Theme.colors.shadow
            Options.Size = UDim2.fromOffset(Metrics.module_width, 8)
            Options.BorderSizePixel = 0
            Options.BackgroundColor3 = Theme.colors.surface
            Options.Parent = Module
            local UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingTop = UDim.new(0, 10)
            UIPadding.Parent = Options
            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.Padding = UDim.new(0, 9)
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Options
            function ModuleManager:change_state(state: boolean)
                self._state = state
                if self._state then
                    TweenService:Create(Module, Motion.expand, {
                        Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                    }):Play()
                    TweenService:Create(Module, Motion.control, {
                        BackgroundColor3 = Theme.colors.surfaceRaised
                    }):Play()
                    TweenService:Create(ModuleStroke, Motion.control, {
                        Color = Theme.colors.accent,
                        Transparency = 0.78
                    }):Play()
                    TweenService:Create(Toggle, Motion.control, {
                        BackgroundColor3 = Theme.colors.accent
                    }):Play()
                    TweenService:Create(Circle, Motion.control, {
                        BackgroundColor3 = Theme.colors.background,
                        Position = UDim2.new(1, -14, 0.5, 0)
                    }):Play()
                else
                    TweenService:Create(Module, Motion.expand, {
                        Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height)
                    }):Play()
                    TweenService:Create(Module, Motion.control, {
                        BackgroundColor3 = Theme.colors.surface
                    }):Play()
                    TweenService:Create(ModuleStroke, Motion.control, {
                        Color = Theme.colors.stroke,
                        Transparency = Theme.transparency.stroke
                    }):Play()
                    TweenService:Create(Toggle, Motion.control, {
                        BackgroundColor3 = Theme.colors.control
                    }):Play()
                    TweenService:Create(Circle, Motion.control, {
                        BackgroundColor3 = Theme.colors.textMuted,
                        Position = UDim2.new(0, 2, 0.5, 0)
                    }):Play()
                end
                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)
                if settings.callback then
                    settings.callback(self._state)
                end
            end
            Library:register_flag(settings.flag, 'boolean')
            if Library:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = Library._config._flags[settings.flag]
                if settings.callback then
                    settings.callback(ModuleManager._state)
                end
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + ModuleManager._size + ModuleManager._multiplier)
                    Toggle.BackgroundColor3 = Theme.colors.accent
                    Module.BackgroundColor3 = Theme.colors.surfaceRaised
                    ModuleStroke.Color = Theme.colors.accent
                    ModuleStroke.Transparency = 0.78
                    Circle.BackgroundColor3 = Theme.colors.background
                    Circle.Position = UDim2.new(1, -14, 0.5, 0)
                else
                    Module.BackgroundColor3 = Theme.colors.surface
                    ModuleStroke.Color = Theme.colors.stroke
                    ModuleStroke.Transparency = Theme.transparency.stroke
                    Toggle.BackgroundColor3 = Theme.colors.control
                    Circle.BackgroundColor3 = Theme.colors.textMuted
                    Circle.Position = UDim2.new(0, 2, 0.5, 0)
                end
            end
            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)
            Header.MouseEnter:Connect(function()
                TweenService:Create(Module, Motion.hover, {
                    BackgroundColor3 = Theme.colors.surfaceHover
                }):Play()
                TweenService:Create(ModuleStroke, Motion.hover, {
                    Transparency = ModuleManager._state and 0.72 or 0.42
                }):Play()
            end)
            Header.MouseLeave:Connect(function()
                TweenService:Create(Module, Motion.hover, {
                    BackgroundColor3 = ModuleManager._state and Theme.colors.surfaceRaised or Theme.colors.surface
                }):Play()
                TweenService:Create(ModuleStroke, Motion.hover, {
                    Transparency = ModuleManager._state and 0.78 or Theme.transparency.stroke
                }):Play()
            end)
            function ModuleManager:create_paragraph(settings: any)
                settings = settings or {}
                LayoutOrderModule = LayoutOrderModule + 1;
                local ParagraphManager = {}
                if self._size == 0 then
                    self._size = 11
                end
                self._size += settings.customScale or 70
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local Paragraph = Instance.new('Frame')
                Paragraph.BackgroundColor3 = Theme.colors.surfaceRaised
                Paragraph.BackgroundTransparency = 0
                Paragraph.Size = UDim2.new(0, Metrics.option_width, 0, 30) 
                Paragraph.BorderSizePixel = 0
                Paragraph.Name = "Paragraph"
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y 
                Paragraph.Parent = Options
                Paragraph.LayoutOrder = LayoutOrderModule;
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Paragraph
                add_stroke(Paragraph, Theme.colors.stroke, 0.72)
                local Title = Instance.new('TextLabel')
                Title.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                Title.TextColor3 = Theme.colors.text
                Title.Text = settings.title or "Title"
                Title.Size = UDim2.new(1, -16, 0, 20)
                Title.Position = UDim2.new(0, 8, 0, 6)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = 13
                Title.AutomaticSize = Enum.AutomaticSize.Y
                Title.Parent = Paragraph
                local Body = Instance.new('TextLabel')
                Body.FontFace = Theme.font(Enum.FontWeight.Regular)
                Body.TextColor3 = Theme.colors.textMuted
                if not settings.rich then
                    Body.Text = settings.text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>Allusive</font> user"
                end
                Body.Size = UDim2.new(1, -16, 0, 20)
                Body.Position = UDim2.new(0, 8, 0, 31)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.Y
                Body.Parent = Paragraph
                Paragraph.MouseEnter:Connect(function()
                    TweenService:Create(Paragraph, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceHover
                    }):Play()
                end)
                Paragraph.MouseLeave:Connect(function()
                    TweenService:Create(Paragraph, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceRaised
                    }):Play()
                end)
                return ParagraphManager
            end
            function ModuleManager:create_text(settings: any)
                settings = settings or {}
                LayoutOrderModule = LayoutOrderModule + 1
                local TextManager = {}
                if self._size == 0 then
                    self._size = 11
                end
                self._size += settings.customScale or 50 
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local TextFrame = Instance.new('Frame')
                TextFrame.BackgroundColor3 = Theme.colors.surfaceRaised
                TextFrame.BackgroundTransparency = 0
                TextFrame.Size = UDim2.new(0, Metrics.option_width, 0, settings.CustomYSize) 
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y 
                TextFrame.Parent = Options
                TextFrame.LayoutOrder = LayoutOrderModule
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = TextFrame
                add_stroke(TextFrame, Theme.colors.stroke, 0.72)
                local Body = Instance.new('TextLabel')
                Body.FontFace = Theme.font(Enum.FontWeight.Regular)
                Body.TextColor3 = Theme.colors.textMuted
                if not settings.rich then
                    Body.Text = settings.text or "Skibidi" 
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>Allusive</font> user" 
                end
                Body.Size = UDim2.new(1, -16, 0, 0)
                Body.Position = UDim2.new(0, 8, 0, 7)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.Y
                Body.Parent = TextFrame
                TextFrame.MouseEnter:Connect(function()
                    TweenService:Create(TextFrame, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceHover
                    }):Play()
                end)
                TextFrame.MouseLeave:Connect(function()
                    TweenService:Create(TextFrame, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceRaised
                    }):Play()
                end)
                function TextManager:Set(new_settings)
                    if not new_settings.rich then
                        Body.Text = new_settings.text or "Skibidi" 
                    else
                        Body.RichText = true
                        Body.Text = new_settings.richtext or "<font color='rgb(255,0,0)'>Allusive</font> user" 
                    end
                end;
                return TextManager
            end
            function ModuleManager:create_textbox(settings: any)
                settings = settings or {}
                normalize_flag(settings, "textbox_" .. tostring(LayoutOrderModule + 1))
                LayoutOrderModule = LayoutOrderModule + 1
                local TextboxManager = {
                    _text = ""
                }
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 48
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                if Library._config._flags[settings.flag] == nil and settings.default ~= nil then
                    Library._config._flags[settings.flag] = tostring(settings.default)
                end
                local Label = Instance.new('TextLabel')
                Label.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                Label.TextColor3 = Theme.colors.text
                Label.TextTransparency = 0
                Label.Text = settings.title or "Enter text"
                Label.Size = UDim2.new(0, Metrics.option_width, 0, 14)
                Label.AnchorPoint = Vector2.new(0, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BorderSizePixel = 0
                Label.Parent = Options
                Label.TextSize = 11;
                Label.LayoutOrder = LayoutOrderModule
                local Textbox = Instance.new('TextBox')
                Textbox.FontFace = Theme.font(Enum.FontWeight.Regular)
                Textbox.TextColor3 = Theme.colors.text
                Textbox.BorderColor3 = Theme.colors.shadow
                Textbox.PlaceholderText = settings.placeholder or "Enter text..."
                Textbox.Text = Library._config._flags[settings.flag] or ""
                Textbox.Name = 'Textbox'
                Textbox.Size = UDim2.new(0, Metrics.option_width, 0, 24)
                Textbox.BorderSizePixel = 0
                Textbox.TextSize = 11
                Textbox.BackgroundColor3 = Theme.colors.surfaceRaised
                Textbox.BackgroundTransparency = 0
                Textbox.ClearTextOnFocus = false
                Textbox.Parent = Options
                Textbox.LayoutOrder = LayoutOrderModule
                add_corner(Textbox, Metrics.radius_control)
                add_stroke(Textbox, Theme.colors.stroke, Theme.transparency.stroke)
                function TextboxManager:update_text(text: string)
                    self._text = text
                    Library._config._flags[settings.flag] = self._text
                    Config:save(game.GameId, Library._config)
                    if settings.callback then
                        settings.callback(self._text)
                    end
                end
                Library:register_flag(settings.flag, 'string')
                if Library:flag_type(settings.flag, 'string') then
                    TextboxManager:update_text(Library._config._flags[settings.flag])
                end
                Textbox.FocusLost:Connect(function()
                    if Textbox.Text ~= TextboxManager._text then
                        TextboxManager:update_text(Textbox.Text)
                    end
                end)
                return TextboxManager
            end   
            function ModuleManager:create_checkbox(settings: any)
                settings = settings or {}
                normalize_flag(settings, "checkbox_" .. tostring(LayoutOrderModule + 1))
                if Library._config._flags[settings.flag] == nil and settings.default ~= nil then
                    Library._config._flags[settings.flag] = settings.default == true
                end
                LayoutOrderModule = LayoutOrderModule + 1
                local CheckboxManager = { _state = false }
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 24
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local Checkbox = Instance.new("TextButton")
                Checkbox.FontFace = Theme.font(Enum.FontWeight.Regular)
                Checkbox.TextColor3 = Theme.colors.shadow
                Checkbox.BorderColor3 = Theme.colors.shadow
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = true
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, Metrics.option_width, 0, 20)
                Checkbox.BorderSizePixel = 0
                Checkbox.TextSize = 14
                Checkbox.BackgroundColor3 = Theme.colors.shadow
                Checkbox.Parent = Options
                Checkbox.LayoutOrder = LayoutOrderModule
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "TitleLabel"
                if SelectedLanguage == "th" then
                    TitleLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TitleLabel.TextSize = 13
                else
                    TitleLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TitleLabel.TextSize = 12
                end
                TitleLabel.TextColor3 = Theme.colors.text
                TitleLabel.TextTransparency = 0
                TitleLabel.Text = settings.title or "Checkbox"
                TitleLabel.Size = UDim2.new(0, 150, 0, 14)
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Checkbox
                local KeybindBox = Instance.new("Frame")
                KeybindBox.Name = "KeybindBox"
                KeybindBox.Size = UDim2.fromOffset(20, 20)
                KeybindBox.Position = UDim2.new(1, -40, 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(1, 0.5)
                KeybindBox.BackgroundColor3 = Theme.colors.surfaceRaised
                KeybindBox.BorderSizePixel = 0
                KeybindBox.Parent = Checkbox
                KeybindBox.Visible = UserInputService.KeyboardEnabled
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 6)
                KeybindCorner.Parent = KeybindBox
                local KBStroke = Instance.new("UIStroke")
                KBStroke.Color = Theme.colors.stroke
                KBStroke.Transparency = 0.7
                KBStroke.Thickness = 1
                KBStroke.Parent = KeybindBox
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = Theme.colors.textMuted
                KeybindLabel.TextScaled = false
                KeybindLabel.TextSize = 11
                KeybindLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                KeybindLabel.Parent = KeybindBox
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Name = "KeybindButton"
                KeybindButton.Size = UDim2.fromScale(1, 1)
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.Text = ""
                KeybindButton.TextTransparency = 1
                KeybindButton.AutoButtonColor = false
                KeybindButton.ZIndex = KeybindLabel.ZIndex + 1
                KeybindButton.Parent = KeybindBox
                local keybind_hovered = false
                local keybindLabel
                local function resize_keybind_box(text)
                    local label_text = text or "..."
                    local font_params = Instance.new("GetTextBoundsParams")
                    font_params.Text = label_text
                    font_params.Font = KeybindLabel.FontFace
                    font_params.Size = KeybindLabel.TextSize
                    font_params.Width = 10000
                    local success, font_size = pcall(function()
                        return TextService:GetTextBoundsAsync(font_params)
                    end)
                    local width = success and font_size.X or (#label_text * 6)
                    KeybindBox.Size = UDim2.fromOffset(math.max(20, width + 10), 20)
                end
                local function update_keybind_display(key_name)
                    local label_text = key_name or "..."
                    KeybindLabel.Text = label_text
                    resize_keybind_box(label_text)
                    if keybindLabel then
                        keybindLabel.Text = "[ " .. label_text .. " ]"
                        if keybindLabel.Parent then
                            keybindLabel.Parent.Visible = (label_text ~= "..." and label_text ~= "None" and label_text ~= "")
                        end
                    end
                end
                local function begin_checkbox_keybind_capture()
                    if Library._choosing_keybind or not UserInputService.KeyboardEnabled then
                        return
                    end
                    Library._choosing_keybind = true
                    local previous_keybind = Library:get_keybind_name(settings.flag)
                    update_keybind_display(nil)
                    Connections:disconnect("checkbox_keybind_capture_" .. settings.flag)
                    Connections["checkbox_keybind_capture_" .. settings.flag] = UserInputService.InputBegan:Connect(function(keyInput, processed)
                        if processed then
                            return
                        end
                        local keybind_string = nil
                        if keyInput.UserInputType == Enum.UserInputType.Keyboard and keyInput.KeyCode == Enum.KeyCode.Escape then
                            update_keybind_display(previous_keybind)
                            Library._choosing_keybind = false
                            Connections:disconnect("checkbox_keybind_capture_" .. settings.flag)
                            return
                        elseif keyInput.UserInputType == Enum.UserInputType.Keyboard then
                            if keyInput.KeyCode == Enum.KeyCode.Unknown then
                                return
                            end
                            if keyInput.KeyCode ~= Enum.KeyCode.Backspace then
                                keybind_string = Library:set_keybind(settings.flag, keyInput.KeyCode)
                            else
                                Library:clear_keybind(settings.flag)
                            end
                        elseif keyInput.UserInputType == Enum.UserInputType.MouseButton2 or keyInput.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library:clear_keybind(settings.flag)
                        else
                            return
                        end
                        Config:save(game.GameId, Library._config)
                        update_keybind_display(keybind_string)
                        Library._choosing_keybind = false
                        Connections:disconnect("checkbox_keybind_capture_" .. settings.flag)
                    end)
                end
                if not Library:get_keybind_name(settings.flag) and settings.keybind and settings.keybind ~= "Unknown" then
                    Library:set_keybind(settings.flag, settings.keybind)
                end
                update_keybind_display(Library:get_keybind_name(settings.flag))
                KeybindButton.MouseEnter:Connect(function()
                    keybind_hovered = true
                    TweenService:Create(KeybindBox, Motion.hover, {
                        BackgroundColor3 = Theme.colors.control
                    }):Play()
                end)
                KeybindButton.MouseLeave:Connect(function()
                    keybind_hovered = false
                    TweenService:Create(KeybindBox, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceRaised
                    }):Play()
                end)
                KeybindButton.MouseButton1Click:Connect(begin_checkbox_keybind_capture)
                local Box = Instance.new("Frame")
                Box.BorderColor3 = Theme.colors.shadow
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundColor3 = Library._config._flags[settings.flag] and Theme.colors.accent or Theme.colors.control
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Name = "Box"
                Box.Size = UDim2.new(0, 34, 0, 18)
                Box.BorderSizePixel = 0
                Box.Parent = Checkbox
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Box
                local Dot = Instance.new("Frame")
                Dot.Name = "Dot"
                Dot.Size = UDim2.new(0, 14, 0, 14)
                Dot.Position = Library._config._flags[settings.flag] and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                Dot.AnchorPoint = Vector2.new(0, 0.5)
                Dot.BackgroundColor3 = Library._config._flags[settings.flag] and Theme.colors.background or Theme.colors.textMuted
                Dot.BorderSizePixel = 0
                Dot.Parent = Box
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = Dot
                function CheckboxManager:change_state(state: boolean)
                    self._state = state
                    TweenService:Create(Box, Motion.control, {
                        BackgroundColor3 = state and Theme.colors.accent or Theme.colors.control
                    }):Play()
                    TweenService:Create(Dot, Motion.control, {
                        Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = state and Theme.colors.background or Theme.colors.textMuted
                    }):Play()
                    if Library._keybinds_widget then
                        local entry = Library._keybinds_widget:FindFirstChild("KB_" .. settings.flag)
                        if entry and entry:FindFirstChild("State") then
                            entry.State.Text = state and "[ Enabled ]" or "[ Disabled ]"
                            entry.State.TextColor3 = state and Theme.colors.accent or Theme.colors.textDim
                        end
                    end
                    Library._config._flags[settings.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    if settings.callback then settings.callback(self._state) end
                end
                if Library._keybinds_widget and settings.flag then
                    local old_entry = Library._keybinds_widget:FindFirstChild("KB_" .. settings.flag)
                    if old_entry then
                        old_entry:Destroy()
                    end
                    local entry = Instance.new("Frame")
                    entry.Name = "KB_" .. settings.flag
                    entry.Size = UDim2.new(1, 0, 0, 20)
                    entry.BackgroundTransparency = 1
                    entry.Parent = Library._keybinds_widget
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, -125, 1, 0)
                    nameLabel.Position = UDim2.new(0, 0, 0, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = settings.title or "Checkbox"
                    nameLabel.TextColor3 = Theme.colors.textMuted
                    nameLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
                    nameLabel.TextSize = 12
                    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    nameLabel.Parent = entry
                    local stateLabel = Instance.new("TextLabel")
                    stateLabel.Name = "State"
                    stateLabel.Size = UDim2.new(0, 70, 1, 0)
                    stateLabel.Position = UDim2.new(1, -70, 0, 0)
                    stateLabel.BackgroundTransparency = 1
                    stateLabel.Text = Library._config._flags[settings.flag] and "[ Enabled ]" or "[ Disabled ]"
                    stateLabel.TextColor3 = Library._config._flags[settings.flag] and Theme.colors.accent or Theme.colors.textDim
                    stateLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
                    stateLabel.TextSize = 12
                    stateLabel.TextXAlignment = Enum.TextXAlignment.Right
                    stateLabel.Parent = entry
                    keybindLabel = Instance.new("TextButton")
                    keybindLabel.Name = "Bind"
                    keybindLabel.Size = UDim2.new(0, 50, 1, 0)
                    keybindLabel.Position = UDim2.new(1, -125, 0, 0)
                    keybindLabel.BackgroundTransparency = 1
                    keybindLabel.Text = "[ " .. (KeybindLabel.Text) .. " ]"
                    keybindLabel.TextColor3 = Theme.colors.accent
                    keybindLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    keybindLabel.TextSize = 12
                    keybindLabel.TextXAlignment = Enum.TextXAlignment.Right
                    keybindLabel.Parent = entry
                    keybindLabel.MouseButton1Click:Connect(function()
                        if Library._choosing_keybind then
                            return
                        end
                        Library._choosing_keybind = true
                        local previous_keybind = Library:get_keybind_name(settings.flag)
                        update_keybind_display(nil)
                        local inputConn
                        inputConn = UserInputService.InputBegan:Connect(function(input, gp)
                            if gp then
                                return
                            end
                            local newKey = nil
                            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                                update_keybind_display(previous_keybind)
                                Library._choosing_keybind = false
                                inputConn:Disconnect()
                                return
                            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Unknown then
                                    return
                                end
                                if input.KeyCode ~= Enum.KeyCode.Backspace then
                                    newKey = Library:set_keybind(settings.flag, input.KeyCode)
                                else
                                    Library:clear_keybind(settings.flag)
                                end
                                Config:save(game.GameId, Library._config)
                                update_keybind_display(newKey)
                                Library._choosing_keybind = false
                                inputConn:Disconnect()
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                                Library:clear_keybind(settings.flag)
                                Config:save(game.GameId, Library._config)
                                update_keybind_display(nil)
                                Library._choosing_keybind = false
                                inputConn:Disconnect()
                            end
                        end)
                    end)
                end
                Library:register_flag(settings.flag, 'boolean')
                if Library:flag_type(settings.flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.flag])
                end
                Checkbox.MouseButton1Click:Connect(function()
                    if keybind_hovered or Library._choosing_keybind then return end
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)
                Checkbox.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    begin_checkbox_keybind_capture()
                end)
                local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or Library._choosing_keybind or UserInputService:GetFocusedTextBox() then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if Library:keybind_matches(settings.flag, input) then
                            CheckboxManager:change_state(not CheckboxManager._state)
                        end
                    end
                end)
                if Connections[settings.flag .. "_keypress"] then Connections[settings.flag .. "_keypress"]:Disconnect() end
                Connections[settings.flag .. "_keypress"] = keyPressConnection
                return CheckboxManager
            end
            function ModuleManager:create_divider(settings: any)
                settings = settings or {}
                LayoutOrderModule = LayoutOrderModule + 1;
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 30
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local dividerHeight = 1
                local dividerWidth = Metrics.option_width
                local OuterFrame = Instance.new('Frame')
                OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20) 
                OuterFrame.BackgroundTransparency = 1 
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.Parent = Options
                OuterFrame.LayoutOrder = LayoutOrderModule
                if settings and settings.showtopic then
                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TextLabel.TextColor3 = Theme.colors.textMuted 
                    TextLabel.TextTransparency = 0
                    TextLabel.Text = settings.title
                    TextLabel.Size = UDim2.new(0, 153, 0, 13)
                    TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                    TextLabel.BorderSizePixel = 0
                    TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
                    TextLabel.BorderColor3 = Theme.colors.shadow
                    TextLabel.TextSize = 11
                    TextLabel.BackgroundColor3 = Theme.colors.accent
                    TextLabel.ZIndex = 3;
                    TextLabel.TextStrokeTransparency = 1;
                    TextLabel.Parent = OuterFrame
                end;
                if not settings or settings and not settings.disableline then
                    local Divider = Instance.new('Frame')
                    Divider.Size = UDim2.new(1, 0, 0, dividerHeight)
                    Divider.BackgroundColor3 = Theme.colors.divider 
                    Divider.BorderSizePixel = 0
                    Divider.Name = 'Divider'
                    Divider.Parent = OuterFrame
                    Divider.ZIndex = 2;
                    Divider.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2) 
                    add_corner(Divider, 2)
                end;
                return true;
            end
            function ModuleManager:create_slider(settings: any)
                settings = settings or {}
                normalize_flag(settings, "slider_" .. tostring(LayoutOrderModule + 1))
                LayoutOrderModule = LayoutOrderModule + 1
                settings.minimum_value = settings.minimum_value or settings.minimum or settings.min or 0
                settings.maximum_value = settings.maximum_value or settings.maximum or settings.max or 100
                if settings.minimum_value > settings.maximum_value then
                    settings.minimum_value, settings.maximum_value = settings.maximum_value, settings.minimum_value
                end
                if settings.value == nil then
                    settings.value = settings.default
                end
                if settings.value == nil then
                    settings.value = settings.minimum_value
                end
                if settings.round_number == nil and settings.rounding ~= nil then
                    settings.round_number = settings.rounding == 0 or settings.rounding == 1
                end
                local SliderManager = {}
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 32
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local Slider = Instance.new('TextButton')
                Slider.FontFace = Theme.font(Enum.FontWeight.Regular);
                Slider.TextSize = 14;
                Slider.TextColor3 = Theme.colors.shadow
                Slider.BorderColor3 = Theme.colors.shadow
                Slider.Text = ''
                Slider.AutoButtonColor = true
                Slider.BackgroundTransparency = 1
                Slider.Name = 'Slider'
                Slider.Size = UDim2.new(0, Metrics.option_width, 0, 26)
                Slider.BorderSizePixel = 0
                Slider.BackgroundColor3 = Theme.colors.shadow
                Slider.Parent = Options
                Slider.LayoutOrder = LayoutOrderModule
                local TextLabel = Instance.new('TextLabel')
                if GG.SelectedLanguage == "th" then
                    TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TextLabel.TextSize = 13;
                else
                    TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TextLabel.TextSize = 12;
                end;
                TextLabel.TextColor3 = Theme.colors.text
                TextLabel.TextTransparency = 0
                TextLabel.Text = settings.title
                TextLabel.Size = UDim2.new(0, 154, 0, 14)
                TextLabel.Position = UDim2.new(0, 0, 0.05000000074505806, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.BorderSizePixel = 0
                TextLabel.BorderColor3 = Theme.colors.shadow
                TextLabel.BackgroundColor3 = Theme.colors.accent
                TextLabel.Parent = Slider
                local Drag = Instance.new('Frame')
                Drag.BorderColor3 = Theme.colors.shadow
                Drag.AnchorPoint = Vector2.new(0.5, 1)
                Drag.BackgroundTransparency = 0
                Drag.Position = UDim2.new(0.5, 0, 0.949999988079071, 0)
                Drag.Name = 'Drag'
                Drag.Size = UDim2.new(0, Metrics.option_width, 0, 5)
                Drag.BorderSizePixel = 0
                Drag.BackgroundColor3 = Theme.colors.control
                Drag.Parent = Slider
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Drag
                local Fill = Instance.new('Frame')
                Fill.BorderColor3 = Theme.colors.shadow
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundTransparency = 0
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0, 103, 0, 5)
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = Theme.colors.accent
                Fill.Parent = Drag
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 3)
                UICorner.Parent = Fill
                local Circle = Instance.new('Frame')
                Circle.AnchorPoint = Vector2.new(1, 0.5)
                Circle.Name = 'Circle'
                Circle.Position = UDim2.new(1, 0, 0.5, 0)
                Circle.BorderColor3 = Theme.colors.shadow
                Circle.Size = UDim2.new(0, 8, 0, 8)
                Circle.BorderSizePixel = 0
                Circle.BackgroundColor3 = Theme.colors.accent
                Circle.Parent = Fill
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Circle
                local Value = Instance.new('TextLabel')
                Value.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                Value.TextColor3 = Theme.colors.text
                Value.TextTransparency = 0
                Value.Text = '50'
                Value.Name = 'Value'
                Value.Size = UDim2.new(0, 46, 0, 14)
                Value.AnchorPoint = Vector2.new(1, 0)
                Value.Position = UDim2.new(1, 0, 0, 0)
                Value.BackgroundTransparency = 1
                Value.TextXAlignment = Enum.TextXAlignment.Right
                Value.BorderSizePixel = 0
                Value.BorderColor3 = Theme.colors.shadow
                Value.TextSize = 11
                Value.BackgroundColor3 = Theme.colors.accent
                Value.Parent = Slider
                function SliderManager:set_percentage(percentage: number, animate: boolean?)
                    local rounded_number = 0
                    if settings.round_number then
                        rounded_number = math.floor(percentage)
                    else
                        rounded_number = math.floor(percentage * 10) / 10
                    end
                    local value_range = settings.maximum_value - settings.minimum_value
                    percentage = value_range == 0 and 1 or (percentage - settings.minimum_value) / value_range
                    local slider_size = math.clamp(percentage, 0.02, 1) * Drag.Size.X.Offset
                    local number_threshold = math.clamp(rounded_number, settings.minimum_value, settings.maximum_value)
                    Library._config._flags[settings.flag] = number_threshold
                    Value.Text = number_threshold
                    local fill_size = UDim2.fromOffset(slider_size, Drag.Size.Y.Offset)
                    if animate == false then
                        Fill.Size = fill_size
                    else
                        TweenService:Create(Fill, Motion.control, {
                            Size = fill_size
                        }):Play()
                    end
                    if settings.callback then
                        settings.callback(number_threshold)
                    end
                end
                function SliderManager:update(input_position: any)
                    local input_x = input_position and input_position.X or mouse.X
                    local mouse_position = (input_x - Drag.AbsolutePosition.X) / Drag.Size.X.Offset
                    local percentage = settings.minimum_value + (settings.maximum_value - settings.minimum_value) * mouse_position
                    self:set_percentage(percentage, false)
                end
                function SliderManager:input(input: InputObject)
                    SliderManager:update(input and input.Position)
                    Connections:disconnect('slider_drag_'..settings.flag)
                    Connections:disconnect('slider_input_'..settings.flag)
                    Connections['slider_drag_'..settings.flag] = UserInputService.InputChanged:Connect(function(changed_input: InputObject)
                        if changed_input.UserInputType ~= Enum.UserInputType.MouseMovement and changed_input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end
                        SliderManager:update(changed_input.Position)
                    end)
                    Connections['slider_input_'..settings.flag] = UserInputService.InputEnded:Connect(function(input: InputObject, process: boolean)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end
                        Connections:disconnect('slider_drag_'..settings.flag)
                        Connections:disconnect('slider_input_'..settings.flag)
                        if not settings.ignoresaved then
                            Config:save(game.GameId, Library._config);
                        end;
                    end)
                end
                Library:register_flag(settings.flag, 'number')
                if Library:flag_type(settings.flag, 'number') then
                    if not settings.ignoresaved then
                        SliderManager:set_percentage(Library._config._flags[settings.flag]);
                    else
                        SliderManager:set_percentage(settings.value);
                    end;
                else
                    SliderManager:set_percentage(settings.value);
                end;
                Slider.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process then
                        return
                    end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    SliderManager:input(input)
                end)
                return SliderManager
            end
            function ModuleManager:create_dropdown(settings: any)
                settings = settings or {}
                normalize_flag(settings, "dropdown_" .. tostring(LayoutOrderModule + 1))
                if settings.multi_dropdown == nil then
                    settings.multi_dropdown = settings.multi_selection == true or settings.multi == true
                end
                if not settings.Order then
                    LayoutOrderModule = LayoutOrderModule + 1;
                end;
                settings.options = settings.options or {}
                if #settings.options == 0 then
                    settings.options = { "None" }
                end
                settings.maximum_options = settings.maximum_options or #settings.options
                local DropdownManager = {
                    _state = false,
                    _size = 0
                }
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 48
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size + self._multiplier)
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size)
                local Dropdown = Instance.new('TextButton')
                Dropdown.FontFace = Theme.font(Enum.FontWeight.Regular)
                Dropdown.TextColor3 = Theme.colors.shadow
                Dropdown.BorderColor3 = Theme.colors.shadow
                Dropdown.Text = ''
                Dropdown.AutoButtonColor = true
                Dropdown.BackgroundTransparency = 1
                Dropdown.Name = 'Dropdown'
                Dropdown.Size = UDim2.new(0, Metrics.option_width, 0, 42)
                Dropdown.BorderSizePixel = 0
                Dropdown.TextSize = 14
                Dropdown.BackgroundColor3 = Theme.colors.shadow
                Dropdown.Parent = Options
                if not settings.Order then
                    Dropdown.LayoutOrder = LayoutOrderModule;
                else
                    Dropdown.LayoutOrder = settings.OrderValue;
                end;
                if Library._config._flags[settings.flag] == nil then
                    Library._config._flags[settings.flag] = settings.multi_dropdown and {} or (settings.default or settings.options[1])
                end
                local TextLabel = Instance.new('TextLabel')
                if GG.SelectedLanguage == "th" then
                    TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    TextLabel.TextSize = 13;
                else
                    TextLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold);
                    TextLabel.TextSize = 12;
                end;
                TextLabel.TextColor3 = Theme.colors.text
                TextLabel.TextTransparency = 0
                TextLabel.Text = settings.title
                TextLabel.Size = UDim2.new(0, Metrics.option_width, 0, 14)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.BorderSizePixel = 0
                TextLabel.BorderColor3 = Theme.colors.shadow
                TextLabel.BackgroundColor3 = Theme.colors.accent
                TextLabel.Parent = Dropdown
                local Box = Instance.new('Frame')
                Box.ClipsDescendants = true
                Box.BorderColor3 = Theme.colors.shadow
                Box.AnchorPoint = Vector2.new(0.5, 0)
                Box.BackgroundTransparency = 0
                Box.Position = UDim2.new(0.5, 0, 1.25, 0)
                Box.Name = 'Box'
                Box.Size = UDim2.new(0, Metrics.option_width, 0, 24)
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = Theme.colors.surfaceRaised
                Box.Parent = TextLabel
                add_corner(Box, Metrics.radius_control)
                add_stroke(Box, Theme.colors.stroke, Theme.transparency.stroke)
                local Header = Instance.new('Frame')
                Header.BorderColor3 = Theme.colors.shadow
                Header.AnchorPoint = Vector2.new(0.5, 0)
                Header.BackgroundTransparency = 1
                Header.Position = UDim2.new(0.5, 0, 0, 0)
                Header.Name = 'Header'
                Header.Size = UDim2.new(0, Metrics.option_width, 0, 24)
                Header.BorderSizePixel = 0
                Header.BackgroundColor3 = Theme.colors.surfaceRaised
                Header.Parent = Box
                local CurrentOption = Instance.new('TextLabel')
                CurrentOption.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                CurrentOption.TextColor3 = Theme.colors.textMuted
                CurrentOption.TextTransparency = 0
                CurrentOption.Name = 'CurrentOption'
                CurrentOption.Size = UDim2.new(0, Metrics.option_width - 36, 0, 14)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position = UDim2.new(0.04999988153576851, 0, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.BorderSizePixel = 0
                CurrentOption.BorderColor3 = Theme.colors.shadow
                CurrentOption.TextSize = 11
                CurrentOption.BackgroundColor3 = Theme.colors.accent
                CurrentOption.Parent = Header
                local Arrow = Instance.new('ImageLabel')
                Arrow.BorderColor3 = Theme.colors.shadow
                Arrow.AnchorPoint = Vector2.new(0, 0.5)
                Arrow.Image = Theme.arrow
                Arrow.ImageColor3 = Theme.colors.textMuted
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(0.9100000262260437, 0, 0.5, 0)
                Arrow.Name = 'Arrow'
                Arrow.Size = UDim2.new(0, 8, 0, 8)
                Arrow.BorderSizePixel = 0
                Arrow.BackgroundColor3 = Theme.colors.accent
                Arrow.Parent = Header
                local Options = Instance.new('ScrollingFrame')
                Options.ScrollBarImageColor3 = Theme.colors.shadow
                Options.Active = true
                Options.ScrollBarImageTransparency = 1
                Options.AutomaticCanvasSize = Enum.AutomaticSize.XY
                Options.ScrollBarThickness = 0
                Options.Name = 'Options'
                Options.Size = UDim2.new(0, Metrics.option_width, 0, 0)
                Options.BackgroundTransparency = 1
                Options.Position = UDim2.new(0, 0, 1, 0)
                Options.BackgroundColor3 = Theme.colors.surfaceRaised
                Options.BorderColor3 = Theme.colors.shadow
                Options.BorderSizePixel = 0
                Options.CanvasSize = UDim2.new(0, 0, 0.5, 0)
                Options.Parent = Box
                local UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = Options
                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingTop = UDim.new(0, 2)
                UIPadding.PaddingLeft = UDim.new(0, 10)
                UIPadding.Parent = Options
                local UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = Box
                function DropdownManager:update(option: string)
                    if settings.multi_dropdown then
                        if not Library._config._flags[settings.flag] then
                            Library._config._flags[settings.flag] = {};
                        end;
                        local CurrentTargetValue = nil;
                        if #Library._config._flags[settings.flag] > 0 then
                            CurrentTargetValue = convertTableToString(Library._config._flags[settings.flag]);
                        end;
                        local selected = {}
                        if CurrentTargetValue then
                            for value in string.gmatch(CurrentTargetValue, "([^,]+)") do
                                local trimmedValue = value:match("^%s*(.-)%s*$")  
                                if trimmedValue ~= "Label" then
                                    table.insert(selected, trimmedValue)
                                end
                            end
                        else
                            for value in string.gmatch(CurrentOption.Text, "([^,]+)") do
                                local trimmedValue = value:match("^%s*(.-)%s*$")  
                                if trimmedValue ~= "Label" then
                                    table.insert(selected, trimmedValue)
                                end
                            end
                        end;
                        local CurrentTextGet = convertStringToTable(CurrentOption.Text);
                        local optionName = "nil";
                        if typeof(option) ~= 'string' then
                            optionName = option.Name;
                        else
                            optionName = option;
                        end;
                        local found = false
                        for i, v in pairs(CurrentTextGet) do
                            if v == optionName then
                                table.remove(CurrentTextGet, i);
                                break;
                            end
                        end
                        CurrentOption.Text = table.concat(selected, ", ")
                        local OptionsChild = {}
                        for _, object in Options:GetChildren() do
                            if object.Name == "Option" then
                                table.insert(OptionsChild, object.Text)
                                if table.find(selected, object.Text) then
                                    object.TextTransparency = 0.2
                                else
                                    object.TextTransparency = 0.6
                                end
                            end
                        end
                        CurrentTargetValue = convertStringToTable(CurrentOption.Text);
                        for _, v in CurrentTargetValue do
                            if not table.find(OptionsChild, v) and table.find(selected, v) then
                                table.remove(selected, _)
                            end;
                        end;
                        CurrentOption.Text = table.concat(selected, ", ");
                        Library._config._flags[settings.flag] = convertStringToTable(CurrentOption.Text);
                    else
                        CurrentOption.Text = (typeof(option) == "string" and option) or option.Name
                        for _, object in Options:GetChildren() do
                            if object.Name == "Option" then
                                if object.Text == CurrentOption.Text then
                                    object.TextTransparency = 0.2
                                else
                                    object.TextTransparency = 0.6
                                end
                            end
                        end
                        Library._config._flags[settings.flag] = option
                    end
                    Config:save(game.GameId, Library._config)
                    if not settings.multi_dropdown and DropdownManager._state then
                        DropdownManager:unfold_settings()
                    end
                    if settings.callback then
                        if settings.multi_dropdown then
                            settings.callback(Library._config._flags[settings.flag])
                        else
                            settings.callback(option)
                        end
                    end
                end
                local CurrentDropSizeState = 0;
                function DropdownManager:unfold_settings()
                    self._state = not self._state
                    if self._state then
                        ModuleManager._multiplier += self._size
                        CurrentDropSizeState = self._size;
                        TweenService:Create(Module, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()
                        TweenService:Create(Module.Options, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.module_width, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()
                        TweenService:Create(Dropdown, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.option_width, 42 + self._size)
                        }):Play()
                        TweenService:Create(Box, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.option_width, 24 + self._size)
                        }):Play()
                        TweenService:Create(Arrow, Motion.expand, {
                            Rotation = 180
                        }):Play()
                    else
                        ModuleManager._multiplier -= self._size
                        CurrentDropSizeState = 0;
                        TweenService:Create(Module, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()
                        TweenService:Create(Module.Options, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.module_width, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()
                        TweenService:Create(Dropdown, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.option_width, 42)
                        }):Play()
                        TweenService:Create(Box, Motion.expand, {
                            Size = UDim2.fromOffset(Metrics.option_width, 24)
                        }):Play()
                        TweenService:Create(Arrow, Motion.expand, {
                            Rotation = 0
                        }):Play()
                    end
                end
                if #settings.options > 0 then
                    DropdownManager._size = 3
                    for index, value in settings.options do
                        local Option = Instance.new('TextButton')
                        Option.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                        Option.Active = false
                        Option.TextTransparency = 0.6000000238418579
                        Option.AnchorPoint = Vector2.new(0, 0.5)
                        Option.TextSize = 11
                        Option.Size = UDim2.new(0, Metrics.option_width - 20, 0, 18)
                        Option.TextColor3 = Theme.colors.textMuted
                        Option.BorderColor3 = Theme.colors.shadow
                        Option.Text = (typeof(value) == "string" and value) or value.Name;
                        Option.AutoButtonColor = true
                        Option.Name = 'Option'
                        Option.BackgroundTransparency = 1
                        Option.TextXAlignment = Enum.TextXAlignment.Left
                        Option.Selectable = false
                        Option.Position = UDim2.new(0.04999988153576851, 0, 0.34210526943206787, 0)
                        Option.BorderSizePixel = 0
                        Option.BackgroundColor3 = Theme.colors.accent
                        Option.Parent = Options
                        Option.MouseButton1Click:Connect(function()
                            if not Library._config._flags[settings.flag] then
                                Library._config._flags[settings.flag] = {};
                            end;
                            if settings.multi_dropdown then
                                if table.find(Library._config._flags[settings.flag], value) then
                                    Library:remove_table_value(Library._config._flags[settings.flag], value)
                                else
                                    table.insert(Library._config._flags[settings.flag], value)
                                end
                            end
                            DropdownManager:update(value)
                        end)
                        if index > settings.maximum_options then
                            continue
                        end
                        DropdownManager._size += 18
                        Options.Size = UDim2.fromOffset(Metrics.option_width, DropdownManager._size)
                    end
                end
                function DropdownManager:New(value)
                    Dropdown:Destroy();
                    value.OrderValue = Dropdown.LayoutOrder
                    ModuleManager._multiplier -= CurrentDropSizeState
                    return ModuleManager:create_dropdown(value)
                end;
                Library:register_flag(settings.flag, settings.multi_dropdown and 'table' or 'string')
                if Library:flag_type(settings.flag, 'string') then
                    DropdownManager:update(Library._config._flags[settings.flag])
                elseif Library:flag_type(settings.flag, 'table') then
                    DropdownManager:update("load")
                else
                    DropdownManager:update(settings.options[1])
                end
                Dropdown.MouseButton1Click:Connect(function()
                    DropdownManager:unfold_settings()
                end)
                return DropdownManager
            end
            function ModuleManager:create_feature(settings)
                settings = settings or {}
                normalize_flag(settings, "feature_" .. tostring(LayoutOrderModule + 1))
                local checked = false;
                LayoutOrderModule = LayoutOrderModule + 1
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 28
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(Metrics.module_width, Metrics.module_header_height + self._size);
                end
                Options.Size = UDim2.fromOffset(Metrics.module_width, self._size);
                Library._config._flags = Library._config._flags or {}
                Library._config._keybinds = Library._config._keybinds or {}
                local saved_feature = Library._config._flags[settings.flag]
                if typeof(saved_feature) == "table" then
                    checked = saved_feature.checked == true
                    if not Library:get_keybind_name(settings.flag) and saved_feature.BIND and saved_feature.BIND ~= "Unknown" then
                        Library:set_keybind(settings.flag, saved_feature.BIND)
                    end
                elseif typeof(saved_feature) == "boolean" then
                    checked = saved_feature
                else
                    checked = settings.default == true
                end
                Library._config._flags[settings.flag] = checked
                Library:register_flag(settings.flag, 'boolean')
                if not Library:get_keybind_name(settings.flag) and settings.keybind and settings.keybind ~= "Unknown" then
                    Library:set_keybind(settings.flag, settings.keybind)
                end
                local FeatureContainer = Instance.new("Frame")
                FeatureContainer.Size = UDim2.new(0, Metrics.option_width, 0, 26)
                FeatureContainer.BackgroundTransparency = 1
                FeatureContainer.Parent = Options
                FeatureContainer.LayoutOrder = LayoutOrderModule
                local UIListLayout = Instance.new("UIListLayout")
                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                UIListLayout.Padding = UDim.new(0, 6)
                UIListLayout.Parent = FeatureContainer
                local FeatureButton = Instance.new("TextButton")
                FeatureButton.FontFace = Theme.font(Enum.FontWeight.SemiBold);
                FeatureButton.TextSize = 12;
                FeatureButton.Size = UDim2.new(1, -96, 0, 20)
                FeatureButton.BackgroundColor3 = Theme.colors.surface
                FeatureButton.TextColor3 = Theme.colors.text
                FeatureButton.Text = "    " .. (settings.title or "Feature")
                FeatureButton.AutoButtonColor = true
                FeatureButton.TextXAlignment = Enum.TextXAlignment.Left
                FeatureButton.TextTransparency = 0
                FeatureButton.ClipsDescendants = true
                FeatureButton.Parent = FeatureContainer
                add_corner(FeatureButton, Metrics.radius_control)
                add_stroke(FeatureButton, Theme.colors.stroke, Theme.transparency.stroke)
                local RightContainer = Instance.new("Frame")
                RightContainer.Size = UDim2.new(0, 92, 0, 26)
                RightContainer.BackgroundTransparency = 1
                RightContainer.Parent = FeatureContainer
                local RightLayout = Instance.new("UIListLayout")
                RightLayout.Padding = UDim.new(0, 6)
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
                RightLayout.Parent = RightContainer
                local KeybindBox = Instance.new("TextLabel")
                KeybindBox.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                KeybindBox.Size = UDim2.new(0, 20, 0, 20)
                KeybindBox.BackgroundColor3 = Theme.colors.surfaceRaised
                KeybindBox.TextColor3 = Theme.colors.textMuted
                KeybindBox.TextSize = 11
                KeybindBox.BackgroundTransparency = 0
                KeybindBox.LayoutOrder = 1
                KeybindBox.Parent = RightContainer
                KeybindBox.Visible = UserInputService.KeyboardEnabled
                if not UserInputService.KeyboardEnabled then
                    KeybindBox.Size = UDim2.fromOffset(0, 20)
                end
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(1, 0, 1, 0)
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.TextTransparency = 1
                KeybindButton.Parent = KeybindBox
                add_corner(KeybindBox, Metrics.radius_control)
                add_stroke(KeybindBox, Theme.colors.stroke, Theme.transparency.stroke)
                local keybindLabel
                local function resize_keybind_box(text)
                    local label_text = text or "..."
                    local font_params = Instance.new("GetTextBoundsParams")
                    font_params.Text = label_text
                    font_params.Font = KeybindBox.FontFace
                    font_params.Size = KeybindBox.TextSize
                    font_params.Width = 10000
                    local success, font_size = pcall(function()
                        return TextService:GetTextBoundsAsync(font_params)
                    end)
                    local width = success and font_size.X or (#label_text * 6)
                    KeybindBox.Size = UDim2.fromOffset(math.clamp(width + 10, 20, 54), 20)
                end
                local function update_keybind_display(key_name)
                    local label_text = key_name or "..."
                    KeybindBox.Text = label_text
                    resize_keybind_box(label_text)
                    if keybindLabel then
                        keybindLabel.Text = "[ " .. label_text .. " ]"
                        if keybindLabel.Parent then
                            keybindLabel.Parent.Visible = (label_text ~= "..." and label_text ~= "None" and label_text ~= "")
                        end
                    end
                end
                update_keybind_display(Library:get_keybind_name(settings.flag))
                if Library._keybinds_widget and settings.flag then
                    local old_entry = Library._keybinds_widget:FindFirstChild("KB_" .. settings.flag)
                    if old_entry then
                        old_entry:Destroy()
                    end
                    local entry = Instance.new("Frame")
                    entry.Name = "KB_" .. settings.flag
                    entry.Size = UDim2.new(1, 0, 0, 20)
                    entry.BackgroundTransparency = 1
                    entry.Parent = Library._keybinds_widget
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
                    nameLabel.Position = UDim2.new(0, 0, 0, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = settings.title or "Feature"
                    nameLabel.TextColor3 = Theme.colors.textMuted
                    nameLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
                    nameLabel.TextSize = 12
                    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    nameLabel.Parent = entry
                    local stateLabel = Instance.new("TextLabel")
                    stateLabel.Name = "State"
                    stateLabel.Size = UDim2.new(0.5, 0, 1, 0)
                    stateLabel.Position = UDim2.new(0.5, 0, 0, 0)
                    stateLabel.BackgroundTransparency = 1
                    stateLabel.Text = settings.disablecheck and "[ Action ]" or (checked and "[ Enabled ]" or "[ Disabled ]")
                    stateLabel.TextColor3 = checked and Theme.colors.accent or Theme.colors.textDim
                    stateLabel.FontFace = Theme.font(Enum.FontWeight.Medium)
                    stateLabel.TextSize = 12
                    stateLabel.TextXAlignment = Enum.TextXAlignment.Right
                    stateLabel.Parent = entry
                    keybindLabel = Instance.new("TextButton")
                    keybindLabel.Name = "Bind"
                    keybindLabel.Size = UDim2.new(0, 62, 1, 0)
                    keybindLabel.Position = UDim2.new(0.5, -67, 0, 0)
                    keybindLabel.BackgroundTransparency = 1
                    keybindLabel.TextColor3 = Theme.colors.accent
                    keybindLabel.FontFace = Theme.font(Enum.FontWeight.SemiBold)
                    keybindLabel.TextSize = 12
                    keybindLabel.TextXAlignment = Enum.TextXAlignment.Right
                    keybindLabel.Parent = entry
                    update_keybind_display(Library:get_keybind_name(settings.flag))
                end
                local function begin_keybind_capture()
                    if Library._choosing_keybind or not UserInputService.KeyboardEnabled then
                        return
                    end
                    Library._choosing_keybind = true
                    local previous_keybind = Library:get_keybind_name(settings.flag)
                    update_keybind_display(nil)
                    Connections:disconnect("keybind_input_" .. settings.flag)
                    Connections["keybind_input_" .. settings.flag] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then
                            return
                        end
                        local key_name = nil
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                            update_keybind_display(previous_keybind)
                            Library._choosing_keybind = false
                            Connections:disconnect("keybind_input_" .. settings.flag)
                            return
                        elseif input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Unknown then
                                return
                            end
                            if input.KeyCode ~= Enum.KeyCode.Backspace then
                                key_name = Library:set_keybind(settings.flag, input.KeyCode)
                            else
                                Library:clear_keybind(settings.flag)
                            end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library:clear_keybind(settings.flag)
                        else
                            return
                        end
                        Config:save(game.GameId, Library._config)
                        update_keybind_display(key_name)
                        Library._choosing_keybind = false
                        Connections:disconnect("keybind_input_" .. settings.flag)
                    end)
                end
                if keybindLabel then
                    keybindLabel.MouseButton1Click:Connect(begin_keybind_capture)
                end
                local UseF_Var = nil;
                if not settings.disablecheck then
                    local Checkbox = Instance.new("TextButton")
                    Checkbox.Size = UDim2.new(0, 34, 0, 18)
                    Checkbox.BackgroundColor3 = checked and Theme.colors.accent or Theme.colors.control
                    Checkbox.Text = ""
                    Checkbox.Parent = RightContainer
                    Checkbox.LayoutOrder = 2;
                    add_corner(Checkbox, Metrics.radius_pill)
                    local Dot = Instance.new("Frame")
                    Dot.Name = "Dot"
                    Dot.Size = UDim2.new(0, 14, 0, 14)
                    Dot.Position = checked and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    Dot.AnchorPoint = Vector2.new(0, 0.5)
                    Dot.BackgroundColor3 = checked and Theme.colors.background or Theme.colors.textMuted
                    Dot.BorderSizePixel = 0
                    Dot.Parent = Checkbox
                    add_corner(Dot, Metrics.radius_pill)
                    local function toggleState()
                        checked = not checked
                        Library._config._flags[settings.flag] = checked
                        Config:save(game.GameId, Library._config)
                        TweenService:Create(Checkbox, Motion.control, {
                            BackgroundColor3 = checked and Theme.colors.accent or Theme.colors.control
                        }):Play()
                        TweenService:Create(Dot, Motion.control, {
                            Position = checked and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                            BackgroundColor3 = checked and Theme.colors.background or Theme.colors.textMuted
                        }):Play()
                        if Library._keybinds_widget then
                            local entry = Library._keybinds_widget:FindFirstChild("KB_" .. settings.flag)
                            if entry and entry:FindFirstChild("State") then
                                entry.State.Text = checked and "[ Enabled ]" or "[ Disabled ]"
                                entry.State.TextColor3 = checked and Theme.colors.accent or Theme.colors.textDim
                            end
                        end
                        if settings.callback then
                            settings.callback(checked)
                        end
                    end
                    UseF_Var = toggleState
                    Checkbox.MouseButton1Click:Connect(toggleState)
                else
                    UseF_Var = function()
                        if settings.button_callback then
                            settings.button_callback();
                        end
                    end;
                end;
                KeybindButton.MouseButton1Click:Connect(begin_keybind_capture)
                local keyPressConnection
                keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or Library._choosing_keybind or UserInputService:GetFocusedTextBox() then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard and Library:keybind_matches(settings.flag, input) then
                        UseF_Var();
                    end
                end)
                Connections["keybind_press_" .. settings.flag] = keyPressConnection
                FeatureButton.MouseButton1Click:Connect(function()
                    if settings.button_callback then
                        settings.button_callback()
                    end
                end)
                FeatureButton.MouseEnter:Connect(function()
                    TweenService:Create(FeatureButton, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surfaceHover
                    }):Play()
                end)
                FeatureButton.MouseLeave:Connect(function()
                    TweenService:Create(FeatureButton, Motion.hover, {
                        BackgroundColor3 = Theme.colors.surface
                    }):Play()
                end)
                if not settings.disablecheck and settings.callback then
                    settings.callback(checked);
                end;
                return FeatureContainer
            end                    
            return ModuleManager
        end
        return TabManager
    end
    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
        if process then return end
        if input.KeyCode ~= (self._toggle_keybind or Enum.KeyCode.Insert) then
            return
        end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)
    self._ui.Container.Handler.Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)
    if UserInputService.TouchEnabled then
        local MobileToggle = Instance.new("ImageButton")
        MobileToggle.Name = "MobileToggle"
        MobileToggle.Size = UDim2.new(0, 45, 0, 45)
        MobileToggle.BackgroundColor3 = Theme.colors.surface
        MobileToggle.Image = Theme.icon
        MobileToggle.Parent = self._ui
        Library._config._library = Library._config._library or {}
        local savedPos = Library._config._library._mobile_toggle_pos
        MobileToggle.Position = savedPos and UDim2.new(savedPos[1], savedPos[2], savedPos[3], savedPos[4]) or UDim2.new(0, 50, 0, 50)
        add_corner(MobileToggle, Metrics.radius_pill)
        add_stroke(MobileToggle, Theme.colors.stroke, Theme.transparency.stroke)
        local MobileToggleScale = Instance.new("UIScale")
        MobileToggleScale.Parent = MobileToggle
        self._mobile_toggle_uiscale = MobileToggleScale
        local DRAG_THRESHOLD = 6 
        local dragging = false
        local dragMoved = false
        local dragStart, startPos
        local activeInput = nil
        local function clamp_position(pos)
            local viewport = workspace.CurrentCamera.ViewportSize
            local size = MobileToggle.AbsoluteSize
            local margin = 12
            local minX = margin
            local maxX = viewport.X - size.X - margin
            local minY = margin
            local maxY = viewport.Y - size.Y - margin
            local x = math.clamp(pos.X.Offset, minX, math.max(minX, maxX))
            local y = math.clamp(pos.Y.Offset, minY, math.max(minY, maxY))
            return UDim2.new(0, x, 0, y)
        end
        MobileToggle.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
                dragging = true
                dragMoved = false
                dragStart = input.Position
                startPos = MobileToggle.Position
                activeInput = input
                if Connections['mobile_toggle_input_ended'] then Connections['mobile_toggle_input_ended']:Disconnect() end
                Connections['mobile_toggle_input_ended'] = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        activeInput = nil
                        if Connections['mobile_toggle_input_ended'] then
                            Connections['mobile_toggle_input_ended']:Disconnect()
                            Connections['mobile_toggle_input_ended'] = nil
                        end
                        if dragMoved then
                            local clamped = clamp_position(MobileToggle.Position)
                            MobileToggle.Position = clamped
                            Library._config._library._mobile_toggle_pos = {
                                clamped.X.Scale, clamped.X.Offset,
                                clamped.Y.Scale, clamped.Y.Offset
                            }
                            Config:save(game.GameId, Library._config)
                        end
                    end
                end)
            end
        end)
        Connections['mobile_toggle_drag'] = UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.Touch and input ~= activeInput then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                if delta.Magnitude >= DRAG_THRESHOLD then
                    dragMoved = true
                end
                if dragMoved then
                    local next_pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    MobileToggle.Position = clamp_position(next_pos)
                end
            end
        end)
        MobileToggle.MouseButton1Click:Connect(function()
            if dragMoved then
                return
            end
            self._ui_open = not self._ui_open
            self:change_visiblity(self._ui_open)
        end)
    end
    return self
end
return Library
