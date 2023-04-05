--- App access check 
-- using Thrive account holders as an example 
drop table if exists #driver 
select 
distinct a.userId 
, a.userLoanApplicationId
, a.loanId 
, b.DateAccessed
, convert(varchar(7), b.DateAccessed , 23) as access_month -- converts the month into a easy to read format. I f you want to do a datediff function use the original field
, row_number() over(partition by b.userId order by DateAccessed desc) as access_num_desc 
into #driver 
from loans a 
left join AccessLog b 
on a.userId = b.userId 
where 1=1 
;

-- will pull most recent month the user accessed the app
select 
* 
from #driver
where access_num_desc = 1 
;

