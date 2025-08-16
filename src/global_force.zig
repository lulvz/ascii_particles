const std = @import("std");

pub const GlobalForce = union(enum) {
    Gravity: Gravity,
    Buoyancy: Buoyancy,

    pub fn update(self: *GlobalForce, ps: anytype, dt: f64) void {
        return switch (self.*) {
            .Gravity => |*g| g.*.update(ps, dt),
            .Buoyancy => |*b| b.*.update(ps, dt)
        };
    }
};

pub const GravityConfig = struct {
    acc: f64 = -1.0
};
 
pub const Gravity = struct {
    const Self = @This();

    config: GravityConfig,

    pub fn init(config: GravityConfig) Self {
        return .{
            .config = config
        };
    }

    pub fn update(self: *Self, ps: anytype, dt: f64) void {
        for(0..ps.particles.len) |i| {
            ps.particles[i].vel[1] += self.config.acc * dt;
        }
    }
};

pub const BuoyancyConfig = struct {
    fluid_density: f64 = 1.225,
    gravity_acc: f64 = -1.0
};

pub const Buoyancy = struct {
    const Self = @This();

    config: BuoyancyConfig,

    pub fn init(config: BuoyancyConfig) Self {
        return .{
            .config = config
        };
    }

    pub fn update(self: *Self, ps: anytype, dt: f64) void {
        for(0..ps.particles.len) |i| {
            var particle = &ps.particles[i];
            // get the buoyant force using archimede's principle
            const buoyant_force = -self.config.fluid_density * self.config.gravity_acc * particle.volume;
            particle.vel[1] += (buoyant_force / particle.mass) * dt;
        }
    }
};
