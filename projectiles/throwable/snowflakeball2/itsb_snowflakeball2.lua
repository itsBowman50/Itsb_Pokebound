require "/scripts/util.lua"
require "/scripts/messageutil.lua"
require "/scripts/companions/snowflakeball2.lua"

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
    spawnFilledSnowflakeball2(self.pet)
  else
    spawnEmptySnowflakeball2()
  end
end

function spawnEmptySnowflakeball2()
  world.spawnItem("itsb_snowflakeball2", mcontroller.position(), 1)
end

function spawnFilledSnowflakeball2(pet)
  local snowflakeball2 = createFilledItsb_snowflakeball2(pet)
  world.spawnItem(snowflakeball2.name, mcontroller.position(), snowflakeball2.count, snowflakeball2.parameters)
end
