--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Animation Tags API v1.0.0-rc1

Github: https://github.com/Bitslayn/AnimationTags
Wiki: https://github.com/Bitslayn/AnimationTags/wiki
--]]

--#REGION ˚♡ Inject ♡˚

---@class AnimationAPI
local AnimationAPI = {}
---@class Animation
local Animation = {}

local api, ani = figuraMetatables.AnimationAPI, figuraMetatables.Animation
local api_i, ani_i = api.__index, ani.__index

function api:__index(key) return AnimationAPI[key] or api_i(self, key) end

function ani:__index(key) return Animation[key] or ani_i(self, key) end

--#ENDREGION
--#REGION ˚♡ API ♡˚

local _ENVMT = getmetatable(_ENV) or getmetatable(setmetatable(_ENV, {}))

local function reflect(tbl)
  local i, t = 0, {}
  for k in pairs(tbl) do
    i = i + 1
    t[i] = k
  end
  return t
end

---@type table<Animation, string[]>
local trackedAnimations = {}

---@type table<string, Animation[]|AnimationTag>
local AnimationTags = {}
---@class AnimationTag
---@field play fun(): self Starts or resumes all animations with this tag
---@field playing fun(self: self, state?: boolean): self Sets the playing state of all animations with this tag. Argument defaults to false
---@field setPlaying fun(self: self, state?: boolean): self Sets the playing state of all animations with this tag. Argument defaults to false
---@field pause fun(): self Pauses all animations with this tag
---@field stop fun(): self Stops all animations with this tag
---@field restart fun(): self Restarts all animations with this tag from the beginning, even if it was currently paused or playing
local AnimationTag = {}

---Get if any animation with this tag is playing
---@return boolean
---@nodiscard
function AnimationTag:isPlaying()
  return getmetatable(self).isPlaying
end

---Returns the animations with this tag that are currently playing
---@return Animation[]
---@nodiscard
function AnimationTag:getPlaying()
  return reflect(getmetatable(self).playing)
end

---Incriments each tag in the table by the given amount
---@param anim Animation
---@param inc number
function _ENVMT.queryAC(anim, inc)
  if not trackedAnimations[anim] then return end
  for _, v in pairs(trackedAnimations[anim]) do
    local meta = getmetatable(AnimationTags[v])
    meta.playing[anim] = inc == 1 and true or nil
    meta.count = meta.count + inc
    meta.isPlaying = meta.count > 0
    assert(meta.count >= 0, "INTERNAL LOGIC ERROR\nReport this to FOX")
  end
  anim:code(
    anim:getLength() - 0.01,
    anim:getLoop() ~= "LOOP" and "getmetatable(_ENV).queryAC(..., -1)" or ""
  )
end

---Returns all animation tags, and a boolean if an animation with that tag is currently playing
---
---This function returns a reference to the internal table, which updates dynamically
---@return table<string, Animation[]|AnimationTag>
function AnimationAPI:getTags()
  return AnimationTags
end

---Sets this animation's tags, which can be used to determine which tags have an animation playing
---
---Any single animation can be assigned to several tags
---@param self Animation
---@param ... string
---@return self
function Animation:setTags(...)
  -- Remove from previous tags

  if trackedAnimations[self] then
    if self:isPlaying() then
      _ENVMT.queryAC(self, -1)
    end
    for _, v in pairs(trackedAnimations[self]) do
      local meta = getmetatable(AnimationTags[v])
      meta.index[self] = nil
      AnimationTags[v] = setmetatable(reflect(meta.index), meta)
    end
  end

  -- Add to new tags

  local tags = { ... }
  trackedAnimations[self] = tags

  for _, v in pairs(tags) do
    local meta = { __index = AnimationTag, playing = {}, isPlaying = false, count = 0, index = {} }
    AnimationTags[v] = AnimationTags[v] or setmetatable({}, meta)
    meta.index[self] = self
    if self:isPlaying() then
      _ENVMT.queryAC(self, 1)
    end
    table.insert(AnimationTags[v], self)
  end

  return self
end

for _, v in pairs({ "play", "playing", "setPlaying", "pause", "stop", "restart" }) do
  ---@param self Animation
  ---@param ... any
  ---@return Animation
  Animation[v] = function(self, ...)
    local wasPlaying = self:isPlaying()
    ani_i(self, v)(self, ...)
    local isPlaying = self:isPlaying()

    if wasPlaying == isPlaying then return self end -- Return early if play state didn't change

    _ENVMT.queryAC(self, isPlaying and 1 or -1)
    return self
  end
  ---@param self AnimationTag
  ---@param ... any
  ---@return AnimationTag
  AnimationTag[v] = function(self, ...)
    for _, anim in pairs(self) do
      anim[v](anim, ...)
    end
    return self
  end
end

--#ENDREGION
