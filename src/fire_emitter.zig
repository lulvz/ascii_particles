const Particle = @import("particle.zig").Particle;
pub const FireEmitter = struct {
    const Self = @This();
    pub fn update(_: *Self, ps: anytype) void {
        const p = Particle{
            .pos = .{10.0, 10.0},
            .vel = .{1.0, 0.0},
            .acc = .{0.0, 0.0},
            .lifetime = 10,
            .brightness = 1.0,
            .fade_rate = 0.1
        };
        ps.append_particle(p) catch {};
    }
};
