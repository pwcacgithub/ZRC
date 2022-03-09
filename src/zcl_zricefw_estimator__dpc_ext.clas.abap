class ZCL_ZRICEFW_ESTIMATOR__DPC_EXT definition
  public
  inheriting from ZCL_ZRICEFW_ESTIMATOR__DPC
  create public .

public section.
protected section.

  methods ESTIMATIONDATASE_CREATE_ENTITY
    redefinition .
  methods ESTIMATIONDATASE_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZRICEFW_ESTIMATOR__DPC_EXT IMPLEMENTATION.


  METHOD estimationdatase_create_entity.
* Work Area Declaration
    DATA : lw_data TYPE ZRICEFW_ESTM_MAN.

**--- Transform data into the internal structure
    TRY.
        io_data_provider->read_entry_data(
          IMPORTING
            es_data = lw_data
            ).
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

    IF lw_data-modelname IS INITIAL.
      lw_data-modelname = 'DEFAULT'.
    ENDIF.

    MODIFY ZRICEFW_ESTM_MAN FROM lw_data.

    er_entity = lw_data.
  ENDMETHOD.


  method ESTIMATIONDATASE_GET_ENTITY.

*Local Variable Declaration
 DATA : lv_date_time TYPE date_time,
        lv_history   TYPE char1,
        lv_model_name TYPE char50.

*Internal Table Declaration
    DATA: lt_filter_select_options TYPE /iwbep/t_mgw_select_option.

**Work Area Declaration
    DATA: lw_filter            TYPE /iwbep/s_mgw_select_option,
          lw_filter_input      TYPE /iwbep/s_cod_select_option.

*lt_filter_select_options = io_tech_request_context->get_filter( )->get_filter_select_options( ).

*    IF lt_filter_select_options IS NOT INITIAL.

*      READ TABLE lt_filter_select_options INTO lw_filter WITH KEY property = 'MODELNAME'.
*      IF sy-subrc EQ 0.
*        READ TABLE lw_filter-select_options INTO lw_filter_input INDEX 1.
*        IF sy-subrc EQ 0.
*          lv_model_name = lw_filter_input-low.   "History Flag
*        ENDIF.
*      ENDIF.
*    ENDIF.



    SELECT SINGLE
           modelname
           modeldata
      FROM zricefw_estm_man INTO er_entity .
*      WHERE modelname = LV_MODEL_NAME.

  endmethod.
ENDCLASS.
