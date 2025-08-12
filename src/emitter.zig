const std = @import("std");
const Particle = @import("particle.zig").Particle;

pub const EmitterConfig = struct {
    min_lifetime: f64,
    max_lifetime: f64,
    min_brightness: f64,
    max_brightness: f64,
    min_vel: @Vector(2, f64),
    max_vel: @Vector(2, f64),
    min_acc: @Vector(2, f64),
    max_acc: @Vector(2, f64),
};

pub const Emitter = union(enum) {
    FireEmitter: FireEmitter,

    pub fn update(self: *Emitter, ps: anytype, dt: f64) void {
        return switch (self.*) {
            .FireEmitter => |*fe| fe.*.update(ps, dt),
        };
    }
};

pub const defaultFireEmitterConfig = EmitterConfig {
    .min_lifetime = 4.0,
    .max_lifetime = 8.0,
    .min_brightness = 0.5,
    .max_brightness = 1.0,
    .min_vel = .{0.0, 2.0},
    .max_vel = .{0.0, 4.0},
    .min_acc = .{-1.0, -0.4},
    .max_acc = .{1.0, -0.7}
};

pub const FireEmitter = struct {
    origin: @Vector(2, f64),
    origin_radius: f64,
    spawn_interval: f64, // particles per second (approximately)
    dt_last_spawn: f64,
    random: std.Random,

    config: EmitterConfig,

    const Self = @This();

    pub fn init(origin: @Vector(2, f64), origin_radius: f64, spawn_rate: f64, random: std.Random, config: ?EmitterConfig) Self {
        return .{
            .origin = origin,
            .origin_radius = origin_radius,
            .spawn_interval = 1/spawn_rate,
            .dt_last_spawn = 0.0,
            .random = random,
            .config = config orelse defaultFireEmitterConfig
        };
    }

    pub fn update(self: *Self, ps: anytype, dt: f64) void {
        self.dt_last_spawn += dt;
        const lifetime = self.config.min_lifetime + self.random.float(f64) * (self.config.max_lifetime - self.config.min_lifetime);
        const brightness = self.config.min_brightness + self.random.float(f64) * (self.config.max_brightness - self.config.min_brightness);

        // check if more time passed than the spawn interval
        while (self.dt_last_spawn > self.spawn_interval) {
            const p = Particle{
                .pos = self.origin + @Vector(2, f64){
                                                        ((self.random.float(f64)-0.5)*2)*self.origin_radius,
                                                        ((self.random.float(f64)-0.5)*2)*self.origin_radius},
                .vel = self.config.min_vel + @Vector(2, f64){self.random.float(f64), self.random.float(f64)} * (self.config.max_vel - self.config.min_vel),
                .acc = self.config.min_acc + @Vector(2, f64){self.random.float(f64), self.random.float(f64)} * (self.config.max_acc - self.config.min_acc),

                .lifetime = lifetime,
                .brightness = brightness,
                .fade_rate = brightness/lifetime
            };
            ps.append_particle(p) catch {};
            self.dt_last_spawn -= self.spawn_interval;
        }
    }
};
