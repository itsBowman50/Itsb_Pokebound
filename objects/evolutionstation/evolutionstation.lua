function evolveToFlareon()
  local nearby = world.entityQuery(object.position(), 5, { includedTypes = {"monster"} })
  for _, entityId in ipairs(nearby) do
    if world.monsterType(entityId) == "itsb_eevee" then
      world.setProperty("eeveeEvolutionStone", "itsb_firestone")
      world.sendEntityMessage(entityId, "addExperience", 999)
    end
  end
end

function evolveToJolteon()
  local nearby = world.entityQuery(object.position(), 5, { includedTypes = {"monster"} })
  for _, entityId in ipairs(nearby) do
    if world.monsterType(entityId) == "itsb_eevee" then
      world.setProperty("eeveeEvolutionStone", "itsb_thunderstone")
      world.sendEntityMessage(entityId, "addExperience", 999)
    end
  end
end