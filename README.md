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

# How to use Decal<sup>CO</sup>?

Decal<sup>CO</sup> uses a node based approach to make things easier.

To add a new decal to your scene, open the "Add Node" window and search for the "Decal" Node .
![adddecal](https://user-images.githubusercontent.com/54776415/83612272-7bd35380-a582-11ea-8f8a-f27121ebd839.PNG)

Decal<sup>CO</sup>'s decals are projected along their negative local Z axis, make sure this axis is perpendicular (like in the screenshot below) with the surface the decal is projected on to avoid wrong projections.
![projection](https://user-images.githubusercontent.com/54776415/83612625-ef756080-a582-11ea-9824-48863c10e307.PNG)

If you want to project a decal in a corner, you can try doing the following :
![projectionAngle](https://user-images.githubusercontent.com/54776415/83612801-3400fc00-a583-11ea-923c-9097e790e601.PNG)

A demo scene showcasing how you can use this plugin and its features is available in the examples folder.
![demo](https://user-images.githubusercontent.com/54776415/83613098-9528cf80-a583-11ea-92e1-d0b6e10069b0.PNG)

# Performance

Because the engine currently doesn't offer per instance uniforms for materials, each decals you add to your scene will have it's own material instance (so 1 decal = 1 unique material, 5 decal = 5 unique materials), this is required to make scaling and rotating work.

Having a dozen decals in your camera's view frustum shouldn't be a problem but don't expect high performances with hundreds of displayed decals.

# Known issues and limitations

- Only work with the GLES3.0 renderer
- PBR lighting not supported because of some hacks necessary for the shader to work, PBR could be done if things like the iradiance texture is exposed to the light shader.
- Specular lighting only works with a single light.
- Decal wrapping on sharp angles produce ugly results, this could be solved by cliping the decal on those spots but will require to compute the face normal using the screen texture which would make the shader even less efficient than it already is.
