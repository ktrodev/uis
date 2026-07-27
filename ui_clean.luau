 if getfenv()['AmferRunning'] then return end
getfenv()['AmferRunning'] = true

local __RuntimeEnvironmentOK, __RuntimeEnvironment = pcall(function()
	return getrenv()
end)
if not __RuntimeEnvironmentOK or type(__RuntimeEnvironment) ~= "table" then
	getfenv()["AmferRunning"] = nil
	error("getrenv() did not return a runtime environment")
end
local __RuntimeDebug = type(__RuntimeEnvironment.debug) == "table" and __RuntimeEnvironment.debug or debug
local __RuntimeDebugInfo = __RuntimeDebug.info or debug.info
local __RuntimeGetFenv = __RuntimeEnvironment.getfenv or getfenv
local __RuntimeHookState = getgenv().__RoniRuntimeHooksV2
if type(__RuntimeHookState) ~= "table" then
	__RuntimeHookState = { CleanEnvironment = __RuntimeEnvironment }
	getgenv().__RoniRuntimeHooksV2 = __RuntimeHookState
end
__RuntimeHookState.CleanEnvironment = __RuntimeHookState.CleanEnvironment or __RuntimeEnvironment
local __OriginalDebugInfo = __RuntimeHookState.DebugInfoOriginal or __RuntimeDebugInfo
local __OriginalGetFenv = __RuntimeHookState.GetFenvOriginal or __RuntimeGetFenv
local __RuntimeHooksInstalled = false

local function __InstallRuntimeHooks()
	if __RuntimeHooksInstalled then
		return
	end
	if typeof(hookfunction) ~= "function" or typeof(checkcaller) ~= "function" then
		warn("Roni runtime hooks require hookfunction and checkcaller")
		return
	end

	local __DebugHookInstalled = typeof(__RuntimeHookState.DebugInfoOriginal) == "function"
	if not __DebugHookInstalled and typeof(__RuntimeDebugInfo) == "function" then
		local __InDebugHook = false
		local __DebugHook
		__DebugHook = function(...)
			if __InDebugHook then
				return __OriginalDebugInfo(...)
			end
			__InDebugHook = true

			local args = table.pack(...)
			local isDirectCall = args.n == 2
			local isThreadCall = args.n == 3 and type(args[1]) == "thread"
			local subject = isDirectCall and args[1] or (isThreadCall and args[2] or nil)
			local options = isDirectCall and args[2] or (isThreadCall and args[3] or nil)

			if isDirectCall and type(subject) == "number" and subject >= 1 then
				args[1] = subject + 1
			end

			local success, results = pcall(function()
				return table.pack(__OriginalDebugInfo(table.unpack(args, 1, args.n)))
			end)

			if not success then
				__InDebugHook = false
				error(tostring(results), 2)
			end

			if not checkcaller() then
				local replacementSource
				if isDirectCall and (type(subject) == "function" or subject == __OriginalDebugInfo or subject == debug.info) then
					replacementSource = "[C]"
				elseif (isDirectCall or isThreadCall) and (subject == 4 or subject == 1 or subject == 2 or subject == 3) then
					replacementSource = "ReplicatedStorage.Controllers.SwordsController"
				end

				if replacementSource and type(options) == "string" then
					local resultIndex = 1
					for index = 1, #options do
						local option = string.sub(options, index, index)
						if option == "s" then
							results[resultIndex] = replacementSource
							break
						end
						resultIndex = resultIndex + (option == "a" and 2 or 1)
					end
				end
			end

			__InDebugHook = false
			return table.unpack(results, 1, results.n)
		end

		local ok, original = pcall(hookfunction, __RuntimeDebugInfo, __DebugHook)
		if ok and typeof(original) == "function" then
			__OriginalDebugInfo = original
			__RuntimeHookState.DebugInfoOriginal = original
			__DebugHookInstalled = true
		end
	end

	local __GetFenvHookInstalled = typeof(__RuntimeHookState.GetFenvOriginal) == "function"
	if not __GetFenvHookInstalled and typeof(__RuntimeGetFenv) == "function" then
		local __InGetFenvHook = false
		local __GetFenvHook
		__GetFenvHook = function(...)
			if __InGetFenvHook then
				return __OriginalGetFenv(...)
			end
			__InGetFenvHook = true

			local count = select("#", ...)
			local target = ...
			if count == 0 or (count == 1 and target == nil) then
				local ok, res = pcall(__OriginalGetFenv, 2)
				__InGetFenvHook = false
				if ok then return res end
				local ok2, res2 = pcall(__OriginalGetFenv, 1)
				if ok2 then return res2 end
				return __RuntimeEnvironment
			end

			if count == 1 and type(target) == "number" then
				if not checkcaller() and target >= 1 and target <= 10 then
					__InGetFenvHook = false
					return __RuntimeHookState.CleanEnvironment or __RuntimeEnvironment
				end
				if target == 0 then
					local ok, res = pcall(__OriginalGetFenv, 0)
					__InGetFenvHook = false
					if ok then return res end
					return __RuntimeEnvironment
				elseif target < 0 then
					local ok, res = pcall(__OriginalGetFenv, target)
					__InGetFenvHook = false
					if ok then return res end
					return __RuntimeEnvironment
				end
				local ok, res = pcall(__OriginalGetFenv, target + 1)
				if not ok then
					ok, res = pcall(__OriginalGetFenv, target)
				end
				__InGetFenvHook = false
				if ok then return res else error("invalid argument #1 to 'getfenv' (invalid level)", 2) end
			end
			local ok, res = pcall(__OriginalGetFenv, ...)
			__InGetFenvHook = false
			if ok then return res else error(tostring(res), 2) end
		end

		local ok, original = pcall(hookfunction, __RuntimeGetFenv, __GetFenvHook)
		if ok and typeof(original) == "function" then
			__OriginalGetFenv = original
			__RuntimeHookState.GetFenvOriginal = original
			__GetFenvHookInstalled = true
		end
	end

	__RuntimeHooksInstalled = __DebugHookInstalled and __GetFenvHookInstalled
end
__InstallRuntimeHooks()

getgenv().sets = {
    title = 'roni hub',
    tab_width = 110,
    window_size = {
        x = 480,
        y = 360
    },
    acrylic = false,
    theme = 'darker',
    keybind = 'end'
}
local __Interface = loadstring(game:HttpGet('https://raw.githubusercontent.com/RiqWhatever/Amfer/refs/heads/main/init.lua'))()
local __Flags = __Interface.Flags
local __Players = cloneref(game:GetService('Players'))
local __UserInputService = cloneref(game:GetService("UserInputService"))
local __RunService = cloneref(game:GetService('RunService'))
local __ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local __StatsService = cloneref(game:GetService("Stats"))
local __Debris = cloneref(game:GetService('Debris'))
local __Workspace = cloneref(game:GetService("Workspace"))
local __LocalPlayer = __Players.LocalPlayer
local __Camera = __Workspace.CurrentCamera
local __Alive = __Workspace:WaitForChild('Alive', 9e9)
local __Balls = __Workspace:WaitForChild('Balls', 9e9)
local __AmferConfig = {
    Combat = {
        AutoParry = true,
        AutoAbility = false,
        Visualize = true,
        AI = false,
        AntiCurve = true,
        AntiInfinity = true,
        AntiDeathSlash = true,
        AntiTimeHole = true,
        AntiSlashOfFury = true,
        AntiPhantom = true,
        AntiSingularity = true,
        AntiCombo = true,
        CooldownProtection = false,
    },
    Particle = {
        NoParticle = false,
        Fps = 144
    },
    Client = {
        WalkSpeed = 36,
        JumpPower = 50,
        WsToggle = false,
        JpToggle = false,
        Status = false
    }
}
local __RevertedRemotes = {}
local __OriginalMetatables = {}
local __CapturedParryData = nil
local __IsMobile = __UserInputService.TouchEnabled
local __HidenCFrame = CFrame.new(0, -1e6, 0)
local __CurveStamp = 0
local __LastBallPos = nil
local __LastBallVel = nil
local __LastBallSample = 0
local __PendingParry = nil

local __PRY = require(__ReplicatedStorage:FindFirstChild('PRY', true))
local __PRY_Network = getupvalue(__PRY, 6)
local __PRY_Constants = getupvalue(__PRY, 3)
local __PRY_Convert = getupvalue(__PRY, 4)
local __PRY_Hash1 = getupvalue(__PRY, 8)
local __PRY_Hash2 = __PRY_Constants[2]
local __PRY_Hash3 = function()
    local Constant = __PRY_Convert(__PRY_Hash2, 'TIME')
    local Time = tostring(math.floor(workspace:GetServerTimeNow() * 100))
    local Encoded = {}
    for i = 1, #Time do
        local s1 = string.byte(Constant, ((i - 1) % #Constant) + 1)
        Encoded[i] = string.char(bit32.bxor((string.byte(Time, i) + i) % 256, s1))
    end
    return table.concat(Encoded)
end

local __ParryRemote = nil
do
    local RemoteName = string.gsub(game.JobId, '-', '')
    local GetRemote = __PRY_Network.RemoteEvent
    task.spawn(function()
        setthreadidentity(2)
        setfenv(0, getfenv(__PRY))
        setfenv(1, getfenv(__PRY))
        __ParryRemote = GetRemote(__PRY_Network, RemoteName)
    end)
end
local function __IsValidRemoteArgs(args)
    return #args == 7 and
        type(args[2]) == "string" and
        type(args[3]) == "number" and
        typeof(args[4]) == "CFrame" and
        type(args[5]) == "table" and
        type(args[6]) == "table" and
        type(args[7]) == "boolean"
end
local __ServerPositionTable
local function __GetServerBallPosition(ball)
    if not ball then return Vector3.zero end
    local serverPos = __ServerPositionTable and __ServerPositionTable[ball]
    if serverPos then return serverPos end
    return ball.Position
end

task.spawn(function()
    local __CachedFuncs = {}
    local function ScanUpvalues(v)
        if __ServerPositionTable then return true end
        for _, u in getupvalues(v) do
            if type(u) ~= 'table' then continue end
            for i, k in u do
                if typeof(i) == 'Instance' and typeof(k) == 'Vector3' then
                    __ServerPositionTable = u
                    return true
                end
            end
        end
        return false
    end
    local function Resolve()
        if __ServerPositionTable then return end
        for _, v in __CachedFuncs do if ScanUpvalues(v) then return end end
        for _, v in getgc(true) do
            if type(v) ~= 'function' then continue end
            if not (debug.info(v, 's') or ''):find('BallReplicationHandler') then continue end
            __CachedFuncs[#__CachedFuncs + 1] = v
            if ScanUpvalues(v) then return end
        end
    end
    if #__Balls:GetChildren() > 0 then
        task.wait(0.1); Resolve()
    end
    __Balls.ChildAdded:Connect(function()
        if __ServerPositionTable then return end
        task.wait(0.1); Resolve()
    end)
end)
local function __HookRemote(remote)
    if not __RevertedRemotes[remote] then
        if not __OriginalMetatables[getrawmetatable(remote)] then
            __OriginalMetatables[getrawmetatable(remote)] = true
            local __Meta = getrawmetatable(remote)
            setreadonly(__Meta, false)
            local __OldIndex = __Meta.__index
            local __InHook = false
            __Meta.__index = function(self, key)
                if __InHook then
                    return __OldIndex(self, key)
                end
                if (key == "FireServer" and self:IsA("RemoteEvent")) or
                   (key == "InvokeServer" and self:IsA("RemoteFunction")) then
                    return function(_, ...)
                        local __Args = {...}
                        if __IsValidRemoteArgs(__Args) then
                            if not __RevertedRemotes[self] then
                                __RevertedRemotes[self] = __Args
                                __CapturedParryData = {
                                    remote = self,
                                    args = __Args
                                }
                            end
                        end
                        __InHook = true
                        local fn = __OldIndex(self, key)
                        __InHook = false
                        return fn(_, unpack(__Args))
                    end
                end
                return __OldIndex(self, key)
            end
            setreadonly(__Meta, true)
        end
    end
end
for _, __Remote in pairs(__ReplicatedStorage:GetChildren()) do
    if __Remote:IsA("RemoteEvent") or __Remote:IsA("RemoteFunction") then
        __HookRemote(__Remote)
    end
end
__ReplicatedStorage.ChildAdded:Connect(function(__Child)
    if __Child:IsA("RemoteEvent") or __Child:IsA("RemoteFunction") then
        __HookRemote(__Child)
    end
end)
local __ParriedBalls = setmetatable({}, {__mode = 'k'})
local __LastFiredTick = 0
local __LastAckTick = 0
do
    local __Remotes = __ReplicatedStorage:WaitForChild('Remotes', 30)
    if __Remotes then
        local __DeathBall    = __Remotes:FindFirstChild('DeathBall')
        local __InfinityBall = __Remotes:FindFirstChild('InfinityBall')
        local __TimeHoleHold = __Remotes:FindFirstChild('TimeHoleHoldBall')
        if __DeathBall then
            __DeathBall.OnClientEvent:Connect(function(_, on)
                __DeathSlash = on and true or false
            end)
        end
        if __InfinityBall then
            __InfinityBall.OnClientEvent:Connect(function(_, on)
                __Infinity = on and true or false
            end)
        end
        if __TimeHoleHold then
            __TimeHoleHold.OnClientEvent:Connect(function(_, on)
                __TimeHole = on and true or false
            end)
        end
    end
end
__Balls.ChildAdded:Connect(function(__Ball)
    __Ball.ChildAdded:Connect(function(__Child)
        if __Child.Name == 'ComboCounter' then
            __SlashOfFuryActive = true
            local __Label = __Child:FindFirstChildOfClass('TextLabel')
            if __Label then
                task.spawn(function()
                    while __Label.Parent do
                        __SlashOfFuryCount = tonumber(__Label.Text) or 0
                        task.wait()
                    end
                    __SlashOfFuryActive = false
                    __SlashOfFuryCount = 0
                end)
            end
        end
        local __Cn = __Child.Name
        if __Cn == 'AeroDynamicSlashVFX' or __Cn:find('[Vv]ortex') or __Cn:find('[Ss]wirl') or __Cn:find('[Cc]urve') or __Cn:find('[Tt]ornado') then
            __CurveStamp = tick()
        end
    end)
    pcall(function()
        __Ball:GetAttributeChangedSignal('DribbleActive'):Connect(function()
            if __Ball:GetAttribute('DribbleActive') then __CurveStamp = tick() end
        end)
    end)
    __LastBallPos = nil
    __LastBallVel = nil
end)
__Balls.ChildRemoved:Connect(function()
    __SlashOfFuryActive = false
    __SlashOfFuryCount = 0
end)
local function __IsCooldownActive()
    local __Char = __LocalPlayer.Character
    if not __Char then return false end
    local __PG = __LocalPlayer:FindFirstChild('PlayerGui')
    if not __PG then return false end
    local __HB = __PG:FindFirstChild('Hotbar')
    if not __HB then return false end
    local __Block = __HB:FindFirstChild('Block')
    if not __Block then return false end
    local __Grad = __Block:FindFirstChild('UIGradient')
    if not __Grad then return false end
    return __Grad.Offset.Y < 0.4
end
local function __CooldownProtection()
    if __IsCooldownActive() then
        if __AmferConfig.Combat.AutoAbility then
            local __ABP = __ReplicatedStorage:FindFirstChild('Remotes') and __ReplicatedStorage.Remotes:FindFirstChild('AbilityButtonPress')
            if __ABP then pcall(function() __ABP:Fire() end) end
        end
        return true
    end
    return false
end
local function __HasSingularity()
    local __Char = __LocalPlayer.Character
    if not __Char or not __Char.PrimaryPart then return false end
    if __Char.PrimaryPart:FindFirstChild('SingularityCape') then return true end
    if __Char.PrimaryPart:FindFirstChild('Cape') then return true end
    return false
end
local __PingCacheVal = 0
local __PingCacheT = 0
local function __GetPing()
    local __T = tick()
    if (__T - __PingCacheT) > 0.1 then
        __PingCacheVal = __StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
        __PingCacheT = __T
    end
    return __PingCacheVal
end
local function __RootPart()
    return (__LocalPlayer.Character and __LocalPlayer.Character:FindFirstChild('HumanoidRootPart'))
end
local __IsCurvedData = { Lerp_Radians = 0, Curving = tick(), Last_Warping = tick() }
local function __IsCurved()
    local __Ball = __RealBall
    if not __Ball then return false end
    local __Zoomies = __Ball:FindFirstChild('zoomies')
    if not __Zoomies then return false end

    local Velocity = __Zoomies.VectorVelocity
    local Speed = Velocity.Magnitude
    if Speed < 1 then return false end

    local Ball_Position = __GetServerBallPosition(__Ball)
    local Root = __RootPart()
    if not Root then return false end
    local Player_Position = Root.Position

    local DX = Player_Position.X - Ball_Position.X
    local DY = Player_Position.Y - Ball_Position.Y
    local DZ = Player_Position.Z - Ball_Position.Z
    local Distance_Squared = DX*DX + DY*DY + DZ*DZ
    if Distance_Squared < 1 then return false end

    local Distance = math.sqrt(Distance_Squared)
    local Inv_Distance = 1 / Distance
    local Dir_X, Dir_Y, Dir_Z = DX*Inv_Distance, DY*Inv_Distance, DZ*Inv_Distance

    local Inv_Speed = 1 / Speed
    local BX, BY, BZ = Velocity.X*Inv_Speed, Velocity.Y*Inv_Speed, Velocity.Z*Inv_Speed

    local Dot = Dir_X*BX + Dir_Y*BY + Dir_Z*BZ
    local Clamped_Dot = math.clamp(Dot, -1, 1)

    local Speed_Threshold = math.min(Speed * 0.01, 40)
    local Pings = __GetPing()
    local Ping_Factor = Pings * 0.001
    local Dot_Threshold = 0.35 - Ping_Factor
    local Angle_Threshold = 8 * math.max(Dot, 0)
    local Reach_Time = Distance * Inv_Speed - Ping_Factor
    local Ball_Distance_Threshold = 18 - math.min(Distance*0.001, 15) + Angle_Threshold + Speed_Threshold

    local Radians = math.asin(Clamped_Dot)
    __IsCurvedData.Lerp_Radians = __IsCurvedData.Lerp_Radians + (Radians - __IsCurvedData.Lerp_Radians) * 0.65

    local Now = tick()
    local Warp_Age = Now - __IsCurvedData.Last_Warping
    local Curve_Age = Now - __IsCurvedData.Curving
    local Half_Reach = Reach_Time * 0.5

    if Distance < Ball_Distance_Threshold then return false end
    if Clamped_Dot < Dot_Threshold then return true end
    if __IsCurvedData.Lerp_Radians < 0.02 then __IsCurvedData.Last_Warping = Now end
    if Warp_Age < Half_Reach then return true end
    if Curve_Age < Half_Reach then return true end
    if Speed > 150 then
        return Dot < (Dot_Threshold - (Speed - 150) * 0.0008)
    end
    return Dot < Dot_Threshold
end
local function __ShouldBlockParry()
    if __AmferConfig.Combat.AntiInfinity   and __Infinity         then return true end
    if __AmferConfig.Combat.AntiDeathSlash and __DeathSlash       then return true end
    if __AmferConfig.Combat.AntiTimeHole   and __TimeHole         then return true end
    if __AmferConfig.Combat.AntiPhantom    and __Phantom          then return true end
    if __AmferConfig.Combat.AntiSingularity and __HasSingularity() then return true end
    if __AmferConfig.Combat.AntiCombo and __RealBall and __RealBall:FindFirstChild('ComboCounter') then return true end
    local __CloseRange = false
    if __RealBall then
        local __CR = __RootPart()
        if __CR then
            __CloseRange = (__CR.Position - __GetServerBallPosition(__RealBall)).Magnitude <= 8
        end
    end
    if not __CloseRange then
        if __AmferConfig.Combat.AntiCurve and __IsCurved()        then return true end
    end
    if __AmferConfig.Combat.CooldownProtection and __CooldownProtection() then return true end
    return false
end
local __TabCombat = __Interface:create_tab('Combat', 'swords')
local __TabVisuals = __Interface:create_tab('Visuals', 'eye')
local __TabMisc = __Interface:create_tab('Misc', 'settings')
local __RealBall
local __FakeBall
local __MyPosition
local __LastPlayerTarget
local __BallSpeedView = 0
local __ParryTimeNow = tick()
local __ParryLastTime = __ParryTimeNow
local __ParryTimeViewer = 5
local __CalaTimeClash = 0.3
local __IsLookAt = true
local __IsClash = false
local __Phantom = false
local __UserFPS = 60
local __TornadoTime = tick()
local __Infinity = false
local __DeathSlash = false
local __TimeHole = false
local __PreviousVelocity = {}
local __Curving = tick()
local __LastWarping = tick()
local __PredictBall
local __GetBallFuture
local __LerpRadians = 0
local __SlashOfFuryActive = false
local __SlashOfFuryCount = 0
local __SitAnimationCollect = {}
local __LoopStack = {
    Loop1 = false, Loop2 = false, Loop3 = false, Loop4 = false, Loop5 = false,
    Loop6 = false, Loop7 = false, Loop8 = false, Loop9 = false, Loop10 = false,
}
local __ArchPart = Instance.new('Part')
__ArchPart.Color = Color3.fromRGB(26, 255, 0)
__ArchPart.Material = Enum.Material.ForceField
__ArchPart.CanCollide = false 
__ArchPart.Shape = Enum.PartType.Ball
__ArchPart.Anchored = true
__ArchPart.Parent = __Workspace
__ArchPart.CastShadow = false
__ArchPart.Size = Vector3.new(0,0,0)
local __StatusGui = Instance.new("ScreenGui")
local __StatusLabel = Instance.new("TextLabel")
__StatusGui.Name = "AmferStatus"
__StatusGui.Parent = game:FindFirstChild('CoreGui')
__StatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
__StatusLabel.Parent = __StatusGui
__StatusLabel.AnchorPoint = Vector2.new(0, 1)
__StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
__StatusLabel.BackgroundTransparency = 1.000
__StatusLabel.Position = UDim2.new(0.01, 0, 0.99, 0)
__StatusLabel.Size = UDim2.new(0.99, 0, 0.02, 0)
__StatusLabel.Font = Enum.Font.GothamBold
__StatusLabel.Text = "Target: None"
__StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
__StatusLabel.TextScaled = true
__StatusLabel.TextTransparency = 0.4
__StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
local function __GetDistance(target)
    local __Root = __RootPart()
    if not __Root then return 0 end
    local __Velocity = __Root.Velocity
    local __MaxUnp = 150
    if not target then
        return (__Root.Position - (__Velocity / __MaxUnp))
    end
    return ((__Root.Position - (__Velocity / __MaxUnp)) - target).Magnitude
end
local __ParryCooldownGradient = nil
local function __ResolveCooldownGradient()
    if __ParryCooldownGradient and __ParryCooldownGradient.Parent then
        return __ParryCooldownGradient
    end
    local __PG = __LocalPlayer:FindFirstChild('PlayerGui')
    if not __PG then return nil end
    local __HB = __PG:FindFirstChild('Hotbar'); if not __HB then return nil end
    local __Block = __HB:FindFirstChild('Block'); if not __Block then return nil end
    local __Grad = __Block:FindFirstChild('UIGradient'); if not __Grad then return nil end
    __ParryCooldownGradient = __Grad
    return __Grad
end
local function __ParryReady(__Dist)
    local __Grad = __ResolveCooldownGradient()
    if __Grad and __Grad.Offset.Y < 0.49 then return false end
    if __Dist and __Dist <= 25 then
        return true
    end
    if __PendingParry then
        local __Age = tick() - __PendingParry
        local __PingMs = __GetPing()
        local __Timeout = (__Dist and __Dist < 35) and 0.015 or (0.03 + (__PingMs / 1000) * 0.8)
        if __Age > __Timeout then
            __PendingParry = nil
            return true
        end
        return false
    end
    return true
end
local __SpeedDivisorMult = 1.1
local function __ShouldParryNow(__Ball)
    __Ball = __Ball or __RealBall
    if not __Ball then return false end
    if __Ball:GetAttribute('target') ~= tostring(__LocalPlayer) then return false end
    local __Zoomies = __Ball:FindFirstChild('zoomies')
    if not __Zoomies then return false end
    local __Root = __RootPart()
    if not __Root then return false end
    local __Vel   = __Zoomies.VectorVelocity
    local __Speed = __Vel.Magnitude
    if __Speed < 0.5 then return false end
    local __ToPlayer = __Root.Position - __GetServerBallPosition(__Ball)
    local __Dist     = __ToPlayer.Magnitude
    if not __ParryReady(__Dist) then return false end
    if __Dist <= 22 then return true end
    local __PingRaw         = __GetPing()
    local __Ping            = __PingRaw / 10
    local __PingThreshold   = math.clamp(__Ping / 10, 5, 17)
    local __CappedSpeedDiff = math.min(math.max(__Speed - 9.5, 0), 650)
    local __SpeedDivBase    = 2.4 + __CappedSpeedDiff * 0.002
    local __SpeedDiv        = __SpeedDivBase * __SpeedDivisorMult
    local __NvFormula       = __PingThreshold + math.max(__Speed / __SpeedDiv, 9.5)
    local __FakeoutRange = __Ball:GetAttribute('FakeoutRange')
    local __HighPing = __PingRaw > 150
    local __SafetyMargin = math.clamp((__PingRaw - 150) / 100, 0, 4)
    local __ParryAccuracy = (__FakeoutRange and math.max(__FakeoutRange, __NvFormula) or __NvFormula) + __SafetyMargin
    if __Dist > __ParryAccuracy then return false end
    if __Dist > (__FakeoutRange or 12) then
        local __D = __GetServerBallPosition(__Ball) - __Root.Position
        local __VRel = __Vel - __Root.Velocity
        local __R = __ParryAccuracy
        local __a = __VRel:Dot(__VRel)
        if __a < 0.001 then return false end
        local __b = 2 * __D:Dot(__VRel)
        local __c = __D:Dot(__D) - __R * __R
        local __Disc = __b * __b - 4 * __a * __c
        if __Disc < 0 then return false end
        local __SqrtD = math.sqrt(__Disc)
        local __TEntry = (-__b - __SqrtD) / (2 * __a)
        local __TExit  = (-__b + __SqrtD) / (2 * __a)
        if __TExit < 0 then return false end
        local __TImpact = math.max(__TEntry, 0)
        local __FireWindow = math.clamp(__PingRaw / 1000 + 0.10, 0.12, 0.55)
        if __TImpact > __FireWindow then return false end
        if not __HighPing and (__TExit - __TImpact) < 0.02 then return false end
    end
    return true
end
local function __ClosestPlayer()
    if __LocalPlayer.Character.Parent ~= __Alive then return nil end
    local __MaxDist = math.huge
    local __Closest = nil
    for _, __Entity in pairs(__Alive:GetChildren()) do
        if tostring(__Entity) ~= tostring(__LocalPlayer) and __Entity.PrimaryPart then
            local __Dist = __LocalPlayer:DistanceFromCharacter(__Entity.PrimaryPart.Position)
            if __Dist < __MaxDist then
                __MaxDist = __Dist
                __Closest = __Entity
            end
        end
    end
    return __Closest
end
local function __ClosestAim()
    if __LocalPlayer.Character.Parent ~= __Alive then return nil end
    local __MaxDist = math.huge
    local __Closest = nil
    local __Center = Vector2.new(__Camera.ViewportSize.X / 2, __Camera.ViewportSize.Y / 2)
    for _, __Entity in pairs(__Alive:GetChildren()) do
        if tostring(__Entity) ~= tostring(__LocalPlayer) and __Entity.PrimaryPart then
            local __ScreenPos, __OnScreen = __Camera:WorldToViewportPoint(__Entity.PrimaryPart.Position)
            if __OnScreen then
                local __Dist = (Vector2.new(__ScreenPos.X, __ScreenPos.Y) - __Center).Magnitude
                if __Dist < __MaxDist then
                    __MaxDist = __Dist
                    __Closest = __Entity
                end
            end
        end
    end
    return __Closest
end
local function __GetEntitiesScreenPoints()
    local __EventData = {}
    if __Alive then
        for _, __Entity in pairs(__Alive:GetChildren()) do
            if __Entity.PrimaryPart then
                local __Success, __ScreenPoint = pcall(function()
                    return __Camera:WorldToScreenPoint(__Entity.PrimaryPart.Position)
                end)
                if __Success then
                    __EventData[__Entity.Name] = __ScreenPoint
                end
            end
        end
    end
    return __EventData
end
local function __GetParryCFrame()
    local __Type = __Flags['curve_mode']
    local __Events = __GetEntitiesScreenPoints()
    local __MouseLocation = {0, 0}
    if __IsMobile then
        __MouseLocation = {__Camera.ViewportSize.X / 2, __Camera.ViewportSize.Y / 2}
    else
        local __Mouse = __UserInputService:GetMouseLocation()
        __MouseLocation = {__Mouse.X, __Mouse.Y}
    end
    if __Type == 'custom' then
        return {0, CFrame.new(__Camera.CFrame.Position, __Camera.CFrame.Position + __Camera.CFrame.LookVector), __Events, __MouseLocation}
    elseif __Type == 'straight' then
        local __Aim = __ClosestAim() or __ClosestPlayer()
        if __Aim then
            return {0, CFrame.new(__LocalPlayer.Character.PrimaryPart.Position, __Aim.PrimaryPart.Position), __Events, __MouseLocation}
        end
        return {0, __Camera.CFrame, __Events, __MouseLocation}
    elseif __Type == 'backwards' then
        local __Back = -__Camera.CFrame.LookVector
        __Back = Vector3.new(__Back.X, 0, __Back.Z)
        return {0, CFrame.new(__Camera.CFrame.Position, __Camera.CFrame.Position + __Back), __Events, __MouseLocation}
    elseif __Type == 'random' then
        local __FwdR = __Camera.CFrame.LookVector
        local __RightR = __Camera.CFrame.RightVector
        local __UpR = __Camera.CFrame.UpVector
        local __SpreadR = math.tan(math.rad(15))
        local __DxR = (math.random() * 2 - 1) * __SpreadR
        local __DyR = (math.random() * 2 - 1) * __SpreadR
        local __AimR = (__FwdR + __RightR * __DxR + __UpR * __DyR).Unit
        return {0, CFrame.new(__Camera.CFrame.Position, __Camera.CFrame.Position + __AimR * 100), __Events, __MouseLocation}
    end
    return {0, __Camera.CFrame, __Events, __MouseLocation}
end
local function __SimulateInput()
    local VIM = Instance.new('VirtualInputManager')
    if __IsMobile then
        local Mouse_Pos = __UserInputService:GetMouseLocation()
        VIM:SendMouseButtonEvent(Mouse_Pos.X, Mouse_Pos.Y, 0, true, game, 0)
        VIM:SendMouseButtonEvent(Mouse_Pos.X, Mouse_Pos.Y, 0, false, game, 0)
    else
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end
local __ParryAnimTrack = nil
local function __PlayParryAnimation()
    local Character = __LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    if not Humanoid then return end
    local Animator = Humanoid:FindFirstChildOfClass('Animator')
    if not Animator then return end

    local Parry_Animation = __ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild('GrabParry')
    local Current_Sword = Character:GetAttribute('CurrentlyEquippedSword')
    if not Current_Sword then return end
    if not Parry_Animation then return end

    local ok, Sword_Data = pcall(function()
        return __ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(Current_Sword)
    end)
    if not ok or not Sword_Data or not Sword_Data['AnimationType'] then return end

    for _, object in __ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren() do
        if object.Name == Sword_Data['AnimationType'] then
            if object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab') then
                local sword_animation_type = 'GrabParry'
                if object:FindFirstChild('Grab') then
                    sword_animation_type = 'Grab'
                end
                Parry_Animation = object[sword_animation_type]
                break
            end
        end
    end

    local Success, Track = pcall(function()
        return Animator:LoadAnimation(Parry_Animation)
    end)

    if Success and Track then
        __ParryAnimTrack = Track
        if Track.IsPlaying then Track:Stop(0) end
        Track:Play()
    end
end

local __LastExecuteParry = 0
local function __ExecuteParry()
    local __NowEP = tick()
    if (__NowEP - __LastExecuteParry) < 0.01 then return end
    __LastExecuteParry = __NowEP
    pcall(__PlayParryAnimation)

    if __ParryRemote then
        local PlayerPositions = {}
        for _, char in next, workspace.Alive:GetChildren() do
            if char:FindFirstChild('HumanoidRootPart') then
                PlayerPositions[char.Name] = char.HumanoidRootPart.Position
            end
        end
        local CameraCenter = __Camera.ViewportSize / 2
        local CameraData = {CameraCenter.X, CameraCenter.Y}
        task.spawn(function()
            pcall(function()
                __ParryRemote:FireServer(__PRY_Hash1, __PRY_Hash2, __PRY_Hash3(), 0.025, __Camera.CFrame, PlayerPositions, CameraData, false)
            end)
        end)
        __PendingParry = tick()
        __LastFiredTick = tick()
        return
    end

    __SimulateInput()
    __PendingParry = tick()
    __LastFiredTick = tick()
end
function __PredictBall(ball, seconds)
    if not ball then return Vector3.zero end
    local __Zoomies = ball:FindFirstChild('zoomies')
    if not __Zoomies then return __GetServerBallPosition(ball) end
    local basePos = __GetServerBallPosition(ball)
    local ping = __GetPing()
    local pred_time = math.clamp(ping / 1000 + 0.05, 0.05, 0.15)
    return basePos + __Zoomies.VectorVelocity * pred_time
end
local __LastSoFFire = 0
task.spawn(function()
    while true do
        if __AmferConfig.Combat.AntiSlashOfFury and __SlashOfFuryActive and __SlashOfFuryCount > 0 and __SlashOfFuryCount < 32 then
            local __NowSoF = tick()
            local __SoFGap = math.clamp(0.05 + __GetPing() / 2000, 0.05, 0.12)
            if (__NowSoF - __LastSoFFire) >= __SoFGap and __ParryReady() then
                local __BallSoF = __RealBall
                if __BallSoF then
                    local __RootSoF = __RootPart()
                    if __RootSoF then
                        local __DistSoF = (__RootSoF.Position - __BallSoF.Position).Magnitude
                        if __DistSoF <= 20 then
                            __ExecuteParry()
                            __LastSoFFire = __NowSoF
                            __LastFiredTick = __NowSoF
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)
function __GetBallFuture(seconds)
    return __PredictBall(__RealBall, seconds or (1 / 10))
end
local function __BallIsLookAt(ball)
    local __Root = __RootPart()
    if not __Root or not ball then return false end
    local __BallFuture = __PredictBall(ball, 1 / 10)
    local __Distance = (__Root.Position - __GetServerBallPosition(ball))
    local __Look = (CFrame.lookAt(__GetServerBallPosition(ball), __BallFuture)).LookVector
    local __Dot = __Distance.Unit:Dot(__Look)
    if (__BallFuture - __Root.Position).Magnitude <= (__BallSpeedView / 1.25) then
        return true
    end
    if __IsClash and __AmferConfig.Combat.ClashMode then
        return true
    end
    if __Dot >= 0.1 or (ball:GetAttribute('target') == tostring(__LocalPlayer) and __Distance.Magnitude <= 30) then 
        return true
    end
    return false
end
local function __IsWalkBetter(target)
    local __Root = __RootPart()
    if not __Root then return false end
    local __Vel = __Root.Velocity / 6
    local __Normal = __Root.Position
    local __Feature = __Normal + Vector3.new(__Vel.X, 0, __Vel.Z)
    local __Dist1 = (target - __Normal).Magnitude
    local __Dist2 = (target - __Feature).Magnitude
    return __Dist1 < __Dist2
end
local function __UpdateBall()
    local __BallChildren = __Balls:GetChildren()
    for _, v in ipairs(__BallChildren) do
        if v:GetAttribute('realBall') == true then
            if v:GetAttribute('RBX') then
                v:SetAttribute('RBX', true)
                if getfenv()['_SignalTarget'] then getfenv()['_SignalTarget']:Disconnect() end
                getfenv()['_SignalTarget'] = v:GetAttributeChangedSignal("target"):Connect(function()
                    if v and tostring(v:GetAttribute('target')) ~= tostring(__LocalPlayer) and v:GetAttribute('target') ~= "amfer-on-top" then
                        __LastPlayerTarget = __Players:FindFirstChild(v:GetAttribute('target')) or __Alive:FindFirstChild(v:GetAttribute('target'))
                    else
                        local __Dist = __GetDistance(v.Position)
                        if __Dist <= 10 then
                            if __AmferConfig.Combat.AutoParry then
                                local __Grad = __ResolveCooldownGradient()
                                if not __Grad or __Grad.Offset.Y >= 0.49 then
                                    __ExecuteParry()
                                    __LastFiredTick = tick()
                                end
                            end
                        end
                    end
                end)
            end
            __RealBall = v
        else
            __FakeBall = v
            local __MainFunc = getfenv()['MainFunction']
            if __MainFunc then
                if not v:GetAttribute('RBX') then
                    v:SetAttribute('RBX', true)
                    if getfenv()['_SignalPos'] then getfenv()['_SignalPos']:Disconnect() end
                    getfenv()['_SignalPos'] = v:GetPropertyChangedSignal('Position'):Connect(__MainFunc)
                end
            end
        end
    end
    if #__BallChildren <= 0 then __IsClash = false end
end
local function __GetCD()
    local __Grad = __ResolveCooldownGradient()
    if not __Grad then return 0 end
    return __Grad.Offset.Y
end
__LocalPlayer.CharacterAdded:Connect(function()
    __IsClash = false
    __CalaTimeClash = 0.3
end)
local __UpdateBallTimer = tick() + 0.4
local __MyParryTime = tick()
local __TactCacheVal = false
local __TactCacheT = 0
local function __MainLogic()
    if tick() > __UpdateBallTimer then
        task.spawn(__UpdateBall)
        __UpdateBallTimer = tick()
    end
    if __LocalPlayer.Character then
        local __Root = __RootPart()
        if __Root then __MyPosition = __Root.Position end
    end
    if __RealBall and __FakeBall and __AmferConfig.Combat.AutoParry and __RealBall:FindFirstChild('zoomies') then
        local __Ping = tonumber(__GetPing())
        local __CD = __GetCD()
        local __RealVel = __RealBall.zoomies.VectorVelocity.Magnitude
        local __CalcSpeed = math.max(__RealVel / math.clamp((500 / __Ping), 0, 3.15), 15.5)
        
        local __BallPos = __GetBallFuture(1 / 10)
        local __OldVelo = __GetDistance()
        local __BallDist = __GetDistance(__BallPos)
        local __Tornado = __Workspace.Runtime:FindFirstChild('Tornado')
        if __Tornado then
            local __Elapsed = (tick() - __TornadoTime)
            local __Duration = (__Tornado:GetAttribute('TornadoTime') or 1) + 0.314159
            if __Elapsed < __Duration then return end
        end
        local __IsCD = tonumber(__CD) > -0.25 or tonumber(__CD) == -0.5
        __BallSpeedView = __CalcSpeed
        if __AmferConfig.Combat.Visualize then
            local archPos = typeof(__OldVelo) == "Vector3" and __OldVelo or (__MyPosition or Vector3.zero)
            __ArchPart.CFrame = CFrame.new(archPos)
            __ArchPart.Size = Vector3.new(__CalcSpeed, __CalcSpeed, __CalcSpeed)
        else
            __ArchPart.CFrame = CFrame.new(__MyPosition or Vector3.zero) * CFrame.new(0,-10000,0)
            __ArchPart.Size = Vector3.new(0,0,0)
        end
        if tonumber(__Ping) <= 450 then
            __IsLookAt = __BallIsLookAt(__RealBall)
        else
            __IsLookAt = true
        end
        if __AmferConfig.Combat.AutoAbility then
            if tonumber(__CD) <= -0.25 and tonumber(__CD) ~= -0.5 then
                __ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
            end
        end
        if __RealVel <= 0.5 then
            if __RealBall:GetAttribute('target') == "amfer-on-top" then
                task.spawn(__RealBall.SetAttribute, __RealBall, 'target', tostring(__LocalPlayer))
            end
        end
        local __Block = __ShouldBlockParry()
        
        
        local __FiredParry = false
        if not __Phantom and not __Block then
            for _, __B in ipairs(__Balls:GetChildren()) do
                if __ShouldParryNow(__B) then
                    __ArchPart.Color = Color3.fromRGB(255, 0, 0)
                    task.spawn(__B.SetAttribute, __B, 'target', "amfer-on-top")
                    __ExecuteParry()
                    __MyParryTime = tick()
                    __LastFiredTick = __MyParryTime
                    __FiredParry = true
                    break
                end
            end
        end
        if not __FiredParry then
            __ArchPart.Color = Color3.fromRGB(26, 255, 0)
        end
        __Camera.CameraSubject = __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
    else
        if __LocalPlayer.Character then
            __Camera.CameraSubject = __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
        end
    end
    if __LocalPlayer.Character then
        if __AmferConfig.Client.WsToggle then
            __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = __AmferConfig.Client.WalkSpeed
        end
        if __AmferConfig.Client.JpToggle then
            __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = __AmferConfig.Client.JumpPower
        end
    end
    if __AmferConfig.Client.Status then
        __StatusGui.Enabled = true
        local __Target = __RealBall and __RealBall:GetAttribute('target') or "None"
        local __FPSDisp
        if __UserFPS <= 15 then __FPSDisp = tostring(__UserFPS).." (BAD)"
        elseif __UserFPS <= 30 then __FPSDisp = tostring(__UserFPS).." (okay)"
        elseif __UserFPS <= 60 then __FPSDisp = tostring(__UserFPS).." (Good)"
        else __FPSDisp = tostring(__UserFPS).." (60+)" end
        __StatusLabel.Text = "          Target: "..tostring(__Target)..' , FPS: '..__FPSDisp
    else
        __StatusGui.Enabled = false
    end
end
__TabCombat:create_toggle('auto_parry', {
    title = 'auto parry',
    default = true,
    callback = function(val) __AmferConfig.Combat.AutoParry = val end
})
__TabCombat:create_dropdown('curve_mode', {
    title = 'curve mode',
    options = {'custom', 'straight', 'random', 'backwards'},
    default = 1
})
__TabCombat:create_toggle('visualize', {
    title = 'visualizer',
    default = true,
    callback = function(val) __AmferConfig.Combat.Visualize = val end
})
__TabCombat:create_toggle('auto_ability', {
    title = 'auto ability',
    callback = function(val) __AmferConfig.Combat.AutoAbility = val end
})
__TabCombat:create_toggle('anti_curve', {
    title = 'anti curve detection',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiCurve = val end
})
__TabCombat:create_toggle('anti_infinity', {
    title = 'anti infinity',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiInfinity = val end
})
__TabCombat:create_toggle('anti_death_slash', {
    title = 'anti death slash',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiDeathSlash = val end
})
__TabCombat:create_toggle('anti_time_hole', {
    title = 'anti time hole',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiTimeHole = val end
})
__TabCombat:create_toggle('anti_slash_of_fury', {
    title = 'anti slash of fury (spam < 32)',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiSlashOfFury = val end
})
__TabCombat:create_toggle('anti_phantom', {
    title = 'anti phantom',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiPhantom = val end
})
__TabCombat:create_toggle('anti_singularity', {
    title = 'anti singularity cape',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiSingularity = val end
})
__TabCombat:create_toggle('anti_combo', {
    title = 'anti combo counter',
    default = true,
    callback = function(val) __AmferConfig.Combat.AntiCombo = val end
})
__TabCombat:create_toggle('cooldown_protection', {
    title = 'cooldown protection',
    default = false,
    callback = function(val) __AmferConfig.Combat.CooldownProtection = val end
})
__TabVisuals:create_toggle('no_particle', {
    title = 'no particle',
    callback = function(val)
        __AmferConfig.Particle.NoParticle = val
        if __LocalPlayer.PlayerScripts.EffectScripts:FindFirstChild("ClientFX") then
            __LocalPlayer.PlayerScripts.EffectScripts.ClientFX.Disabled = val
        end
    end
})
__TabVisuals:create_slider('fps_cap', {
    title = 'fps cap',
    min = 5,
    max = 360,
    rounding = 0,
    default = 144,
    callback = function(val) setfpscap(tonumber(val)) end
})
__TabMisc:create_toggle('walkspeed', {
    title = 'walkspeed value',
    callback = function(val)
        __AmferConfig.Client.WsToggle = val
        if not val and __LocalPlayer.Character then
            __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = 36
        end
    end
})
__TabMisc:create_slider('ws_val', {
    title = 'ws value',
    min = 16,
    max = 200,
    default = 36,
    callback = function(val) __AmferConfig.Client.WalkSpeed = val end
})
__TabMisc:create_toggle('jumppower', {
    title = 'jump power enable',
    callback = function(val)
        __AmferConfig.Client.JpToggle = val
        if not val and __LocalPlayer.Character then
            __LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = 50
        end
    end
})
__TabMisc:create_slider('jp_val', {
    title = 'jp value',
    min = 50,
    max = 400,
    default = 50,
    callback = function(val) __AmferConfig.Client.JumpPower = val end
})
__TabMisc:create_toggle('status', {
    title = 'status ui',
    callback = function(val) __AmferConfig.Client.Status = val end
})
__TabMisc:create_keybind('minimize_bind', {
    title = 'Minimize UI',
    default = getgenv().sets.keybind,
    mode = 'Toggle',
    callback = function(keybind)
        if __Interface and __Interface.Minimize then __Interface:Minimize() end
        getgenv().sets.keybind = keybind
    end
})
task.spawn(function()
    local __MainLogicGate = 0
    local function __MainLogicGated()
        local __T = tick()
        if (__T - __MainLogicGate) < 0.008 then return end
        __MainLogicGate = __T
        __MainLogic()
    end
    __RunService.RenderStepped:Connect(__MainLogicGated)
    __RunService.Heartbeat:Connect(__MainLogicGated)
    __RunService.PreSimulation:Connect(__MainLogicGated)

    local __FPSCount = 0
    local __FPSWal = tick()
    __RunService.RenderStepped:Connect(function()
        if tick() > __FPSWal then
            __UserFPS = __FPSCount
            __FPSCount = 0
            __FPSWal = tick() + 1
        else
            __FPSCount = __FPSCount + 1
        end
    end)
    __Workspace.ChildAdded:Connect(function(child)
        if __AmferConfig.Particle.NoParticle then
            local __N = tostring(child)
            if __N == "clash" or __N == "shine" then
                child.Anchored = true
                child.CFrame = __HidenCFrame
                child.Size = Vector3.one
            end
        end
    end)
    getfenv()['MainFunction'] = __MainLogic
end)
local __ReplicatedRemotes = __ReplicatedStorage:WaitForChild("Remotes")
if __ReplicatedRemotes:FindFirstChild("ParrySuccessAll") then
    __ReplicatedRemotes.ParrySuccessAll.OnClientEvent:Connect(function(a1, MyCharacter)
        if __LocalPlayer.Character and __LocalPlayer.Character:FindFirstChild('HumanoidRootPart') == MyCharacter then
            __ParryTimeNow = tick()
            __ParryTimeViewer = (__ParryTimeNow - __ParryLastTime)
            __ParryLastTime = __ParryTimeNow
            __LastAckTick = __ParryTimeNow
            __PendingParry = nil
        end
    end)
end
if __ReplicatedRemotes:FindFirstChild("Phantom") then
    __ReplicatedRemotes.Phantom.OnClientEvent:Connect(function(a, b)
        __Phantom = (b.Name == tostring(__LocalPlayer))
    end)
end
__Balls.ChildAdded:Connect(function() __Phantom = false end)
__Balls.ChildRemoved:Connect(function() __Phantom = false end)
__Workspace.Runtime.ChildAdded:Connect(function(v) if v.Name == 'Tornado' then __TornadoTime = tick() end end)
local __TabUnlocker = __Interface:create_tab('Unlocker', 'unlock')
do
    local __HttpService = cloneref(game:GetService("HttpService"))
    local __TextChatService = cloneref(game:GetService("TextChatService"))
    local __PlayerGui = __LocalPlayer:WaitForChild("PlayerGui")
    local __UnlockForcedOwnedSet = {}
    local __UnlockSelectedExplosion = nil
    local __UnlockOriginalFields = {}
    local __UNLOCK_SAVE_FILE = "RoniHub/unlock_save.json"
    local __UnlockPersist = { FakeFavorites = {} }
    local __UnlockHasFiles = (typeof(writefile) == "function") and (typeof(readfile) == "function") and (typeof(isfile) == "function")

    getgenv().__RoniUnlockEnabled = false
    getgenv().__RoniSwordName = nil
    _G.__RoniTitleState = _G.__RoniTitleState or { Selected = nil }

    local function __UnlockEnsureFolder()
        if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
            if not isfolder("RoniHub") then pcall(makefolder, "RoniHub") end
        end
    end

    local function __UnlockLoadPersist()
        if not __UnlockHasFiles then return end
        __UnlockEnsureFolder()
        if isfile(__UNLOCK_SAVE_FILE) then
            local ok, data = pcall(function() return __HttpService:JSONDecode(readfile(__UNLOCK_SAVE_FILE)) end)
            if ok and type(data) == "table" then
                __UnlockPersist.FakeFavorites = data.FakeFavorites or {}
            end
        end
    end

    local __UnlockSavePending = false
    local function __UnlockSavePersist()
        if not __UnlockHasFiles then return end
        if __UnlockSavePending then return end
        __UnlockSavePending = true
        task.delay(0.3, function()
            __UnlockSavePending = false
            __UnlockEnsureFolder()
            pcall(function()
                writefile(__UNLOCK_SAVE_FILE, __HttpService:JSONEncode(__UnlockPersist))
            end)
        end)
    end

    __UnlockLoadPersist()

    task.spawn(function()
        local __ShopController = require(__ReplicatedStorage.Controllers.UI.ShopController)
        local __InventoryController = require(__ReplicatedStorage.Controllers.Trading.InventoryController)
        local __Swords = require(__ReplicatedStorage.Shared.ReplicatedInstances.Swords)
        local __Statable = require(__ReplicatedStorage.Shared.Statable)
        local __Inventory_Shared = require(__ReplicatedStorage.Shared.Inventory.Shared)
        local __ItemInfo = require(__ReplicatedStorage.Shared.ItemInfo)
        local __Shop = __PlayerGui:WaitForChild("Shop")
        local __BuyButton = __Shop.Holder.InfoBG.BuyButton
        local __DeleteButton = __Shop.Holder.InfoBG.Delete
        local __FavoriteButton = __Shop.Holder.Favorite
        local __ShopDisabledConns = {}
        local __UNLOCK_TYPES = { Sword = true, Explosion = true }
        local __FAVORITE_TYPES = { Sword = true, Explosion = true, Ability = true }
        local __FakeFavorites = __UnlockPersist.FakeFavorites
        local __FAV_IMG = {
            [true]  = { Image = "rbxassetid://15697987058", HoverImage = "rbxassetid://15697983062" },
            [false] = { Image = "rbxassetid://15697981750", HoverImage = "rbxassetid://15697987058" },
        }

        local function __BypassSwordOwnership()
            if not __Swords or type(__Swords.EquipSwordTo) ~= "function" then return end
            pcall(function()
                for i = 1, 15 do
                    local ok, val = pcall(debug.getupvalue, __Swords.EquipSwordTo, i)
                    if ok and type(val) == "boolean" and val == true then
                        pcall(debug.setupvalue, __Swords.EquipSwordTo, i, false)
                    end
                end
            end)
        end

        local function __GrabAndDisable(signal)
            local fn
            for _, c in getconnections(signal) do
                if c and c.Function then
                    fn = fn or c.Function
                    if c.Disable then
                        c:Disable()
                        table.insert(__ShopDisabledConns, c)
                    end
                end
            end
            return fn
        end

        local function __ReDisableShop()
            for _, c in ipairs(__ShopDisabledConns) do
                pcall(function() if c.Disable then c:Disable() end end)
            end
        end

        local function __DoUnlockAll()
            local __Categories = { Sword = true, Explosion = true }
            for Category in pairs(__Categories) do
                local Shop_List = __ShopController._virtualItems[Category]
                if Shop_List then
                    for _, Value in pairs(Shop_List) do
                        local already = false
                        pcall(function() already = Value.OwnsItem:Get() == true end)
                        if not __UnlockForcedOwnedSet[Value] then
                            __UnlockForcedOwnedSet[Value] = { type = Category, trulyOwned = already }
                        end
                        if not already then
                            pcall(function() Value.OwnsItem:Set(true) end)
                            pcall(function() Value.Section:Set("Owned") end)
                            pcall(function() Value.ForceHide:Set(false) end)
                        end
                    end
                end
            end
        end

        if typeof(__Inventory_Shared.FindItems) == "function" then
            local __RealFindItems
            __RealFindItems = hookfunction(__Inventory_Shared.FindItems, function(self, caller, inventoryType, itemName, filter)
                if not getgenv().__RoniUnlockEnabled then
                    return __RealFindItems(self, caller, inventoryType, itemName, filter)
                end
                local ok, real = pcall(__RealFindItems, self, caller, inventoryType, itemName, filter)
                if ok and type(real) == "table" and #real > 0 then return real end
                if not __UNLOCK_TYPES[inventoryType] then
                    if ok then return real end
                    return {}
                end
                if itemName ~= nil then return { itemName } end
                return {}
            end)
        end

        local function __FindVirtualItem(itemType, name)
            local list = __ShopController._virtualItems[itemType]
            if not list then return nil end
            for key, item in pairs(list) do
                if item and (item.Name == name or key == name) then return item end
            end
            return nil
        end

        local function __PinItem(item)
            if not item then return end
            if __UnlockOriginalFields[item] then
                item.Name_ = __Statable.State("#\0|" .. (item.Name or ""))
                item.LayoutOrder = __Statable.State(-1000000000)
                return
            end
            __UnlockOriginalFields[item] = { Name_ = item.Name_, LayoutOrder = item.LayoutOrder }
            item.Name_ = __Statable.State("#\0|" .. (item.Name or ""))
            item.LayoutOrder = __Statable.State(-1000000000)
        end

        local function __UnpinItem(item)
            local orig = __UnlockOriginalFields[item]
            if not orig then return end
            item.Name_ = orig.Name_
            item.LayoutOrder = orig.LayoutOrder
            __UnlockOriginalFields[item] = nil
        end

        local function __ReSort(itemType)
            local page = __ShopController._inventoryPages[itemType]
            if page and page.Scroll then pcall(function() page.Scroll.Sort() end) end
        end

        local function __ApplyFakeFavorite(itemType, name, state, skipSave)
            __FakeFavorites[itemType] = __FakeFavorites[itemType] or {}
            __FakeFavorites[itemType][name] = state or nil
            local favState = __InventoryController:GetFavoriteState(itemType, name)
            if favState then favState:Set(state and true or false) end
            local item = __FindVirtualItem(itemType, name)
            if item then
                if state then __PinItem(item) else __UnpinItem(item) end
            end
            __ReSort(itemType)
            if not skipSave then __UnlockSavePersist() end
        end

        local __FavOriginal = __GrabAndDisable(__FavoriteButton.Activated)
        __FavoriteButton.Activated:Connect(function(...)
            if not getgenv().__RoniUnlockEnabled then
                if __FavOriginal then return __FavOriginal(...) end
                return
            end
            local sel = __ShopController._selectedItem
            if not sel or not __FAVORITE_TYPES[sel.type] then return end
            local current = __FakeFavorites[sel.type] and __FakeFavorites[sel.type][sel.name]
            __ApplyFakeFavorite(sel.type, sel.name, not current)
            local on = __FakeFavorites[sel.type] and __FakeFavorites[sel.type][sel.name] or false
            for k, v in pairs(__FAV_IMG[on]) do __FavoriteButton[k] = v end
        end)

        local __DeleteItemPromptController = require(__ReplicatedStorage.Controllers.DeleteItemPromptController)

        local function __RemoveVirtualItem(itemType, name)
            local list = __ShopController._virtualItems[itemType]
            if not list then return end
            for key, item in pairs(list) do
                if item and (item.Name == name or key == name) then
                    local page = __ShopController._inventoryPages[itemType]
                    if page and page.Scroll then
                        pcall(function() page.Scroll.RemoveInstance("Owned", item) end)
                        pcall(function() page.Scroll.RemoveInstance("Unowned", item) end)
                    end
                    if item.Trove then pcall(function() item.Trove:Destroy() end) end
                    list[key] = nil
                end
            end
        end

        local function __DoFakeDelete(itemType, name)
            if itemType == "Sword" and getgenv().__RoniSwordName == name then
                getgenv().__RoniSwordName = "Base Sword"
                local Base = __Swords:GetSword("Base Sword")
                if Base then
                    __BypassSwordOwnership()
                    pcall(function() __Swords:EquipSwordTo(__LocalPlayer.Character, Base.Name) end)
                end
            end
            __UnlockSavePersist()
            __RemoveVirtualItem(itemType, name)
            __ShopController._selectedItem = nil
        end

        local __DelOriginal = __GrabAndDisable(__DeleteButton.Activated)
        __DeleteButton.Activated:Connect(function(...)
            if not getgenv().__RoniUnlockEnabled then
                if __DelOriginal then return __DelOriginal(...) end
                return
            end
            local sel = __ShopController._selectedItem
            if not sel or (sel.type ~= "Sword" and sel.type ~= "Explosion") then return end
            local Type, Name = sel.type, sel.name
            local info = __ItemInfo[Type] and __ItemInfo[Type][Name]
            local displayName = (info and info.DisplayName) or Name
            __DeleteItemPromptController:PromptConfirmation({
                PromptType = "Single",
                Description = string.format("Are you sure you want to delete x1 %s? This cannot be undone.", displayName),
            }, function(confirmed) if confirmed then __DoFakeDelete(Type, Name) end end)
        end)

        __ShopController.itemSelected:Connect(function()
            task.defer(function()
                local sel = __ShopController._selectedItem
                if getgenv().__RoniUnlockEnabled and sel and (sel.type == "Sword" or sel.type == "Explosion") then
                    __DeleteButton.Visible = true
                end

                if sel and __FAVORITE_TYPES[sel.type] then
                    local on = __FakeFavorites[sel.type] and __FakeFavorites[sel.type][sel.name] or false
                    for k, v in pairs(__FAV_IMG[on]) do __FavoriteButton[k] = v end
                end

                if getgenv().__RoniUnlockEnabled and sel and (sel.type == "Sword" or sel.type == "Explosion") then
                    __BuyButton.Visible = true
                    if sel.type == "Sword" and getgenv().__RoniSwordName == sel.name then
                        __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                    elseif sel.type == "Explosion" and __UnlockSelectedExplosion == sel.name then
                        __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                    else
                        __BuyButton.PriceTag.TextLabel.Text = "Equip"
                    end
                end
            end)
        end)
        local __OriginalBuyHandlers = {}
        for _, c in getconnections(__BuyButton.Activated) do
            if c and c.Function then table.insert(__OriginalBuyHandlers, c.Function) end
        end
        __GrabAndDisable(__BuyButton.Activated)
        local __SwordFunction = nil
        for _, c in getconnections(__ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent) do
            if c and c.Function then __SwordFunction = c.Function; break end
        end
        local __ExplosionModule = require(__ReplicatedStorage.Controllers.VFXController)
        local __OriginalPlayExplosion = __ExplosionModule.PlayExplosion
        local __PlayParry = nil
        for _, c in getconnections(__ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent) do
            if c and c.Function then __PlayParry = c.Function end
        end
        if __PlayParry then
            for _, c in getconnections(__ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent) do
                if c and c.Function then c:Disable() end
            end
            __ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
                local Args = { ... }
                local Sword = __Swords:GetSword(getgenv().__RoniSwordName)
                local hrp = __LocalPlayer.Character and __LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if Sword and (Args[4] == hrp or tostring(Args[4]) == __LocalPlayer.Name) then
                    Args[1] = Sword.SlashName
                    Args[3] = Sword.Name
                end
                if __LocalPlayer.Character and __LocalPlayer.Character:FindFirstChild('HumanoidRootPart') == Args[2] then
                    __ParryTimeNow = tick()
                    __ParryTimeViewer = (__ParryTimeNow - __ParryLastTime)
                    __ParryLastTime = __ParryTimeNow
                    __LastAckTick = __ParryTimeNow
                    __PendingParry = nil
                end
                return __PlayParry(unpack(Args))
            end)
        end
        __BuyButton.Activated:Connect(function(...)
            local Sell = __ShopController._selectedItem
            if not Sell then return end
            local Type, Name = Sell.type, Sell.name
            if not getgenv().__RoniUnlockEnabled or (Type ~= "Sword" and Type ~= "Explosion") then
                for _, handler in ipairs(__OriginalBuyHandlers) do pcall(handler, ...) end
                return
            end
            if Type == "Sword" and getgenv().__RoniSwordName == Name then
                __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                return
            end
            if Type == "Explosion" and __UnlockSelectedExplosion == Name then
                __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                return
            end
            if Type == "Sword" then
                __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                __BypassSwordOwnership()
                local Sword_Model = __Swords:GetSword(Name)
                getgenv().__RoniSwordName = Sword_Model.Name
                pcall(function() __Swords:EquipSwordTo(__LocalPlayer.Character, Sword_Model.Name) end)
                if __SwordFunction then pcall(__SwordFunction, Sword_Model.Name) end
                __UnlockSavePersist()
            elseif Type == "Explosion" then
                __BuyButton.PriceTag.TextLabel.Text = "Equipped"
                __UnlockSelectedExplosion = Name
                __ExplosionModule.PlayExplosion = function(self, name, position, ball, character, attributionCharacter, kill)
                    if getgenv().__RoniUnlockEnabled and __UnlockSelectedExplosion and __UnlockSelectedExplosion ~= "" then
                        if kill and attributionCharacter == __LocalPlayer.Character then name = __UnlockSelectedExplosion end
                    end
                    return __OriginalPlayExplosion(self, name, position, ball, character, attributionCharacter, kill)
                end
            end
        end)
        __LocalPlayer.CharacterAppearanceLoaded:Connect(function()
            if not getgenv().__RoniUnlockEnabled or not getgenv().__RoniSwordName then return end
            __BypassSwordOwnership()
            pcall(function() __Swords:EquipSwordTo(__LocalPlayer.Character, getgenv().__RoniSwordName) end)
            if __SwordFunction then pcall(__SwordFunction, getgenv().__RoniSwordName) end
        end)
        local function __Hex(color)
            return string.format("#%02X%02X%02X", math.floor(color.R*255+0.5), math.floor(color.G*255+0.5), math.floor(color.B*255+0.5))
        end
        local function __BuildTitleText()
            local sel = _G.__RoniTitleState.Selected
            if not sel then return "" end
            return string.format('<font color="%s">%s</font>', __Hex(sel.Color), sel.Text)
        end
        local __TITLE_PATHS = {
            { "Customize", "Profile", "Playerprofile", "Details", "Title" },
            { "Customize", "PlayerCard", "Title" },
        }
        local function __IsOwnProfileCard(pc)
            if not pc then return false end
            for _, desc in ipairs(pc:GetDescendants()) do
                if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                    local txt = desc.Text
                    if txt and (txt == __LocalPlayer.Name or txt == __LocalPlayer.DisplayName or string.find(txt, __LocalPlayer.DisplayName, 1, true)) then return true end
                end
            end
            return false
        end
        local function __GetTitleLabels()
            local out = {}
            local pc = __PlayerGui:FindFirstChild("ProfileCard")
            if not pc or not __IsOwnProfileCard(pc) then return out end
            for _, path in ipairs(__TITLE_PATHS) do
                local node = pc
                for _, n in ipairs(path) do if node then node = node:FindFirstChild(n) end end
                if node and (node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox")) then table.insert(out, node) end
            end
            return out
        end
        local function __ForceTitleLabel(lbl)
            local want = __BuildTitleText()
            pcall(function()
                lbl.RichText = true; lbl.Visible = true; lbl.TextTransparency = 0
                if lbl.TextSize == 0 then lbl.TextSize = 18 end
                if lbl.TextColor3 == Color3.new(0,0,0) then lbl.TextColor3 = Color3.new(1,1,1) end
                if lbl.Text ~= want then lbl.Text = want end
            end)
        end
        local function __UpdateProfileCardTitle()
            if not getgenv().__RoniUnlockEnabled then return end
            for _, lbl in ipairs(__GetTitleLabels()) do __ForceTitleLabel(lbl) end
        end
        __PlayerGui.DescendantAdded:Connect(function(d)
            if not d then return end
            if d.Name == "Title" and (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) then
                if d:FindFirstAncestor("ProfileCard") then
                    task.delay(0.05, __UpdateProfileCardTitle)
                    task.delay(0.3, __UpdateProfileCardTitle)
                    task.delay(1.0, __UpdateProfileCardTitle)
                end
            end
        end)
        local function __RunProfileCardTitleLoop(pc)
            task.spawn(function()
                while pc.Parent do pcall(__UpdateProfileCardTitle); task.wait(0.1) end
            end)
        end
        local existingCard = __PlayerGui:FindFirstChild("ProfileCard")
        if existingCard then __RunProfileCardTitleLoop(existingCard) end
        __PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == "ProfileCard" then __RunProfileCardTitleLoop(child) end
        end)

        task.spawn(function()
            local ok, Title_Data = pcall(function() return require(__ReplicatedStorage.Shared:WaitForChild("TitleData")) end)
            if not ok or not Title_Data then return end
            local List = __PlayerGui:WaitForChild("Settings"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("SettingTitles"):WaitForChild("TitleList")
            local needed = #Title_Data + 1
            for _ = 1, 60 do
                local count = 0
                for _, c in ipairs(List:GetChildren()) do if c:IsA("ImageButton") then count = count + 1 end end
                if count >= needed then break end
                task.wait(0.25)
            end
            local UI_Rows = {}
            for _, Row in ipairs(List:GetChildren()) do if Row:IsA("ImageButton") then table.insert(UI_Rows, Row) end end
            table.sort(UI_Rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
            for Index, Data in ipairs(Title_Data) do
                local Row = UI_Rows[Index + 1]
                if not Row then break end
                local Label = Row:FindFirstChild("TextLabel")
                if Label and Data.Tag then Label.Text = Data.Tag.Text; Label.TextColor3 = Data.Tag.Color end
                Row.Name = Data.Name or Row.Name
                Row.Visible = true
            end
            local Selected_Row = nil
            for i, Row in ipairs(UI_Rows) do
                local rowIndex = i
                Row.Activated:Connect(function()
                    Selected_Row = Row
                    local Data = Title_Data[rowIndex - 1]
                    if rowIndex == 1 or not Data then
                        _G.__RoniTitleState.Selected = nil
                    else
                        _G.__RoniTitleState.Selected = { Text = Data.Tag.Text, Color = Data.Tag.Color }
                    end
                    for _, Other in ipairs(UI_Rows) do
                        local Highlighted = Other:FindFirstChild("Selected")
                        if Highlighted then Highlighted.Visible = (Other == Selected_Row) end
                    end
                    __UpdateProfileCardTitle()
                end)
            end
        end)

        task.delay(0.5, __UpdateProfileCardTitle)
        pcall(function()
            if __TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                __TextChatService.OnIncomingMessage = function(message)
                    local props = Instance.new("TextChatMessageProperties")
                    if getgenv().__RoniUnlockEnabled and message.TextSource and message.TextSource.UserId == __LocalPlayer.UserId then
                        local sel = _G.__RoniTitleState.Selected
                        if sel then
                            props.PrefixText = string.format('<font color="%s">[%s]</font> <font color="%s">%s</font>', __Hex(sel.Color), sel.Text, __Hex(sel.Color), __LocalPlayer.DisplayName)
                        end
                    end
                    return props
                end
            end
        end)
        getgenv().__RoniUnlock_ReDisableShop = __ReDisableShop
        getgenv().__RoniUnlock_DoUnlockAll = __DoUnlockAll
        getgenv().__RoniUnlock_ReapplyFavorites = function()
            task.spawn(function()
                for _ = 1, 10 do
                    task.wait(0.1)
                    if not getgenv().__RoniUnlockEnabled then return end
                    for itemType, names in pairs(__FakeFavorites) do
                        for name, on in pairs(names) do
                            if on then __ApplyFakeFavorite(itemType, name, true, true) end
                        end
                    end
                end
            end)
        end
        if getgenv().__RoniUnlockEnabled then
            __DoUnlockAll()
            for itemType, names in pairs(__FakeFavorites) do
                for name, on in pairs(names) do
                    if on then __ApplyFakeFavorite(itemType, name, true, true) end
                end
            end
        end
    end)
    __TabUnlocker:create_toggle('unlock_all', {
        title = 'unlock all',
        default = false,
        callback = function(val)
            getgenv().__RoniUnlockEnabled = val
            if val then
                if getgenv().__RoniUnlock_ReDisableShop then pcall(getgenv().__RoniUnlock_ReDisableShop) end
                if getgenv().__RoniUnlock_DoUnlockAll then pcall(getgenv().__RoniUnlock_DoUnlockAll) end
                if getgenv().__RoniUnlock_ReapplyFavorites then pcall(getgenv().__RoniUnlock_ReapplyFavorites) end
            end
        end
    })
end
__Interface:select_tab(1)
