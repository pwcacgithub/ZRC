class ZCL_ZFI_DOC_DPC_EXT definition
  public
  inheriting from ZCL_ZFI_DOC_DPC
  create public .

public section.

  methods CUSTOM_CREATE_DEEP_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_DEEP_ENTITY type ZCL_ZFI_DOC_MPC_EXT=>TS_DEEP_ENTITY .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_DOC_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.

    data custome_create_deep_entity type ZCL_ZFI_DOC_mPC_EXT=>ts_deep_entity.

    case iv_entity_set_name.
*-------------------------------------------------------------------------*
*             EntitySet -  HeaderSet
*-------------------------------------------------------------------------*

      when 'fb02_headSet'.
*       Call the entity set generated method
*      TRY.

        call method me->custom_create_deep_entity
          exporting
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
*            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          importing
            er_deep_entity          = custome_create_deep_entity.

        copy_data_to_ref(
        exporting
        is_data = custome_create_deep_entity
        changing
        cr_data = er_deep_entity
        ).
    endcase.

  endmethod.


  method CUSTOM_CREATE_DEEP_ENTITY.
    TYPES : BEGIN OF ty_bseg,
              bukrs TYPE bseg-bukrs,
              belnr TYPE bseg-belnr,
              gjahr TYPE bseg-gjahr,
              buzei TYPE bseg-buzei,
              bschl TYPE bseg-bschl,
              zuonr TYPE bseg-zuonr,
            END OF ty_bseg.


    DATA: ls_bseg    TYPE ty_bseg,
          lt_bseg    TYPE TABLE OF ty_bseg,
          lt_payload TYPE TABLE OF ty_bseg,
          lt_bseg_op TYPE TABLE OF bseg,
          lt_errtab  TYPE tpit_t_errdoc,
          ls_errtab  LIKE LINE OF lt_errtab,
          lt_buztab  TYPE  tpit_t_buztab,
          lt_fldtab  TYPE  tpit_t_fname,
          ls_buztab  LIKE LINE OF lt_buztab,
          ls_fldtab  LIKE LINE OF lt_fldtab,
          ls_payload TYPE  ty_bseg,
          ls_bseg_op TYPE bseg,
          ls_fm_bseg TYPE bseg,
          ls_return  TYPE bapiret2,
          lt_return  TYPE TABLE OF bapiret2.


    DATA: lr_deep_entity TYPE zcl_zfi_doc_mpc_ext=>ts_deep_entity,
          lt_itemo       TYPE zcl_zfi_doc_mpc_ext=>tt_fb02_head,
          ls_itemo       TYPE zcl_zfi_doc_mpc_ext=>ts_fb02_item.



    FIELD-SYMBOLS: <ls_item> TYPE zcl_zfi_doc_mpc_ext=>ts_fb02_item.


*  Transform data into the internal structure

    io_data_provider->read_entry_data(
    IMPORTING
    es_data = lr_deep_entity ).

    er_deep_entity = lr_deep_entity.



***********Collect the header fields here
*    -count = lr_deep_entity-count.

**********Collet the item fields here
*    LOOP AT lr_deep_entity-np_fb02 ASSIGNING <ls_item>.
    LOOP AT lr_deep_entity-fb02_itemSet ASSIGNING <ls_item>.
      ls_payload-belnr = <ls_item>-documentnumber.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_payload-belnr
        IMPORTING
          output = ls_payload-belnr.


      ls_payload-bukrs = <ls_item>-companycode.
      ls_payload-gjahr = <ls_item>-fiscalyear.
      ls_payload-zuonr = <ls_item>-assignment.
      APPEND ls_payload TO lt_payload.
      CLEAR ls_payload.
    ENDLOOP.

*process the record (filter further bschl = 50).
    IF lt_payload IS NOT INITIAL.
      SELECT bukrs belnr gjahr buzei bschl FROM bseg INTO TABLE lt_bseg FOR ALL ENTRIES IN
        lt_payload WHERE bukrs = lt_payload-bukrs
        AND belnr = lt_payload-belnr
        AND gjahr = lt_payload-gjahr
        AND bschl = '50'.
    ENDIF.

*process only bschl = 50 records.
    IF lt_bseg IS NOT INITIAL.

      SORT lt_bseg by belnr.

      ls_fldtab-fname = 'ZUONR'.
      ls_fldtab-aenkz = 'X'.
      APPEND ls_fldtab TO lt_fldtab.
      CLEAR ls_fldtab.

      LOOP AT lt_bseg INTO ls_bseg.
        CLEAR ls_fm_bseg.
        REFRESH : lt_errtab, lt_buztab.

        ls_fm_bseg-bukrs = ls_bseg-bukrs.
        ls_fm_bseg-belnr = ls_bseg-belnr.
        ls_fm_bseg-gjahr = ls_bseg-gjahr.
        ls_fm_bseg-buzei = ls_bseg-buzei.
        READ TABLE lt_payload INTO ls_payload WITH KEY belnr = ls_bseg-belnr
                                                                gjahr = ls_bseg-gjahr
                                                                bukrs = ls_bseg-bukrs.
        IF sy-subrc IS INITIAL.
          ls_fm_bseg-zuonr = ls_payload-zuonr.
        ENDIF.


        ls_buztab-belnr = ls_bseg-belnr.
        ls_buztab-bukrs = ls_bseg-bukrs.
        ls_buztab-gjahr = ls_bseg-gjahr.
        ls_buztab-buzei = ls_bseg-buzei.
        ls_buztab-bschl = ls_bseg-bschl.
        APPEND ls_buztab TO lt_buztab.
        CLEAR ls_buztab.

        CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
          EXPORTING
            s_bseg     = ls_fm_bseg
          IMPORTING
            errtab     = lt_errtab
          TABLES
            it_buztab  = lt_buztab
            it_fldtab  = lt_fldtab
          EXCEPTIONS
            bdc_errors = 1
            OTHERS     = 2.

        IF sy-subrc IS INITIAL AND lt_errtab IS INITIAL.

          CONCATENATE ls_bseg-belnr ls_bseg-bukrs ls_bseg-gjahr
          'Successfully updated!' INTO ls_return-message SEPARATED BY space.
          ls_return-type = 'S'.
        ELSE.

          READ TABLE lt_errtab INTO ls_errtab INDEX 1.
*          IF sy-subrc eq 0.
*            CONCATENATE 'Error: ' ls_errtab-doc ls_errtab-err INTO ls_return-message SEPARATED BY space.
*          ELSE.
            CONCATENATE ls_bseg-belnr ls_bseg-bukrs ls_bseg-gjahr
            'Error during update!' INTO ls_return-message SEPARATED BY space.
*          ENDIF.
          ls_return-type = 'E'.
        ENDIF.


        ls_return-id   = '00'.
        ls_return-number = '000'.
        APPEND ls_return TO lt_return.
        CLEAR ls_return.

      ENDLOOP.

    ELSE.
        ls_return-message = 'Updates Failed. Records does not exist!'.
        ls_return-type = 'E'.
        ls_return-id   = '00'.
        ls_return-number = '000'.
        APPEND ls_return TO lt_return.
        CLEAR ls_return.
    ENDIF.

*add messages to output
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    lo_message_container = mo_context->get_message_container( ).
    lo_message_container->add_messages_from_bapi(
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first
      iv_add_to_response_header = 'X' ).

  endmethod.
ENDCLASS.
