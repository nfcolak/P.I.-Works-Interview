WITH t AS (
  SELECT 
    country,
    COALESCE(daily_vaccinations, 0) AS daily_vaccinations
  FROM 
    country_vaccination_stats
  WHERE 
    daily_vaccinations IS NOT NULL
  UNION ALL
  SELECT 
    country,
    COALESCE((
      SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY daily_vaccinations)
      FROM 
        country_vaccination_stats
      WHERE 
        daily_vaccinations IS NOT NULL AND
        country = c.country
    ), 0) AS daily_vaccinations
  FROM 
    country_vaccination_stats AS c
  WHERE 
    daily_vaccinations IS NULL
)
UPDATE 
  country_vaccination_stats AS c
SET 
  daily_vaccinations = t.daily_vaccinations
FROM 
  t
WHERE 
  c.country = t.country;