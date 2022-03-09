FUNCTION ZFM_FI_DIRECT_CASH_FLOW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(COMPANY_CODE) TYPE  BUKRS
*"     REFERENCE(HOUSE_BANK) TYPE  HBKID OPTIONAL
*"     REFERENCE(ACCOUNT_ID) TYPE  HKTID OPTIONAL
*"     REFERENCE(FISCAL_YEAR) TYPE  GJAHR OPTIONAL
*"     REFERENCE(PERIOD) TYPE  POPER OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_CASHFLOW) TYPE  ZTT_CASHFLOW
*"----------------------------------------------------------------------

TYPES: BEGIN OF ty_t012k,
        BUKRS   TYPE bukrs,
        HBKID   TYPE hbkid,
        HKTID   TYPE hktid,
        HKONT   TYPE hkont,
        HKONT_1 TYPE hkont, "1 - Incoming
        HKONT_2 TYPE hkont, "2 - Outgoing
       END OF ty_t012k.

TYPES: BEGIN OF ty_in_out,
        BUKRS   TYPE bukrs,
        HBKID   TYPE hbkid,
        HKTID   TYPE hktid,
        HKONT   TYPE hkont,
       END OF ty_in_out.


TYPES: BEGIN OF ty_ska1,
        KTOPL TYPE ktopl,
        SAKNR TYPE saknr,
        XBILK TYPE xbilk,
       END OF ty_ska1.

*TYPES: BEGIN OF ty_acdoca,
*        RBUKRS  TYPE acdoca-rbukrs,
*        GJAHR   TYPE acdoca-gjahr,
*        BELNR   TYPE acdoca-belnr,
*        DOCLN   TYPE acdoca-docln,
*        RWCUR   TYPE acdoca-rwcur,
*        RHCUR   TYPE acdoca-rhcur,
*        RKCUR   TYPE acdoca-rkcur,
*        RACCT   TYPE acdoca-racct,
*        PRCTR   TYPE acdoca-prctr,
*        RASSC   TYPE acdoca-rassc,
*        WSL     TYPE acdoca-wsl,
*        HSL     TYPE acdoca-hsl,
*        KSL     TYPE acdoca-ksl,
*        DRCRK   TYPE acdoca-drcrk,
*        POPER   TYPE acdoca-poper,
*        KTOSL   TYPE acdoca-ktosl,
*        LIFNR   TYPE acdoca-lifnr,
*        KUNNR   TYPE acdoca-kunnr,
*        KOART   TYPE acdoca-koart,
*        UMSKZ   TYPE acdoca-umskz,
*        MWSKZ   TYPE acdoca-mwskz,
*        AUGBL   TYPE acdoca-augbl,
*        ANLN1   TYPE acdoca-anln1,
*        GKONT   TYPE acdoca-gkont,
*        GKOAR   TYPE acdoca-gkoar,
*       END OF ty_acdoca.

DATA: gs_t012k      TYPE ty_t012k,
      gt_t012k      TYPE STANDARD TABLE OF ty_t012k,
      gs_t012k_mask TYPE ty_t012k,
      gt_t012k_mask TYPE STANDARD TABLE OF ty_t012k,
      gs_in_out     TYPE ty_in_out,
      gt_in_out     TYPE STANDARD TABLE OF ty_in_out,
      gs_ska1       TYPE ty_ska1,
      gt_ska1       TYPE STANDARD TABLE OF ty_ska1,
      gs_acdoca     TYPE zst_acdoca,
      gt_acdoca     TYPE STANDARD TABLE OF zst_acdoca,
      es_cashflow   TYPE ZST_CASHFLOW.

FIELD-SYMBOLS: <fs_t012k> TYPE ty_t012k.

DATA: lv_string(10) TYPE c,
      lv_length     TYPE i,
      lv_continue   TYPE c VALUE 'X',
      ls_acdoca     TYPE zst_acdoca,
      ls_acdoca_offset TYPE zst_acdoca,
      ls_acdoca_final  TYPE zst_acdoca,
      lt_acdoca     TYPE STANDARD TABLE OF zst_acdoca,
      lv_drcrk      TYPE SHKZG,
      lv_augbl      TYPE augbl.

SELECT BUKRS HBKID HKTID HKONT
       from t012k
       INTO CORRESPONDING FIELDS OF TABLE gt_t012k
       WHERE bukrs = company_code.

  IF sy-subrc eq 0.
    IF house_bank IS NOT INITIAL.
      DELETE gt_t012k WHERE hbkid ne house_bank.
    ENDIF.

    IF account_id IS NOT INITIAL.
      DELETE gt_t012k WHERE hktid ne account_id.
    ENDIF.
  ENDIF.

  LOOP AT gt_t012k ASSIGNING <fs_t012k>.
    lv_string = <fs_t012k>-hkont.
    lv_length = strlen( lv_string ).
    lv_length = lv_length - 1.
    lv_string+lv_length(1) = '1'.
    <fs_t012k>-hkont_1 = lv_string.

    gs_in_out-HBKID = <fs_t012k>-hbkid.
    gs_in_out-HKTID = <fs_t012k>-hktid.
    gs_in_out-HKONT = <fs_t012k>-hkont_1.
    APPEND gs_in_out to gt_in_out.
    clear gs_in_out.

    lv_string+lv_length(1) = '2'.
    <fs_t012k>-hkont_2 = lv_string.

    gs_in_out-HBKID = <fs_t012k>-hbkid.
    gs_in_out-HKTID = <fs_t012k>-hktid.
    gs_in_out-HKONT = <fs_t012k>-hkont_2.
    APPEND gs_in_out to gt_in_out.
    clear gs_in_out.

  ENDLOOP.

  REFRESH gt_t012k_mask.
  gt_t012k_mask = gt_t012k.
  DELETE gt_t012k_mask WHERE hkont_1 eq space.

  IF gt_t012k_mask IS NOT INITIAL.

    SELECT KTOPL
           SAKNR
           XBILK
      FROM ska1
      INTO TABLE gt_ska1
      FOR ALL ENTRIES IN gt_t012k_mask
      WHERE saknr = gt_t012k_mask-hkont_1.
  ENDIF.

  REFRESH gt_t012k_mask.
  gt_t012k_mask = gt_t012k.
  DELETE gt_t012k_mask WHERE hkont_2 eq space.

  IF gt_t012k_mask IS NOT INITIAL.

    SELECT KTOPL
           SAKNR
           XBILK
      FROM ska1
      APPENDING TABLE gt_ska1
      FOR ALL ENTRIES IN gt_t012k_mask
      WHERE saknr = gt_t012k_mask-hkont_2.
  ENDIF.

    IF gt_ska1 IS NOT INITIAL.

    SELECT  RBUKRS
            GJAHR
            BELNR
            DOCLN
            RWCUR
            RHCUR
            RKCUR
            RACCT
            PRCTR
            RASSC
            WSL
            HSL
            KSL
            DRCRK
            POPER
            KTOSL
            LIFNR
            KUNNR
            KOART
            UMSKZ
            MWSKZ
            AUGBL
            ANLN1
            GKONT
            GKOAR
      FROM acdoca
      INTO TABLE gt_acdoca
      FOR ALL ENTRIES IN gt_ska1
      WHERE rbukrs = company_code
*      AND gjahr = fiscal_year
      AND racct = gt_ska1-saknr.
*      AND poper = period.

      IF fiscal_year IS NOT INITIAL.
        DELETE gt_acdoca WHERE gjahr ne fiscal_year.
        IF period IS NOT INITIAL.
          DELETE gt_acdoca WHERE poper ne period.
        ENDIF.
      ENDIF.
      ENDIF.


  LOOP AT gt_in_out INTO gs_in_out.
      es_cashflow-HBKID = gs_in_out-hbkid.
      es_cashflow-hktid = gs_in_out-hktid.
      READ TABLE gt_ska1 INTO gs_ska1 WITH KEY saknr = gs_in_out-hkont.

      IF sy-subrc eq 0.
        es_cashflow-saknr = gs_ska1-saknr.
*        es_cashflow-txt50 = gs_ska1-txt50.
*-------main logic start--------
        IF gt_acdoca IS NOT INITIAL.

        LOOP AT gt_acdoca INTO gs_acdoca WHERE racct = gs_ska1-saknr.

          es_cashflow-bukrs = gs_acdoca-rbukrs.
          es_cashflow-gjahr = gs_acdoca-gjahr.
          es_cashflow-BELNR = gs_acdoca-belnr.

          IF gs_acdoca-augbl IS NOT INITIAL.
            lv_augbl = gs_acdoca-augbl.

          WHILE lv_continue eq 'X'.
            REFRESH lt_acdoca.
            CLEAR ls_acdoca_offset.

            CALL FUNCTION 'ZFM_FI_CASH_CLEARING'
              EXPORTING
                BUKRS                  = gs_acdoca-rbukrs
                GJAHR                  = gs_acdoca-gjahr
                AUGBL                  = lv_augbl
                PERIOD                 = gs_acdoca-poper
             IMPORTING
               EV_CONTINUE            = lv_continue
               ES_ACDOCA_OFFSET       = ls_acdoca_offset
                      .
            CLEAR lv_augbl.
            lv_augbl = ls_acdoca_offset-augbl.

          ENDWHILE.

          ls_acdoca_final = ls_acdoca_offset.

          ELSE.
            ls_acdoca_final = gs_acdoca.
          ENDIF.
*-------main logic end----------
          APPEND es_cashflow to et_cashflow.
          CLEAR: es_cashflow, ls_acdoca_final.
        ENDLOOP.



        ENDIF.

      ENDIF.

  ENDLOOP.




ENDFUNCTION.
