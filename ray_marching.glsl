const vec3 light_color = vec3(0.98, 0.98, 1.0);


float sdsphere(vec3 p, vec3 c, float r) {
    return length(p - c) - r;
}

float sdplane(vec3 p, vec3 c, float height) {
    return p.y - c.y - height;
}

float map_the_world(in vec3 p) {
    float d = sdsphere(p, vec3(0.0, 0.0, 0.0), 1.0);
    return d;
}

vec3 calculate_normal(in vec3 p)
{
    const vec3 small_step = vec3(0.001, 0.0, 0.0);

    float gradient_x = map_the_world(p + small_step.xyy) - map_the_world(p - small_step.xyy);
    float gradient_y = map_the_world(p + small_step.yxy) - map_the_world(p - small_step.yxy);
    float gradient_z = map_the_world(p + small_step.yyx) - map_the_world(p - small_step.yyx);

    return normalize(vec3(gradient_x, gradient_y, gradient_z));
}

const float step_size = 0.1;

vec3 ray_march(in vec3 ro, in vec3 rd, in vec3 light_position, in vec3 camera_position)
{
    float total_distance_traveled = 0.0;
    const int NUMBER_OF_STEPS = 32;
    const float MIN_HIT_DISTANCE = 0.001;
    const float MAX_TRACE_DISATANCE = 1000.0;

    for (int i = 0; i < NUMBER_OF_STEPS; ++i)
    {
        vec3 current_position = ro + rd * total_distance_traveled;

        vec3 view_direction = normalize(camera_position - current_position);
        vec3 light_direction = normalize(current_position - light_position);
        vec3 halfway_direction = normalize(light_direction + view_direction);

        float distance_to_closest = sdsphere(current_position, vec3(0.0, 0.0, 0.0), 1.0);
        // float distance_to_closest = sdplane(current_position, vec3(0.0, -10.0, 0.0), 10.0);

        if (distance_to_closest < MIN_HIT_DISTANCE)
        {
            vec3 normal = calculate_normal(current_position);

            float diffuse = max(0.0, dot(normal, light_direction));
            float specular = pow(max(0.0, dot(normal, halfway_direction)), 64.0);

            vec3 shading_color = diffuse * vec3(.6, .2, .4) + specular;
            
            return shading_color * light_color;
        }

        if (total_distance_traveled > MAX_TRACE_DISATANCE)
        {
            break;
        }

        total_distance_traveled += distance_to_closest;
    }

    return vec3(0.0);
}

void main() {
    const vec3 light_position = vec3(2.0, -5.0, 2.0);

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    vec3 camera_position = vec3(0.0, 0.0, -5.0);
    vec3 ro = camera_position;
    vec3 rd = vec3(uv, 1.0);

    vec3 shaded_color = ray_march(ro, rd, light_position, camera_position);
    gl_FragColor = vec4(shaded_color, 1.0);
}