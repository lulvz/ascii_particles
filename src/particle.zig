pub const Particle = struct {
    pos: @Vector(2, f64),
    vel: @Vector(2, f64),
    acc: @Vector(2, f64),

    mass: f64,
    volume: f64,

    lifetime: f64, // lifetime in seconds

    brightness: f64, // 0.0 to 1.0 (initial brightness)
    fade_rate: f64 // brightness lost per second
};
