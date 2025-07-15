require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/primerball.lua"

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
    spawnFilledPrimerball(self.pet)
  else
    spawnEmptyPrimerball()
  end
end

function spawnEmptyPrimerball()
  world.spawnItem("itsb_primerball", mcontroller.position(), 1)
end

function spawnFilledPrimerball(pet)
  local primerball = createFilleditsb_primerball(pet)
  world.spawnItem(primerball.name, mcontroller.position(), primerball.count, primerball.parameters)
end
