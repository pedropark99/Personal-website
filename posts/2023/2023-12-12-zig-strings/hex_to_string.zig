const std = @import("std");

pub fn main() !void {
    const string_literal = "Ⱥ";
    std.debug.print("Bytes that represents the string object: ", .{});
    for (string_literal) |char| {
        std.debug.print("{X} ", .{char});
    }
    std.debug.print("\n", .{});
}
