@AbapCatalog.sqlViewName: 'ZCDSVLITCALC'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'cds view - literals and calculations'
define view zcdsv_lit_calc as select from snwd_so {
    so_id,
    currency_code,
    'TestValue' as descr,
    gross_amount,
    net_amount,
    gross_amount - net_amount as tax_amount
} 
 