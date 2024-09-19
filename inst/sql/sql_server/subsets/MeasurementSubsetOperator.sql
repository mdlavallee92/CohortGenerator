/* SQL Script to subset by measurement type
Developed by Katy Sadowski and Ajit Londhe
Adapted for CohortGenerator Subsets by Martin Lavallee
*/

WITH cte_lab_values
as
(
  SELECT
  	cohort_definition_id,
  	subject_id,
  	measurement_date,
    value_as_number AS covariate_value,
    DENSE_RANK() OVER(PARTITION BY cohort_definition_id, person_id ORDER BY measurement_date ASC) AS date_rank
  FROM @cohort_database_schema.@cohort_table cohort
    JOIN @cdm_database_schema.measurement ON measurement.person_id = cohort.subject_id
	    AND measurement_date > cohort_start_date
	    AND measurement_concept_id IN (@measurement_concept_ids)
      AND measurement.unit_concept_id IN (@unit_concept_ids)
      AND measurement.value_as_number >= @min_lab_value
      AND measurement.value_as_number <= @max_lab_value
      AND measurement.measurement_type_concept_id IN (@type_concept_ids)
  WHERE cohort.cohort_definition_id IN (@cohort_ids)
),
cte_lab_values_final
as
(
  select
    cohort_definition_id,
  	subject_id,
  	measurement_date,
    min(covariate_value) as covariate_value
  from cte_lab_values
  where date_rank = 1
  group by 1, 2, 3
)
select distinct
  --cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
{@output_table != ''} ? {INTO @output_table}
from @cohort_database_schema.@cohort_table COHORT
where cohort_definition_id in (@cohort_ids)
  and exists
  (
    select 1
    from cte_lab_values_final
    where cte_lab_values_final.cohort_definition_id = COHORT.cohort_definition_id
      and cte_lab_values_final.subject_id = COHORT.subject_id
      and cte_lab_values_final.covariate_value >= @left_bound_inclusive
      and cte_lab_values_final.covariate_value < @right_bound_exclusive
  )
;
