
DROP TABLE IF EXISTS analytics.clean_customers;
CREATE TABLE analytics.clean_customers AS
SELECT
  COALESCE(LOWER(customerid), 'unknown') AS customerid,
  COALESCE(LOWER(gender), 'unknown') AS gender,
  COALESCE(tenure, 0) AS tenure,
  COALESCE(LOWER(partner), 'unknown') AS partner,
  COALESCE(LOWER(dependents), 'unknown') AS dependents,
  COALESCE(LOWER(phoneservice), 'unknown') AS phoneservice,
  COALESCE(LOWER(multiplelines), 'unknown') AS multiplelines,
  COALESCE(LOWER(internetservice), 'unknown') AS internetservice,
  COALESCE(LOWER(onlinesecurity), 'unknown') AS onlinesecurity,
  COALESCE(LOWER(onlinebackup), 'unknown') AS onlinebackup,
  COALESCE(LOWER(deviceprotection), 'unknown') AS deviceprotection,
  COALESCE(LOWER(techsupport), 'unknown') AS techsupport,
  COALESCE(LOWER(streamingtv), 'unknown') AS streamingtv,
  COALESCE(LOWER(streamingmovies), 'unknown') AS streamingmovies,
  COALESCE(LOWER(contract), 'unknown') AS contract,
  COALESCE(LOWER(paperlessbilling), 'unknown') AS paperlessbilling,
  COALESCE(LOWER(paymentmethod), 'unknown') AS paymentmethod,
  COALESCE(monthlycharges, 0) AS monthlycharges,
  COALESCE(totalcharges, 0) AS totalcharges,
  COALESCE(LOWER(churn), 'unknown') AS churn
FROM staging.telecom_raw;
