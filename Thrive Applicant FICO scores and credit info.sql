drop table if exists #LoansAppDriver 
select 
* 
, RANK() OVER(PARTITION BY userId ORDER BY CreatedAt DESC) AS loan_app_rank -- rank = 1 pulls most recent 
into #LoansAppDriver
from userLoanApplications 
;

drop table if exists #MostRecentLoanApp 
select 
* 
into #MostRecentLoanApp
from #LoansAppDriver 
where loan_app_rank = 1 
;

--select * from #MostRecentLoanApp order by userId, loan_app_rank ;

drop table if exists #ThriveBureauDriver_1
select 
distinct g.userId 
, g.CreatedAt as App_CreatedAt
, convert(varchar(10), g.CreatedAt, 23) as App_date
, RANK() OVER(PARTITION BY g.userId ORDER BY z.UserCreditSummaryId DESC) AS credit_report_rank -- 1 = most recent credit report pull 

, z.UserCreditSummaryId 
, convert(varchar, z.CreatedAt, 23) as CreatedAt
, z.FicoScore 

-- , DATEDIFF(month, c.Date, c.CreatedAt) as months_since_last_DQ 
-- , c.AccountRating as DQAccountRating_enum
-- , case when c.AccountRating = 2 then '30 days PD'
-- when c.AccountRating = 3 then '60 days PD'
-- when c.AccountRating = 4 then '90 days PD'
-- when c.AccountRating = 5 then '120 days PD'
-- when c.AccountRating = 6 then '150 days PD'
-- when c.AccountRating = 8 then 'Reposession/Voluntary surrender'
-- when c.AccountRating = 9 then 'Charge-off'
-- when c.AccountRating = 10 then 'Bankruptcy'
-- else 'n/a'
-- end as DQAccountRating

-- clean so that averages make sense
-- , case when b.CurrentBalance is null then 0 else b.CurrentBalance end as IL_balance 
-- , case when b.pastDue is null then 0 else b.pastDue  end as IL_pastDue_amount 
-- , case when d.collectionCount is null then 0 else d.collectionCount end as collectionCount
-- , case when d.TotalTradeCount is null then 0 else d.TotalTradeCount  end as TotalTradeCount 
-- , case when d.NegativeTradeCount is null then 0 else d.NegativeTradeCount end as NegativeTradeCount 
-- , case when d.HistoricalNegativeTradeCount is null then 0 else d.HistoricalNegativeTradeCount end as HistoricalNegativeTradeCount  
-- , case when d.revolvingTradeCount is null then 0 else d.revolvingTradeCount end as revolvingTradeCount 
-- , case when d.installmentTradeCount is null then 0 else d.installmentTradeCount end as installmentTradeCount
-- , case when d.MortgageTradeCount is null then 0 else d.MortgageTradeCount end as MortgageTradeCount
-- , case when d.OpenTradeCount is null then 0 else d.OpenTradeCount end as OpenTradeCount
-- , case when d.TotalInquiryCount is null then 0 else d.TotalInquiryCount end as TotalInquiryCount 
-- , case when d.openRevolvingTradeCount is null then 0 else d.openRevolvingTradeCount end as openRevolvingTradeCount 
-- , case when d.openInstallmentTradeCount is null then 0 else d.openInstallmentTradeCount end as openInstallmentTradeCount
-- , case when d.openMortgageTradeCount is null then 0 else d.openMortgageTradeCount end as openMortgageTradeCount
-- , case when e.CreditLimit is null then 0 else e.CreditLimit end as Total_Revolving_Credit_Limit
-- , case when e.CurrentBalance is null then 0 else e.CurrentBalance end as Total_Revolving_Current_Balance
-- , case when e.PastDue is null then 0 else e.PastDue end as Total_Revolving_Past_Due 
-- , case when f.CreditLimit is null then 0 else f.CreditLimit end as Total_Bureau_Credit_Limit
-- , case when f.CurrentBalance is null then 0 else f.CurrentBalance end as Total_Bureau_Current_Balance
-- , case when f.PastDue is null then 0 else f.PastDue end as Total_Bureau_Past_Due

-- , b.CurrentBalance as IL_balance 
-- , b.pastDue as IL_pastDue_amount 
-- , d.collectionCount
-- , d.TotalTradeCount 
-- , d.NegativeTradeCount 
-- , d.HistoricalNegativeTradeCount 
-- , d.revolvingTradeCount 
-- , d.installmentTradeCount 
-- , d.MortgageTradeCount
-- , d.OpenTradeCount 
-- , d.TotalInquiryCount 
-- , d.openRevolvingTradeCount 
-- , d.openInstallmentTradeCount 
-- , d.openMortgageTradeCount 
-- , e.CreditLimit as Total_Revolving_Credit_Limit 
-- , e.CurrentBalance as Total_Revolving_Current_Balance 
-- , e.PastDue as Total_Revolving_Past_Due 
-- , f.CreditLimit as Total_Bureau_Credit_Limit 
-- , f.CurrentBalance as Total_Bureau_Current_Balance  
-- , f.PastDue as Total_Bureau_Past_Due 

into #ThriveBureauDriver_1

from #MostRecentLoanApp g 
left join UserCreditReports a
on g.UserId = a.UserId 
left join UserCreditSummary z 
on a.UserCreditReportId = z.UserCreditReportId 
left join UserCreditSummaryInstallmentAmount b 
on z.UserCreditSummaryId  = b.UserCreditSummaryId 
left join UserCreditSummaryMostRecentDelinquency c 
on z.UserCreditSummaryId  = c.UserCreditSummaryId 
left join UserCreditSummaryRecordCounts d 
on z.UserCreditSummaryId  = d.UserCreditSummaryId 
left join UserCreditSummaryRevolvingAmount e 
on z.UserCreditSummaryId  = e.UserCreditSummaryId 
left join UserCreditSummaryTotalAmount f 
on z.UserCreditSummaryId  = f.UserCreditSummaryId 

where 1=1 
and z.UserCreditSummaryId is not null --capture only those that we have credit data returned for 
;



drop table if exists #FICO_cats 
select 
*
, case when FicoScore between 300 and 500 then '< 500'
when FicoScore between 500 and 549 then '500-549'
when FicoScore between 550 and 599 then '550-599' 
when FicoScore >= 600 then '600+'
else 'No Score' 
end as fico_cat_50s 
--, floor(FicoScore/10)*10 as fico_cat_10s_base 
, CONVERT(VARCHAR(7), App_CreatedAt, 126) as app_month

into #FICO_cats 
from #ThriveBureauDriver_1 
where 1=1 
and credit_report_rank = 1 -- filtering to most recent credit report pulled
;

select 
distinct userId 
, app_date 
, app_month 
, FicoScore 
, fico_cat_50s 
from #FICO_cats 
;