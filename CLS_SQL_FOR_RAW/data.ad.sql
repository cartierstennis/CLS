# --------- Data.ad -------------- #

select
'fi' AS source, 
campaign_id,
cls_is_active,
campaign_name,
campaign_start_date,
adj_campaign_end_date,
campaign_status,
account_id,
account_name,
study_types
from
(
select
cls_fi_id,
campaign_id,
CASE
    WHEN adj_campaign_end_date < now() THEN 'No'
    WHEN cls_fi_is_active = 0 THEN 'No'
    /*WHEN campaign_start_date >= cls_fi.start_time AND campaign_start_date <= cls_fi.end_time THEN 'Yes'*/
    WHEN campaign_start_date between cls_fi_start_time AND cls_fi_end_time THEN 'Yes'
    ELSE 'Yes'
END AS cls_is_active,
campaign_deleted,
campaign_name,
campaign_start_date,
adj_campaign_end_date,
CASE
    when campaign_deleted = 1 then 'Deleted'
    when adj_campaign_end_date <= now() THEN 'Ended'
    when campaign_start_date >= now() THEN 'Scheduled'
    when adj_campaign_end_date >= now() AND campaign_serving_status = 1 THEN 'Paused'
    when adj_campaign_end_date >= now() AND campaign_serving_status = 0 THEN 'Active'
    when campaign_serving_status in (2,3) THEN 'Draft'
    when adj_campaign_end_date is null AND campaign_serving_status = 1 THEN 'Paused'
    when adj_campaign_end_date is null AND campaign_serving_status = 0 THEN 'Active'
END AS campaign_status, 
account_id,
account_name
FROM

(
select a.name AS account_name, cls_fi.id AS cls_fi_id, cls_fi.funding_instrument_id AS cls_fi, cls_fi.start_time AS cls_fi_start_time, cls_fi.end_time AS cls_fi_end_time,
CASE
    WHEN cls_fi.deleted = 0 THEN 'No'
    WHEN cls_fi.deleted = 1 THEN 'Yes'
    ELSE 'NA'
END AS cls_fi_deleted, 

cls_fi.is_active AS cls_fi_is_active,
c.id AS campaign_id, c.name AS campaign_name, 
date(c.start_time) AS campaign_start_date,
CASE
    when c.end_time is NULL then date(io.contract_end_date)
    when c.end_time is NULL and io.contract_end_date is NULL then date(f.end_time)
    else date(c.end_time)
END AS adj_campaign_end_date,
c.deleted AS campaign_deleted,
c.serving_status AS campaign_serving_status,
f.account_id account_id
from conversion_lift_study_funding_instruments cls_fi
left join funding_instruments f on f.id = cls_fi.funding_instrument_id
left join campaigns c on cls_fi.funding_instrument_id = c.funding_instrument_id
left join accounts a on f.account_id = a.id
left join insertion_orders io ON io.funding_instrument_id = f.id

where cls_fi.deleted = 0
and c.deleted = 0 
/*date(c.start_time) >= cls_fi.start_time
and date(c.start_time) <= cls_fi.end_time*/
AND date(c.start_time) between cls_fi.start_time and cls_fi.end_time
) main_cls_fi
) main_cls_fi_top

LEFT JOIN

(
select
cls_fi_id,
CONCAT_WS(',',study_type_1, study_type_2,study_type_3,study_type_4) as study_types
/*CHARACTER_LENGTH(CONCAT(study_type_1, study_type_2,study_type_3,study_type_4)) as number_of_studies*/
from
(
select 
cls_fi_id, 
MAX(CASE WHEN study_type = 1 THEN 'OCT' ELSE '' END) AS study_type_1,
MAX(CASE WHEN study_type = 2 THEN ' CARRIER_TARGETING' ELSE '' END) AS study_type_2,
MAX(CASE WHEN study_type = 3 THEN ' MACT' ELSE '' END) AS study_type_3,
MAX(CASE WHEN study_type = 4 THEN ' TRAVEL' ELSE '' END) AS study_type_4
from conversion_lift_study_fi_profiles
where deleted = 0
group by 1
) AS main_study_type_fi
) AS main_study_type_fi_top
ON main_cls_fi_top.cls_fi_id = main_study_type_fi_top.cls_fi_id



UNION ALL



/*CLS campaign OLD method*/

select 'campaign' as source, campaign_id, cls_is_active, campaign_name, campaign_start_date, adj_campaign_end_date, campaign_status, account_id, account_name, study_types
from
(

select
id,
campaign_id,
CASE
    WHEN adj_campaign_end_date < now() THEN 'No'
    WHEN is_active = 0 THEN 'No'
    ELSE 'Yes'
END AS cls_is_active,
deleted,
campaign_name,
campaign_start_date,
adj_campaign_end_date,
CASE
    when campaign_deleted = 1 then 'Deleted'
    when adj_campaign_end_date <= now() THEN 'Ended'
    when campaign_start_date >= now() THEN 'Scheduled'
    when adj_campaign_end_date >= now() AND campaign_serving_status = 1 THEN 'Paused'
    when adj_campaign_end_date >= now() AND campaign_serving_status = 0 THEN 'Active'
    when campaign_serving_status in (2,3) THEN 'Draft'
    when adj_campaign_end_date is null AND campaign_serving_status = 1 THEN 'Paused'
    when adj_campaign_end_date is null AND campaign_serving_status = 0 THEN 'Active'
END AS campaign_status,
account_id,
account_name
from
(
select
cls.id,
f.id AS fi_id,
io.id AS io_id,
cls.campaign_id,
cls.is_active,
CASE
    WHEN cls.deleted = 0 THEN 'No'
    WHEN cls.deleted = 1 THEN 'Yes'
    ELSE 'NA'
END AS deleted, 
c.name campaign_name, 
date(c.start_time) AS campaign_start_date,
date(c.end_time) AS campaign_end_date,
CASE
    when c.end_time is NULL then date(io.contract_end_date)
    when c.end_time is NULL and io.contract_end_date is NULL then date(f.end_time)
    else date(c.end_time)
END AS adj_campaign_end_date,
c.deleted AS campaign_deleted,
c.serving_status AS campaign_serving_status,
f.account_id, a.name account_name
from conversion_lift_study_campaigns cls
left join campaigns c on c.id = cls.campaign_id
left join funding_instruments f on f.id = c.funding_instrument_id
left join accounts a on f.account_id = a.id
left join insertion_orders io ON io.funding_instrument_id = f.id
where cls.deleted = 0
and c.deleted = 0
) main_cls_campaign
) main_cls_campaign_top

LEFT JOIN

(
select
campaign_details_id,
CONCAT_WS(',',study_type_1, study_type_2,study_type_3,study_type_4) as study_types
/*CHARACTER_LENGTH(CONCAT(study_type_1, study_type_2,study_type_3,study_type_4)) as number_of_studies*/
from
(
select 
campaign_details_id, 
MAX(CASE WHEN study_type = 1 THEN 'OCT' ELSE '' END) AS study_type_1,
MAX(CASE WHEN study_type = 2 THEN ' CARRIER_TARGETING' ELSE '' END) AS study_type_2,
MAX(CASE WHEN study_type = 3 THEN ' MACT' ELSE '' END) AS study_type_3,
MAX(CASE WHEN study_type = 4 THEN ' TRAVEL' ELSE '' END) AS study_type_4
from conversion_lift_study_study_types
where deleted = 0
group by 1
) AS main_study_type_campaign
) AS main_study_type_campaign_top

ON main_cls_campaign_top.id = main_study_type_campaign_top.campaign_details_id