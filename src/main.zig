const std = @import("std");

const File = std.fs.File;

const alloc = std.alloc.page_allocator;

const IoError = error{BufferOverflow} || File.WriteError || File.ReadError;

pub fn main() IoError!void {
    const out = File.stdout();
    defer out.close();
    const in = File.stdin();
    defer in.close();

    var len: usize = undefined;
    var buf = [_]u8{0} ** 512;

    while (true) {
        try out.writeAll("$ ");
        len = try in.read(&buf);
        if (len == 512) return IoError.BufferOverflow;
        _ = try out.write(">>> ");
        _ = try out.write(buf[0 .. len - 1]);
        try out.writeAll("\n");
    }
}
