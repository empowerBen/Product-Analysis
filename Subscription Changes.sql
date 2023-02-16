drop table if exists #sub_change
select 
distinct b.userSubscriptionId
, b.PastSubscriptionStatus 
, b.StatusChangedAtUtc as status_change_date
, a.startDate as sub_start_date
, a.endDate as sub_end_date
, a.subscriptionStatus 
,  case when PastSubscriptionStatus  = 0 then 'None'
when PastSubscriptionStatus  = 1 then 'Active'
when PastSubscriptionStatus  = 2 then 'Overdue'
when PastSubscriptionStatus  = 3 then 'Canceled'
when PastSubscriptionStatus  = 4 then 'Delinquent'
when PastSubscriptionStatus  = 5 then 'Closed by User'
when PastSubscriptionStatus  = 6 then 'Closed by Empower'
when PastSubscriptionStatus  = 7 then 'Pending Payment'
when PastSubscriptionStatus  = 8 then 'Trial Autoclose'
when PastSubscriptionStatus  = 9 then 'Subscription Paused'
end as past_subscriptionStatus
, case when subscriptionStatus = 0 then 'None'
when subscriptionStatus = 1 then 'Active'
when subscriptionStatus = 2 then 'Overdue'
when subscriptionStatus = 3 then 'Canceled'
when subscriptionStatus = 4 then 'Delinquent'
when subscriptionStatus = 5 then 'Closed by User'
when subscriptionStatus = 6 then 'Closed by Empower'
when subscriptionStatus = 7 then 'Pending Payment'
when subscriptionStatus = 8 then 'Trial Autoclose'
when subscriptionStatus = 9 then 'Subscription Paused'
end as current_subscriptionStatus
into #sub_change
from UserSubscriptionStatusChange b
left join [UserSubscription] a 
on b.userSubscriptionId = a.userSubscriptionId
where 1=1 
and datediff(day,b.StatusChangedAtUtc,GETDATE())<=30 -- L30D
; 

drop table if exists #sub_change_ranked
select 
a.*
, row_number() over(partition by UserSubscriptionId order by status_change_date desc) as sub_change_rank -- 1 = most recent
into #sub_change_ranked
from #sub_change a
order by UserSubscriptionId 
;

drop table if exists #most_recent_change
select 
* 
into #most_recent_change
from #sub_change_ranked
where sub_change_rank = 1 
;
