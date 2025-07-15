require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/pookieball.lua"

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
    spawnFilledPookieball(self.pet)
  else
    spawnEmptyPookieball()
  end
end

function spawnEmptyPookieball()
  world.spawnItem("itsb_pookieball", mcontroller.position(), 1)
end

function spawnFilledPookieball(pet)
  local pookieball = createFilledItsb_pookieball(pet)
  world.spawnItem(pookieball.name, mcontroller.position(), pookieball.count, pookieball.parameters)
end
