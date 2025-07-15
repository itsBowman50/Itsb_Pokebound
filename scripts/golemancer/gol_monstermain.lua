require "/scripts/golemancer/gol_resourceManager.lua"
require "/scripts/golemancer/gol_spawnManager.lua"

local preGolemInit = init or function() end
local preGolemUpdate = update or function(dt) end
local preGolemRequire = require

function init()
  preGolemInit()

  self.exp = config.getParameter("exp", 0)
  self.level = config.getParameter("level", 1)
  self.evolvesAt = config.getParameter("evolvesAt")
  self.evolutionTarget = config.getParameter("evolutionTarget")
  self.evolutions = config.getParameter("evolutions", {})
  self.hasEvolved = config.getParameter("hasEvolved", false)

  self.tickEvoTime = config.getParameter("tickEvoTime", 5.0)
  self.tickEvoTimer = self.tickEvoTime

  self.lastDamageTime = nil
end

function update(dt)
  preGolemUpdate(dt)

  self.tickEvoTimer = self.tickEvoTimer - dt
  if self.tickEvoTimer <= 0 then
    self.tickEvoTimer = self.tickEvoTime

    -- Gain EXP from combat
    if not self.lastDamageTime then
      _, self.lastDamageTime = status.damageTakenSince()
    end
    local dmgNotifs
    dmgNotifs, self.lastDamageTime = status.inflictedDamageSince(self.lastDamageTime)

    if dmgNotifs then
      for _, notif in ipairs(dmgNotifs) do
        if notif.healthLost > 0 then
          gainExp(math.ceil(notif.healthLost / 2))
        end
      end
    end

    checkEvolution()
    checkItemBasedEvolutions()
  end

  world.debugText("Lvl: %s | EXP: %s", self.level, self.exp, mcontroller.position(), "white")
end

function gainExp(amount)
  self.exp = self.exp + amount
  while self.exp >= expToNextLevel(self.level) do
    self.exp = self.exp - expToNextLevel(self.level)
    self.level = self.level + 1
  end
end

function expToNextLevel(level)
  return 10 + (level * 5)
end

function checkEvolution()
  if self.evolutionTarget and not self.hasEvolved and self.level >= self.evolvesAt then
    evolveTo(self.evolutionTarget)
    self.hasEvolved = true
  end
end

function checkItemBasedEvolutions()
  if self.hasEvolved then return end

  local drops = world.itemDropQuery(mcontroller.position(), 2.5)
  for _, evoPath in ipairs(self.evolutions) do
    local evo = root.assetJson(evoPath)
    if evo.requiredResources then
      for _, res in ipairs(evo.requiredResources) do
        if res.type == "droppedItem" then
          for _, dropId in ipairs(drops) do
            if world.entityName(dropId) == res.id then
              -- Consume the item
              local taken = world.takeItemDrop(dropId)
              if taken then
                evolveTo(evo.monsterSpawn.type)
                self.hasEvolved = true
                return
              end
            end
          end
        end
      end
    end
  end
end

function evolveTo(monsterType)
  local pos = mcontroller.position()
  local isPet = config.getParameter("capturable", false)
  local owner = config.getParameter("uniqueId") or config.getParameter("ownerUuid")

  -- Evolution FX
  world.spawnProjectile("planet", pos, entity.id(), {0, 0}, false, {})
  animator.playSound("evolution")

  if isPet and owner then
    -- Pet evolution: spawn new filled capture pod and delete old monster
    local filledPod = {
      name = "filledcapturepod",
      count = 1,
      parameters = {
        monsterType = monsterType,
        level = self.level,
        exp = self.exp,
        description = "An evolved Pokémon!",
        name = config.getParameter("shortdescription") or monsterType
      }
    }

    world.spawnItem(filledPod, pos)
    status.setResource("health", 0)

  else
    -- Wild evolution: spawn monster in-world
    local params = {
      level = self.level,
      exp = self.exp,
      hasEvolved = true,
      evolutionSource = entity.configParameter("type")
    }
    world.spawnMonster(monsterType, pos, params)
    status.setResource("health", 0)
  end
end

function require(s)
  if s ~= "/monsters/monster.lua" then
    preGolemRequire(s)
  end
end
