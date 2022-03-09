FUNCTION ZFM_FI_CASH_CLEARING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(GJAHR) TYPE  GJAHR
*"     REFERENCE(AUGBL) TYPE  AUGBL
*"     REFERENCE(PERIOD) TYPE  POPER
*"  EXPORTING
*"     VALUE(EV_CONTINUE) TYPE  C
*"     VALUE(ES_ACDOCA_OFFSET) TYPE  ZST_ACDOCA
*"----------------------------------------------------------------------

DATA: lv_continue TYPE c VALUE 'X',
      lv_drcrk TYPE shkzg,
      lt_acdoca TYPE STANDARD TABLE OF zst_acdoca,
      ls_acdoca TYPE zst_acdoca,
      ls_acdoca_offset TYPE zst_acdoca.

"Fetch all the documents whcih have the same clearing document number
          SELECT RBUKRS GJAHR BELNR DOCLN RWCUR RHCUR RKCUR RACCT PRCTR RASSC WSL HSL KSL
                 DRCRK POPER KTOSL LIFNR KUNNR KOART UMSKZ MWSKZ AUGBL ANLN1 GKONT GKOAR
          FROM acdoca
          INTO TABLE lt_acdoca
          WHERE rbukrs = bukrs
          AND gjahr = gjahr
          AND augbl = augbl
          AND poper = period.

          IF lt_acdoca IS NOT INITIAL.
            CLEAR lv_drcrk.
            DELETE lt_acdoca WHERE belnr = augbl.
            READ TABLE lt_acdoca INTO ls_acdoca INDEX 1.
            IF sy-subrc eq 0.
              IF ls_acdoca-drcrk = 'H'.
                lv_drcrk = 'S'.
              ELSEIF
                ls_acdoca-drcrk = 'S'.
                lv_drcrk = 'H'.
              ENDIF.
              "Fetch the Offset Document
              SELECT SINGLE RBUKRS GJAHR BELNR DOCLN RWCUR RHCUR RKCUR RACCT PRCTR RASSC WSL HSL KSL
                 DRCRK POPER KTOSL LIFNR KUNNR KOART UMSKZ MWSKZ AUGBL ANLN1 GKONT GKOAR
                  FROM acdoca
                  INTO ls_acdoca_offset
                  WHERE rbukrs = bukrs
                  AND gjahr = gjahr
                  AND belnr = ls_acdoca-belnr
                  AND drcrk = lv_drcrk
                  AND poper = period
                  AND ktosl = space.
                IF sy-subrc eq 0.
                  ES_ACDOCA_OFFSET = ls_acdoca_offset.
                  IF ls_acdoca_offset-augbl IS INITIAL."final document
                    CLEAR lv_continue.
                    CLEAR ls_acdoca.
                  ENDIF.
                ENDIF.
            ELSE.
             CLEAR lv_continue.
            ENDIF.
          ELSE.
            CLEAR lv_continue.
          ENDIF.

ev_continue = lv_continue.




ENDFUNCTION.
