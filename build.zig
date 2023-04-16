const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib = b.addStaticLibrary(.{ .name = "ssh2", .target = target, .optimize = optimize });
    lib.addIncludePath("include");
    lib.addIncludePath("config");

    lib.addCSourceFiles(srcs, &.{});

    const mbedtls_dep = b.dependency("mbedtls", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(mbedtls_dep.artifact("mbedtls"));

    lib.linkLibC();

    lib.defineCMacro("LIBSSH2_MBEDTLS", null);
    if (target.isWindows()) {
        lib.defineCMacro("_CRT_SECURE_NO_DEPRECATE", "1");
        lib.defineCMacro("HAVE_LIBCRYPT32", null);
        lib.defineCMacro("HAVE_WINSOCK2_H", null);
        lib.defineCMacro("HAVE_IOCTLSOCKET", null);
        lib.defineCMacro("HAVE_SELECT", null);
        lib.defineCMacro("LIBSSH2_DH_GEX_NEW", "1");

        if (target.getAbi().isGnu()) {
            lib.defineCMacro("HAVE_UNISTD_H", null);
            lib.defineCMacro("HAVE_INTTYPES_H", null);
            lib.defineCMacro("HAVE_SYS_TIME_H", null);
            lib.defineCMacro("HAVE_GETTIMEOFDAY", null);
        }
    } else {
        lib.defineCMacro("HAVE_UNISTD_H", null);
        lib.defineCMacro("HAVE_INTTYPES_H", null);
        lib.defineCMacro("HAVE_STDLIB_H", null);
        lib.defineCMacro("HAVE_SYS_SELECT_H", null);
        lib.defineCMacro("HAVE_SYS_UIO_H", null);
        lib.defineCMacro("HAVE_SYS_SOCKET_H", null);
        lib.defineCMacro("HAVE_SYS_IOCTL_H", null);
        lib.defineCMacro("HAVE_SYS_TIME_H", null);
        lib.defineCMacro("HAVE_SYS_UN_H", null);
        lib.defineCMacro("HAVE_LONGLONG", null);
        lib.defineCMacro("HAVE_GETTIMEOFDAY", null);
        lib.defineCMacro("HAVE_INET_ADDR", null);
        lib.defineCMacro("HAVE_POLL", null);
        lib.defineCMacro("HAVE_SELECT", null);
        lib.defineCMacro("HAVE_SOCKET", null);
        lib.defineCMacro("HAVE_STRTOLL", null);
        lib.defineCMacro("HAVE_SNPRINTF", null);
        lib.defineCMacro("HAVE_O_NONBLOCK", null);
    }

    b.installArtifact(lib);
    lib.installHeadersDirectory("include", "");
}

const srcs = &.{
    "src/channel.c",
    "src/comp.c",
    "src/crypt.c",
    "src/hostkey.c",
    "src/kex.c",
    "src/mac.c",
    "src/misc.c",
    "src/packet.c",
    "src/publickey.c",
    "src/scp.c",
    "src/session.c",
    "src/sftp.c",
    "src/userauth.c",
    "src/transport.c",
    "src/version.c",
    "src/knownhost.c",
    "src/agent.c",
    "src/mbedtls.c",
    "src/pem.c",
    "src/keepalive.c",
    "src/global.c",
    "src/blowfish.c",
    "src/bcrypt_pbkdf.c",
    "src/agent_win.c",
};
