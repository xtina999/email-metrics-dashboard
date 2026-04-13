with union_data as(
    SELECT
            DATE_ADD(ss.date, INTERVAL s.sent_date DAY ) as date,
            sp.country,
            count(distinct s.id_message) as sent_cnt,
            count(distinct o.id_message) as open_cnt,
            count(distinct v.id_message) as click_cnt,
            null as account_cnt
FROM `DA.email_sent` s
left join `DA.account_session` ac
on s.id_account = ac.account_id
left join `DA.session_params` sp
on ac.ga_session_id = sp.ga_session_id
left join `DA.email_open` o
on s.id_message = o.id_message
left join `DA.email_visit` v
on o.id_message = v.id_message
join `DA.session` ss
on ac.ga_session_id = ss.ga_session_id
group by sp.country, DATE_ADD (ss.date, INTERVAL s.sent_date DAY ) 
union all
Select
        ss.date,
        sp.country,
        null, null, null,
        count(ac.account_id) as account_cnt
from `DA.account_session` ac
left join `DA.session_params` sp
on ac.ga_session_id = sp.ga_session_id
join `DA.session` ss
on ac.ga_session_id = ss.ga_session_id
group by ss.date,
        sp.country
)

SELECT
        date,
        country,
        sum(sent_cnt) as sent_cnt, 
        sum(open_cnt) as open_cnt,
        sum(click_cnt) as clicn_cnt,
        sum(account_cnt) as account_cnt,
from union_data
group by date, country
