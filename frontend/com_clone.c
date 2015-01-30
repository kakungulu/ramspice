#include "ramspice_types.h"
#include "ngspice/ngspice.h"
#include "ngspice/bool.h"
#include "ngspice/wordlist.h"
#include "ngspice/fteext.h"
#include "ngspice/cpextern.h"

#include "com_clone.h"
#include "quote.h"
#include "variable.h"
#include "plotting/plotting.h"
#include "plotting/pvec.h"
#include <tcl.h>


void
com_clone(wordlist *wl)
{
    struct dvec *d;
    struct dvec **dvs;
    int len = 0, i = 0;
    char *s;

    /* Maybe he wants to know about just a few vectors. */

    out_init();

    while (wl) {
        s = cp_unquote(wl->wl_word);
        d = vec_get(s);
        tfree(s);               /*DG to avoid the cp_unquote memory leak */
        if (d == NULL)
            fprintf(cp_err, "Error: no such vector as %s.\n", wl->wl_word);
        else
            while (d) {
                pvec(d);
                d = d->v_link2;
            }
        if (wl->wl_next == NULL)
            return;
        wl = wl->wl_next;
    }

    if (plot_cur)
        for (d = plot_cur->pl_dvecs; d; d = d->v_next)
            len++;

    if (len == 0) {
        return;
    }

    dvs = TMALLOC(struct dvec *, len);
    for (d = plot_cur->pl_dvecs, i = 0; d; d = d->v_next, i++) dvs[i] = d;

    for (i = 0; i < len; i++) {
        d = dvs[i];
        pvec(d);
    }
    tfree(dvs);
}


