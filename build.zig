const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib = b.addStaticLibrary(.{ .name = "ssh2", .target = target, .optimize = optimize });
    lib.addIncludePath(.{ .path = "include" });
    lib.addIncludePath(.{ .path = "config" });

    lib.addCSourceFiles(.{ .files = srcs });

    const mbedtls_dep = b.dependency("mbedtls", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(mbedtls_dep.artifact("mbedtls"));

    lib.linkLibC();

    lib.defineCMacro("LIBSSH2_MBEDTLS", null);
    if (target.result.os.tag == .windows) {
        lib.defineCMacro("_CRT_SECURE_NO_DEPRECATE", "1");
        lib.defineCMacro("HAVE_LIBCRYPT32", null);
        lib.defineCMacro("HAVE_WINSOCK2_H", null);
        lib.defineCMacro("HAVE_IOCTLSOCKET", null);
        lib.defineCMacro("HAVE_SELECT", null);
        lib.defineCMacro("LIBSSH2_DH_GEX_NEW", "1");

        if (target.result.abi.isGnu()) {
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
