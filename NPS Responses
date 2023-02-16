drop table if exists #NPS_free_response
SELECT
    s.SurveyId,
    usr.UserId,
    s.SurveyName as SurveyType,
    Rating = sr.ResponseText,
    Feedback = usr.CustomResponse,
    convert(varchar, usr.CreatedAt, 23) as ResponseDate,
    case when usr.CreatedAt >= (GETDATE() - 7) then 1 else 0 end as last_7_days_ind
into #NPS_free_response
FROM
    UserSurveyResponse usr
    inner join SurveyResponse sr on usr.SurveyResponseId = sr.SurveyResponseId
    inner join SurveyQuestion sq on sq.SurveyQuestionId = sr.SurveyQuestionId
    inner join Survey s on sq.SurveyId = s.SurveyId
WHERE
    s.SurveyId > 1
    AND sr.ResponseText <> '-1' -- keep filter if you want to limit to ratings with text responses, comment out if you would like all ratings
    ;

select 
distinct userId
, responseDate 
, surveyType
, rating
, feedback
from #NPS_free_response
where feedback <> ''
--and responseDate between '2023-02-05' and '2023-02-12'
order by responseDate  ASC
;
