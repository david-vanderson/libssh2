#include "runner.h"

/* configured in Dockerfile */
static const char *PASSWORD = "my test password";
static const char *WRONG_USERNAME = "i dont exist";

int test(LIBSSH2_SESSION *session)
{
    int rc;

    const char *userauth_list =
        libssh2_userauth_list(session, WRONG_USERNAME,
                              (unsigned int)strlen(WRONG_USERNAME));
    if(!userauth_list) {
        print_last_session_error("libssh2_userauth_list");
        return 1;
    }

    if(!strstr(userauth_list, "password")) {
        fprintf(stderr, "'password' was expected in userauth list: %s\n",
                userauth_list);
        return 1;
    }

    rc = libssh2_userauth_password_ex(session, WRONG_USERNAME,
                                      (unsigned int)strlen(WRONG_USERNAME),
                                      PASSWORD,
                                      (unsigned int)strlen(PASSWORD), NULL);
    if(rc == 0) {
        fprintf(stderr, "Password auth succeeded with wrong username\n");
        return 1;
    }

    return 0;
}
