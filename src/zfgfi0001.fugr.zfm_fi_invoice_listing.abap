FUNCTION ZFM_FI_INVOICE_LISTING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_STATUS) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      IT_WERKS STRUCTURE  PLMIFO_TS_PLANT_RANGE OPTIONAL
*"      IT_EBELN STRUCTURE  ZFAGL_S_RANGE_EBELN OPTIONAL
*"      IT_LIFNR STRUCTURE  /ACCGO/CAS_S_LIFNR_RANGE OPTIONAL
*"      IT_KEY_DATE STRUCTURE  EMMA_DATE_RANGE
*"      IT_ANLN1 STRUCTURE  ZFAGL_S_RANGE_ASSET OPTIONAL
*"      ET_OUTPUT STRUCTURE  ZST_INVOICE_LISTING
*"----------------------------------------------------------------------
*data delcarations
  DATA : ls_output       TYPE ZST_INVOICE_LISTING.


*Fetch PO entries
  SELECT a~ebeln, a~lifnr, b~ebelp, b~werks, c~name1 FROM ekko as a INNER JOIN ekpo as b
    ON a~ebeln = b~ebeln INNER JOIN t001w as c ON b~werks = c~werks INTO TABLE @DATA(lt_purchase)
    WHERE a~ebeln in @it_ebeln and a~lifnr in @it_lifnr AND b~werks in @it_werks.

*Fetch EKBE entries
  SELECT ebeln, belnr FROM ekbe INTO TABLE @DATA(lt_ekbe) FOR ALL ENTRIES IN @lt_purchase WHERE ebeln = @lt_purchase-ebeln AND BEWTP eq 'Q'. "vgabe eq '2'.

*Fetch RBKP Entries
  SELECT belnr, gjahr, bldat, budat, xblnr, lifnr, waers, rmwwr FROM rbkp INTO TABLE @DATA(lt_rbkp)
    FOR ALL ENTRIES IN @lt_ekbe WHERE belnr eq @lt_ekbe-belnr AND bldat in @IT_KEY_DATE.

*Fetch Vendor Description
    SELECT lifnr, name1 FROM lfa1 INTO TABLE @DATA(lt_lfa1) FOR ALL ENTRIES IN @lt_rbkp WHERE lifnr = @lt_rbkp-lifnr.

*Fetch ACDOCA
    SELECT belnr, awref, ebeln, koart, augdt, augbl FROM acdoca INTO TABLE @DATA(lt_acdoca) FOR ALL ENTRIES IN @lt_rbkp WHERE awref = @lt_rbkp-belnr AND koart = 'S'.
*    IF IM_STATUS eq 'P'.
      SELECT belnr, awref, ebeln, koart, augdt, augbl FROM acdoca APPENDING TABLE @lt_acdoca FOR ALL ENTRIES IN @lt_rbkp
        WHERE awref = @lt_rbkp-belnr AND koart = 'K'." AND augbl IS NOT NULL.
*    ELSEIF IM_STATUS eq 'N'.
*      SELECT belnr, awref, ebeln, koart, augdt FROM acdoca APPENDING TABLE @lt_acdoca FOR ALL ENTRIES IN @lt_rbkp
*        WHERE awref = @lt_rbkp-belnr AND koart = 'K' AND augbl IS NULL.
*    ENDIF.


IF im_status eq 'P'.
  DELETE lt_acdoca WHERE augbl IS INITIAL.
ELSEIF im_status eq 'N'.
  DELETE lt_acdoca WHERE augbl IS NOT INITIAL.
ENDIF.


*process data
  LOOP AT lt_rbkp INTO DATA(ls_rbkp).
    MOVE ls_rbkp-bldat TO ls_output-bldat.
    MOVE ls_rbkp-budat TO ls_output-budat.
    MOVE ls_rbkp-belnr TO ls_output-belnr.
    MOVE ls_rbkp-xblnr TO ls_output-xblnr.
    MOVE ls_rbkp-lifnr TO ls_output-lifnr.
    MOVE ls_rbkp-rmwwr TO ls_output-rmwwr.
    MOVE ls_rbkp-waers TO ls_output-waers.
    READ TABLE lt_ekbe INTO DATA(ls_ekbe) WITH KEY belnr = ls_rbkp-belnr.
    IF sy-subrc eq 0.
      READ TABLE lt_purchase INTO DATA(ls_purchase) WITH KEY ebeln = ls_ekbe-ebeln.
      IF sy-subrc eq 0.
        MOVE ls_purchase-werks TO ls_output-werks.
        MOVE ls_purchase-name1 TO ls_output-PLANT_NAME.
      ENDIF.
    ENDIF.
    READ TABLE lt_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_rbkp-lifnr.
    IF sy-subrc eq 0.
      MOVE ls_lfa1-name1 TO ls_output-PARTY_NAME.
    ENDIF.
    READ TABLE lt_acdoca INTO DATA(ls_acdoca) WITH KEY awref = ls_rbkp-belnr
                                                       koart = 'S'.
    IF sy-subrc eq 0.
      MOVE ls_acdoca-ebeln TO ls_output-ebeln.
    ENDIF.

   READ TABLE lt_acdoca INTO ls_acdoca WITH KEY awref = ls_rbkp-belnr
                                                 koart = 'K'.
    IF sy-subrc eq 0.
      MOVE ls_acdoca-augdt TO ls_output-augdt.

      IF ls_acdoca-augbl IS NOT INITIAL.
        MOVE 'PAID' TO ls_output-rbstat.
      ELSE..
        MOVE 'NOT PAID' TO ls_output-rbstat.
      ENDIF.
    ENDIF.

    APPEND ls_output TO et_output. CLEAR ls_output.
  ENDLOOP.


ENDFUNCTION.
