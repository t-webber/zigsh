const std = @import("std");
const File = std.fs.File;

const Shell = @import("shell.zig").Shell;

const IoError = error{ BufferOverflow, OutOfMemory } || File.WriteError || File.ReadError;

pub fn main() IoError!void {
    const out = File.stdout();
    defer out.close();
    const in = File.stdin();
    defer in.close();

    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = general_purpose_allocator.allocator();
    var shell = try Shell.new(gpa);

    var buf: [512]u8 = [_]u8{0} ** 512;

    while (true) {
        try out.writeAll(shell.get_ps1());
        const len = try in.read(&buf);
        if (len == 512) return IoError.BufferOverflow;
        if (try shell.process_input(buf[0 .. len - 1])) |res|
            try out.writeAll(res);
    }
}
