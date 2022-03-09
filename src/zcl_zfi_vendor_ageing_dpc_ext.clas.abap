class ZCL_ZFI_VENDOR_AGEING_DPC_EXT definition
  public
  inheriting from ZCL_ZFI_VENDOR_AGEING_DPC
  create public .

public section.
protected section.

  methods VENDORAGEINGSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZFI_VENDOR_AGEING_DPC_EXT IMPLEMENTATION.


  method VENDORAGEINGSET_GET_ENTITYSET.
    DATA: lt_so_lifnr TYPE TABLE OF /accgo/cas_s_lifnr_range,
          lt_so_bukrs TYPE TABLE OF fmeuf_range_bukrs.

    DATA(lt_so_lifnr_temp)  = VALUE #( it_filter_select_options[ property = 'Lifnr' ]-select_options OPTIONAL ).
    DATA(lt_so_bukrs_temp)  = VALUE #( it_filter_select_options[ property = 'Bukrs' ]-select_options OPTIONAL ).
    DATA(lv_so_allgstid)    = VALUE dats( it_filter_select_options[ property = 'Allgstid' ]-select_options[ 1 ]-low OPTIONAL ).
    DATA lt_output TYPE TABLE OF zst_vendor.

    lt_so_lifnr = CORRESPONDING #( lt_so_lifnr_temp ).
    lt_so_bukrs = CORRESPONDING #( lt_so_bukrs_temp ).

    CALL FUNCTION 'ZVENDOR_AGEING_REP'
      EXPORTING
        im_key_date = lv_so_allgstid
      TABLES
        it_lifnr    = lt_so_lifnr
        it_bukrs    = lt_so_bukrs
        et_output   = lt_output.

    et_entityset = CORRESPONDING #(
      lt_output
    ).

  endmethod.
ENDCLASS.
