require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/spoopybatball.lua"

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
    spawnFilledSpoopybatball(self.pet)
  else
    spawnEmptySpoopybatball()
  end
end

function spawnEmptySpoopybatball()
  world.spawnItem("itsb_spoopybatball", mcontroller.position(), 1)
end

function spawnFilledSpoopybatball(pet)
  local spoopybatball = createFilledItsb_spoopybatball(pet)
  world.spawnItem(spoopybatball.name, mcontroller.position(), spoopybatball.count, spoopybatball.parameters)
end
