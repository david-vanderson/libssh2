#include "runner.h"

static const char *USERNAME = "libssh2"; /* set in Dockerfile */
static const char *KEY_FILE_PRIVATE = "key_rsa";
static const char *KEY_FILE_PUBLIC = "key_rsa.pub"; /* set in Dockerfile */

int test(LIBSSH2_SESSION *session)
{
    int rc;
    LIBSSH2_CHANNEL *channel;

    const char *userauth_list =
        libssh2_userauth_list(session, USERNAME,
                              (unsigned int)strlen(USERNAME));
    if(!userauth_list) {
        print_last_session_error("libssh2_userauth_list");
        return 1;
    }

    if(!strstr(userauth_list, "publickey")) {
        fprintf(stderr, "'publickey' was expected in userauth list: %s\n",
                userauth_list);
        return 1;
    }

    rc = libssh2_userauth_publickey_fromfile_ex(
        session, USERNAME, (unsigned int)strlen(USERNAME),
        srcdir_path(KEY_FILE_PUBLIC), srcdir_path(KEY_FILE_PRIVATE),
        NULL);
    if(rc) {
        print_last_session_error("libssh2_userauth_publickey_fromfile_ex");
        return 1;
    }

    channel = libssh2_channel_open_session(session);
    #if 0
    if(!channel) {
        printf("Error opening channel\n");
        return 1;
    }
    #endif

    rc = libssh2_channel_request_auth_agent(channel);
    if(rc) {
        fprintf(stderr, "Auth agent request for agent forwarding failed, "
            "error code %d\n", rc);
        return 1;
    }

    return 0;
}
