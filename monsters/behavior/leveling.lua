function init()
  storage.experience = storage.experience or config.getParameter("experience", 0)
  storage.level = storage.level or config.getParameter("level", 5)
  storage.evolved = storage.evolved or false
end

function update(dt)
  if storage.evolved then return end

  -- Level up check
  local expToLevel = 100 + (storage.level * 20)
  if storage.experience >= expToLevel then
    storage.experience = storage.experience - expToLevel
    storage.level = storage.level + 1
    status.setStatusProperty("pokemonLevel", storage.level)
    say("Level up! Now level " .. storage.level)
  end

  -- Evolution logic
  if storage.level >= 20 and not storage.evolved then
    tryEvolve()
  end
end

function addExperience(amount)
  storage.experience = storage.experience + amount
  say("Gained " .. amount .. " XP!")
end

function tryEvolve()
  local stoneUsed = world.getProperty("eeveeEvolutionStone")

  local nextForm = nil
  if stoneUsed == "firestone" then
    nextForm = "itsb_flareon"
  elseif stoneUsed == "thunderstone" then
    nextForm = "itsb_jolteon"
  end

  -- If no stone, fallback to random evolution
  if not nextForm then
    local options = {"itsb_flareon", "itsb_jolteon"}
    nextForm = options[math.random(#options)]
  end

  -- Evolve by spawning the evolved form
  if nextForm then
    local pos = entity.position()
    world.spawnMonster(nextForm, pos, {
      level = storage.level,
      aggressive = true
    })
    say("Evolving into " .. nextForm)
    status.setResource("health", 0)  -- Despawn Eevee
    storage.evolved = true
  end
end
