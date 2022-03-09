FUNCTION zvendor_ageing_rep.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_KEY_DATE) TYPE  SYDATUM OPTIONAL
*"     REFERENCE(IM_CATEGORY) TYPE  C OPTIONAL
*"  TABLES
*"      IT_LIFNR STRUCTURE  /ACCGO/CAS_S_LIFNR_RANGE OPTIONAL
*"      IT_BUKRS STRUCTURE  FMEUF_RANGE_BUKRS OPTIONAL
*"      ET_OUTPUT STRUCTURE  ZST_VENDOR
*"----------------------------------------------------------------------

*im_category 1 - Normal Document
*im_category 2 - Noted Item

*data delcarations
  DATA : ls_output       TYPE zst_vendor,
         ls_currency_tot TYPE zst_vendor,
         lt_currency_tot TYPE TABLE OF zst_vendor,
         lv_category     TYPE c.

*Fetch open items
  SELECT bukrs, lifnr, budat, waers, wrbtr, zfbdt, zbd1t FROM bsik INTO TABLE @DATA(lt_open_clear)
    WHERE bukrs IN @it_bukrs AND lifnr IN @it_lifnr AND UMSKZ = @im_category AND budat LE @im_key_date.

*Fetch clear items
  SELECT bukrs, lifnr, budat, waers, wrbtr, zfbdt, zbd1t FROM bsak APPENDING TABLE  @lt_open_clear
  WHERE bukrs IN @it_bukrs AND lifnr IN @it_lifnr AND UMSKZ = @im_category and budat LE @im_key_date
    AND augdt GT @im_key_date.

*Fetch vendor description
  IF lines( lt_open_clear ) IS NOT INITIAL.
    SELECT lifnr, name1, name2, name3 FROM lfa1 INTO TABLE @DATA(lt_lfa1)
      FOR ALL ENTRIES IN @lt_open_clear WHERE lifnr = @lt_open_clear-lifnr.
  ENDIF.

*process data
  LOOP AT lt_open_clear INTO DATA(ls_open_clear).
    MOVE ls_open_clear-lifnr TO ls_output-lifnr.
    MOVE ls_open_clear-bukrs TO ls_output-bukrs.
    MOVE ls_open_clear-waers TO ls_output-waers.
    MOVE ls_open_clear-waers TO ls_currency_tot-waers.
    MOVE ls_open_clear-wrbtr TO ls_output-openitemtotal.
    MOVE ls_open_clear-wrbtr TO ls_currency_tot-openitemtotal.
    MOVE 'Total of ' TO ls_currency_tot-lifnr.

    READ TABLE lt_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_open_clear-lifnr.
    IF sy-subrc IS INITIAL.
      MOVE ls_lfa1-name1 TO ls_output-name1.
      MOVE ls_lfa1-name2 TO ls_output-name2.
      MOVE ls_lfa1-name3 TO ls_output-name3.
    ENDIF.

    DATA(lv_days) = sy-datum - ( ls_open_clear-zfbdt + ls_open_clear-zbd1t ).


    IF lv_days BETWEEN 1 AND 30.
      MOVE ls_open_clear-wrbtr TO ls_output-period1.
      MOVE ls_open_clear-wrbtr TO ls_currency_tot-period1.
    ELSEIF lv_days BETWEEN 31 AND 60.
      MOVE ls_open_clear-wrbtr TO ls_output-period2.
      MOVE ls_open_clear-wrbtr TO ls_currency_tot-period2.
    ELSEIF lv_days BETWEEN 61 AND 90.
      MOVE ls_open_clear-wrbtr TO ls_output-period3.
      MOVE ls_open_clear-wrbtr TO ls_currency_tot-period3.
    ELSEIF lv_days BETWEEN 91 AND 120.
      MOVE ls_open_clear-wrbtr TO ls_output-period4.
      MOVE ls_open_clear-wrbtr TO ls_currency_tot-period4.
    ELSEIF lv_days GT 120.
      MOVE ls_open_clear-wrbtr TO ls_output-period5.
      MOVE ls_open_clear-wrbtr TO ls_currency_tot-period5.
    ENDIF.
    COLLECT ls_output INTO et_output. CLEAR ls_output.
    COLLECT ls_currency_tot INTO lt_currency_tot. CLEAR ls_currency_tot.
  ENDLOOP.


  APPEND LINES OF lt_currency_tot TO et_output[].
ENDFUNCTION.
