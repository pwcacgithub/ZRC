FUNCTION ZFM_FI_PAYMENT_DETAILS2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(COMPANY_CODE) TYPE  BUKRS
*"     VALUE(FISCAL_YEAR) TYPE  GJAHR
*"     VALUE(POSTING_DATE) TYPE  BUDAT OPTIONAL
*"  EXPORTING
*"     VALUE(IT_PAYMENT_DETAILS) TYPE  ZFITT0001
*"--------------------------------------------------------------------

  TYPES: BEGIN OF ty_acdoca,
           rbukrs TYPE acdoca-rbukrs,
           belnr  TYPE acdoca-belnr,
           rwcur  TYPE acdoca-rwcur,
           wsl    TYPE acdoca-wsl,
           hsl    TYPE acdoca-hsl,
           budat  TYPE acdoca-budat,
           bldat  TYPE acdoca-bldat,
           bschl  TYPE acdoca-bschl,
           usnam  TYPE acdoca-usnam,
           lifnr  TYPE acdoca-lifnr,
           hbkid  TYPE acdoca-hbkid,
           hktid  TYPE acdoca-hktid,
           augbl  TYPE acdoca-augbl,
           lifnr1 TYPE char90,
         END OF ty_acdoca.

  TYPES: BEGIN OF ty_ausp,
           objek TYPE ausp-objek,
           atwrt TYPE ausp-atwrt,
         END OF ty_ausp.

  TYPES: BEGIN OF ty_lfa1,
           lifnr TYPE lfa1-lifnr,
           land1 TYPE lfa1-land1,
           name1 TYPE lfa1-name1,
           name2 TYPE lfa1-name2,
           name3 TYPE lfa1-name3,
           name4 TYPE lfa1-name4,
           ort01 TYPE lfa1-ort01,
           pstlz TYPE lfa1-pstlz,
           regio TYPE lfa1-regio,
           stras TYPE lfa1-stras,
           dtaws TYPE lfa1-dtaws,
           spras TYPE lfa1-spras,
         END OF ty_lfa1.

  TYPES: BEGIN OF ty_but0bk,
           partner TYPE but0bk-partner,
           bkvid   TYPE but0bk-bkvid,
           banks   TYPE but0bk-banks,
           bankl   TYPE but0bk-bankl,
           bankn   TYPE but0bk-bankn,
           bkont   TYPE but0bk-bkont,
           bkref   TYPE but0bk-bkref,
           koinh   TYPE but0bk-koinh,
           bkext   TYPE but0bk-bkext,
           xezer   TYPE but0bk-xezer,
           accname TYPE but0bk-accname,
         END OF ty_but0bk.

  TYPES: BEGIN OF ty_bnka,
           banks TYPE bnka-banks,
           bankl TYPE bnka-bankl,
           banka TYPE bnka-banka,
           stras TYPE bnka-stras,
           swift TYPE bnka-swift,
         END OF ty_bnka.

  TYPES: BEGIN OF ty_bseg,
           belnr TYPE bseg-belnr,
           zlsch TYPE bseg-zlsch,
         END OF ty_bseg.

  TYPES: BEGIN OF ty_bkpf,
           belnr TYPE bkpf-belnr,
           kursf TYPE bkpf-kursf,
         END OF ty_bkpf.

  TYPES: BEGIN OF ty_t005t,
           spras TYPE spras,
           land1 TYPE land1,
           landx TYPE landx,
         END OF ty_t005t.

  TYPES: BEGIN OF ty_t005u,
           spras TYPE spras,
           land1 TYPE land1,
           bezei TYPE bezei20,
         END OF ty_t005u.

  DATA: gt_acdoca          TYPE STANDARD TABLE OF ty_acdoca,
        gs_acdoca          TYPE ty_acdoca,
        gt_ausp            TYPE STANDARD TABLE OF ty_ausp,
        gs_ausp            TYPE ty_ausp,
        gt_lfa1            TYPE STANDARD TABLE OF ty_lfa1,
        gs_lfa1            TYPE ty_lfa1,
        gt_bseg            TYPE STANDARD TABLE OF ty_bseg,
        gs_bseg            TYPE ty_bseg,
        gt_imd_bnka        TYPE STANDARD TABLE OF ty_bnka,
        gs_imd_bnka        TYPE ty_bnka,
        gt_bnka            TYPE STANDARD TABLE OF ty_bnka,
        gs_bnka            TYPE ty_bnka,
        gt_bkpf            TYPE STANDARD TABLE OF ty_bkpf,
        gs_bkpf            TYPE ty_bkpf,
        gt_t005t           TYPE STANDARD TABLE OF ty_t005t,
        gs_t005t           TYPE ty_t005t,
        gt_t005u           TYPE STANDARD TABLE OF ty_t005u,
        gs_t005u           TYPE ty_t005u,
        gt_but0bk          TYPE STANDARD TABLE OF ty_but0bk,
        gs_but0bk          TYPE ty_but0bk,
        gt_payment_details TYPE zfitt0001,
        gs_payment_details TYPE zfist0001.

  DATA: lt_acdoca1 TYPE STANDARD TABLE OF ty_acdoca,
        ls_acdoca1 TYPE ty_acdoca,
        lt_acdoca2 TYPE STANDARD TABLE OF ty_acdoca,
        ls_acdoca2 TYPE ty_acdoca,
        lt_acdoca3 TYPE STANDARD TABLE OF ty_acdoca,
        ls_acdoca3 TYPE ty_acdoca,
        lt_lfa1    TYPE STANDARD TABLE OF ty_lfa1,
        ls_lfa1    TYPE ty_lfa1,
        lt_but0bk  TYPE STANDARD TABLE OF ty_but0bk,
        ls_but0bk  TYPE ty_but0bk.

  FIELD-SYMBOLS: <fs_acdoca> TYPE ty_acdoca.


  SELECT rbukrs
         belnr
         rwcur
         wsl
         hsl
         budat
         bldat
         bschl
         usnam
         lifnr
         hbkid
         hktid
         augbl
    FROM acdoca
    INTO CORRESPONDING FIELDS OF TABLE gt_acdoca
    WHERE rbukrs = company_code AND
          gjahr  = fiscal_year AND
          budat  = posting_date
    ORDER BY PRIMARY KEY.


  LOOP AT gt_acdoca ASSIGNING <fs_acdoca>.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <fs_acdoca>-lifnr
      IMPORTING
        output = <fs_acdoca>-lifnr1.

    IF <fs_acdoca>-bschl = '25' OR <fs_acdoca>-bschl = '29'.
      MOVE <fs_acdoca> TO ls_acdoca1.
    ENDIF.

  ENDLOOP.

  SORT lt_acdoca1 BY lifnr1.
  DELETE ADJACENT DUPLICATES FROM lt_acdoca1 COMPARING lifnr1.

  IF lt_acdoca1 IS NOT INITIAL.
    SELECT objek
           atwrt
      FROM ausp
      INTO TABLE gt_ausp
      FOR ALL ENTRIES IN lt_acdoca1
      WHERE objek = lt_acdoca1-lifnr1.

    lt_acdoca2 = gt_acdoca.
    SORT lt_acdoca2 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_acdoca2 COMPARING lifnr.
    SELECT  lifnr
            land1
            name1
            name2
            name3
            name4
            ort01
            pstlz
            regio
            stras
            dtaws
            spras
      INTO TABLE gt_lfa1
      FROM lfa1
      FOR ALL ENTRIES IN lt_acdoca2
      WHERE lifnr = lt_acdoca2-lifnr.

    lt_acdoca3 = gt_acdoca.
    SORT lt_acdoca3 BY belnr.
    DELETE ADJACENT DUPLICATES FROM lt_acdoca3 COMPARING belnr.
    SELECT belnr
           kursf
      INTO TABLE gt_bkpf
      FROM bkpf
      FOR ALL ENTRIES IN lt_acdoca3
      WHERE belnr = lt_acdoca3-belnr.

    SELECT belnr
         zlsch
    INTO TABLE gt_bseg
    FROM bseg
    FOR ALL ENTRIES IN lt_acdoca3
    WHERE belnr = lt_acdoca3-belnr.

    lt_lfa1 = gt_lfa1.
    SORT lt_lfa1 BY land1 spras.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING land1 spras.

    IF gt_lfa1 IS NOT INITIAL.
      SORT gt_lfa1 BY lifnr.
      SELECT partner
             bkvid
             banks
             bankl
             bankn
             bkont
             bkref
             koinh
             bkext
             xezer
             accname
        FROM but0bk
        INTO TABLE gt_but0bk
        FOR ALL ENTRIES IN gt_lfa1
        WHERE partner = gt_lfa1-lifnr.

      lt_but0bk = gt_but0bk.
      DELETE lt_but0bk WHERE bkvid = 'IMD'.
      SORT lt_but0bk BY banks bankl.
      DELETE ADJACENT DUPLICATES FROM lt_but0bk COMPARING banks bankl.
      IF lt_but0bk IS NOT INITIAL.
        SELECT banks
               bankl
               banka
               stras
               swift
          FROM bnka
          INTO TABLE gt_bnka
          FOR ALL ENTRIES IN lt_but0bk
          WHERE banks = lt_but0bk-banks AND
                bankl = lt_but0bk-bankl.
      ENDIF.

      REFRESH lt_but0bk.
      lt_but0bk = gt_but0bk.
      DELETE lt_but0bk WHERE bkvid NE 'IMD'.
      SORT lt_but0bk BY banks bankl.
      DELETE ADJACENT DUPLICATES FROM lt_but0bk COMPARING banks bankl.
      IF lt_but0bk IS NOT INITIAL.
        SELECT banks
               bankl
               banka
               stras
               swift
          FROM bnka
          INTO TABLE gt_imd_bnka
          FOR ALL ENTRIES IN lt_but0bk
          WHERE banks = lt_but0bk-banks AND
                bankl = lt_but0bk-bankl.
      ENDIF.
    ENDIF.

    IF lt_lfa1 IS NOT INITIAL.
      SELECT spras
             land1
             landx
        FROM t005t
        INTO TABLE gt_t005t
        FOR ALL ENTRIES IN lt_lfa1
        WHERE spras = lt_lfa1-spras AND
              land1 = lt_lfa1-land1.

      SELECT spras
             land1
             bezei
        FROM t005u
        INTO TABLE gt_t005u
        FOR ALL ENTRIES IN lt_lfa1
        WHERE spras = lt_lfa1-spras AND
              land1 = lt_lfa1-land1.
    ENDIF.

  ENDIF.

  SORT gt_ausp BY objek.
  SORT gt_lfa1 BY lifnr.
  SORT gt_bkpf BY belnr.
  SORT gt_bseg BY belnr.
  SORT gt_but0bk BY partner.
  SORT gt_bnka BY banks bankl.
  SORT gt_imd_bnka BY banks bankl.
  SORT gt_t005t BY spras land1.
  SORT gt_t005u BY spras land1.

  LOOP AT gt_acdoca INTO gs_acdoca.
    gs_payment_details-payment_number   = gs_acdoca-belnr.
    gs_payment_details-doc_amt          = gs_acdoca-wsl.
    gs_payment_details-doc_date         = gs_acdoca-bldat.
    gs_payment_details-check_amt        = gs_acdoca-hsl.
    CONCATENATE gs_acdoca-hbkid gs_acdoca-hktid INTO gs_payment_details-hse_acc.
    gs_payment_details-userid           = gs_acdoca-usnam.
    gs_payment_details-payment_ref      = gs_acdoca-augbl.
    gs_payment_details-currency_id      = gs_acdoca-rwcur.
    gs_payment_details-currency_amt     = gs_acdoca-wsl.
    gs_payment_details-company_code     = gs_acdoca-rbukrs.

    READ TABLE gt_ausp INTO gs_ausp WITH KEY objek = gs_acdoca-lifnr1.
    IF sy-subrc EQ 0.
      gs_payment_details-vednor_grouping = gs_ausp-atwrt.
    ENDIF.

    READ TABLE gt_lfa1 INTO gs_lfa1 WITH KEY lifnr = gs_acdoca-lifnr.
    IF sy-subrc EQ 0.
      CONCATENATE gs_lfa1-name1
                  gs_lfa1-name2
                  gs_lfa1-name3
                  gs_lfa1-name4
                  INTO gs_payment_details-vendor_name RESPECTING BLANKS.
      CONCATENATE gs_lfa1-stras
                  gs_lfa1-pstlz
                  INTO gs_payment_details-address1 RESPECTING BLANKS.

      IF gs_lfa1-dtaws IS NOT INITIAL.
        gs_payment_details-chrgsbfy = 'Y'.
      ELSE.
        gs_payment_details-chrgsbfy = 'N'.
      ENDIF.
    ENDIF.

    READ TABLE gt_bkpf INTO gs_bkpf WITH KEY belnr = gs_acdoca-belnr.
    IF sy-subrc EQ 0.
      gs_payment_details-bank_rate = gs_bkpf-kursf.
    ENDIF.

    READ TABLE gt_bseg INTO gs_bseg WITH KEY belnr = gs_acdoca-belnr.
    IF sy-subrc EQ 0.
      gs_payment_details-payment_method = gs_bseg-zlsch.
    ENDIF.

    READ TABLE gt_but0bk INTO gs_but0bk WITH KEY partner = gs_acdoca-lifnr.
    IF sy-subrc EQ 0.
      gs_payment_details-py_bank_acc_name = gs_but0bk-koinh.

      READ TABLE gt_bnka INTO gs_bnka WITH KEY banks = gs_but0bk-banks
                                               bankl = gs_but0bk-bankl.
      IF sy-subrc EQ 0.
        gs_payment_details-py_bank_acc_no = gs_bnka-banka.
        gs_payment_details-py_bank_addr   = gs_bnka-stras.
        gs_payment_details-swift_code     = gs_bnka-swift.
      ENDIF.

      READ TABLE gt_imd_bnka INTO gs_imd_bnka WITH KEY banks = gs_but0bk-banks
                                                       bankl = gs_but0bk-bankl.
      IF sy-subrc EQ 0.
        gs_payment_details-imd_bank_name  = gs_imd_bnka-banka.
        gs_payment_details-imd_bank_addr  = gs_imd_bnka-stras.
        gs_payment_details-imd_bank_swift = gs_imd_bnka-swift.
      ENDIF.
    ENDIF.

    READ TABLE gt_t005t INTO gs_t005t WITH KEY spras = gs_lfa1-spras
                                               land1 = gs_lfa1-land1.
    IF sy-subrc EQ 0.
      gs_payment_details-country = gs_t005t-landx.
    ENDIF.

    READ TABLE gt_t005u INTO gs_t005u WITH KEY spras = gs_lfa1-spras
                                               land1 = gs_lfa1-land1.
    IF sy-subrc EQ 0.
      gs_payment_details-state = gs_t005u-bezei.
    ENDIF.

    APPEND gs_payment_details TO gt_payment_details.

  ENDLOOP.

ENDFUNCTION.
