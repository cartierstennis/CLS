# ----------- Data.roi ------------- #

SELECT study_datetime,
       advertiser_id,
       campaign_id,
       study_type,
       attribution_window,
       conversion_type,
       CASE WHEN cohort in (0, 1) then 'Control_Group'
            WHEN cohort in (6, 7) then 'Exposed_Group'
            WHEN cohort in (8, 9) then 'Engaged_Group'
            WHEN cohort in (10,11) then 'Eligible_Lost_Group'
            WHEN cohort in (12,13) then 'Eligible_Filtered_Group'
            ELSE 'Unknown' END as 'Group_Type', # -- dimensions
     
       total_users,
       number_of_conversions # -- measures
       
FROM conversion_lift_study_results_convtype
WHERE date(study_datetime) between '2016-02-01' and '2016-02-10'