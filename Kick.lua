--[[
    Advanced UI Component System
    Version 2.4.1
    Licensed Module
]]

local function InitializeCore()
    local ServiceCache = {}
    local function GetService(name)
        if not ServiceCache[name] then
            ServiceCache[name] = game:GetService(name)
        end
        return ServiceCache[name]
    end
    
    local Players = GetService(string.char(80,108,97,121,101,114,115))
    local UserInput = GetService(string.char(85,115,101,114,73,110,112,117,116,83,101,114,118,105,99,101))
    local TweenService = GetService(string.char(84,119,101,101,110,83,101,114,118,105,99,101))
    
    return Players, UserInput, TweenService
end

local Players, UserInput, TweenService = InitializeCore()

local UIModule = {}
UIModule.__index = UIModule

function UIModule.new()
    local self = setmetatable({}, UIModule)
    
    self.LocalPlayer = Players.LocalPlayer
    self.GuiParent = self.LocalPlayer:WaitForChild(string.char(80,108,97,121,101,114,71,117,105))
    
    self.DragState = {
        Active = false,
        StartPos = nil,
        ElementPos = nil,
        HasMoved = false,
        InputObj = nil
    }
    
    self:CreateInterface()
    self:BindEvents()
    
    return self
end

function UIModule:CreateInterface()
    local Container = Instance.new(string.char(83,99,114,101,101,110,71,117,105))
    Container.Name = string.char(67,111,114,101,83,121,115,116,101,109)
    Container.ResetOnSpawn = false
    Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Container.IgnoreGuiInset = true
    Container.Parent = self.GuiParent
    
    local ActionButton = Instance.new(string.char(84,101,120,116,66,117,116,116,111,110))
    ActionButton.Name = string.char(65,99,116,105,111,110,67,111,109,112,111,110,101,110,116)
    ActionButton.Size = UDim2.new(0, 120, 0, 55)
    ActionButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    ActionButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ActionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ActionButton.BorderSizePixel = 0
    ActionButton.Text = string.char(75,73,67,75)
    ActionButton.TextColor3 = Color3.fromRGB(255, 85, 85)
    ActionButton.TextSize = 18
    ActionButton.Font = Enum.Font.GothamBold
    ActionButton.AutoButtonColor = false
    ActionButton.Parent = Container
    
    local BorderFrame = Instance.new(string.char(70,114,97,109,101))
    BorderFrame.Name = string.char(66,111,114,100,101,114)
    BorderFrame.Size = UDim2.new(1, 4, 1, 4)
    BorderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    BorderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    BorderFrame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    BorderFrame.BorderSizePixel = 0
    BorderFrame.ZIndex = 0
    BorderFrame.Parent = ActionButton
    
    local Corner1 = Instance.new(string.char(85,73,67,111,114,110,101,114))
    Corner1.CornerRadius = UDim.new(0, 12)
    Corner1.Parent = ActionButton
    
    local Corner2 = Instance.new(string.char(85,73,67,111,114,110,101,114))
    Corner2.CornerRadius = UDim.new(0, 12)
    Corner2.Parent = BorderFrame
    
    local Gradient = Instance.new(string.char(85,73,71,114,97,100,105,101,110,116))
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
    }
    Gradient.Rotation = 45
    Gradient.Parent = ActionButton
    
    self.Container = Container
    self.Button = ActionButton
end

function UIModule:AnimatePress(pressed)
    local targetColor = pressed and Color3.fromRGB(15, 15, 25) or Color3.fromRGB(25, 25, 35)
    local targetSize = pressed and UDim2.new(0, 115, 0, 52) or UDim2.new(0, 120, 0, 55)
    
    local tween1 = TweenService:Create(
        self.Button,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = targetColor, Size = targetSize}
    )
    tween1:Play()
end

function UIModule:UpdatePosition(inputPos)
    local delta = inputPos - self.DragState.StartPos
    local newPos = UDim2.new(
        self.DragState.ElementPos.X.Scale,
        self.DragState.ElementPos.X.Offset + delta.X,
        self.DragState.ElementPos.Y.Scale,
        self.DragState.ElementPos.Y.Offset + delta.Y
    )
    
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(self.Button, tweenInfo, {Position = newPos})
    tween:Play()
end

function UIModule:ExecuteAction()
    if not self.DragState.HasMoved then
        local message = string.char(72,97,115,32,112,114,101,115,105,111,110,97,100,111,32,101,108,32,98,111,116,195,179,110,32,75,73,67,75,32,240,159,154,170)
        self.LocalPlayer:Kick(message)
    end
end

function UIModule:BindEvents()
    self.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            self.DragState.Active = true
            self.DragState.StartPos = input.Position
            self.DragState.ElementPos = self.Button.Position
            self.DragState.HasMoved = false
            
            self:AnimatePress(true)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.DragState.Active = false
                    self:AnimatePress(false)
                end
            end)
        end
    end)
    
    self.Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            self.DragState.InputObj = input
        end
    end)
    
    UserInput.InputChanged:Connect(function(input)
        if input == self.DragState.InputObj and self.DragState.Active then
            self.DragState.HasMoved = true
            self:UpdatePosition(input.Position)
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self:ExecuteAction()
    end)
end

local UIInstance = UIModule.new()

return UIInstance