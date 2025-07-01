# AnimationTags

Animation Tags is a utility API which allows for giving tags to animations

This API is written to solve two issues:

When you need to check several animations if they're playing

```lua
function events.render()
  if animations.model.crouching:isPlaying() or animations.model.crouching_alt1:isPlaying() or animations.model.crouching_alt2:isPlaying() or animations.model.crouching_alt3:isPlaying() or animations.model.crouchWalking:isPlaying() or animations.model.crouchingWalking_alt1:isPlaying() or animations.model.crouchingWalking_alt2:isPlaying() or animations.model.crouchingWalking_alt3:isPlaying() then
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
  end
end
```

or if you want to stop several animations but not all animations

# Features
* Assign multiple tags to an animation
* Animation tags can be indexed to view all animations with the tag
* Indexing an animation tag allows for playing, pausing, and stopping all animations with that tag
* You can view if any animations with a specific tag are playing, and get a list of all playing animations with that tag
