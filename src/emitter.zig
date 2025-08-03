const FireEmitter = @import("fire_emitter.zig").FireEmitter;

pub const Emitter = union(enum) {
    FireEmitter: FireEmitter,

    pub fn update(self: *Emitter, ps: anytype) void {
        return switch (self.*) {
            .FireEmitter => |*fe| fe.*.update(ps),
        };
    }
};
