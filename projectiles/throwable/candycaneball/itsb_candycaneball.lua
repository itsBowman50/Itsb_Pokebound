require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/candycaneball.lua"

function update(dt)
  promises:update()
end

function hit(entityId)
  if self.hit then return end
  if world.isMonster(entityId) then
    self.hit = true

    -- If a monster doesn't implement pet.attemptCapture or its response is nil
    -- then it isn't caught.
    promises:add(world.sendEntityMessage(entityId, "pet.attemptCapture", projectile.sourceEntity()), function (pet)
        self.pet = pet
      end)
  end
end

function shouldDestroy()
  return projectile.timeToLive() <= 0 and promises:empty()
end

function destroy()
  if self.pet then
    spawnFilledCandycaneball(self.pet)
  else
    spawnEmptyCandycaneball()
  end
end

function spawnEmptyCandycaneball()
  world.spawnItem("itsb_candycaneball", mcontroller.position(), 1)
end

function spawnFilledCandycaneball(pet)
  local candycaneball = createFilledItsb_candycaneball(pet)
  world.spawnItem(candycaneball.name, mcontroller.position(), candycaneball.count, candycaneball.parameters)
end
