const std = @import("std");
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;

pub const Shell = struct {
    allocator: Allocator,
    env: process.EnvMap,

    pub fn new(allocator: Allocator) process.GetEnvMapError!@This() {
        return @This(){ .env = try process.getEnvMap(allocator), .allocator = allocator };
    }

    pub fn free(self: @This()) void {
        self.env.free();
    }

    pub fn get_ps1(self: *const @This()) []const u8 {
        var ps1 = [_]u8{0} ** (511 + 3);
        const pwd = self.env.get("PWD").?;
        @memcpy(ps1[0..pwd.len], pwd);
        @memcpy(ps1[pwd.len .. pwd.len + 3], " $ ");
        return ps1[0 .. pwd.len + 3];
    }

    pub fn process_input(self: *@This(), line: []const u8) !?[]const u8 {
        if (line.len < 3) return null;
        if (line[0] != 'p') return null;
        if (line[1] != ' ') return null;
        const dest = line[2..];
        for (dest) |ch| if (ch == ' ') return "Found more than 2 args for `p`.\n";
        if (dest[0] == '/')
            try self.env.put("PWD", dest)
        else {
            const old_pwd = self.env.get("PWD").?;
            const new_pwd = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ old_pwd, dest });
            try self.env.put("PWD", new_pwd);
        }

        return null;
    }
};
