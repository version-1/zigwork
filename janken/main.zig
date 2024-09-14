const std = @import("std");

const HAND_TYPE = enum {
    rock,
    scissors,
    paper,
};

pub fn main() !void {
    std.debug.print("{s}\n", .{"Your Turn. Select Hands."});
    std.debug.print("{s}\n", .{"1 => Rock. 🪨"});
    std.debug.print("{s}\n", .{"2 => Scrissors. 🦞"});
    std.debug.print("{s}\n", .{"3 => Paper. 📄"});

    const handCount = @intFromEnum(HAND_TYPE.paper) + 1;

    const buffer_size: usize = 10;
    var buffer: [buffer_size]u8 = undefined;
    const stdin = std.io.getStdIn().reader();

    // waiting for user input
    std.debug.print("----> \n", .{});
    _ = try stdin.readUntilDelimiter(&buffer, '\n');

    const char = buffer[0..1];
    const res = try std.fmt.parseInt(u8, char, 10);
    const hand = res - 1;
    if (hand < 0 or hand >= handCount) {
        std.debug.print("Invalid Selection. Please select Rock(1), Paper(2) or Scissors(3).\n", .{});
        return;
    }
    printHand("You", hand);

    const cpu = try randomInt(0, handCount - 1);
    printHand("CPU", cpu);

    const messages: [3][]const u8 = .{ "Draw. 🤝\n", "You Win. 🎉\n", "You Lose. 😢\n" };
    for (messages, 0..) |message, index| {
        if ((hand + index) % handCount == cpu) {
            std.debug.print("{s}", .{message});
        }
    }
}

fn printHand(doer: []const u8, value: u8) void {
    switch (value) {
        @intFromEnum(HAND_TYPE.rock) => std.debug.print("{s} selected: Rock. 🪨\n", .{doer}),
        @intFromEnum(HAND_TYPE.paper) => std.debug.print("{s} selected: Paper. 📄\n", .{doer}),
        @intFromEnum(HAND_TYPE.scissors) => std.debug.print("{s} selected: Scissors. 🦞\n", .{doer}),
        else => unreachable,
    }
}

fn randomInt(min: u8, max: u8) !u8 {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    return (min + rand.int(u8)) % max;
}
