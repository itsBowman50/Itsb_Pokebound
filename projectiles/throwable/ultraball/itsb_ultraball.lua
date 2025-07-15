require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/ultraball.lua"

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
    spawnFilledUltraball(self.pet)
  else
    spawnEmptyUltraball()
  end
end

function spawnEmptyUltraball()
  world.spawnItem("itsb_ultraball", mcontroller.position(), 1)
end

function spawnFilledUltraball(pet)
  local ultraball = createFilledItsb_ultraball(pet)
  world.spawnItem(ultraball.name, mcontroller.position(), ultraball.count, ultraball.parameters)
end
