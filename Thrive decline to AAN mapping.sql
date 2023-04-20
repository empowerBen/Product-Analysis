--- Thrive decline -> AAN mapping 

drop table if exists #decline_starter
select 
distinct a.userLoanApplicationId 
, a.userId
, case when a.status = 0 then 'Denied'
when a.status = 1 then 'Created'
when a.status = 2 then 'Incomplete'
when a.status = 3 then 'Qualified'
when a.status = 4 then 'Accepted'
end as app_status_enum
, d.createdAt as decline_date
, d.[rule] as decline_rule_enum
, case when d.[rule] = 1 then 'AccountHistory'
when d.[rule] = 3 then 'CurrentAccountBalance'
when d.[rule] = 4 then 'RecurringPaychecks'
when d.[rule] = 5 then 'MonthlyIncome'
when d.[rule] = 7 then 'LendingResidential'
when d.[rule] = 8 then 'KYC'
when d.[rule] = 9 then 'CreditFreeze'
when d.[rule] = 10 then 'MLA'
when d.[rule] = 11 then 'IncompletedIn30DaysWindow'
when d.[rule] = 12 then 'MLModelScore'
when d.[rule] = 13 then 'AccountStatus'
end as decline_rule_title
, case when d.[rule] =0 then 'Successfully repay at least one Cash Advance'
when d.[rule] =1 then 'Insufficient account history on primary checking account'
when d.[rule] =2 then 'Insufficient transaction volume'
when d.[rule] =3 then 'Insufficient deposit account balance'
when d.[rule] =4 then 'Insufficient income'
when d.[rule] =5 then 'Insufficient income'
when d.[rule] =6 then 'Insufficient deposit account balance'
when d.[rule] =7 then 'Outside of our lending footprint'
when d.[rule] =8 then 'Identity could not be verified'
when d.[rule] =9 then 'Credit freeze on file'
when d.[rule] =10 then 'We are unable to provide you a loan due to your Active Duty/Covered Borrower status'
when d.[rule] =11 then 'All information required to approve your application was not provided'
when d.[rule] =12 then 'See next tab'
when d.[rule] =13 then 'We are unable to support your linked account'
end as AAN_copy 
-- , case when  d.[rule] =12 then ucvms.Explanations end as ML_AAN_copy
-- , case when d.[rule] =12 then json_value(ucvms.Explanations, '$[0]') end as ML_reason1 
-- , case when d.[rule] =12 then json_value(ucvms.Explanations, '$[1]') end as ML_reason2 
-- , case when d.[rule] =12 then json_value(ucvms.Explanations, '$[2]') end as ML_reason3
-- , case when d.[rule] =12 then json_value(ucvms.Explanations, '$[3]') end as ML_reason4
-- , case when d.[rule] =12 then json_value(ucvms.Explanations, '$[4]') end as ML_reason5  

,  ucvms.Explanations as ML_AAN_copy
, json_value(ucvms.Explanations, '$[0]') as ML_reason1 
, json_value(ucvms.Explanations, '$[1]') as ML_reason2 
, json_value(ucvms.Explanations, '$[2]') as ML_reason3
, json_value(ucvms.Explanations, '$[3]') as ML_reason4
, json_value(ucvms.Explanations, '$[4]') as ML_reason5  

, case when json_value(ucvms.Explanations, '$[0]') in ('AccountAge', 'TotalHistoryInDays')  then 1 
when json_value(ucvms.Explanations, '$[0]') in ('IsRestrictedEligibilityInstitution', 'InstitutionName') then 2 
when json_value(ucvms.Explanations, '$[0]') in ('LatefeesTotalCount', 'LatefeesCount', 'IsInDefaultWithCompetitor', 'Category_Fees') then 3 
when json_value(ucvms.Explanations, '$[0]') in ('CreditAccounts', 'CreditLimit', 'CheckingAccountCount', 'SavingsAccountCount') then 4 
when json_value(ucvms.Explanations, '$[0]') in ('LastRepaymentAmount') then 5
when json_value(ucvms.Explanations, '$[0]') in ('OverdraftCount', 'OverdraftTotal', 'NegativeBalanceCount', 'ConnectedAccountsWithNegativeBalances') then 6
when json_value(ucvms.Explanations, '$[0]') in ('AverageMonthlySpend', 'AverageNumberOfTransactionsADay', 'AverageMonthlyDiscretionarySpend', 'AverageNumberOfTransactionsADayPrimaryChecking', 'AverageWeeklyExpensesToCurrentWeekExpenses') then 7
when json_value(ucvms.Explanations, '$[0]') in ('BalanceAverage', 'BalanceMin', 'TotalAssets', 'TotalCash') then 8
when json_value(ucvms.Explanations, '$[0]') in ('RetryTransactionsCount') then 9
when json_value(ucvms.Explanations, '$[0]') in ('Utilisation') then 10
when json_value(ucvms.Explanations, '$[0]') in ('Paycheck', 'AverageMonthlyIncome', 'AveragePotentialMonthlyIncome', 'TotalMonthsIncomeOver200', 'Category_Paycheck', 'VariationOfPaycheckAmount') then 11
when json_value(ucvms.Explanations, '$[0]') in ('Debtpayments', 'IsPayingInterest', 'StudentLoanPayment', 'MortgagePayment', 'OutstandingCreditDebt', 'OutstandingCreditDebtWherePayingInterest') then 12
when json_value(ucvms.Explanations, '$[0]') in ('Bal4100', 'Bal3100', 'Bal2100', 'Bal450', 'Bal350', 'Bal250', 'BalanceCushionDaysToLessThan100', 'BalanceAbove100L30Count', 'WindowsLast30', 'WindowsLast180', 'WindowsLast90') then 13
when json_value(ucvms.Explanations, '$[0]') in ('PaycheckModelUsed', 'ArchetypeProbability', 'NumberOfMatches', 'ErrorRate', 'ErrorRatio', 'IsNameBased', 'DaysEarly', 'CoefficientOfVariationOnIncome180', 'RecurringTransactionArchetype') then 14
when json_value(ucvms.Explanations, '$[0]') in ('CompetitorAdvancesCount', 'OutstandingCompetitorBalance', 'CompetitorAdvancesAverageRatioToPaycheckPerPeriod') then 15
when json_value(ucvms.Explanations, '$[0]') in ('ExpenseToIncomeRatio', 'ExpenseToIncomeRatioExTransfersLast90') then 16
when json_value(ucvms.Explanations, '$[0]') in ('AtmWithdrawalsOverExpenses', 'P2pWithdrawalsOverExpenses', 'TransfersRatioOfExpensesLast30', 'Category_Transfer') then 17
when json_value(ucvms.Explanations, '$[0]') in ('CountOfUtilityBillsOnPaycheckAccount') then 18
end as ML_decline_enum_1

, case when json_value(ucvms.Explanations, '$[1]') in ('AccountAge', 'TotalHistoryInDays')  then 1 
when json_value(ucvms.Explanations, '$[1]') in ('IsRestrictedEligibilityInstitution', 'InstitutionName') then 2 
when json_value(ucvms.Explanations, '$[1]') in ('LatefeesTotalCount', 'LatefeesCount', 'IsInDefaultWithCompetitor', 'Category_Fees') then 3 
when json_value(ucvms.Explanations, '$[1]') in ('CreditAccounts', 'CreditLimit', 'CheckingAccountCount', 'SavingsAccountCount') then 4 
when json_value(ucvms.Explanations, '$[1]') in ('LastRepaymentAmount') then 5
when json_value(ucvms.Explanations, '$[1]') in ('OverdraftCount', 'OverdraftTotal', 'NegativeBalanceCount', 'ConnectedAccountsWithNegativeBalances') then 6
when json_value(ucvms.Explanations, '$[1]') in ('AverageMonthlySpend', 'AverageNumberOfTransactionsADay', 'AverageMonthlyDiscretionarySpend', 'AverageNumberOfTransactionsADayPrimaryChecking', 'AverageWeeklyExpensesToCurrentWeekExpenses') then 7
when json_value(ucvms.Explanations, '$[1]') in ('BalanceAverage', 'BalanceMin', 'TotalAssets', 'TotalCash') then 8
when json_value(ucvms.Explanations, '$[1]') in ('RetryTransactionsCount') then 9
when json_value(ucvms.Explanations, '$[1]') in ('Utilisation') then 10
when json_value(ucvms.Explanations, '$[1]') in ('Paycheck', 'AverageMonthlyIncome', 'AveragePotentialMonthlyIncome', 'TotalMonthsIncomeOver200', 'Category_Paycheck', 'VariationOfPaycheckAmount') then 11
when json_value(ucvms.Explanations, '$[1]') in ('Debtpayments', 'IsPayingInterest', 'StudentLoanPayment', 'MortgagePayment', 'OutstandingCreditDebt', 'OutstandingCreditDebtWherePayingInterest') then 12
when json_value(ucvms.Explanations, '$[1]') in ('Bal4100', 'Bal3100', 'Bal2100', 'Bal450', 'Bal350', 'Bal250', 'BalanceCushionDaysToLessThan100', 'BalanceAbove100L30Count', 'WindowsLast30', 'WindowsLast180', 'WindowsLast90') then 13
when json_value(ucvms.Explanations, '$[1]') in ('PaycheckModelUsed', 'ArchetypeProbability', 'NumberOfMatches', 'ErrorRate', 'ErrorRatio', 'IsNameBased', 'DaysEarly', 'CoefficientOfVariationOnIncome180', 'RecurringTransactionArchetype') then 14
when json_value(ucvms.Explanations, '$[1]') in ('CompetitorAdvancesCount', 'OutstandingCompetitorBalance', 'CompetitorAdvancesAverageRatioToPaycheckPerPeriod') then 15
when json_value(ucvms.Explanations, '$[1]') in ('ExpenseToIncomeRatio', 'ExpenseToIncomeRatioExTransfersLast90') then 16
when json_value(ucvms.Explanations, '$[1]') in ('AtmWithdrawalsOverExpenses', 'P2pWithdrawalsOverExpenses', 'TransfersRatioOfExpensesLast30', 'Category_Transfer') then 17
when json_value(ucvms.Explanations, '$[1]') in ('CountOfUtilityBillsOnPaycheckAccount') then 18
end as ML_decline_enum_2

, case when json_value(ucvms.Explanations, '$[2]') in ('AccountAge', 'TotalHistoryInDays')  then 1 
when json_value(ucvms.Explanations, '$[2]') in ('IsRestrictedEligibilityInstitution', 'InstitutionName') then 2 
when json_value(ucvms.Explanations, '$[2]') in ('LatefeesTotalCount', 'LatefeesCount', 'IsInDefaultWithCompetitor', 'Category_Fees') then 3 
when json_value(ucvms.Explanations, '$[2]') in ('CreditAccounts', 'CreditLimit', 'CheckingAccountCount', 'SavingsAccountCount') then 4 
when json_value(ucvms.Explanations, '$[2]') in ('LastRepaymentAmount') then 5
when json_value(ucvms.Explanations, '$[2]') in ('OverdraftCount', 'OverdraftTotal', 'NegativeBalanceCount', 'ConnectedAccountsWithNegativeBalances') then 6
when json_value(ucvms.Explanations, '$[2]') in ('AverageMonthlySpend', 'AverageNumberOfTransactionsADay', 'AverageMonthlyDiscretionarySpend', 'AverageNumberOfTransactionsADayPrimaryChecking', 'AverageWeeklyExpensesToCurrentWeekExpenses') then 7
when json_value(ucvms.Explanations, '$[2]') in ('BalanceAverage', 'BalanceMin', 'TotalAssets', 'TotalCash') then 8
when json_value(ucvms.Explanations, '$[2]') in ('RetryTransactionsCount') then 9
when json_value(ucvms.Explanations, '$[2]') in ('Utilisation') then 10
when json_value(ucvms.Explanations, '$[2]') in ('Paycheck', 'AverageMonthlyIncome', 'AveragePotentialMonthlyIncome', 'TotalMonthsIncomeOver200', 'Category_Paycheck', 'VariationOfPaycheckAmount') then 11
when json_value(ucvms.Explanations, '$[2]') in ('Debtpayments', 'IsPayingInterest', 'StudentLoanPayment', 'MortgagePayment', 'OutstandingCreditDebt', 'OutstandingCreditDebtWherePayingInterest') then 12
when json_value(ucvms.Explanations, '$[2]') in ('Bal4100', 'Bal3100', 'Bal2100', 'Bal450', 'Bal350', 'Bal250', 'BalanceCushionDaysToLessThan100', 'BalanceAbove100L30Count', 'WindowsLast30', 'WindowsLast180', 'WindowsLast90') then 13
when json_value(ucvms.Explanations, '$[2]') in ('PaycheckModelUsed', 'ArchetypeProbability', 'NumberOfMatches', 'ErrorRate', 'ErrorRatio', 'IsNameBased', 'DaysEarly', 'CoefficientOfVariationOnIncome180', 'RecurringTransactionArchetype') then 14
when json_value(ucvms.Explanations, '$[2]') in ('CompetitorAdvancesCount', 'OutstandingCompetitorBalance', 'CompetitorAdvancesAverageRatioToPaycheckPerPeriod') then 15
when json_value(ucvms.Explanations, '$[2]') in ('ExpenseToIncomeRatio', 'ExpenseToIncomeRatioExTransfersLast90') then 16
when json_value(ucvms.Explanations, '$[2]') in ('AtmWithdrawalsOverExpenses', 'P2pWithdrawalsOverExpenses', 'TransfersRatioOfExpensesLast30', 'Category_Transfer') then 17
when json_value(ucvms.Explanations, '$[2]') in ('CountOfUtilityBillsOnPaycheckAccount') then 18
end as ML_decline_enum_3

, case when json_value(ucvms.Explanations, '$[3]') in ('AccountAge', 'TotalHistoryInDays')  then 1 
when json_value(ucvms.Explanations, '$[3]') in ('IsRestrictedEligibilityInstitution', 'InstitutionName') then 2 
when json_value(ucvms.Explanations, '$[3]') in ('LatefeesTotalCount', 'LatefeesCount', 'IsInDefaultWithCompetitor', 'Category_Fees') then 3 
when json_value(ucvms.Explanations, '$[3]') in ('CreditAccounts', 'CreditLimit', 'CheckingAccountCount', 'SavingsAccountCount') then 4 
when json_value(ucvms.Explanations, '$[3]') in ('LastRepaymentAmount') then 5
when json_value(ucvms.Explanations, '$[3]') in ('OverdraftCount', 'OverdraftTotal', 'NegativeBalanceCount', 'ConnectedAccountsWithNegativeBalances') then 6
when json_value(ucvms.Explanations, '$[3]') in ('AverageMonthlySpend', 'AverageNumberOfTransactionsADay', 'AverageMonthlyDiscretionarySpend', 'AverageNumberOfTransactionsADayPrimaryChecking', 'AverageWeeklyExpensesToCurrentWeekExpenses') then 7
when json_value(ucvms.Explanations, '$[3]') in ('BalanceAverage', 'BalanceMin', 'TotalAssets', 'TotalCash') then 8
when json_value(ucvms.Explanations, '$[3]') in ('RetryTransactionsCount') then 9
when json_value(ucvms.Explanations, '$[3]') in ('Utilisation') then 10
when json_value(ucvms.Explanations, '$[3]') in ('Paycheck', 'AverageMonthlyIncome', 'AveragePotentialMonthlyIncome', 'TotalMonthsIncomeOver200', 'Category_Paycheck', 'VariationOfPaycheckAmount') then 11
when json_value(ucvms.Explanations, '$[3]') in ('Debtpayments', 'IsPayingInterest', 'StudentLoanPayment', 'MortgagePayment', 'OutstandingCreditDebt', 'OutstandingCreditDebtWherePayingInterest') then 12
when json_value(ucvms.Explanations, '$[3]') in ('Bal4100', 'Bal3100', 'Bal2100', 'Bal450', 'Bal350', 'Bal250', 'BalanceCushionDaysToLessThan100', 'BalanceAbove100L30Count', 'WindowsLast30', 'WindowsLast180', 'WindowsLast90') then 13
when json_value(ucvms.Explanations, '$[3]') in ('PaycheckModelUsed', 'ArchetypeProbability', 'NumberOfMatches', 'ErrorRate', 'ErrorRatio', 'IsNameBased', 'DaysEarly', 'CoefficientOfVariationOnIncome180', 'RecurringTransactionArchetype') then 14
when json_value(ucvms.Explanations, '$[3]') in ('CompetitorAdvancesCount', 'OutstandingCompetitorBalance', 'CompetitorAdvancesAverageRatioToPaycheckPerPeriod') then 15
when json_value(ucvms.Explanations, '$[3]') in ('ExpenseToIncomeRatio', 'ExpenseToIncomeRatioExTransfersLast90') then 16
when json_value(ucvms.Explanations, '$[3]') in ('AtmWithdrawalsOverExpenses', 'P2pWithdrawalsOverExpenses', 'TransfersRatioOfExpensesLast30', 'Category_Transfer') then 17
when json_value(ucvms.Explanations, '$[3]') in ('CountOfUtilityBillsOnPaycheckAccount') then 18
end as ML_decline_enum_4

, case when json_value(ucvms.Explanations, '$[4]') in ('AccountAge', 'TotalHistoryInDays')  then 1 
when json_value(ucvms.Explanations, '$[4]') in ('IsRestrictedEligibilityInstitution', 'InstitutionName') then 2 
when json_value(ucvms.Explanations, '$[4]') in ('LatefeesTotalCount', 'LatefeesCount', 'IsInDefaultWithCompetitor', 'Category_Fees') then 3 
when json_value(ucvms.Explanations, '$[4]') in ('CreditAccounts', 'CreditLimit', 'CheckingAccountCount', 'SavingsAccountCount') then 4 
when json_value(ucvms.Explanations, '$[4]') in ('LastRepaymentAmount') then 5
when json_value(ucvms.Explanations, '$[4]') in ('OverdraftCount', 'OverdraftTotal', 'NegativeBalanceCount', 'ConnectedAccountsWithNegativeBalances') then 6
when json_value(ucvms.Explanations, '$[4]') in ('AverageMonthlySpend', 'AverageNumberOfTransactionsADay', 'AverageMonthlyDiscretionarySpend', 'AverageNumberOfTransactionsADayPrimaryChecking', 'AverageWeeklyExpensesToCurrentWeekExpenses') then 7
when json_value(ucvms.Explanations, '$[4]') in ('BalanceAverage', 'BalanceMin', 'TotalAssets', 'TotalCash') then 8
when json_value(ucvms.Explanations, '$[4]') in ('RetryTransactionsCount') then 9
when json_value(ucvms.Explanations, '$[4]') in ('Utilisation') then 10
when json_value(ucvms.Explanations, '$[4]') in ('Paycheck', 'AverageMonthlyIncome', 'AveragePotentialMonthlyIncome', 'TotalMonthsIncomeOver200', 'Category_Paycheck', 'VariationOfPaycheckAmount') then 11
when json_value(ucvms.Explanations, '$[4]') in ('Debtpayments', 'IsPayingInterest', 'StudentLoanPayment', 'MortgagePayment', 'OutstandingCreditDebt', 'OutstandingCreditDebtWherePayingInterest') then 12
when json_value(ucvms.Explanations, '$[4]') in ('Bal4100', 'Bal3100', 'Bal2100', 'Bal450', 'Bal350', 'Bal250', 'BalanceCushionDaysToLessThan100', 'BalanceAbove100L30Count', 'WindowsLast30', 'WindowsLast180', 'WindowsLast90') then 13
when json_value(ucvms.Explanations, '$[4]') in ('PaycheckModelUsed', 'ArchetypeProbability', 'NumberOfMatches', 'ErrorRate', 'ErrorRatio', 'IsNameBased', 'DaysEarly', 'CoefficientOfVariationOnIncome180', 'RecurringTransactionArchetype') then 14
when json_value(ucvms.Explanations, '$[4]') in ('CompetitorAdvancesCount', 'OutstandingCompetitorBalance', 'CompetitorAdvancesAverageRatioToPaycheckPerPeriod') then 15
when json_value(ucvms.Explanations, '$[4]') in ('ExpenseToIncomeRatio', 'ExpenseToIncomeRatioExTransfersLast90') then 16
when json_value(ucvms.Explanations, '$[4]') in ('AtmWithdrawalsOverExpenses', 'P2pWithdrawalsOverExpenses', 'TransfersRatioOfExpensesLast30', 'Category_Transfer') then 17
when json_value(ucvms.Explanations, '$[4]') in ('CountOfUtilityBillsOnPaycheckAccount') then 18
end as ML_decline_enum_5


into #decline_starter
from UserLoanApplications a
left join UserLoanApplicationDenialReasons d 
on a.userLoanApplicationId = d.userLoanApplicationId
inner join UserCreditModel ucm on a.UserCreditModelId = ucm.UserCreditModelId
-- after the table rework from last night, UserCreditVariable is now our top level aggregate for all things credit score related
inner join UserCreditVariable ucv on ucm.UserCreditVariableId = ucv.UserCreditVariableId
-- this is something to raise with @justin, the MLScore table here is in use for loans underwriting/aan
inner join UserCreditVariableMLScore ucvms on ucv.UserCreditVariableId = ucvms.UserCreditVariableId
-- the denial reasons table here should map to 12 for all the ML score related reasons
where 1=1 
and d.createdAt between '2023-01-01' and '2023-03-31'
;

drop table if exists #decline_starter2
select 
* 
, case when ML_decline_enum_1 =1 then 'Your deposit account history is not long enough for us to properly assess your finances'
when ML_decline_enum_1 =2 then 'Your paycheck institution has policies that impact our ability to collect on cash advances'
when ML_decline_enum_1 =3 then 'There have been too many missed or late payments across your accounts'
when ML_decline_enum_1 =4 then 'There are too few accounts connected to Empower'
when ML_decline_enum_1 =5 then 'Recent payments on your debt obligations have been too low'
when ML_decline_enum_1 =6 then 'There have been too many negative balances on your deposit accounts'
when ML_decline_enum_1 =7 then 'There is insufficient recent transaction history on your deposit accounts'
when ML_decline_enum_1 =8 then 'Deposit account balances have been too low recently'
when ML_decline_enum_1 =9 then 'There have been too many failed transactions on your deposit accounts recently'
when ML_decline_enum_1 =10 then 'Utilization of your available credit is too high'
when ML_decline_enum_1 =11 then 'Recent income has been too low to cover your outstanding debt'
when ML_decline_enum_1 =12 then 'Your outstanding debt is too high'
when ML_decline_enum_1 =13 then 'Your deposit account balances have decreased too quickly after receiving a paycheck'
when ML_decline_enum_1 =14 then 'Recent income has been too inconsistent or infrequent'
when ML_decline_enum_1 =15 then ' ' --'You have received too many cash advances recently'
when ML_decline_enum_1 =16 then 'Recent expenses have been too high relative to recent income'
when ML_decline_enum_1 =17 then 'There have been too many transfers and withdrawals across your deposit accounts recently'
when ML_decline_enum_1 =18 then 'We are unable to detect sufficient bill payments on your primary deposit account'
else ''
end as AAN_copy_MLdecline1

, case when ML_decline_enum_2 =1 then 'Your deposit account history is not long enough for us to properly assess your finances'
when ML_decline_enum_2 =2 then 'Your paycheck institution has policies that impact our ability to collect on cash advances'
when ML_decline_enum_2 =3 then 'There have been too many missed or late payments across your accounts'
when ML_decline_enum_2 =4 then 'There are too few accounts connected to Empower'
when ML_decline_enum_2 =5 then 'Recent payments on your debt obligations have been too low'
when ML_decline_enum_2 =6 then 'There have been too many negative balances on your deposit accounts'
when ML_decline_enum_2 =7 then 'There is insufficient recent transaction history on your deposit accounts'
when ML_decline_enum_2 =8 then 'Deposit account balances have been too low recently'
when ML_decline_enum_2 =9 then 'There have been too many failed transactions on your deposit accounts recently'
when ML_decline_enum_2 =10 then 'Utilization of your available credit is too high'
when ML_decline_enum_2 =11 then 'Recent income has been too low to cover your outstanding debt'
when ML_decline_enum_2 =12 then 'Your outstanding debt is too high'
when ML_decline_enum_2 =13 then 'Your deposit account balances have decreased too quickly after receiving a paycheck'
when ML_decline_enum_2 =14 then 'Recent income has been too inconsistent or infrequent'
when ML_decline_enum_2 =15 then ' ' --'You have received too many cash advances recently'
when ML_decline_enum_2 =16 then 'Recent expenses have been too high relative to recent income'
when ML_decline_enum_2 =17 then 'There have been too many transfers and withdrawals across your deposit accounts recently'
when ML_decline_enum_2 =18 then 'We are unable to detect sufficient bill payments on your primary deposit account'
else ''
end as AAN_copy_MLdecline2

, case when ML_decline_enum_3 =1 then 'Your deposit account history is not long enough for us to properly assess your finances'
when ML_decline_enum_3 =2 then 'Your paycheck institution has policies that impact our ability to collect on cash advances'
when ML_decline_enum_3 =3 then 'There have been too many missed or late payments across your accounts'
when ML_decline_enum_3 =4 then 'There are too few accounts connected to Empower'
when ML_decline_enum_3 =5 then 'Recent payments on your debt obligations have been too low'
when ML_decline_enum_3 =6 then 'There have been too many negative balances on your deposit accounts'
when ML_decline_enum_3 =7 then 'There is insufficient recent transaction history on your deposit accounts'
when ML_decline_enum_3 =8 then 'Deposit account balances have been too low recently'
when ML_decline_enum_3 =9 then 'There have been too many failed transactions on your deposit accounts recently'
when ML_decline_enum_3 =10 then 'Utilization of your available credit is too high'
when ML_decline_enum_3 =11 then 'Recent income has been too low to cover your outstanding debt'
when ML_decline_enum_3 =12 then 'Your outstanding debt is too high'
when ML_decline_enum_3 =13 then 'Your deposit account balances have decreased too quickly after receiving a paycheck'
when ML_decline_enum_3 =14 then 'Recent income has been too inconsistent or infrequent'
when ML_decline_enum_3 =15 then ' ' --'You have received too many cash advances recently'
when ML_decline_enum_3 =16 then 'Recent expenses have been too high relative to recent income'
when ML_decline_enum_3 =17 then 'There have been too many transfers and withdrawals across your deposit accounts recently'
when ML_decline_enum_3 =18 then 'We are unable to detect sufficient bill payments on your primary deposit account'
else ''
end as AAN_copy_MLdecline3

, case when ML_decline_enum_4 =1 then 'Your deposit account history is not long enough for us to properly assess your finances'
when ML_decline_enum_4 =2 then 'Your paycheck institution has policies that impact our ability to collect on cash advances'
when ML_decline_enum_4 =3 then 'There have been too many missed or late payments across your accounts'
when ML_decline_enum_4 =4 then 'There are too few accounts connected to Empower'
when ML_decline_enum_4 =5 then 'Recent payments on your debt obligations have been too low'
when ML_decline_enum_4 =6 then 'There have been too many negative balances on your deposit accounts'
when ML_decline_enum_4 =7 then 'There is insufficient recent transaction history on your deposit accounts'
when ML_decline_enum_4 =8 then 'Deposit account balances have been too low recently'
when ML_decline_enum_4 =9 then 'There have been too many failed transactions on your deposit accounts recently'
when ML_decline_enum_4 =10 then 'Utilization of your available credit is too high'
when ML_decline_enum_4 =11 then 'Recent income has been too low to cover your outstanding debt'
when ML_decline_enum_4 =12 then 'Your outstanding debt is too high'
when ML_decline_enum_4 =13 then 'Your deposit account balances have decreased too quickly after receiving a paycheck'
when ML_decline_enum_4 =14 then 'Recent income has been too inconsistent or infrequent'
when ML_decline_enum_4 =15 then ' ' --'You have received too many cash advances recently'
when ML_decline_enum_4 =16 then 'Recent expenses have been too high relative to recent income'
when ML_decline_enum_4 =17 then 'There have been too many transfers and withdrawals across your deposit accounts recently'
when ML_decline_enum_4 =18 then 'We are unable to detect sufficient bill payments on your primary deposit account'
else ''
end as AAN_copy_MLdecline4

, case when ML_decline_enum_5 =1 then 'Your deposit account history is not long enough for us to properly assess your finances'
when ML_decline_enum_5 =2 then 'Your paycheck institution has policies that impact our ability to collect on cash advances'
when ML_decline_enum_5 =3 then 'There have been too many missed or late payments across your accounts'
when ML_decline_enum_5 =4 then 'There are too few accounts connected to Empower'
when ML_decline_enum_5 =5 then 'Recent payments on your debt obligations have been too low'
when ML_decline_enum_5 =6 then 'There have been too many negative balances on your deposit accounts'
when ML_decline_enum_5 =7 then 'There is insufficient recent transaction history on your deposit accounts'
when ML_decline_enum_5 =8 then 'Deposit account balances have been too low recently'
when ML_decline_enum_5 =9 then 'There have been too many failed transactions on your deposit accounts recently'
when ML_decline_enum_5 =10 then 'Utilization of your available credit is too high'
when ML_decline_enum_5 =11 then 'Recent income has been too low to cover your outstanding debt'
when ML_decline_enum_5 =12 then 'Your outstanding debt is too high'
when ML_decline_enum_5 =13 then 'Your deposit account balances have decreased too quickly after receiving a paycheck'
when ML_decline_enum_5 =14 then 'Recent income has been too inconsistent or infrequent'
when ML_decline_enum_5 =15 then ' ' --'You have received too many cash advances recently'
when ML_decline_enum_5 =16 then 'Recent expenses have been too high relative to recent income'
when ML_decline_enum_5 =17 then 'There have been too many transfers and withdrawals across your deposit accounts recently'
when ML_decline_enum_5 =18 then 'We are unable to detect sufficient bill payments on your primary deposit account'
else ''
end as AAN_copy_MLdecline5

, case when decline_rule_enum = 12 and ML_decline_enum_1 is null and ML_decline_enum_2 is null and ML_decline_enum_3 is null and ML_decline_enum_4 is null and ML_decline_enum_5 is null then 1 else 0 end as dupe_record_decline_ind
, case when decline_rule_enum = 12 and ML_decline_enum_1 is not null and ML_decline_enum_2 is null and ML_decline_enum_3 is null and ML_decline_enum_4 is null and ML_decline_enum_5 is null then 1 else 0 end as one_decline_flag_ind1
, case when decline_rule_enum = 12 and ML_decline_enum_1 is null and ML_decline_enum_2 is not null and ML_decline_enum_3 is null and ML_decline_enum_4 is null and ML_decline_enum_5 is null then 1 else 0 end as one_decline_flag_ind2
, case when decline_rule_enum = 12 and ML_decline_enum_1 is null and ML_decline_enum_2 is null and ML_decline_enum_3 is not null and ML_decline_enum_4 is null and ML_decline_enum_5 is null then 1 else 0 end as one_decline_flag_ind3
, case when decline_rule_enum = 12 and ML_decline_enum_1 is null and ML_decline_enum_2 is null and ML_decline_enum_3 is null and ML_decline_enum_4 is not null and ML_decline_enum_5 is null then 1 else 0 end as one_decline_flag_ind4
, case when decline_rule_enum = 12 and ML_decline_enum_1 is null and ML_decline_enum_2 is null and ML_decline_enum_3 is null and ML_decline_enum_4 is null and ML_decline_enum_5 is not null then 1 else 0 end as one_decline_flag_ind5

into #decline_starter2
from #decline_starter
where 1=1 

order by userId, decline_date
;

select 
distinct userLoanApplicationId
, userId 
, decline_date 
, decline_rule_enum 
, decline_rule_title
, AAN_copy 
, case when decline_rule_enum  <> 12 then '' else AAN_copy_MLdecline1 end as AAN_copy_MLdecline1
, case when decline_rule_enum  <> 12 then '' else AAN_copy_MLdecline2 end as AAN_copy_MLdecline2
, case when decline_rule_enum  <> 12 then '' else AAN_copy_MLdecline3 end as AAN_copy_MLdecline3
, case when decline_rule_enum  <> 12 then '' else AAN_copy_MLdecline4 end as AAN_copy_MLdecline4
, case when decline_rule_enum  <> 12 then '' else AAN_copy_MLdecline5 end as AAN_copy_MLdecline5

from #decline_starter2
where 1=1 
and dupe_record_decline_ind = 0 
and one_decline_flag_ind1 = 0
and one_decline_flag_ind2 = 0
and one_decline_flag_ind3 = 0
and one_decline_flag_ind4 = 0
and one_decline_flag_ind5 = 0

order by userLoanApplicationId, decline_rule_enum
;