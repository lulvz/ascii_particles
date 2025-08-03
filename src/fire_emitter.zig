const std = @import("std"); const Particle = @import("particle.zig").Particle;

pub const FireEmitter = struct {
    origin: @Vector(2, f64),
    origin_radius: f64,
    spawn_interval: f64, // particles per second (approximately)
    dt_last_spawn: f64,
    random: std.Random,

    const Self = @This();

    pub fn init(origin: @Vector(2, f64), origin_radius: f64, spawn_rate: f64, random: std.Random) Self {
        return .{
            .origin = origin,
            .origin_radius = origin_radius,
            .spawn_interval = 1/spawn_rate,
            .dt_last_spawn = 0.0,
            .random = random
        };
    }

    pub fn update(self: *Self, ps: anytype, dt: f64) void {
        self.dt_last_spawn += dt;

        // check if more time passed than the spawn interval
        while (self.dt_last_spawn > self.spawn_interval) {
            const p = Particle{
                .pos = self.origin + @Vector(2, f64){((self.random.float(f64)-0.5)*2)*self.origin_radius,
                                                        ((self.random.float(f64)-0.5)*2)*self.origin_radius},
                .vel = .{0.0, 3.0 + (self.random.float(f64) - 0.5) * 2.0},
                .acc = .{0.0 + ((self.random.float(f64) - 0.5) * 2.0), -0.4},
                .lifetime = 6,
                .brightness = 1.0,
                .fade_rate = 1.0/6.0
            };
            ps.append_particle(p) catch {};
            self.dt_last_spawn -= self.spawn_interval;
        }
    }
};
