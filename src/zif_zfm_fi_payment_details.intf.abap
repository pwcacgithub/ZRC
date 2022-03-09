interface ZIF_ZFM_FI_PAYMENT_DETAILS
  public .


  types:
    BELNR_D type C length 000010 .
  types:
    ATWRT type C length 000070 .
  types:
    ZDOC_AMT type P length 12  decimals 000002 .
  types:
    ZNAME type C length 000140 .
  types:
    SCHZW_BSEG type C length 000001 .
  types:
    ZCHECK_AMT type P length 12  decimals 000002 .
  types:
    ZHSE_ACC type C length 000010 .
  types:
    USNAM type C length 000012 .
  types:
    AUGBL type C length 000010 .
  types:
    ZPOSTED type C length 000020 .
  types:
    ZCHECK_NO type C length 000020 .
  types:
    ZADDRESS type C length 000035 .
  types:
    ORT01 type C length 000025 .
  types:
    BEZEI20 type C length 000020 .
  types:
    LANDX type C length 000015 .
  types:
    BANKA type C length 000060 .
  types:
    STRAS type C length 000030 .
  types:
    SWIFT type C length 000011 .
  types:
    KURSF type P length 5  decimals 000005 .
  types:
    RWCUR type C length 000005 .
  types:
    ZCURR_AMT type P length 12  decimals 000002 .
  types:
    BUKRS type C length 000004 .
  types:
    BANKN type C length 000018 .
  types:
    ZBANK_ACC_NAME type C length 000060 .
  types:
    ZCHRGSBFY type C length 000001 .
  types:
    begin of ZFIST0001,
      PAYMENT_NUMBER type BELNR_D,
      VEDNOR_GROUPING type ATWRT,
      DOC_AMT type ZDOC_AMT,
      VENDOR_NAME type ZNAME,
      DOC_DATE type DATS,
      PAYMENT_METHOD type SCHZW_BSEG,
      CHECK_AMT type ZCHECK_AMT,
      HSE_ACC type ZHSE_ACC,
      USERID type USNAM,
      PAYMENT_REF type AUGBL,
      POSTED type ZPOSTED,
      CHECK_NO type ZCHECK_NO,
      ADDRESS1 type ZADDRESS,
      ADDRESS2 type ZADDRESS,
      ADDRESS3 type ZADDRESS,
      CITY type ORT01,
      STATE type BEZEI20,
      COUNTRY type LANDX,
      IMD_BANK_NAME type BANKA,
      IMD_BANK_ADDR type STRAS,
      IMD_BANK_SWIFT type SWIFT,
      BANK_RATE type KURSF,
      CURRENCY_ID type RWCUR,
      CURRENCY_AMT type ZCURR_AMT,
      COMPANY_CODE type BUKRS,
      PY_BANK_ACC_NO type BANKN,
      PY_BANK_ADDR type STRAS,
      PY_BANK_NAME type BANKA,
      PY_BANK_ACC_NAME type ZBANK_ACC_NAME,
      SWIFT_CODE type SWIFT,
      CHRGSBFY type ZCHRGSBFY,
    end of ZFIST0001 .
  types:
    ZFITT0001                      type standard table of ZFIST0001                      with non-unique default key .
  types:
    TVARV_SIGN type C length 000001 .
  types:
    TVARV_OPTI type C length 000002 .
  types:
    begin of ZFIST_BUKRS,
      SIGN type TVARV_SIGN,
      OPTION type TVARV_OPTI,
      LOW type BUKRS,
      HIGH type BUKRS,
    end of ZFIST_BUKRS .
  types:
    GJAHR type N length 000004 .
  types:
    begin of ZFIST_DATES,
      SIGN type TVARV_SIGN,
      OPTION type TVARV_OPTI,
      LOW type DATS,
      HIGH type DATS,
    end of ZFIST_DATES .
endinterface.
