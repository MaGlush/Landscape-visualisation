#version 330 core
in vec3 vFragPosition;
in vec2 vTexCoords;
in vec3 vNormal;
uniform int state;
uniform sampler2D forest_texture;
uniform sampler2D sand_texture;
uniform sampler2D water_texture;
uniform sampler2D mountain_texture;
uniform sampler2D grass_texture;

out vec4 final_color;

vec3 smooth_color(in float border, in vec3 first_color, in vec3 second_color)
{
    float height = vFragPosition.y;
    if (height >= border + 4.0f)
        return second_color;

    float p = int(height * 100) % 100;
    vec3 result_color;
    if (height < border + 1.0f)
        result_color = (p*second_color+(400-p)*first_color) / 400;
    else if (height < border + 2.0f)
        result_color = ((100+p)*second_color+(300-p)*first_color) / 400;
    else if (height < border + 3.0f)
        result_color = ((200+p)*second_color+(200-p)*first_color) / 400;
    else
        result_color = ((300+p)*second_color+(100-p)*first_color) / 400;

    return result_color;
}

vec4 smooth_tex(in float border, in sampler2D first_texture, in sampler2D second_texture)
{
    float height = vFragPosition.y;
    if (height >= border + 4.0f)
        return texture(second_texture, vTexCoords);

    float p = int(height * 100) % 100;
    vec4 result_texture;
    if (height < border + 1.0f)
        result_texture = mix(texture(first_texture, vTexCoords), texture(second_texture, vTexCoords), p/400);
    else if (height < border + 2.0f)
        result_texture = mix(texture(first_texture, vTexCoords), texture(second_texture, vTexCoords), 0.25+p/400);
    else if (height < border + 3.0f)
        result_texture = mix(texture(first_texture, vTexCoords), texture(second_texture, vTexCoords), 0.5+p/400);
    else
        result_texture = mix(texture(first_texture, vTexCoords), texture(second_texture, vTexCoords), 0.75+p/400);

    return result_texture;
}

void main()
{

    vec3 lightDir = vec3(1.0f, 1.0f, 0.0f);

    vec3 result_color  = vec3(0.0f, 0.9f, 0.75f);
    vec4 result_texture = texture(water_texture, vTexCoords);

    float kd = max(dot(vNormal, lightDir), 0.0);

    vec3 mountain_col = vec3(0.5f, 0.51f, 0.5f);
    vec3 sand_col = vec3(0.6f, 0.6f, 0.3f);
    vec3 water_col = vec3(0.0f, 0.7f, 0.9f);
    vec3 forest_col = vec3(0.11f, 0.21f, 0.11f);
    vec3 grass_col = vec3(0.15f, 0.3f, 0.17f);

    // цвет тумана
    vec4 fog_color = vec4(1,1,1,0);
    // глубина тумана
    float fog_cord = (gl_FragCoord.z/gl_FragCoord.w)/2000.0f;
    // плотность тумана
    float fog_destiny = 6.0;
    float fog = fog_cord * fog_destiny;
    // коэффициент смешивания
    float alpha =  exp(-pow(1.0 / fog, 2.0));

    if (vFragPosition.y <= 0){ // water_col
        result_color  = water_col;
        result_texture = texture(water_texture, vTexCoords);
    }else if (vFragPosition.y <= 2){ // sand_col
        result_color  = smooth_color(0.0f, water_col, sand_col);
        result_texture = texture(sand_texture, vTexCoords);
    }else if (vFragPosition.y <= 9){ // grass_col
        result_color  = smooth_color(2.0f, sand_col, grass_col);
        result_texture = smooth_tex(2.0f, sand_texture, grass_texture);
    }else if (vFragPosition.y <= 20){ // forest_col
        result_color  = smooth_color(9.0f, grass_col, forest_col);
        result_texture = smooth_tex(9.0f, grass_texture, forest_texture);
    }else{ // mountain_col
        result_color  = smooth_color(20.0f, forest_col, mountain_col);
        result_texture = smooth_tex(20.0f, forest_texture, mountain_texture);
    }


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
}
