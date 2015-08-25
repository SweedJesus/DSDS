-- 0. Play sound, wait to start animation
-- 1. Background fade in
-- 2. Text fade and zoom in
-- 3. Text hold
-- 4. Text grow horizontal. At 50%...
-- 5. Background and text fade out

local MEDIA_PATH = "Interface\\AddOns\\DSDS\\media\\"

local SOUND_YOU_DIED = MEDIA_PATH.."YOUDIED.ogg"
local TEXT_YOU_DIED  = MEDIA_PATH.."YOUDIED.tga"

local screen_height = UIParent:GetHeight()

local BG_SOLID_HEIGHT_SCALE = 0.15
local BG_GRADIENT_HEIGHT_SCALE = 0.10

local TEXT_FULL_HEIGHT = screen_height * 0.18
local TEXT_FULL_WIDTH = TEXT_FULL_HEIGHT * 4

-- 0. Play sound, wait to start animation
local ANIM0 = "DSDS_Anim0"
local ANIM0_LENGTH = 0.5

-- 1. Background fade in
local ANIM1 = "DSDS_Anim1"
local ANIM1_LENGTH = 0.2
local ANIM1_NUM_STEPS = 10
local ANIM1_BACK_START_ALPHA = 0.0
local ANIM1_BACK_END_ALPHA = 0.9

-- 2. Text fade and zoom in
local ANIM2 = "DSDS_Anim2"
local ANIM2_LENGTH = 0.3
local ANIM2_NUM_STEPS = 15
local ANIM2_TEXT_START_ALPHA = 0.0
local ANIM2_TEXT_START_SCALE = 0.9
local ANIM2_TEXT_END_ALPHA = 0.6
local ANIM2_TEXT_END_SCALE = 1.0

-- 3. Text hold
local ANIM3 = "DSDS_Anim3"
local ANIM3_LENGTH = 1

-- 4. Text grow horizontal. At 50%...
local ANIM4 = "DSDS_Anim4"
local ANIM4_LENGTH = 0.2
local ANIM4_NUM_STEPS = 10
local ANIM4_TEXT_START_ALPHA = ANIM2_TEXT_END_ALPHA
local ANIM4_TEXT_START_SCALE = ANIM2_TEXT_END_SCALE
local ANIM4_TEXT_START_WIDTH_SCALE = 1.0
local ANIM4_TEXT_END_ALPHA = ANIM4_TEXT_START_ALPHA
local ANIM4_TEXT_END_SCALE = ANIM4_TEXT_START_SCALE
local ANIM4_TEXT_END_WIDTH_SCALE = 1.05

-- 5. Background and text fade out
local ANIM5 = "DSDS_Anim5"
local ANIM5_LENGTH = 0.2
local ANIM5_NUM_STEPS = 10
local ANIM5_BACK_START_ALPHA = ANIM1_BACK_END_ALPHA
local ANIM5_TEXT_START_ALPHA = ANIM4_TEXT_END_ALPHA
local ANIM5_TEXT_START_SCALE = ANIM4_TEXT_END_SCALE
local ANIM5_TEXT_START_WIDTH_SCALE = ANIM4_TEXT_END_WIDTH_SCALE
local ANIM5_BACK_END_ALPHA = 0
local ANIM5_TEXT_END_ALPHA = 0
local ANIM5_TEXT_END_SCALE = ANIM5_TEXT_START_SCALE
local ANIM5_TEXT_END_WIDTH_SCALE = 1.1

-- Reset
local RESET_BACK_START_ALPHA = ANIM1_BACK_START_ALPHA
local RESET_TEXT_START_ALPHA = ANIM2_TEXT_START_ALPHA
local RESET_TEXT_START_SCALE = ANIM2_TEXT_START_SCALE
local RESET_TEXT_START_WIDTH_SCALE = ANIM4_TEXT_START_WIDTH_SCALE

local M = AceLibrary("Metrognome-2.0")

-- Create addon module
DSDS = AceLibrary("AceAddon-2.0"):new(
"AceConsole-2.0",
"AceDebug-2.0",
"AceDB-2.0",
"AceEvent-2.0")

function DSDS:OnInitialize()
    self.counter = 0

    self:InitBackground()
    self:InitText()
    self:InitTimers()

    self:RegisterChatCommand({ "/DSDS", "/at" }, {
        type = "group",
        args = {
            you_died_test = {
                name = "You Died",
                desc = "Test the You Died animation.",
                type = "execute",
                func = function()
                    self:YouDied()
                end
            }
        }
    })
end

function DSDS:OnEnable()
    self.was_fake_death = false

    self.background.alpha = 0
    self.background:SetAlpha(0)
    self.text.alpha = 0
    self.text:SetAlpha(0)

    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("PLAYER_AURAS_CHANGED")
end

function DSDS:OnDisable()
end

local SOR = "Interface\\Icons\\INV_Enchant_EssenceEternalLarge"
local FD  = "Interface\\Icons\\Ability_Rogue_FeignDeath"

function DSDS:PLAYER_DEAD()
    self:Debug("PLAYER_DEAD")
    local i, buff, sor, fd = 1, UnitBuff("player", 1), false
    while buff and (not sor or not fd) do
        sor = buff == SOR
        fd = buff == FD
        i = i + 1
        buff = UnitBuff("player", i)
    end
    if not (sor or fd) then
        self:Debug("You died!")
        self:YouDied()
    elseif sor then
        self:Debug("You died! (gained SOR)")
        self.was_fake_death = true
    else
        self:Debug("You feigned death!")
    end
end

function DSDS:PLAYER_AURAS_CHANGED()
    if UnitIsDead("player") then
        if self.was_fake_death then
            self.was_fake_death = false
            self:Debug("You died! (lost SOR)")
            self:YouDied()
        end
    end
end

function DSDS:InitBackground()
    local f = self.background or CreateFrame("Frame")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(1)
    f.alpha = 0

    local screen_height = UIParent:GetHeight()

    -- Background components
    local t = f:CreateTexture()
    local m = f:CreateTexture()
    local b = f:CreateTexture()
    f.top, f.middle, f.bottom = t, m, b

    for _,f in { t, m, b } do
        f:SetTexture(0, 0, 0)
        f:SetWidth(UIParent:GetWidth())
    end

    -- Top gradient
    t:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
    t:SetHeight(BG_GRADIENT_HEIGHT_SCALE * screen_height)
    t:SetPoint("BOTTOM", m, "TOP")

    -- Middle
    m:SetHeight(BG_SOLID_HEIGHT_SCALE * screen_height)
    m:SetPoint("CENTER", UIParent, "CENTER")

    -- Bottom gradient
    b:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
    b:SetHeight(BG_GRADIENT_HEIGHT_SCALE * screen_height)
    b:SetPoint("TOP", m, "BOTTOM")

    self.background = f
end

function DSDS:InitText()
    local f = self.you_died or CreateFrame("Frame")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(2)
    f.WIDTH = 512 * 1.2
    f.HEIGHT = 128 * 1.5

    f.alpha = 0
    f.scale = 1
    f.width_scale = 1

    f:SetWidth(f.WIDTH)
    f:SetHeight(f.HEIGHT)
    f:SetPoint("CENTER", UIParent, "CENTER")

    -- Actual texture
    local t = f:CreateTexture()
    f.texture = t
    t:SetTexture(TEXT_YOU_DIED)
    t:SetAllPoints()

    self.text = f
end

function DSDS:InitTimers()
    local b = self.background
    local t = self.text

    -- 0. Play sound, wait to start animation
    M:Register(ANIM0, function()
        self:Anim1()
    end, ANIM0_LENGTH)

    -- 1. Background fade in
    local freq = ANIM1_LENGTH / ANIM1_NUM_STEPS
    local alpha_step = ANIM1_BACK_END_ALPHA / ANIM1_NUM_STEPS
    M:Register(ANIM1, function()
        self.counter = self.counter + 1
        b.alpha = b.alpha + alpha_step
        b:SetAlpha(b.alpha)
        self:Debug("Animation 1 (%i) b.alpha:%s", self.counter, b.alpha)

        if self.counter == ANIM1_NUM_STEPS then
            self:Debug("|cffff0000Starting Animation 2|r")
            self:Anim2()
        end
    end, freq)

    -- 2. Text fade and zoom in
    local freq = ANIM2_LENGTH / ANIM2_NUM_STEPS
    local alpha_step = ANIM2_TEXT_END_ALPHA / ANIM2_NUM_STEPS
    local scale_step = (1 - ANIM2_TEXT_START_SCALE) / ANIM2_NUM_STEPS
    M:Register(ANIM2, function()
        self.counter = self.counter + 1
        t.alpha = t.alpha + alpha_step
        t.scale = t.scale + scale_step
        t:SetAlpha(t.alpha)
        t:SetScale(t.scale)
        self:Debug("Animation 2 (%i) t.alpha:%s t.scale:%s", self.counter, t.alpha, t.scale)

        if self.counter == ANIM2_NUM_STEPS then
            self:Debug("|cffff0000Starting Animation 3 (wait)|r")
            self:Anim3()
        end
    end, freq)

    -- 3. Text hold
    M:Register(ANIM3, function()
        self:Debug("Animation 3 (wait)")
        self:Debug("|cffff0000Starting Animation 4|r")
        self:Anim4()
    end, ANIM3_LENGTH)

    -- 4. Text grow horizontal. At 50%...
    local freq = ANIM4_LENGTH / ANIM4_NUM_STEPS
    local scale_step = (ANIM4_TEXT_END_WIDTH_SCALE - 1) / ANIM4_NUM_STEPS
    M:Register(ANIM4, function()
        self.counter = self.counter + 1
        t.width_scale = t.width_scale + scale_step
        t:SetWidth(t.WIDTH * t.width_scale)
        self:Debug("Animation 4 (%i) t.width_scale:%s", self.counter, t.width_scale)

        if self.counter == ANIM4_NUM_STEPS then
            self:Debug("|cffff0000Starting Animation 5|r")
            self:Anim5()
        end
    end, freq)

    -- 5. Background and text fade out
    local freq = ANIM5_LENGTH / ANIM5_NUM_STEPS
    local back_alpha_step = (ANIM5_BACK_END_ALPHA - ANIM5_BACK_START_ALPHA) / ANIM5_NUM_STEPS
    local text_alpha_step = (ANIM5_TEXT_END_ALPHA - ANIM5_TEXT_START_ALPHA) / ANIM5_NUM_STEPS
    local text_scale_step = (ANIM5_TEXT_END_WIDTH_SCALE - ANIM5_TEXT_START_WIDTH_SCALE) / ANIM5_NUM_STEPS
    M:Register(ANIM5, function()
        self.counter = self.counter + 1
        b.alpha = b.alpha + back_alpha_step
        t.alpha = t.alpha + text_alpha_step
        t.width_scale = t.width_scale + text_scale_step
        b:SetAlpha(b.alpha)
        t:SetAlpha(t.alpha)
        t:SetWidth(t.WIDTH * t.width_scale)
        self:Debug("Animation 5 (%i) t.alpha:%s t.scale:%s", self.counter, t.alpha, t.scale)
    end, freq)
end

-- 1. Background fade in
function DSDS:Anim1()
    self.counter = 0
    local b = self.background
    self:Debug("Animation 1")
    b.alpha = ANIM1_BACK_START_ALPHA
    b:SetAlpha(b.alpha)
    if M:Status(ANIM1) then
        M:Stop(ANIM1)
    end
    M:Start(ANIM1, ANIM1_NUM_STEPS)
end

-- 2. Text fade and zoom in
function DSDS:Anim2()
    self.counter = 0
    local t = self.text
    self:Debug("Animation 2")
    t.alpha = ANIM2_TEXT_START_ALPHA
    t.scale = ANIM2_TEXT_START_SCALE
    t:SetAlpha(t.alpha)
    t:SetScale(t.scale)
    t:SetWidth(t.WIDTH)
    if M:Status(ANIM2) then
        M:Stop(ANIM2)
    end
    M:Start(ANIM2, ANIM2_NUM_STEPS)
end

-- 3. Text hold
function DSDS:Anim3()
    self.counter = 0
    local b = self.background
    local t = self.text
    b.alpha = ANIM1_BACK_END_ALPHA
    t.alpha = ANIM2_TEXT_END_ALPHA
    t.scale = ANIM2_TEXT_END_SCALE
    b:SetAlpha(b.alpha)
    t:SetAlpha(t.alpha)
    t:SetScale(t.scale)
    t:SetWidth(t.WIDTH)
    if M:Status(ANIM3) then
        M:Stop(ANIM4)
    end
    M:Start(ANIM3, 1)
end

-- 4. Text grow horizontal. At 50%...
function DSDS:Anim4()
    self.counter = 0
    local t = self.text
    self:Debug("Animation 4")
    t.alpha = 0.6
    t.scale = 1.0
    t.width_scale = 1.0
    t:SetAlpha(t.alpha)
    t:SetScale(t.scale)
    t:SetWidth(t.WIDTH)
    if M:Status(ANIM4) then
        M:Stop(ANIM4)
    end
    M:Start(ANIM4, ANIM4_NUM_STEPS)
end

-- 5. Background and text fade out
function DSDS:Anim5()
    self.counter = 0
    local b = self.background
    local t = self.text
    self:Debug("Animation 5")
    t.alpha = ANIM4_TEXT_END_ALPHA
    t.scale = ANIM4_TEXT_END_SCALE
    t.width_scale = ANIM4_TEXT_END_WIDTH_SCALE
    t:SetAlpha(t.alpha)
    t:SetScale(t.scale)
    t:SetWidth(t.WIDTH * t.width_scale)
    if M:Status(ANIM5) then
        M:Stop(ANIM5)
    end
    M:Start(ANIM5, ANIM5_NUM_STEPS)
end

function DSDS:YouDied()
    PlaySoundFile(SOUND_YOU_DIED, "Master")
    M:Start(ANIM0, 1)
end
