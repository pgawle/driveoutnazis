# Drive Out Nazis - Godot Learning Recordings

It is a project to learn Godot and game creation. 
I am working on Godot 4+

You play the recent version: https://pgawle.github.io/driveoutnazis/Build/


## Setting up Project and Project Organisation:

- Forward+, Mobile, Compatibility: https://www.youtube.com/watch?v=KWhVVMpihsc	
- GitHub Desktop Download: https://desktop.github.com/download/
- Github connect to project: https://www.youtube.com/watch?v=5H4A74FIEtg
- Basic Project Settings: https://youtu.be/NFK7VKzpp2o?si=sM-Pl9mxwLkPN4D1&t=73
- Composition methodology of organising project scenes: 1: https://www.youtube.com/watch?v=PYHgvXqOSo4 2: https://www.youtube.com/watch?v=JJid46XzW8A
- Files order short recommendation: https://www.youtube.com/watch?v=kH5HkKNImXo
- Project organisation with good explanation (OOO approach): https://www.youtube.com/watch?v=cpKr1lRUPWA

## Player Input

- InputEvents: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html

- InputMaps (project settings): https://www.youtube.com/watch?v=ngHbAmN062c
_Input actions are a grouping of zero or more InputEvents into a commonly understood title (for example, the default "ui_left" action grouping both joypad-left input and a keyboard's left arrow key)._
```python
# there are build in inputs that you can listen too like : ui_up, ui_left, ui_right, ui_down_
Input.is_action_pressed("ui_up")
```


## Physics && Math used for Player Movement

### Full tutorial for Car Steering in 2D in Godot 4: https://kidscancode.org/godot_recipes/4.x/2d/car_steering/index.html


### Physhics dictionary: 
	
	DRAG FORCE
	- it is force that activily oppose the car movement
	- in real life areadynamic drag incricises at higher speed
	- in game we do the same. As car goes faster we incrise drag force
	- in code we define drag variable to count the drag force depending on speed

	ROTATION
	- represent where the car is poiting
	- car can be rotated to the direction of movment (drift)
	
	STEERING
	- simmulate effect of turning wheels (based on simplified bicicle model)
	- steering angle (max angle of front wheels)
	- steer direction (left, right), (between -1 and 1, multiplied by the maximum angle)
	- 
	
	TRANSFORM.X
	- Normalised (always lenght=1) poiting in the direction forward axis of a CAR

### Velocity
	VELOCITY
	- represents where the car is moving
	- It is VECTOR (we use Vector2) to represent not only SPEED but also DIRECTION 
	- SPEED + DIRECTION provides posibility to move car in drifts. So the car front is facing one way but it moves the other. 
	- PERSISTENCE: velocity do not change until other forces will not force the change (DRAG_FORCE, FRICTION)
- Velocity angle illustration: https://raw.githubusercontent.com/godotengine/godot-docs/master/img/vector2_angle.png
- Velocity and Acceleration (Godot): https://www.youtube.com/watch?v=5OG_Sw6hM84

### Math and Vectors

- 2D Transforms: https://kidscancode.org/godot_recipes/4.x/math/transforms/
- Math Wrap what it does: `It ensures that a number stays within a specified range by looping it back around when it exceeds the bounds`
- Clamping (what is it in computer science): https://en.wikipedia.org/wiki/Clamp_(function)
- linear interpolation: https://pl.khanacademy.org/computing/pixar/animate/parametric-curves/v/animation-5
- Interpolation in Godot4: https://kidscancode.org/godot_recipes/4.x/math/interpolation/

### Kinematic Bicycle Model and Steering
- https://www.youtube.com/watch?v=d4WW-Fcm4_k
- https://dingyan89.medium.com/simple-understanding-of-kinematic-bicycle-model-81cac6420357


## GdScript

Style guide best practises: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order

### Basics
- Variables (Types and := meaning): https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#variables
- Static Typing: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html
- Dictionary(data by keys to return multiple values): https://docs.godotengine.org/en/stable/classes/class_dictionary.html#class-dictionary

### Patterns
- Signelton: https://www.youtube.com/watch?v=0ox8C9b5fkQ
- Observer Pattern: https://www.youtube.com/watch?v=uNDwVx_hnEA
- Observer: https://gameprogrammingpatterns.com/observer.html
- Event Bus, Global Signals: https://www.youtube.com/watch?v=excnQA86hW8
- Classes https://www.youtube.com/watch?v=1B4DSpM0goo






<br><br><br><br><br><br><br><br><br><br>
# Todo: Review materials below
<hr/>





QuickHelp:
	When have Sprite for background use AtlasTexture to actually edit region to be used. 
	- Documentation https://docs.godotengine.org/pl/4.x/classes/class_atlastexture.html
 






### GDScript


- Using CharacterBody2D: https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html

- 
- 

- 
- Input.getAxis https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-get-axis


- Character Screen Wrap: https://kidscancode.org/godot_recipes/4.x/2d/screen_wrap/index.html

- @Exports(how to set up), you can edit in IDE inspector, press endter and see the change in game: https://www.youtube.com/watch?v=VOcN6Y8mTEE 
- Custom Signals: https://www.youtube.com/watch?v=bkmXd1hHPVw, https://www.youtube.com/watch?v=qkLBzm5D3Rs



### Resources
Basics: https://www.youtube.com/watch?v=h5vpjCDNa-w
AtlasTezxture: https://youtu.be/TbzXCHfhK-E?si=wwgnGDyW322V3ioy&t=228


### Nodes
- Using timer node: https://gamedevacademy.org/timer-in-godot-complete-guide/

### Graphics: 
- Adding Sprite from Region: https://youtu.be/NFK7VKzpp2o?si=pyMdw4o1bdPjKGUC&t=1186			\
- Y-sorting (for tilemap): https://www.youtube.com/watch?v=AHHKfNqnUWI
- TilesMaps : https://www.youtube.com/watch?v=43sJIWaj2Yw

### UI, Control Node
- Control Node: https://www.youtube.com/watch?v=5Hog6a0EYa0
- Menu Creation: https://www.youtube.com/watch?v=zHYkcJyE52g

### Animations: 
- AnimationPlayer https://www.youtube.com/watch?v=ATfE4k6EP9U
- AnimatedSprite: https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html

### Other
- Export to web: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Adding SFX: https://www.youtube.com/watch?v=H6E8hxGwYRg


---
For review: 
	- Export vs Tool : https://www.youtube.com/watch?v=PrCza2z0Log
	- Godot Car Steering GODOT4: https://www.youtube.com/watch?v=Obt-hDTICwQ
	- Car steering: https://kidscancode.org/godot_recipes/3.x/2d/car_steering/index.html
	- https://www.gdquest.com/tutorial/godot/learning-paths/beginner/
	- Adding Sprites Animation: https://www.youtube.com/watch?v=Vwj_hX9h4zo
	- 4 Topdown movement: https://kidscancode.org/godot_recipes/4.x/2d/topdown_movement/index.html
