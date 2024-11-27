

using Agents
using LinearAlgebra

export init_base_model
# everything is in feet, seconds, and radians
function init_base_model(;
    drone_speed=55.0,
    heli_speed=115.0,
    drone_θ=1.0π,
    heli_θ=0.0,
    drone_ϕ=0.0,
    heli_ϕ=0.0,
    drone_x_pos=BOUNDS_X - 100,
    drone_y_pos=BOUNDS_Y / 2,
    drone_altitude=BOUNDS_ALTITUDE / 2,
    heli_x_pos::Optional{<:Real}=nothing,
    heli_y_pos::Optional{<:Real}=nothing,
    heli_altitude=BOUNDS_ALTITUDE / 2,
    bounds_x::Optional{<:Real}=nothing,
    bounds_y::Optional{<:Real}=nothing,
    bounds_altitude::Optional{<:Real}=nothing,
    drone_initial_state::Optional{<:State}=nothing,
    heli_initial_state::Optional{<:State}=nothing,
    drone_initial_vars::Optional{Dict}=nothing,
    heli_initial_vars::Optional{Dict}=nothing,
)
    """
    Defaults to canonical head-on initial state
    """

    bounds_x = isnothing(bounds_x) ? BOUNDS_X : bounds_x
    bounds_y = isnothing(bounds_y) ? BOUNDS_Y : bounds_y
    bounds_altitude = isnothing(bounds_altitude) ? BOUNDS_ALTITUDE : bounds_altitude
    drone_initial_vars = isnothing(drone_initial_vars) ? Dict() : drone_initial_vars
    heli_initial_vars = isnothing(heli_initial_vars) ? Dict() : heli_initial_vars
    drone_initial_state = isnothing(drone_initial_state) ? IDLE : drone_initial_state
    heli_initial_state = isnothing(heli_initial_state) ? IDLE : heli_initial_state
    heli_x_pos = isnothing(heli_x_pos) ? 100.0 : heli_x_pos
    heli_y_pos = isnothing(heli_y_pos) ? BOUNDS_Y / 2 : heli_y_pos

    bounds = (bounds_x, bounds_y, bounds_altitude)
    space = ContinuousSpace(bounds; spacing=200, periodic=false)
    model = StandardABM(
        Vehicle,
        space;
        properties=Properties()
    )

    drone_pos = (drone_x_pos, drone_y_pos, drone_altitude)
    drone_vel = get_vel(drone_θ, drone_ϕ, Float64(drone_speed))

    heli_pos = (heli_x_pos, heli_y_pos, heli_altitude)
    # heli_pos = (heli_y_pos, heli_x_pos, heli_altitude)
    heli_vel = get_vel(heli_θ, heli_ϕ, Float64(heli_speed))

    add_agent!(
        drone_pos,
        Vehicle,
        model,
        drone_vel,
        drone,
        drone_initial_state,
        ignoring,
        Vector{PositionLog}(),
        drone_initial_vars,
    )
    add_agent!(
        heli_pos,
        Vehicle,
        model,
        heli_vel,
        heli,
        heli_initial_state,
        ignoring,
        Vector{PositionLog}(),
        heli_initial_vars,
    )

    return model
end

