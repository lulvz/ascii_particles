const std = @import("std");

const Particle = @import("particle.zig").Particle;
const ParticleSystem = @import("particle_system.zig").ParticleSystem;
const Emitter = @import("emitter.zig").Emitter;
const FireEmitter = @import("fire_emitter.zig").FireEmitter;

const MAX_PARTICLES = 200;
const WIDTH = 70;
const HEIGHT = 35;
const BUFFER_SIZE = WIDTH * HEIGHT;

// const luminance_ramp: []const u8 = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ";
const luminance_ramp: []const u8 = "@OC*+~:,. ";
var frame_buffer: [BUFFER_SIZE]u8 = .{'A'}**BUFFER_SIZE;

pub fn updateFrameBuffer(ps: *ParticleSystem(MAX_PARTICLES)) void {
    @memset(&frame_buffer, ' ');
    for(0..ps.particle_count) |i| {
        const particle = ps.particles[i];
        if ((particle.pos[0] < 0 or particle.pos[0] > WIDTH-1) or
        (particle.pos[1] < 0 or particle.pos[1] > HEIGHT-1)) continue;
        const floored_pos = std.math.floor(particle.pos);
        const x: usize = @intFromFloat(floored_pos[0]);
        const y: usize = @intFromFloat(floored_pos[1]);
        frame_buffer[y*WIDTH + x] = 
            luminance_ramp[@intFromFloat((luminance_ramp.len-1) - particle.brightness * (luminance_ramp.len-1))];
    }
}

pub fn main() !void {
    const PS = ParticleSystem(MAX_PARTICLES);
    var ps = PS.init();

    // const p = Particle{
    //     .pos = .{10.0, 10.0},
    //     .vel = .{1.0, 0.0},
    //     .acc = .{0.0, 0.0},
    //     .lifetime = 10,
    //     .brightness = 1.0,
    //     .fade_rate = 0.1
    // };
    // try ps.append_particle(p);

    var em: Emitter = .{ .FireEmitter = .{} };

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const running = true;
    var timer = try std.time.Timer.start();

    _ = try stdout.write("\x1b[2J"); // clear the screen
    try bw.flush();
    while(running) {
        const dt = @as(f64, @floatFromInt(timer.lap())) / std.time.ns_per_s;

        // logic
        em.update(&ps, dt);
        ps.update_particles(dt);
        updateFrameBuffer(&ps);

        // render
        _ = try stdout.write("\x1b[H"); // return the cursor to home
        try stdout.print("{s}\n", .{"-"**(WIDTH+2)});
        for(0..HEIGHT) |row| {
            _ = try stdout.write("|");
            _ = try stdout.write(frame_buffer[row*WIDTH..row*WIDTH+WIDTH]);
            _ = try stdout.write("|\n"); // return the cursor to home
        }
        try stdout.print("{s}\n", .{"-"**(WIDTH+2)});
        try stdout.print("{d}", .{dt});
        try bw.flush();
        std.time.sleep(200000000);
    }
}
