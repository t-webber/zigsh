const std = @import("std");
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;
const OpenError = std.fs.Dir.OpenError;

pub const Error = []const u8;

pub const Shell = struct {
    allocator: Allocator,
    env: process.EnvMap,

    pub fn new(allocator: Allocator) process.GetEnvMapError!@This() {
        return @This(){ .env = try process.getEnvMap(allocator), .allocator = allocator };
    }

    pub fn free(self: @This()) void {
        self.env.free();
    }

    pub fn get_ps1(self: *const @This()) Error {
        var ps1 = [_]u8{0} ** (511 + 3);
        const pwd = self.env.get("PWD").?;
        @memcpy(ps1[0..pwd.len], pwd);
        @memcpy(ps1[pwd.len .. pwd.len + 3], " $ ");
        return ps1[0 .. pwd.len + 3];
    }

    pub fn process_input(self: *@This(), line: []const u8) error{OutOfMemory}!Error {
        if (line.len < 3) return "";
        if (line[0] != 'p') return "";
        if (line[1] != ' ') return "";
        const dest = line[2..];
        for (dest) |ch| if (ch == ' ') return "Found more than 2 args for `p`.\n";
        if (dest[0] == '/') {
            return self.set_pwd(dest);
        } else {
            const old_pwd = self.env.get("PWD").?;
            const new_pwd = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ old_pwd, dest });
            return self.set_pwd(new_pwd);
        }

        return null;
    }

    pub fn set_pwd(self: *@This(), pwd: []const u8) error{OutOfMemory}!Error {
        const cwd = std.fs.cwd();
        var dir = cwd.openDir(pwd, .{ .access_sub_paths = false, .iterate = false }) catch |err| {
            const msg = switch (err) {
                OpenError.InvalidWtf8,
                OpenError.NetworkNotFound,
                OpenError.ProcessNotFound,
                OpenError.InvalidUtf8,
                OpenError.BadPathName,
                => unreachable,
                OpenError.FileNotFound => "doesn't exist",
                OpenError.NotDir => "not a dir",
                OpenError.AccessDenied,
                OpenError.PermissionDenied,
                => "permission denied (missing `x` mode)",
                OpenError.SymLinkLoop => "symlink loop",
                OpenError.ProcessFdQuotaExceeded => "process fd quota exceeded",
                OpenError.NameTooLong => "name too long",
                OpenError.SystemFdQuotaExceeded => "system fd quota exceeded",
                OpenError.NoDevice => "no device",
                OpenError.DeviceBusy => "device busy",
                OpenError.SystemResources => "kernel error",
                OpenError.Unexpected,
                => unreachable,
            };
            return try std.fmt.allocPrint(self.allocator, "chdir {s}: {s}.\n", .{ pwd, msg });
        };
        dir.close();
        try self.env.put("PWD", pwd);
        return "";
    }
};
