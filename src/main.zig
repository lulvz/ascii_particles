const std = @import("std");

const Particle = @import("particle.zig").Particle;
const ParticleSystem = @import("particle_system.zig").ParticleSystem;
const emitter = @import("emitter.zig");
const Emitter = emitter.Emitter;
const FireEmitter = emitter.FireEmitter;

const global_force = @import("global_force.zig");
const GlobalForce = global_force.GlobalForce;
const Gravity = global_force.Gravity;
const Buoyancy = global_force.Buoyancy;

const MAX_PARTICLES = 200;
const WIDTH = 70;
const HEIGHT = 35;
const BUFFER_SIZE = WIDTH * HEIGHT;
const TARGET_FPS = 144;
const TARGET_DT_NS: comptime_int = @intFromFloat((1.0 / @as(comptime_float, TARGET_FPS)) * @as(comptime_float, @floatFromInt(std.time.ns_per_s)));

// const luminance_ramp: []const u8 = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ";
const luminance_ramp: []const u8 = "@OC*+~:,. ";
var frame_buffer: [BUFFER_SIZE]u8 = .{'A'} ** BUFFER_SIZE;

pub fn updateFrameBuffer(ps: *ParticleSystem(MAX_PARTICLES)) void {
    @memset(&frame_buffer, ' ');
    for (0..ps.particle_count) |i| {
        const particle = ps.particles[i];
        if ((particle.pos[0] < 0 or particle.pos[0] > WIDTH - 1) or
            (particle.pos[1] < 0 or particle.pos[1] > HEIGHT - 1)) continue;
        const floored_pos = std.math.floor(particle.pos);
        const x: usize = @intFromFloat(floored_pos[0]);
        const y: usize = @intFromFloat(floored_pos[1]);
        frame_buffer[y * WIDTH + x] =
            luminance_ramp[@intFromFloat((luminance_ramp.len - 1) - particle.brightness * (luminance_ramp.len - 1))];
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

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var emitters = [_]Emitter{.{ .FireEmitter = FireEmitter.init(.{ @floor(@as(f64, @floatFromInt(WIDTH)) / 2), 0.0 }, 1.0, 20.0, rand, null) }};

    // var gfg: GlobalForce = .{ .Gravity = Gravity.init(.{}) };
    // var gfb: GlobalForce = .{ .Buoyancy = Buoyancy.init(.{}) };

    var global_forces = [_]GlobalForce{
        .{ .Gravity = Gravity.init(.{}) },
        .{ .Buoyancy = Buoyancy.init(.{}) },
    };

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.fs.File.stdout().writer(&stdout_buffer);
    var stdout = &stdout_file.interface;

    const running = true;
    var timer = try std.time.Timer.start();
    _ = try stdout.write("\x1b[2J"); // clear the screen
    while (running) {
        const elapsed_ns = timer.lap();
        const dt = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;

        // logic

        // emitters
        for (&emitters) |*em| {
            em.update(&ps, dt);
        }

        // global forces
        for (&global_forces) |*gf| {
            gf.update(&ps, dt);
        }

        ps.update_particles(dt);
        updateFrameBuffer(&ps);

        // render
        _ = try stdout.write("\x1b[H"); // return the cursor to home
        try stdout.print("{s}\n", .{"-" ** (WIDTH + 2)});
        var row: isize = HEIGHT - 1;
        while (row >= 0) : (row -= 1) {
            const row_idx = @as(usize, @intCast(row));
            _ = try stdout.write("|");
            _ = try stdout.write(frame_buffer[row_idx * WIDTH .. row_idx * WIDTH + WIDTH]);
            _ = try stdout.write("|\n"); // return the cursor to home
        }
        try stdout.print("{s}\n", .{"-" ** (WIDTH + 2)});
        try stdout.print("dt: {d}", .{dt});
        // try bw.flush();

        if (elapsed_ns < TARGET_DT_NS) {
            std.Thread.sleep(TARGET_DT_NS - elapsed_ns);
        }
    }
}
