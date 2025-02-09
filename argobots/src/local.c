/* -*- Mode: C; c-basic-offset:4 ; indent-tabs-mode:nil ; -*- */
/*
 * See COPYRIGHT in top-level directory.
 */

#include "abti.h"


/*****************************************************************************/
/* Private APIs                                                              */
/*****************************************************************************/

/* ES Local Data */
ABTD_XSTREAM_LOCAL ABTI_local *lp_ABTI_local = NULL;
ABTD_XSTREAM_LOCAL int l_ABTI_entry_count = 1;

static ABTI_local *ABTI_local_get(void)
{
    return lp_ABTI_local;
}

ABTI_local *(*gp_ABTI_local_get)(void) = ABTI_local_get;

static int *ABTI_local_get_entry_count_internal(void)
{
    return &l_ABTI_entry_count;
}

int *(*gp_ABTI_local_entry_count_get)(void) = ABTI_local_get_entry_count_internal;

int ABTI_local_init(void)
{
    int abt_errno = ABT_SUCCESS;
    ABTI_CHECK_TRUE(lp_ABTI_local == NULL, ABT_ERR_OTHER);

    lp_ABTI_local = (ABTI_local *)ABTU_malloc(sizeof(ABTI_local));
    lp_ABTI_local->p_xstream = NULL;
    lp_ABTI_local->p_thread = NULL;
    lp_ABTI_local->p_task = NULL;

    ABTI_mem_init_local(lp_ABTI_local);

    ABTI_LOG_INIT();

  fn_exit:
    return abt_errno;

  fn_fail:
    HANDLE_ERROR_FUNC_WITH_CODE(abt_errno);
    goto fn_exit;
}

int ABTI_local_finalize(void)
{
    int abt_errno = ABT_SUCCESS;
    ABTI_CHECK_TRUE(lp_ABTI_local != NULL, ABT_ERR_OTHER);
    ABTI_mem_finalize_local(lp_ABTI_local);
    ABTU_free(lp_ABTI_local);
    lp_ABTI_local = NULL;

    ABTI_LOG_FINALIZE();

  fn_exit:
    return abt_errno;

  fn_fail:
    HANDLE_ERROR_FUNC_WITH_CODE(abt_errno);
    goto fn_exit;
}

