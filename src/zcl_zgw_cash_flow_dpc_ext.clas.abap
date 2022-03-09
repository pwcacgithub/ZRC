class ZCL_ZGW_CASH_FLOW_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_CASH_FLOW_DPC
  create public .

public section.
protected section.

  methods CASHFLOWSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_CASH_FLOW_DPC_EXT IMPLEMENTATION.


  method CASHFLOWSET_GET_ENTITYSET.
    DATA: lt_so_bukrs TYPE TABLE OF fmeuf_range_bukrs.

    DATA(lv_bukrs) = VALUE #( it_filter_select_options[ property = 'Bukrs' ]-select_options[ 1 ]-low OPTIONAL ).
    DATA(lv_hbkid) = VALUE #( it_filter_select_options[ property = 'Hbkid' ]-select_options[ 1 ]-low OPTIONAL ).
    DATA(lv_hktid) = VALUE #( it_filter_select_options[ property = 'Hktid' ]-select_options[ 1 ]-low OPTIONAL ).
    DATA(lv_gjahr) = VALUE #( it_filter_select_options[ property = 'Gjahr' ]-select_options[ 1 ]-low OPTIONAL ).
    DATA(lv_period) = VALUE #( it_filter_select_options[ property = 'Period' ]-select_options[ 1 ]-low OPTIONAL ).

    DATA lt_output TYPE TABLE OF zst_cashflow.

*    lt_so_bukrs = CORRESPONDING #( lt_so_bukrs_temp ).

    CALL FUNCTION 'ZFM_FI_DIRECT_CASH_FLOW'
      EXPORTING
        company_code       = lv_bukrs
        HOUSE_BANK         = lv_hbkid
        ACCOUNT_ID         = lv_hktid
        FISCAL_YEAR        = lv_gjahr
        PERIOD             = lv_period
      IMPORTING
        ET_CASHFLOW        = lt_output
              .

    et_entityset = CORRESPONDING #(
      lt_output
    ).

  endmethod.
ENDCLASS.
