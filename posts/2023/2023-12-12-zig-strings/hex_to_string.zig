const std = @import("std");

pub fn main() !void {
    var utf8 = (try std.unicode.Utf8View.init("アメリカ")).iterator();
    while (utf8.nextCodepointSlice()) |codepoint| {
        std.debug.print("got codepoint {}\n", .{std.fmt.fmtSliceHexUpper(codepoint)});
    }
}
