#version 330 core
in vec3 vFragPosition;
in vec2 vTexCoords;
in vec3 vNormal;
uniform int state;
uniform sampler2D water_texture;

out vec4 final_color;

void main()
{

    vec3 lightDir = vec3(1.0f, 1.0f, 0.0f);

    vec3 result_color  = vec3(0.0f, 0.9f, 0.75f);
    vec4 result_texture = texture(water_texture, vTexCoords);

    float kd = max(dot(vNormal, lightDir), 0.0);

    vec3 water_col = vec3(0.0f, 0.75f, 0.8f);

    // цвет тумана
    vec4 fog_color = vec4(1,1,1,0);
    // глубина тумана
    float fog_cord = (gl_FragCoord.z/gl_FragCoord.w)/2000.0f;
    // плотность тумана
    float fog_destiny = 6.0;
    float fog = fog_cord * fog_destiny;
    // коэффициент смешивания
    float alpha =  exp(-pow(1.0 / fog, 2.0));

    result_color  = water_col;
    result_texture = texture(water_texture, vTexCoords);

    if (state == 1) {
        final_color = mix(result_texture, vec4(kd * result_color , 1.0), 0.1); // тексутра + цвет
        final_color = mix(final_color, fog_color, alpha);
    }
    else if (state == 2){
        final_color =  mix(vec4(abs(vNormal), 1.0f), vec4(kd * result_color, 1.0), 0.2); // нормали + цвет

    }else{
        final_color = vec4(kd * result_color , 1.0); // цвет
        final_color = mix(final_color, fog_color, alpha);
    }

    final_color = final_color*vec4(kd*water_col, 0.8f);
    
}
