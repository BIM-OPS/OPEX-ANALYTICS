with 
CL_BATCH_HEADER6 as 
    (select 
           CL_BATCH_HEADER.BATCH_ID,
           CL_BATCH_HEADER.PROV_CODE,
           CL_BATCH_HEADER.RCV_DATE,
           CL_BATCH_HEADER.PERIOD,
           CL_BATCH_HEADER.BILL_PRESENT_AMT,
           CL_BATCH_HEADER.BILL_DISC_AMT,
           CL_BATCH_HEADER.BILL_DEDUCT_AMT,
           CL_BATCH_HEADER.CRT_DATE,
           CL_BATCH_HEADER.NOTES,
           CL_BATCH_HEADER.UN_HOLD_DATE,
           CL_BATCH_HEADER.VAT_AMT,
           CL_BATCH_HEADER.HOLD_REASON,
           SY_STATUS_BATCH_HEADER.EDESC as BATCH_STATUS_DESC,
           SYS_SUBMIS_TYPE.EDESC as CLM_SUBMISSION_TYPE,
           CL_BATCH_HEADER.TPA
     from 
            ( 
                   ( 
                         BUPAProd..CSR.CL_BATCH_HEADER CL_BATCH_HEADER
                   inner  join 
                         BUPAProd..CSR.SY_STATUS_BATCH_HEADER SY_STATUS_BATCH_HEADER
                   on CL_BATCH_HEADER.STATUS = SY_STATUS_BATCH_HEADER.SYS_CODE ) 
            left outer  join 
                  BUPAProd..CSR.SY_SYS_CODE SYS_SUBMIS_TYPE
            on CL_BATCH_HEADER.CLM_SUBMIS_TYPE = SYS_SUBMIS_TYPE.SYS_CODE and SYS_TYPE = 'CLM_SUBMISSION_TYPE' ) ),
PV_PROVIDER7 as 
    (select 
           PV_PROVIDER.PROV_CODE,
           PV_PROVIDER.PROV_NAME,
           PV_PROVIDER.CORR_DIST_CODE,
           PV_PROVIDER.RELATIONS
     from 
            ( 
                   ( 
                          ( 
                                 ( 
                                        ( 
                                               ( 
                                                      ( 
                                                            BUPAProd..CSR.PV_PROVIDER PV_PROVIDER
                                                      inner  join 
                                                            BUPAProd..CSR.DC_DISTRICT DC_DISTRICT
                                                      on PV_PROVIDER.CORR_DIST_CODE = DC_DISTRICT.DIST_CODE ) 
                                               left outer  join 
                                                     BUPAProd..CSR.SY_PROVIDER_LEVEL SY_PROVIDER_LEVEL1
                                               on PV_PROVIDER.PROV_LEVEL = SY_PROVIDER_LEVEL1.SYS_CODE ) 
                                        left outer  join 
                                              BUPAProd..CSR.SY_PRACTICE_TYPE SY_PRACTICE_TYPE
                                        on PV_PROVIDER.PRACTICE_TYPE = SY_PRACTICE_TYPE.SYS_CODE ) 
                                 left outer  join 
                                       BUPAProd..CSR.PV_PROV_LVL_MVMNT
                                 on PV_PROVIDER.PROV_CODE = PV_PROV_LVL_MVMNT.PROV_CODE ) 
                          left outer  join 
                                BUPAProd..CSR.SY_PROVIDER_LEVEL SY_PROVIDER_LEVEL2
                          on PV_PROV_LVL_MVMNT.PROV_LEVEL = SY_PROVIDER_LEVEL2.SYS_CODE ) 
                   left outer  join 
                         BUPAProd..CSR.SY_SYS_CODE VRS
                   on trim ( VRS.SYS_CODE )  = PV_PROVIDER.VAT_REG_STATUS and trim ( VRS.SYS_TYPE )  = 'VAT_REG_STATUS' ) 
            left outer  join 
                  BUPAProd..CSR.SY_SYS_CODE CTC
            on trim ( CTC.SYS_CODE )  = PV_PROVIDER.CTRY_CODE and trim ( CTC.SYS_TYPE )  = 'COUNTRY_CODE' ) 
     where PV_PROV_LVL_MVMNT.END_DATE is null and PV_PROVIDER.PRACTICE_TYPE <> 280),
SY_PROVIDER_LOCATION as 
    (select 
           DC_DISTRICT.DIST_CODE, 
           DC_DISTRICT.EDESC as TOWN, 
           DC_DISTRICT.AREA_CODE
     from 
           BUPAProd..CSR.DC_DISTRICT DC_DISTRICT),
SY_PROVIDER_LOCATION8 as 
    (select 
           SY_PROVIDER_LOCATION.DIST_CODE  as  DIST_CODE,
           case 
             when SY_PROVIDER_LOCATION.AREA_CODE = 'W' then 'a. Western Region'
             when SY_PROVIDER_LOCATION.AREA_CODE = 'C' then 'b. Central Region'
             when SY_PROVIDER_LOCATION.AREA_CODE = 'E' then 'c. Eastern Region'
             when SY_PROVIDER_LOCATION.AREA_CODE = 'N' then 'd. Northern Region'
             when SY_PROVIDER_LOCATION.AREA_CODE = 'S' then 'e. Southern Region'
             else 'f. Overseas'
           end  as  REGION
     from 
           SY_PROVIDER_LOCATION
    ),
Batch_Header13 as 
    (select 
           CL_BATCH_HEADER6.BATCH_ID  as  Batch_ID,
           CL_BATCH_HEADER6.PERIOD  as  Batch_Period,
           substr(CL_BATCH_HEADER6.PERIOD,1,4)  as  Batch_Year,
           CL_BATCH_HEADER6.BATCH_STATUS_DESC  as  Batch_Status,
           XSUM(((nvl(CL_BATCH_HEADER6.BILL_PRESENT_AMT,0) - nvl(CL_BATCH_HEADER6.BILL_DISC_AMT,0)) - nvl(CL_BATCH_HEADER6.BILL_DEDUCT_AMT,0))  for CL_BATCH_HEADER6.BATCH_ID,CL_BATCH_HEADER6.PERIOD,substr(CL_BATCH_HEADER6.PERIOD,1,4),CL_BATCH_HEADER6.BATCH_STATUS_DESC,CL_BATCH_HEADER6.NOTES,CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE,CL_BATCH_HEADER6.HOLD_REASON,CL_BATCH_HEADER6.RCV_DATE,CL_BATCH_HEADER6.UN_HOLD_DATE,trim(PV_PROVIDER7.PROV_CODE),PV_PROVIDER7.PROV_NAME,SY_PROVIDER_LOCATION8.REGION,PV_PROVIDER7.RELATIONS,CL_BATCH_HEADER6.CRT_DATE,CL_BATCH_HEADER6.TPA )  as  PROV_Netbilled,
           XSUM(CL_BATCH_HEADER6.VAT_AMT  for CL_BATCH_HEADER6.BATCH_ID,CL_BATCH_HEADER6.PERIOD,substr(CL_BATCH_HEADER6.PERIOD,1,4),CL_BATCH_HEADER6.BATCH_STATUS_DESC,CL_BATCH_HEADER6.NOTES,CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE,CL_BATCH_HEADER6.HOLD_REASON,CL_BATCH_HEADER6.RCV_DATE,CL_BATCH_HEADER6.UN_HOLD_DATE,trim(PV_PROVIDER7.PROV_CODE),PV_PROVIDER7.PROV_NAME,SY_PROVIDER_LOCATION8.REGION,PV_PROVIDER7.RELATIONS,CL_BATCH_HEADER6.CRT_DATE,CL_BATCH_HEADER6.TPA )  as  VAT_AMT,
           CL_BATCH_HEADER6.NOTES  as  Batch_Notes,
           CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE  as  Claim_Submission_Type,
           CL_BATCH_HEADER6.HOLD_REASON  as  Hold_Reason,
           CL_BATCH_HEADER6.RCV_DATE  as  Batch_Received_Date,
           CL_BATCH_HEADER6.UN_HOLD_DATE  as  UnholdDate,
           trim(PV_PROVIDER7.PROV_CODE)  as  Provider_Code,
           PV_PROVIDER7.PROV_NAME  as  Provider_Name,
           SY_PROVIDER_LOCATION8.REGION  as  Provider_Region,
           PV_PROVIDER7.RELATIONS  as  Relations,
           CL_BATCH_HEADER6.CRT_DATE  as  Create_Date,
           (XSUM(((nvl(CL_BATCH_HEADER6.BILL_PRESENT_AMT,0) - nvl(CL_BATCH_HEADER6.BILL_DISC_AMT,0)) - nvl(CL_BATCH_HEADER6.BILL_DEDUCT_AMT,0))  for CL_BATCH_HEADER6.BATCH_ID,CL_BATCH_HEADER6.PERIOD,substr(CL_BATCH_HEADER6.PERIOD,1,4),CL_BATCH_HEADER6.BATCH_STATUS_DESC,CL_BATCH_HEADER6.NOTES,CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE,CL_BATCH_HEADER6.HOLD_REASON,CL_BATCH_HEADER6.RCV_DATE,CL_BATCH_HEADER6.UN_HOLD_DATE,trim(PV_PROVIDER7.PROV_CODE),PV_PROVIDER7.PROV_NAME,SY_PROVIDER_LOCATION8.REGION,PV_PROVIDER7.RELATIONS,CL_BATCH_HEADER6.CRT_DATE,CL_BATCH_HEADER6.TPA ) + XSUM(CL_BATCH_HEADER6.VAT_AMT  for CL_BATCH_HEADER6.BATCH_ID,CL_BATCH_HEADER6.PERIOD,substr(CL_BATCH_HEADER6.PERIOD,1,4),CL_BATCH_HEADER6.BATCH_STATUS_DESC,CL_BATCH_HEADER6.NOTES,CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE,CL_BATCH_HEADER6.HOLD_REASON,CL_BATCH_HEADER6.RCV_DATE,CL_BATCH_HEADER6.UN_HOLD_DATE,trim(PV_PROVIDER7.PROV_CODE),PV_PROVIDER7.PROV_NAME,SY_PROVIDER_LOCATION8.REGION,PV_PROVIDER7.RELATIONS,CL_BATCH_HEADER6.CRT_DATE,CL_BATCH_HEADER6.TPA ))  as  PROV_NB___VAT,
           CL_BATCH_HEADER6.TPA  as  TPA_Batch
     from 
           (
               CL_BATCH_HEADER6
                join 
               PV_PROVIDER7
                on (CL_BATCH_HEADER6.PROV_CODE = PV_PROVIDER7.PROV_CODE)
           )
            left outer join 
           SY_PROVIDER_LOCATION8
            on (PV_PROVIDER7.CORR_DIST_CODE = SY_PROVIDER_LOCATION8.DIST_CODE)
     where 
           (CL_BATCH_HEADER6.RCV_DATE between TIMESTAMP '2025-11-09 00:00:00.0' and TIMESTAMP '2025-11-09 00:00:00.0')
     group by 
           CL_BATCH_HEADER6.BATCH_ID,
           CL_BATCH_HEADER6.PERIOD,
           substr(CL_BATCH_HEADER6.PERIOD,1,4),
           CL_BATCH_HEADER6.BATCH_STATUS_DESC,
           CL_BATCH_HEADER6.NOTES,
           CL_BATCH_HEADER6.CLM_SUBMISSION_TYPE,
           CL_BATCH_HEADER6.HOLD_REASON,
           CL_BATCH_HEADER6.RCV_DATE,
           CL_BATCH_HEADER6.UN_HOLD_DATE,
           trim(PV_PROVIDER7.PROV_CODE),
           PV_PROVIDER7.PROV_NAME,
           SY_PROVIDER_LOCATION8.REGION,
           PV_PROVIDER7.RELATIONS,
           CL_BATCH_HEADER6.CRT_DATE,
           CL_BATCH_HEADER6.TPA
    ),
CL_BATCH_HEADER11 as 
    (select 
           CL_BATCH_HEADER.BATCH_ID,
           CL_BATCH_HEADER.PERIOD
     from 
            ( 
                   ( 
                         BUPAProd..CSR.CL_BATCH_HEADER CL_BATCH_HEADER
                   inner  join 
                         BUPAProd..CSR.SY_STATUS_BATCH_HEADER SY_STATUS_BATCH_HEADER
                   on CL_BATCH_HEADER.STATUS = SY_STATUS_BATCH_HEADER.SYS_CODE ) 
            left outer  join 
                  BUPAProd..CSR.SY_SYS_CODE SYS_SUBMIS_TYPE
            on CL_BATCH_HEADER.CLM_SUBMIS_TYPE = SYS_SUBMIS_TYPE.SYS_CODE and SYS_TYPE = 'CLM_SUBMISSION_TYPE' ) ),
BF_CLM_PAYMENT10 as 
    (select 
           *
     from 
           BUPAProd..CSR.BF_CLM_PAYMENT_V BF_CLM_PAYMENT_V
     where BF_CLM_PAYMENT_V.DELETED_IND = 'N'),
SY_PV_PAY_TYPE as 
    (select 
           SYS_CODE,
           EDESC as PV_PAY_TYPE
     from 
           BUPAProd..CSR.SY_SYS_CODE
     where SYS_TYPE = 'PAY_TYPE'),
BF_CLM_PAYMENT1 as 
    (select 
           *
     from 
           BUPAProd..CSR.BF_CLM_PAYMENT
     where BF_CLM_PAYMENT.DELETED_IND = 'N'),
Payment14 as 
    (select distinct 
           SY_PV_PAY_TYPE.PV_PAY_TYPE  as  Payment_Type,
           case when (BF_CLM_PAYMENT10.PAY_METHOD = 'AT') then BF_CLM_PAYMENT10.EFT_DATE else BF_CLM_PAYMENT10.CHQ_DATE end   as  Payment_Date,
           BF_CLM_PAYMENT10.BATCH_ID  as  BATCH_HEADER,
           CL_BATCH_HEADER11.PERIOD  as  Batch_Period
     from 
           CL_BATCH_HEADER11
            left outer join 
           BF_CLM_PAYMENT10
            on (CL_BATCH_HEADER11.BATCH_ID = BF_CLM_PAYMENT10.BATCH_ID)
            left outer join 
           SY_PV_PAY_TYPE
            on (BF_CLM_PAYMENT10.PAY_TYPE = SY_PV_PAY_TYPE.SYS_CODE)
            full outer join 
           BF_CLM_PAYMENT1
            on (BF_CLM_PAYMENT1.PAY_TYPE = SY_PV_PAY_TYPE.SYS_CODE)
     where 
           (SY_PV_PAY_TYPE.PV_PAY_TYPE = 'Prompt Payment') and 
           (CL_BATCH_HEADER11.PERIOD >= '201901') and 
           (BF_CLM_PAYMENT1.DELETED_IND = 'N')
    )
select 
       Batch_Header13.Provider_Code  as  Provider_Code,
       Batch_Header13.Provider_Name  as  Provider_Name,
       Batch_Header13.Claim_Submission_Type  as  Claim_Submission_Type,
       Batch_Header13.Provider_Region  as  Provider_Region,
       Batch_Header13.Batch_ID  as  Batch_ID,
       Batch_Header13.Batch_Status  as  Batch_Status,
       Batch_Header13.Batch_Period  as  Batch_Period,
       Batch_Header13.Batch_Year  as  Batch_Year,
       Batch_Header13.UnholdDate  as  UnholdDate,
       Batch_Header13.Batch_Received_Date  as  Batch_Received_Date,
       Payment14.Payment_Date  as  Payment_Date,
       Batch_Header13.Hold_Reason  as  Hold_Reason,
       Batch_Header13.Batch_Notes  as  Batch_Notes,
       XSUM(Batch_Header13.PROV_Netbilled  for Batch_Header13.Batch_ID,Batch_Header13.Batch_Period,Batch_Header13.Batch_Year,Batch_Header13.Batch_Status,Batch_Header13.Batch_Notes,Batch_Header13.Claim_Submission_Type,Batch_Header13.Hold_Reason,Batch_Header13.Batch_Received_Date,Batch_Header13.UnholdDate,Batch_Header13.Provider_Code,Batch_Header13.Provider_Name,Batch_Header13.Provider_Region,Batch_Header13.Relations,Batch_Header13.Create_Date,Batch_Header13.TPA_Batch )  as  PROV_Netbilled,
       Payment14.Payment_Type  as  Payment_Type,
       Batch_Header13.Create_Date  as  Create_Date,
       Batch_Header13.Relations  as  Relations,
       XSUM(Batch_Header13.PROV_NB___VAT  for Batch_Header13.Batch_ID,Batch_Header13.Batch_Period,Batch_Header13.Batch_Year,Batch_Header13.Batch_Status,Batch_Header13.Batch_Notes,Batch_Header13.Claim_Submission_Type,Batch_Header13.Hold_Reason,Batch_Header13.Batch_Received_Date,Batch_Header13.UnholdDate,Batch_Header13.Provider_Code,Batch_Header13.Provider_Name,Batch_Header13.Provider_Region,Batch_Header13.Relations,Batch_Header13.Create_Date,Batch_Header13.TPA_Batch )  as  PROV_NB___VAT,
       Batch_Header13.TPA_Batch  as  TPA_Batch
 from 
       Batch_Header13
        left outer join 
       Payment14
        on (Batch_Header13.Batch_ID = Payment14.BATCH_HEADER)
 group by 
       Batch_Header13.Provider_Code,
       Batch_Header13.Provider_Name,
       Batch_Header13.Claim_Submission_Type,
       Batch_Header13.Provider_Region,
       Batch_Header13.Batch_ID,
       Batch_Header13.Batch_Status,
       Batch_Header13.Batch_Period,
       Batch_Header13.Batch_Year,
       Batch_Header13.UnholdDate,
       Batch_Header13.Batch_Received_Date,
       Payment14.Payment_Date,
       Batch_Header13.Hold_Reason,
       Batch_Header13.Batch_Notes,
       Payment14.Payment_Type,
       Batch_Header13.Create_Date,
       Batch_Header13.Relations,
       Batch_Header13.TPA_Batch
