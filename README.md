![DecalCo](https://user-images.githubusercontent.com/54776415/83648022-d8039b00-a5b5-11ea-90b1-ebffe687ffd9.PNG)

# What is Decal<sup>CO</sup>?

Decal<sup>CO</sup> is a shader based solution for the Godot game engine. Decals are a great tool used to add details to a 3d object without having to add more details to its geometry or using really large texture maps.

You can use decal to add things like bullet holes, blood splashes, water puddles in your scenes.

# System requirements

Godot game engine version 3.2.
Decal<sup>CO</sup> should work with 3.1 version of the Godot game engine too but not confirmed yet.
The 3.0 version of the Godot game engine isn't supported because of an engine bug concerning the depth buffer.

# Features 

Decal<sup>CO</sup>'s decals offer the following features :
- Texture mapping (albedo, specular, emission, normal map)
- Flipbook animation (useful to animate things like rain drops)
- Shadow mapping
- Multiple lights.

# Intallation

- Download Decal<sup>CO</sup>'s source code
- Unzip it and copy the "decalco" folder into your Godot's project folder.

Decal<sup>CO</sup> is also available on the Godot game engine's Asset Library, you can also download and install it directly from the engine's editor.

# How to use Decal<sup>CO</sup>?

To add a new decal to your scene, create a new MeshInstance node and give it a cube mesh and turn off it's "cast shadows" property.
![image](https://user-images.githubusercontent.com/54776415/103170784-57550680-4847-11eb-81f3-b243117669b8.png)

Next, in the MeshInstance's material slot, create a new shader material and load the decal shader.
![image](https://user-images.githubusercontent.com/54776415/103170845-c7fc2300-4847-11eb-84da-aea89d8842eb.png)

Decal<sup>CO</sup>'s decals are projected along their negative local Z axis, make sure this axis is perpendicular (like in the screenshot below) with the surface the decal is projected on to avoid wrong projections.
![projection](https://user-images.githubusercontent.com/54776415/83612625-ef756080-a582-11ea-9824-48863c10e307.PNG)

If you want to project a decal in a corner, you can try doing the following :
![projectionAngle](https://user-images.githubusercontent.com/54776415/83612801-3400fc00-a583-11ea-923c-9097e790e601.PNG)

In order to fix projections artefacs as much as possible (see example bellow), try keeping the decal as thin as possible by scaling it down on the Z axis.
Here, the decal's projection box is large, objects passing near it will interfere with it's projection.
![image](https://user-images.githubusercontent.com/54776415/103170908-435dd480-4848-11eb-8a52-4df38c7ff885.png)
By making it thiner, the artefac is now gone.
![image](https://user-images.githubusercontent.com/54776415/103170973-bc5d2c00-4848-11eb-823e-f32bd508f8ef.png)

As the decal's logic is happening in a shader, you can save your decal's materials in your project as a resource and share it accros multiple decals.

A demo scene showcasing how you can use this plugin and its features is available in the examples folder.
![demo](https://user-images.githubusercontent.com/54776415/83613098-9528cf80-a583-11ea-92e1-d0b6e10069b0.PNG)

# Performance

As the decals are shader-based, they should be pretty efficient. They also can share the same material, so the material count dedicated to them can be limited to one material per decal type.

# Known issues and limitations

- GLES2.0 projections update with a delay when the camera moves.
- GLES2.0 normal maps may look considerably worse than they do with GLES3.0 depending on viewing angle and light setup.
- GLES2.0 in DecalCo uses DEPTH_TEXTURE which may not work on some old hardware; especially mobile, as stated in the official documentation.
- PBR lighting not supported because of some hacks necessary for the shader to work, PBR could be done if things like the iradiance texture is exposed to the light shader.
- Specular lighting only works with a single light.
- Decal wrapping on sharp angles produce ugly results, this could be solved by cliping the decal on those spots but will require to compute the face normal using the screen texture which would make the shader even less efficient than it already is.
