CLASS zcl_customer_open_invoices DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_amdp_marker_hdb.
    TYPES: tt_cust_info TYPE STANDARD TABLE OF zcustomer_info WITH KEY customer_id,
           tt_inv_info  TYPE STANDARD TABLE OF zinvoice_info  WITH KEY customer_id.
    METHODS: get_customer_info
      IMPORTING VALUE(iv_client) TYPE symandt
                VALUE(iv_bupaid) TYPE zcustomer_info-customer_id
      EXPORTING VALUE(et_bpinfo) TYPE tt_cust_info,

      get_invoice_info
        IMPORTING VALUE(iv_client)  TYPE symandt
                  VALUE(iv_bupaid)  TYPE zcustomer_info-customer_id
        EXPORTING VALUE(et_invinfo) TYPE tt_inv_info.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_rel_items,
             client             TYPE snwd_so_inv_item-client,
             inv_i_guid         TYPE snwd_so_inv_item-node_key,
             inv_guid           TYPE snwd_so_inv_head-node_key,
             buyer_guid         TYPE snwd_bpa-node_key,
             customer_id        TYPE snwd_bpa-bp_id,
             invoice_date       TYPE snwd_so_inv_head-created_at,
             gross_amount       TYPE snwd_so_inv_item-gross_amount,
             currency_code_conv TYPE snwd_so_inv_item-currency_code,
           END OF ty_rel_items,

           tt_rel_items TYPE STANDARD TABLE OF ty_rel_items.

    METHODS: get_curr_conv_relevant_items
      IMPORTING VALUE(iv_client)     TYPE symandt
                VALUE(iv_bupaid)     TYPE zcustomer_info-customer_id
      EXPORTING VALUE(et_conv_items) TYPE tt_rel_items.
ENDCLASS.



CLASS ZCL_CUSTOMER_OPEN_INVOICES IMPLEMENTATION.


  METHOD get_curr_conv_relevant_items BY DATABASE PROCEDURE
                                      FOR HDB
                                      LANGUAGE SQLSCRIPT
                                      OPTIONS READ-ONLY
                                      USING snwd_bpa
                                            snwd_so_inv_head
                                            snwd_so_inv_item.
    -- declare a local variable
    declare lv_today date;
    -- get current date for conversion
    select current_date into lv_today from dummy;
    -- select relevant invoice items
    lt_relevant_items = select
                              i.client      as client,
                              i.node_key    as inv_i_guid,
                              h.node_key    as inv_guid,
                              bpa.node_key  as buyer_guid,
                              bpa.bp_id     as customer_id,
                              h.created_at  as invoice_date,
                              i.gross_amount,
                              i.currency_code
                        from snwd_so_inv_item as i
                        join snwd_so_inv_head as h
                        on i.client = h.client
                        and i.parent_key = h.node_key
                        join snwd_bpa as bpa
                        on h.client = bpa.client
                        and h.buyer_guid = bpa.node_key
                        where h.client = :iv_client
                        and bpa.bp_id = :iv_bupaid
                        and h.payment_status = '';

                        --convert gross amount of items to currency 'USD'
                        et_conv_items =
                        ce_conversion( :lt_relevant_items,
                        [ family = 'currency',
                        method = 'ERP',
                        steps = 'shift,convert,shift_back',
                        source_unit_column = "CURRENCY_CODE" ,
                        output_unit_column = "CURRENCY_CODE_CONV",
                        target_unit = 'USD',
                        reference_date = :lv_today,
                        client = :iv_client ],
                        [gross_amount] ) ;


  ENDMETHOD.


  METHOD get_invoice_info BY DATABASE PROCEDURE
FOR HDB
LANGUAGE SQLSCRIPT
OPTIONS READ-ONLY
USING snwd_so snwd_so_inv_head zcl_customer_open_invoices=>get_curr_conv_relevant_items.
    call "ZCL_CUSTOMER_OPEN_INVOICES=>GET_CURR_CONV_RELEVANT_ITEMS" (
    iv_client => :iv_client,
    iv_bupaid => :iv_bupaid,
    et_conv_items => :lt_converted_items );
    --aggregated gross amounts per sales order invoice
    et_invinfo =
    select
    customer_id,
    so_id as order_id,
    invoice_date,
    currency_code_conv as currency_code,
    sum( conv_items.gross_amount ) as sum_gross_amount
    from :lt_converted_items as conv_items
    join snwd_so_inv_head as h
    on h.client = conv_items.client
    and h.node_key = conv_items.inv_guid
    join snwd_so as so
    on so.client = h.client
    and so.node_key = h.so_guid
    group by customer_id, so_id, invoice_date, currency_code_conv
    order by so_id asc;
  ENDMETHOD.


  METHOD get_customer_info BY DATABASE PROCEDURE
FOR HDB
LANGUAGE SQLSCRIPT
OPTIONS READ-ONLY
USING snwd_bpa snwd_ad
zcl_customer_open_invoices=>get_curr_conv_relevant_items.
    call "ZCL_CUSTOMER_OPEN_INVOICES=>GET_CURR_CONV_RELEVANT_ITEMS" (
    iv_client => :iv_client,
    iv_bupaid => :iv_bupaid,
    et_conv_items => :lt_converted_items );
    --aggregated gross amounts per customer
    et_bpinfo =
    select
    customer_id,
    bpa.company_name as customer_name,
    ad.city,
    ad.street,
    ad.postal_code,
    ad.country,
    conv_items.currency_code_conv as currency_code,
    sum( conv_items.gross_amount ) as sum_gross_amount
    from :lt_converted_items as conv_items
    join snwd_bpa as bpa
    on conv_items.client = bpa.client
    and buyer_guid = bpa.node_key
    join snwd_ad as ad
    on bpa.client = ad.client
    and bpa.address_guid = ad.node_key
    group by customer_id, company_name, city, street, postal_code, country, currency_code_conv;
  ENDMETHOD.
ENDCLASS.
