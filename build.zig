const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib = b.addStaticLibrary(.{ .name = "ssh2", .target = target, .optimize = optimize });
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("config"));

    var cflags: std.ArrayList([]const u8) = .init(b.allocator);
    cflags.append("-DLIBSSH2_MBEDTLS") catch @panic("OOM");

    if (target.result.os.tag == .windows) {
        cflags.append("-D_CRT_SECURE_NO_DEPRECATE=1") catch @panic("OOM");
        cflags.append("-DHAVE_LIBCRYPT32") catch @panic("OOM");
        cflags.append("-DHAVE_WINSOCK2_H") catch @panic("OOM");
        cflags.append("-DHAVE_IOCTLSOCKET") catch @panic("OOM");
        cflags.append("-DHAVE_SELECT") catch @panic("OOM");
        cflags.append("-DLIBSSH2_DH_GEX_NEW=1") catch @panic("OOM");

        if (target.result.abi.isGnu()) {
            cflags.append("-DHAVE_UNISTD_H") catch @panic("OOM");
            cflags.append("-DHAVE_INTTYPES_H") catch @panic("OOM");
            cflags.append("-DHAVE_SYS_TIME_H") catch @panic("OOM");
            cflags.append("-DHAVE_GETTIMEOFDAY") catch @panic("OOM");
        }
    } else {
        cflags.append("-DHAVE_UNISTD_H") catch @panic("OOM");
        cflags.append("-DHAVE_INTTYPES_H") catch @panic("OOM");
        cflags.append("-DHAVE_STDLIB_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_SELECT_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_UIO_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_SOCKET_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_IOCTL_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_TIME_H") catch @panic("OOM");
        cflags.append("-DHAVE_SYS_UN_H") catch @panic("OOM");
        cflags.append("-DHAVE_LONGLONG") catch @panic("OOM");
        cflags.append("-DHAVE_GETTIMEOFDAY") catch @panic("OOM");
        cflags.append("-DHAVE_INET_ADDR") catch @panic("OOM");
        cflags.append("-DHAVE_POLL") catch @panic("OOM");
        cflags.append("-DHAVE_SELECT") catch @panic("OOM");
        cflags.append("-DHAVE_SOCKET") catch @panic("OOM");
        cflags.append("-DHAVE_STRTOLL") catch @panic("OOM");
        cflags.append("-DHAVE_SNPRINTF") catch @panic("OOM");
        cflags.append("-DHAVE_O_NONBLOCK") catch @panic("OOM");
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
