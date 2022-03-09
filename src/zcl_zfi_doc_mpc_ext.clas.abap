class ZCL_ZFI_DOC_MPC_EXT definition
  public
  inheriting from ZCL_ZFI_DOC_MPC
  create public .

public section.

*types TS_DEEP_ENTITY .

  TYPES: BEGIN OF ts_deep_entity,
         count TYPE string,
         fb02_itemSet TYPE STANDARD TABLE OF ts_fb02_item WITH DEFAULT KEY,
         END OF ts_deep_entity.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_DOC_MPC_EXT IMPLEMENTATION.


  method DEFINE.
    super->define( ).
    DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

***********************************************************************************************************************************
*   ENTITY - Deep Entity
***********************************************************************************************************************************

    lo_entity_type = model->get_entity_type( iv_entity_name = 'fb02_head' ). "#EC NOTEXT

    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZFI_DOC_MPC_EXT=>TS_DEEP_ENTITY' ). "#EC NOTEXT

  endmethod.
ENDCLASS.
