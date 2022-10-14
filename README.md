# PowerLit

a shader for rendering scene.

1 Render Whether
    1 create empty in hierarchy
    2 add component(PowerLitWeatherControl), 
        control wind,snow,rain,thunder
    3 add component(PowerLitFogControl),
         control fog
    4 create material (use shader URP/PowerLit) assign to object
        4.1 set Wind,Snow,Fog,Rain



Reference Git
https://github.com/redcool/PowerUtilities.git
https://github.com/redcool/PowerShaderLib.git

put them into same folder.


========================================================
* v2.1.1
optimise PowerLit
add keywords(shader_feature)

1 weather fx keywords
_SNOW_ON
_WIND_ON
_RAIN_ON

2
parallax move vs