const std = @import("std");

pub const GlobalForce = union(enum) {
    Gravity: Gravity,

    pub fn update(self: *GlobalForce, ps: anytype, dt: f64) void {
        return switch (self.*) {
            .Gravity => |*g| g.*.update(ps, dt),
        };
    }
};

pub const GravityConfig = struct {
    acc: f64
};

pub const DefaultGravityConfig = GravityConfig {
    .acc = -1.0,
};
 
pub const Gravity = struct {
    const Self = @This();

    config: GravityConfig,

    pub fn init(config: ?GravityConfig) Self {
        return .{
            .config = config orelse DefaultGravityConfig
        };
    }

    pub fn update(self: *Self, ps: anytype, dt: f64) void {
        for(0..ps.particles.len) |i| {
            ps.particles[i].velocity += self.config.acc * dt;
        }
    }
};

pub const BuoyancyConfig = struct {

};

pub const DefaultBuoyancyConfig = struct {

};

pub const Buoyancy = struct {

};
