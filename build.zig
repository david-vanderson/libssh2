const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib = b.addStaticLibrary(.{ .name = "ssh2", .target = target, .optimize = optimize });
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("config"));

    var cflags: std.ArrayList([]const u8) = .init(b.allocator);
    defer cflags.deinit();
    try cflags.append("-DLIBSSH2_MBEDTLS");

    if (target.result.os.tag == .windows) {
        try cflags.appendSlice(&.{
            "-D_CRT_SECURE_NO_DEPRECATE=1",
            "-DHAVE_LIBCRYPT32",
            "-DHAVE_WINSOCK2_H",
            "-DHAVE_IOCTLSOCKET",
            "-DHAVE_SELECT",
            "-DLIBSSH2_DH_GEX_NEW=1",
        });

        if (target.result.abi.isGnu()) {
            try cflags.appendSlice(&.{
                "-DHAVE_UNISTD_H",
                "-DHAVE_INTTYPES_H",
                "-DHAVE_SYS_TIME_H",
                "-DHAVE_GETTIMEOFDAY",
            });
        }
    } else {
        try cflags.appendSlice(&.{
            "-DHAVE_UNISTD_H",
            "-DHAVE_INTTYPES_H",
            "-DHAVE_STDLIB_H",
            "-DHAVE_SYS_SELECT_H",
            "-DHAVE_SYS_UIO_H",
            "-DHAVE_SYS_SOCKET_H",
            "-DHAVE_SYS_IOCTL_H",
            "-DHAVE_SYS_TIME_H",
            "-DHAVE_SYS_UN_H",
            "-DHAVE_LONGLONG",
            "-DHAVE_GETTIMEOFDAY",
            "-DHAVE_INET_ADDR",
            "-DHAVE_POLL",
            "-DHAVE_SELECT",
            "-DHAVE_SOCKET",
            "-DHAVE_STRTOLL",
            "-DHAVE_SNPRINTF",
            "-DHAVE_O_NONBLOCK",
        });
    }

    lib.addCSourceFiles(.{ .files = srcs, .flags = cflags.items });

    const mbedtls_dep = b.dependency("mbedtls", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(mbedtls_dep.artifact("mbedtls"));

    lib.linkLibC();

    b.installArtifact(lib);
    lib.installHeadersDirectory(b.path("include"), "", .{});
}

const srcs = &.{
    "src/agent.c",
    "src/agent_win.c",
    "src/bcrypt_pbkdf.c",
    "src/blowfish.c",
    "src/channel.c",
    "src/comp.c",
    "src/crypt.c",
    "src/crypto.c",
    "src/global.c",
    "src/hostkey.c",
    "src/keepalive.c",
    "src/kex.c",
    "src/knownhost.c",
    "src/libgcrypt.c",
    "src/mac.c",
    "src/mbedtls.c",
    "src/misc.c",
    "src/openssl.c",
    "src/os400qc3.c",
    "src/packet.c",
    "src/pem.c",
    "src/publickey.c",
    "src/scp.c",
    "src/session.c",
    "src/sftp.c",
    "src/transport.c",
    "src/userauth.c",
    "src/userauth_kbd_packet.c",
    "src/version.c",
    "src/wincng.c",
};
