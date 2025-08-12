const std = @import("std"); const Particle = @import("particle.zig").Particle;

pub const Smoke = struct {
    origin: @Vector(2, f64),
    origin_radius: f64,
    spawn_interval: f64, // particles per second (approximately)
    dt_last_spawn: f64,
    random: std.Random,

    min_lifetime: f64 = 4.0,
    max_lifetime: f64 = 8.0,
    min_brightness: f64 = 0.5,
    max_brightness: f64 = 1.0,
    min_vel: @Vector(2, f64) = .{0.0, 2.0},
    max_vel: @Vector(2, f64) = .{0.0, 4.0},
    min_acc: @Vector(2, f64) = .{-1.0, -0.4},
    max_acc: @Vector(2, f64) = .{1.0, -0.7},

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
            const lifetime = self.min_lifetime + self.random.float(f64) * (self.max_lifetime - self.min_lifetime);
            const brightness = self.min_brightness + self.random.float(f64) * (self.max_brightness - self.min_brightness);

            const p = Particle{
                .pos = self.origin + @Vector(2, f64){
                                                        ((self.random.float(f64)-0.5)*2)*self.origin_radius,
                                                        ((self.random.float(f64)-0.5)*2)*self.origin_radius},
                .vel = self.min_vel + @Vector(2, f64){self.random.float(f64), self.random.float(f64)} * (self.max_vel - self.min_vel),
                .acc = self.min_acc + @Vector(2, f64){self.random.float(f64), self.random.float(f64)} * (self.max_acc - self.min_acc),

                .lifetime = lifetime,
                .brightness = brightness,
                .fade_rate = brightness/lifetime
            };
            ps.append_particle(p) catch {};
            self.dt_last_spawn -= self.spawn_interval;
        }
    }
};
