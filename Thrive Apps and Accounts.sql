-- LOAN application table
select 
a.status as app_status 
, a.progress as app_progress 
, case when a.status = 4 then 1 else 0 end as accepted_ind 
, case when a.status = 0 then 1 else 0 end as declined_ind 
, c.ficoScore 
, floor(c.ficoScore/50)*50 as fico_cat_50_floor 
, d.[rule] as decline_rule 
, convert(varchar, a.createdAt, 23) as app_date
, count(distinct a.userId) as tot_users 
, count(distinct a.userLoanApplicationId) as tot_apps
from UserLoanApplications a
left join UserCreditReports b 
on a.userId = b.userId 
left join UserCreditSummary c 
on b.userCreditReportId = c.userCreditReportId
left join UserLoanApplicationDenialReasons d 
on a.userLoanApplicationId = d.userLoanApplicationId
where a.createdAt >= '2023-03-31 19:22' -- use whatever window you'd like
group by a.status, a.progress, convert(varchar, a.createdAt, 23), c.ficoScore , floor(c.ficoScore/50)*50, d.[rule]
;

-- LOAN table 
select 
[status] as loan_acct_status 
, [version] as loan_version (v1 vs v2)
, AutoPay 
, convert(varchar, createdAt, 23) as created_date
, count(distinct userId) as tot_users 
, count(distinct userLoanApplicationId) as tot_apps
, count(distinct loanId) as tot_loans
from loans 
where createdAt >= '2023-03-31 19:22' 
group by [status], [version] , AutoPay, convert(varchar, createdAt, 23)
;


-- LOANS
-- loan.STATUS 
-- 0 = Created,
-- 1 = Active,
-- 2 = Overdue,
-- 3 = Closed,
-- 4 = Declined,
-- 5 = Collections,
-- 6 = Bankruptcy,

-- USERLOANAPPLICATIONS
-- APP STATUS
-- Denied = 0,
-- Created = 1,
-- Incomplete = 2,
-- Qualified = 3,
-- Accepted = 4

-- APP PROGRESS
-- Declined = 0,
-- RepaidCashAdvanceCheckStarted = 1,
-- RepaidCashAdvanceCheckFinished = 2,
-- CreditModelCheckStarted = 3,
-- CreditModelCheckFinished = 4,
-- SubmitCreditModelToFinWise = 5,
-- FullKycStarted = 6,
-- FullKycFinished = 7,
-- CreditReportCheckStarted = 8,
-- CreditReportHitFreeze = 9,
-- CreditReportCheckFinished = 10,
-- AddressDiscrepancyStarted = 11,
-- AddressDiscrepancyHit = 12,
-- AddressDiscrepancyFinished = 13,
-- OfferGenerated = 14,
-- OfferAccepted = 15,
-- LoanAgreementCreated = 16,
-- LoanAgreementSigned = 17,
-- UserLoanCreated = 18,
-- LoanCreatedInFinWise = 19,
-- CreditReportFraudAlertCheckStarted = 20,
-- CreditReportFraudAlertUnremediated = 21,
--  CreditReportFraudAlertCheckFinished = 22