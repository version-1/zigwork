const std = @import("std");

const HAND_TYPE = enum {
    rock,
    scissors,
    paper,

    fn description(self: HAND_TYPE) []const u8 {
        switch (self) {
            HAND_TYPE.rock => return "Rock. 🪨",
            HAND_TYPE.scissors => return "Scissors. 🦞",
            HAND_TYPE.paper => return "Paper. 📄",
        }
    }
};

const RESULT = enum {
    draw,
    win,
    lose,
};

const Player = struct {
    name: []const u8,
    hand: HAND_TYPE,
    cpu: bool,
};

const GameMaster = struct {
    hands: *std.AutoArrayHashMap(HAND_TYPE, u8),

    pub fn record(self: *GameMaster, cpu: Player) !void {
        const n = self.hands.get(cpu.hand);
        if (n == null) {
            _ = try self.hands.put(cpu.hand, 1);
        } else {
            const v: u8 = n.?;
            _ = try self.hands.put(cpu.hand, v + 1);
        }
    }

    pub fn judge(self: GameMaster, player: Player) RESULT {
        if (self.hands.count() == 1 or self.hands.count() == 3) {
            return RESULT.draw;
        }

        var sum: u8 = 0;
        for (self.hands.keys()) |key| {
            sum += @intFromEnum(key);
        }

        const hand = player.hand;
        switch (sum) {
            1 => return if (hand == HAND_TYPE.rock) RESULT.win else RESULT.lose,
            2 => return if (hand == HAND_TYPE.paper) RESULT.win else RESULT.lose,
            3 => return if (hand == HAND_TYPE.scissors) RESULT.win else RESULT.lose,
            else => unreachable,
        }
    }

    pub fn printState(self: GameMaster) void {
        std.debug.print("\nGame State:\n", .{});
        for (self.hands.keys()) |key| {
            const v = self.hands.get(key).?;
            std.debug.print("Hand: {s} Count: {d}\n", .{ key.description(), v });
        }
    }
};

const maxCPUCount = 100;

const messages: [3][]const u8 = .{ "Draw. 🤝\n", "You Win. 🎉\n", "You Lose. 😢\n" };

pub fn main() !void {
    std.debug.print("Choose cpu counts (up to 100). ====>\n", .{});
    const cpuCount = try chooseNumber();
    if (cpuCount > maxCPUCount) {
        std.debug.print("Invalid Selection. Please select a number between 1 and 100.\n", .{});
        return;
    }
    std.debug.print("CPU Count: {d}\n", .{cpuCount});

    std.debug.print("{s}\n", .{"Your Turn. Select Hands."});
    std.debug.print("{s}\n", .{"1 => Rock. 🪨"});
    std.debug.print("{s}\n", .{"2 => Scrissors. 🦞"});
    std.debug.print("{s}\n", .{"3 => Paper. 📄"});

    const handCount = @intFromEnum(HAND_TYPE.paper) + 1;

    // waiting for user input
    std.debug.print("----> \n", .{});
    const res = try chooseNumber();
    const hand = res - 1;
    if (hand < 0 or hand >= handCount) {
        std.debug.print("Invalid Selection. Please select Rock(1), Paper(2) or Scissors(3).\n", .{});
        return;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var hands = std.AutoArrayHashMap(HAND_TYPE, u8).init(alloc);
    var gm = GameMaster{ .hands = &hands };
    const player = Player{
        .name = "You",
        .hand = @enumFromInt(hand),
        .cpu = false,
    };
    try gm.record(player);
    printHand("You", player.hand);
    defer arena.deinit();

    for (1..(cpuCount + 1)) |index| {
        var buf: [10]u8 = undefined;
        const name = try std.fmt.bufPrint(&buf, "CPU {d}", .{index});
        const handInt = try randomInt(0, handCount - 1);
        const cpu = Player{
            .name = name,
            .hand = @enumFromInt(handInt),
            .cpu = true,
        };

        try gm.record(cpu);
        printHand(cpu.name, cpu.hand);
    }

    const result = gm.judge(player);
    gm.printState();
    std.debug.print("{s}", .{messages[@intFromEnum(result)]});
}

fn chooseNumber() !u8 {
    const buffer_size: usize = 10;
    var buffer: [buffer_size]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    _ = try stdin.readUntilDelimiter(&buffer, '\n');
    var len: u8 = 0;
    for (buffer) |c| {
        if (c < '0' or c > '9') {
            break;
        } else {
            len = len + 1;
        }
    }

    const char = buffer[0..len];
    return std.fmt.parseInt(u8, char, 10);
}

fn printHand(doer: []const u8, value: HAND_TYPE) void {
    switch (value) {
        HAND_TYPE.rock => std.debug.print("{s} selected: Rock. 🪨\n", .{doer}),
        HAND_TYPE.paper => std.debug.print("{s} selected: Paper. 📄\n", .{doer}),
        HAND_TYPE.scissors => std.debug.print("{s} selected: Scissors. 🦞\n", .{doer}),
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
