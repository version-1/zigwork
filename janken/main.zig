const std = @import("std");

const HAND_TYPE = enum { rock, paper, scissors };

pub fn main() !void {
    std.debug.print("{s}\n", .{"Your Turn. Select Hands."});
    std.debug.print("{s}\n", .{"1 => Rock. 🪨"});
    std.debug.print("{s}\n", .{"2 => Paper. 📄"});
    std.debug.print("{s}\n", .{"3 => Scrissors. 🦞"});

    const buffer_size: usize = 10;
    var buffer: [buffer_size]u8 = undefined;
    const stdin = std.io.getStdIn().reader();

    // waiting for user input
    std.debug.print("----> \n", .{});
    _ = try stdin.readUntilDelimiter(&buffer, '\n');

    const char = buffer[0..1];
    const res = try std.fmt.parseInt(u8, char, 10);
    const hand = res - 1;
    switch (hand) {
        @intFromEnum(HAND_TYPE.rock) => std.debug.print("You selected: Rock. 🪨\n", .{}),
        @intFromEnum(HAND_TYPE.paper) => std.debug.print("You selected: Paper. 📄\n", .{}),
        @intFromEnum(HAND_TYPE.scissors) => std.debug.print("You selected: Scissors. 🦞\n", .{}),
        else => {
            std.debug.print("Invalid Selection. Please select Rock(1), Paper(2) or Scissors(3).\n", .{});
            return;
        },
    }

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    const i = rand.int(u8);

    const cpu = i & 3;
    switch (cpu) {
        @intFromEnum(HAND_TYPE.rock) => std.debug.print("CPU selected: Rock. 🪨\n", .{}),
        @intFromEnum(HAND_TYPE.paper) => std.debug.print("CPU selected: Paper. 📄\n", .{}),
        @intFromEnum(HAND_TYPE.scissors) => std.debug.print("CPU selected: Scissors. 🦞\n", .{}),
        else => unreachable,
    }

    switch (hand) {
        @intFromEnum(HAND_TYPE.rock) => switch (cpu) {
            @intFromEnum(HAND_TYPE.rock) => std.debug.print("Draw. 🤝\n", .{}),
            @intFromEnum(HAND_TYPE.paper) => std.debug.print("You Lose. 😢\n", .{}),
            @intFromEnum(HAND_TYPE.scissors) => std.debug.print("You Win. 🎉\n", .{}),
            else => unreachable,
        },
        @intFromEnum(HAND_TYPE.paper) => switch (cpu) {
            @intFromEnum(HAND_TYPE.rock) => std.debug.print("You Win. 🎉\n", .{}),
            @intFromEnum(HAND_TYPE.paper) => std.debug.print("Draw. 🤝\n", .{}),
            @intFromEnum(HAND_TYPE.scissors) => std.debug.print("You Lose. 😢\n", .{}),
            else => unreachable,
        },
        @intFromEnum(HAND_TYPE.scissors) => switch (cpu) {
            @intFromEnum(HAND_TYPE.rock) => std.debug.print("You Lose. 😢\n", .{}),
            @intFromEnum(HAND_TYPE.paper) => std.debug.print("You Win. 🎉\n", .{}),
            @intFromEnum(HAND_TYPE.scissors) => std.debug.print("Draw. 🤝\n", .{}),
            else => unreachable,
        },
        else => unreachable,
    }
}
