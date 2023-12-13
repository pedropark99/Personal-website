const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const string_literal = "This is an example of string literal in Zig";
    const simple_array = [_]i32{1, 2, 3, 4};


    print("Type of array object: {}\n", .{@TypeOf(simple_array)});
    print("Type of string object: {}\n", .{@TypeOf(string_literal)});
    print("Type of a pointer that points to the array object: {}\n", .{@TypeOf(&simple_array)});
}