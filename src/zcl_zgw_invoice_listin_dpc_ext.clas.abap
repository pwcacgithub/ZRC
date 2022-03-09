class ZCL_ZGW_INVOICE_LISTIN_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_INVOICE_LISTIN_DPC
  create public .

public section.
protected section.

  methods INVOICELISTINGSE_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_INVOICE_LISTIN_DPC_EXT IMPLEMENTATION.


  method INVOICELISTINGSE_GET_ENTITYSET.
    DATA: lt_so_lifnr TYPE TABLE OF /accgo/cas_s_lifnr_range,
          lt_so_werks TYPE TABLE OF PLMIFO_TS_PLANT_RANGE,
          lt_so_ebeln TYPE TABLE OF ZFAGL_S_RANGE_EBELN,
          lt_so_date  TYPE STANDARD TABLE OF EMMA_DATE_RANGE,
          lt_so_anln1 TYPE TABLE OF ZFAGL_S_RANGE_ASSET,
          lv_status TYPE c.
BREAK rchandran001.
    DATA(lt_so_lifnr_temp) = VALUE #( it_filter_select_options[ property = 'Lifnr' ]-select_options OPTIONAL ).
    DATA(lt_so_werks_temp) = VALUE #( it_filter_select_options[ property = 'Werks' ]-select_options OPTIONAL ).
    DATA(lt_so_ebeln_temp) = VALUE #( it_filter_select_options[ property = 'Ebeln' ]-select_options OPTIONAL ).
    DATA(lt_so_anln1_temp) = VALUE #( it_filter_select_options[ property = 'Anln1' ]-select_options OPTIONAL ).
    DATA(lt_so_date_temp)  = VALUE #( it_filter_select_options[ property = 'Bldat' ]-select_options OPTIONAL ).

    DATA(lv_so_status_temp)  = VALUE #( it_filter_select_options[ property = 'Rbstat' ]-select_options[ 1 ]-low OPTIONAL ).
*    DATA(lv_so_date)    = VALUE dats( it_filter_select_options[ property = 'Bldat' ]-select_options[ 1 ]-low OPTIONAL ).

    DATA lt_output TYPE TABLE OF ZST_INVOICE_LISTING.

    lt_so_lifnr = CORRESPONDING #( lt_so_lifnr_temp ).
    lt_so_werks = CORRESPONDING #( lt_so_werks_temp ).
    lt_so_ebeln = CORRESPONDING #( lt_so_ebeln_temp ).
    lt_so_date  = CORRESPONDING #( lt_so_date_temp ).
    lt_so_anln1 = CORRESPONDING #( lt_so_anln1_temp ).

    lv_status = lv_so_status_temp.


    CALL FUNCTION 'ZFM_FI_INVOICE_LISTING'
     EXPORTING
       IM_STATUS         = lv_status
      TABLES
       IT_WERKS          = lt_so_werks
       IT_EBELN          = lt_so_ebeln
       IT_LIFNR          = lt_so_lifnr
       IT_KEY_DATE       = lt_so_date
       IT_ANLN1          = lt_so_anln1
        et_output        = lt_output
              .

    et_entityset = CORRESPONDING #(
      lt_output
    ).
  endmethod.
ENDCLASS.
