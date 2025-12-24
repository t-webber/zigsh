const std = @import("std");
const File = std.fs.File;

const Shell = @import("shell.zig").Shell;

const IoError = error{ BufferOverflow, OutOfMemory } || File.WriteError || File.ReadError;

pub fn main() IoError!void {
    const out = File.stdout();
    defer out.close();
    const in = File.stdin();
    defer in.close();

    var cwd: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&cwd);
    const allocator = fba.allocator();
    var shell = try Shell.new(allocator);

    var len: usize = undefined;
    var buf: [512]u8 = [_]u8{0} ** 512;

    while (true) {
        try out.writeAll(shell.get_ps1());
        len = try in.read(&buf);
        if (len == 512) return IoError.BufferOverflow;
        if (shell.process_input(buf[0 .. len - 1])) |res|
            try out.writeAll(res);
    }
}
