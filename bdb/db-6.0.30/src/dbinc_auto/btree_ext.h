/* DO NOT EDIT: automatically built by dist/s_include. */
#ifndef	_btree_ext_h_
#define	_btree_ext_h_

#if defined(__cplusplus)
extern "C" {
#endif

int __bam_compact_int __P((DBC *, DBT *, DBT *, u_int32_t, int *, DB_COMPACT *, int *));
int __bam_compact_opd __P((DBC *, db_pgno_t, PAGE **, u_int32_t, DB_COMPACT *, int *));
int __bam_truncate_ipages __P((DB *, DB_THREAD_INFO *, DB_TXN *, DB_COMPACT *, int *));
int __bam_cmp __P((DBC *, const DBT *, PAGE *, u_int32_t, int (*)(DB *, const DBT *, const DBT *, size_t *), int *, size_t *));
int __bam_defcmp __P((DB *, const DBT *, const DBT *, size_t *));
size_t __bam_defpfx __P((DB *, const DBT *, const DBT *));
int __bam_compress_dupcmp __P((DB *, const DBT *, const DBT *, size_t *));
int __bam_defcompress __P((DB *, const DBT *, const DBT *, const DBT *, const DBT *, DBT *));
int __bam_defdecompress __P((DB *, const DBT *, const DBT *, DBT *, DBT *, DBT *));
int __bamc_compress_get __P((DBC *, DBT *, DBT *, u_int32_t));
int __bamc_compress_put __P((DBC *, DBT *, DBT *, u_int32_t));
int __bamc_compress_del __P((DBC *, u_int32_t));
int __bamc_compress_bulk_del __P((DBC *, DBT *, u_int32_t));
int __bamc_compress_count __P((DBC *, db_recno_t *));
int __bamc_compress_cmp __P((DBC *, DBC *, int *));
int __bamc_compress_dup __P((DBC *, DBC *, u_int32_t));
int __bam_compress_salvage __P((DB *, VRFY_DBINFO *, void *, int (*)(void *, const void *), DBT *, DBT *));
int __bam_compress_count __P((DBC *, u_int32_t *, u_int32_t *));
int __bam_pgin __P((DB *, db_pgno_t, void *, DBT *));
int __bam_pgout __P((DB *, db_pgno_t, void *, DBT *));
int __bam_mswap __P((ENV *, PAGE *));
int __bam_ca_delete __P((DB *, db_pgno_t, u_int32_t, int, u_int32_t *));
int __ram_ca_delete __P((DB *, db_pgno_t, u_int32_t *));
int __bam_ca_di __P((DBC *, db_pgno_t, u_int32_t, int));
int __bam_ca_dup __P((DBC *, u_int32_t, db_pgno_t, u_int32_t, db_pgno_t, u_int32_t));
int __bam_ca_undodup __P((DB *, u_int32_t, db_pgno_t, u_int32_t, u_int32_t));
int __bam_ca_rsplit __P((DBC *, db_pgno_t, db_pgno_t));
int __bam_ca_split __P((DBC *, db_pgno_t, db_pgno_t, db_pgno_t, u_int32_t, int));
int __bam_ca_undosplit __P((DB *, db_pgno_t, db_pgno_t, db_pgno_t, u_int32_t));
int __bamc_init __P((DBC *, DBTYPE));
int __bamc_refresh __P((DBC *));
int __bamc_cmp __P((DBC *, DBC *, int *));
int __bamc_count __P((DBC *, db_recno_t *));
int __bamc_dup __P((DBC *, DBC *, u_int32_t));
int __bam_bulk_overflow __P((DBC *, u_int32_t, db_pgno_t, u_int8_t *));
int __bam_bulk_duplicates __P((DBC *, db_pgno_t, u_int8_t *, int32_t *, int32_t **, u_int8_t **, u_int32_t *, int));
int __bamc_rget __P((DBC *, DBT *));
int  __bam_opd_exists __P((DBC *, db_pgno_t));
int __bam_ditem __P((DBC *, PAGE *, u_int32_t));
int __bam_adjindx __P((DBC *, PAGE *, u_int32_t, u_int32_t, int));
int __bam_dpages __P((DBC *, int, int));
int __bam_pupdate __P((DBC *, PAGE *));
int __bam_db_create __P((DB *));
int __bam_db_close __P((DB *));
void __bam_map_flags __P((DB *, u_int32_t *, u_int32_t *));
int __bam_set_flags __P((DB *, u_int32_t *flagsp));
int __bam_set_bt_compare __P((DB *, int (*)(DB *, const DBT *, const DBT *, size_t *)));
int __bam_set_bt_compress __P((DB *, int (*)(DB *, const DBT *, const DBT *, const DBT *, const DBT *, DBT *), int (*)(DB *, const DBT *, const DBT *, DBT *, DBT *, DBT *)));
int __bam_get_bt_minkey __P((DB *, u_int32_t *));
void __bam_copy_config __P((DB *, DB*, u_int32_t));
void __ram_map_flags __P((DB *, u_int32_t *, u_int32_t *));
int __ram_set_flags __P((DB *, u_int32_t *flagsp));
int __ram_get_re_len __P((DB *, u_int32_t *));
int __ram_get_re_pad __P((DB *, int *));
int __bam_open __P((DB *, DB_THREAD_INFO *, DB_TXN *, const char *, db_pgno_t, u_int32_t));
int __bam_metachk __P((DB *, const char *, BTMETA *));
int __bam_read_root __P((DB *, DB_THREAD_INFO *, DB_TXN *, db_pgno_t, u_int32_t));
int __bam_new_file __P((DB *, DB_THREAD_INFO *, DB_TXN *, DB_FH *, const char *));
int __bam_new_subdb __P((DB *, DB *, DB_THREAD_INFO *, DB_TXN *));
int __bam_iitem __P((DBC *, DBT *, DBT *, u_int32_t, u_int32_t));
int __bam_ritem __P((DBC *, PAGE *, u_int32_t, DBT *, u_int32_t));
int __bam_ritem_nolog __P((DBC *, PAGE *, u_int32_t, DBT *, DBT *, u_int32_t));
int __bam_irep __P((DBC *, PAGE *, u_int32_t, DBT *, DBT *));
int __bam_split_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_split_48_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_split_42_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_rsplit_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_adj_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_cadjust_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_cdel_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_repl_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_irep_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_root_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_curadj_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_rcuradj_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_merge_44_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_relink_43_recover __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_reclaim __P((DB *, DB_THREAD_INFO *, DB_TXN *, u_int32_t));
int __bam_truncate __P((DBC *, u_int32_t *));
int __ram_open __P((DB *, DB_THREAD_INFO *, DB_TXN *, const char *, db_pgno_t, u_int32_t));
int __ram_append __P((DBC *, DBT *, DBT *));
int __ramc_del __P((DBC *, u_int32_t));
int __ramc_get __P((DBC *, DBT *, DBT *, u_int32_t, db_pgno_t *));
int __ramc_put __P((DBC *, DBT *, DBT *, u_int32_t, db_pgno_t *));
int __ram_ca __P((DBC *, ca_recno_arg, int *));
int __ram_getno __P((DBC *, const DBT *, db_recno_t *, int));
int __ram_writeback __P((DB *));
int __bam_rsearch __P((DBC *, db_recno_t *, u_int32_t, int, int *));
int __bam_adjust __P((DBC *, int32_t));
int __bam_nrecs __P((DBC *, db_recno_t *));
db_recno_t __bam_total __P((DB *, PAGE *));
int __bam_get_root __P((DBC *, db_pgno_t, int, u_int32_t, int *));
int __bam_search __P((DBC *, db_pgno_t, const DBT *, u_int32_t, int, db_recno_t *, int *));
int __bam_stkrel __P((DBC *, u_int32_t));
int __bam_stkgrow __P((ENV *, BTREE_CURSOR *));
int __bam_split __P((DBC *, void *, db_pgno_t *));
int __bam_broot __P((DBC *, PAGE *, u_int32_t, PAGE *, PAGE *));
int __ram_root __P((DBC *, PAGE *, PAGE *, PAGE *));
int __bam_pinsert __P((DBC *, EPG *, u_int32_t, PAGE *, PAGE *, int));
int __bam_copy __P((DB *, PAGE *, PAGE *, u_int32_t, u_int32_t));
int __bam_stat __P((DBC *, void *, u_int32_t));
int __bam_stat_print __P((DBC *, u_int32_t));
int __bam_stat_callback __P((DBC *, PAGE *, void *, int *));
void __bam_print_cursor __P((DBC *));
int __bam_key_range __P((DBC *, DBT *, DB_KEY_RANGE *, u_int32_t));
int __bam_traverse __P((DBC *, db_lockmode_t, db_pgno_t, int (*)(DBC *, PAGE *, void *, int *), void *));
int __bam_30_btreemeta __P((DB *, char *, u_int8_t *));
int __bam_31_btreemeta __P((DB *, char *, u_int32_t, DB_FH *, PAGE *, int *));
int __bam_31_lbtree __P((DB *, char *, u_int32_t, DB_FH *, PAGE *, int *));
int __bam_60_btreemeta __P((DB *, char *, u_int32_t, DB_FH *, PAGE *, int *));
int __bam_60_lbtree __P((DB *, char *, u_int32_t, DB_FH *, PAGE *, int *));
int __bam_vrfy_meta __P((DB *, VRFY_DBINFO *, BTMETA *, db_pgno_t, u_int32_t));
int __ram_vrfy_leaf __P((DB *, VRFY_DBINFO *, PAGE *, db_pgno_t, u_int32_t));
int __bam_vrfy __P((DB *, VRFY_DBINFO *, PAGE *, db_pgno_t, u_int32_t));
int __bam_vrfy_itemorder __P((DB *, VRFY_DBINFO *, DB_THREAD_INFO *, PAGE *, db_pgno_t, u_int32_t, int, int, u_int32_t));
int __bam_vrfy_structure __P((DB *, VRFY_DBINFO *, db_pgno_t, void *, void *, u_int32_t));
int __bam_vrfy_subtree __P((DB *, VRFY_DBINFO *, db_pgno_t, void *, void *, u_int32_t, u_int32_t *, u_int32_t *, u_int32_t *));
int __bam_salvage __P((DB *, VRFY_DBINFO *, db_pgno_t, u_int32_t, PAGE *, void *, int (*)(void *, const void *), DBT *, u_int32_t));
int __bam_salvage_walkdupint __P((DB *, VRFY_DBINFO *, PAGE *, DBT *, void *, int (*)(void *, const void *), u_int32_t));
int __bam_meta2pgset __P((DB *, VRFY_DBINFO *, BTMETA *, u_int32_t, DB *));
int __bam_init_recover __P((ENV *, DB_DISTAB *));
int __bam_split_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_split_48_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_split_42_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_rsplit_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_adj_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_cadjust_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_cdel_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_repl_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_irep_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_root_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_curadj_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_rcuradj_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_relink_43_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_merge_44_print __P((ENV *, DBT *, DB_LSN *, db_recops, void *));
int __bam_init_print __P((ENV *, DB_DISTAB *));

#if defined(__cplusplus)
}
#endif
#endif /* !_btree_ext_h_ */


