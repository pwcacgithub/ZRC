@AbapCatalog.sqlViewName: 'ZCUSTOMER_VW'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'cust book view'
define view zcust_book_view_entity as select from scustom
     join sbook 
     on scustom.id = sbook.customid
     {
           scustom.id,
           scustom.name,
           sbook.bookid
     }
