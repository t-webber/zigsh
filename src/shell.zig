const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const File = std.fs.File;

pub const Shell = struct {
    cwd: struct { data: []u8, len: usize },

    pub fn new(allocator: Allocator) !@This() {
        var buffer = try allocator.alloc(u8, 512);
        buffer[0] = '/';
        return @This(){ .cwd = .{ .data = buffer, .len = 1 } };
    }

    pub fn free(self: @This()) void {
        self.cwd.free();
    }

    pub fn get_ps1(self: *const @This()) []const u8 {
        var ps1 = [_]u8{0} ** (511 + 3);
        @memcpy(ps1[0..self.cwd.len], self.cwd.data[0..self.cwd.len]);
        @memcpy(ps1[self.cwd.len .. self.cwd.len + 3], " $ ");
        return ps1[0 .. self.cwd.len + 3];
    }

    pub fn process_input(self: *@This(), line: []const u8) ?[]const u8 {
        if (line.len < 3) return null;
        if (line[0] != 'p') return null;
        if (line[1] != ' ') return null;
        const dest = line[2..];
        for (dest) |ch| if (ch == ' ') return "Found more than 2 args for `p`.\n";
        @memcpy(self.cwd.data[0..dest.len], dest);
        self.cwd.len = dest.len;
        return null;
    }
};
