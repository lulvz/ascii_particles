const std = @import("std");
const Particle = @import("particle.zig").Particle;

pub fn ParticleSystem(max_particles: comptime_int) type {
    return struct {
        particles: [max_particles]Particle,
        particle_count: usize,

        const Self = @This();

        pub fn init() Self {
            return .{
                .particles = std.mem.zeroes([max_particles]Particle),
                .particle_count = 0,
            };
        }
        pub const AppendError = error{
            ParticleSystemFull,
        };

        pub fn update_particles(self: *Self, dt: f64) void {
            const dt_vec = @as(@Vector(2, f64), @splat(dt));
            var i: usize = 0;
            while (i < self.particle_count) {
                var p = &self.particles[i];
                if (p.lifetime < 0) {
                    p.* = self.particles[self.particle_count - 1];
                    self.particle_count -= 1;
                    // don't decrement i to iterate over the swapped particle
                } else {
                    p.lifetime -= dt;
                    p.vel += p.acc * dt_vec;
                    p.pos += p.vel * dt_vec;
                    p.brightness -= p.fade_rate * dt;
                    if (p.brightness < 0)
                        p.brightness = 0;
                    i += 1;
                }
            }
        }

        pub fn append_particle(self: *Self, p: Particle) !void {
            if (self.particle_count > max_particles)
                return AppendError.ParticleSystemFull;

            self.particles[self.particle_count] = p;
            self.particle_count += 1;
        }
    };
}
