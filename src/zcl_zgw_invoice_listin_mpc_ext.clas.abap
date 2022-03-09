class ZCL_ZGW_INVOICE_LISTIN_MPC_EXT definition
  public
  inheriting from ZCL_ZGW_INVOICE_LISTIN_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZGW_INVOICE_LISTIN_MPC_EXT IMPLEMENTATION.


  method DEFINE.

    DATA: lo_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lo_property    TYPE REF TO /iwbep/cl_mgw_odata_property,
          lo_annotation  TYPE REF TO /iwbep/if_mgw_odata_annotation.

    super->define( ). "Ensure you call the parent metadata

    lo_entity_type = model->get_entity_type( iv_entity_name = 'InvoiceListing'). "Your Entity Name

    lo_property ?= lo_entity_type->get_property( iv_property_name = 'Bldat'). "Property inside your Entity

    CALL METHOD lo_property->/iwbep/if_mgw_odata_annotatabl~create_annotation
      EXPORTING
        iv_annotation_namespace = /iwbep/if_mgw_med_odata_types=>gc_sap_namespace
      RECEIVING
        ro_annotation           = lo_annotation.

    lo_annotation->add( iv_key = 'display-format' iv_value = 'Date' ). "Specific annotation you want to add.

  endmethod.
ENDCLASS.
