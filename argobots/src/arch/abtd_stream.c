/* -*- Mode: C; c-basic-offset:4 ; indent-tabs-mode:nil ; -*- */
/*
 * See COPYRIGHT in top-level directory.
 */

#include "abti.h"
#include "real_pthread.h"

int ABTD_xstream_context_create(void *(*f_xstream)(void *), void *p_arg,
                                ABTD_xstream_context *p_ctx)
{
    int abt_errno = ABT_SUCCESS;
    int ret = real_pthread_create(p_ctx, NULL, f_xstream, p_arg);
    if (ret != 0) {
        HANDLE_ERROR("real_pthread_create");
        abt_errno = ABT_ERR_XSTREAM;
    }
    return abt_errno;
}

int ABTD_xstream_context_free(ABTD_xstream_context *p_ctx)
{
    ABTI_UNUSED(p_ctx);
    int abt_errno = ABT_SUCCESS;
    /* Currently, nothing to do */
    return abt_errno;
}

int ABTD_xstream_context_join(ABTD_xstream_context ctx)
{
    int abt_errno = ABT_SUCCESS;
    int ret = real_pthread_join(ctx, NULL);
    if (ret != 0) {
        HANDLE_ERROR("real_pthread_join");
        abt_errno = ABT_ERR_XSTREAM;
    }
    return abt_errno;
}

int ABTD_xstream_context_exit(void)
{
    real_pthread_exit(NULL);
    return ABT_SUCCESS;
}

int ABTD_xstream_context_self(ABTD_xstream_context *p_ctx)
{
    int abt_errno = ABT_SUCCESS;
    *p_ctx = real_pthread_self();
    return abt_errno;
}
