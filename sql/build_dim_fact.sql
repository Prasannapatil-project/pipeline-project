
DROP TABLE IF EXISTS analytics.dim_customers;
CREATE TABLE analytics.dim_customers AS
SELECT
  encode(digest(customerid || current_setting('app.hash_salt', true), 'sha256'), 'hex') AS customer_key,
  gender, partner, dependents, contract, paperlessbilling, paymentmethod
FROM analytics.clean_customers;

DROP TABLE IF EXISTS analytics.fact_churn_signals;
CREATE TABLE analytics.fact_churn_signals AS
SELECT
  encode(digest(customerid || current_setting('app.hash_salt', true), 'sha256'), 'hex') AS customer_key,
  tenure, monthlycharges, totalcharges,
  CASE WHEN churn IN ('yes','true','1') THEN 1 ELSE 0 END AS churned,
  internetservice, phoneservice, multiplelines, onlinesecurity, onlinebackup,
  deviceprotection, techsupport, streamingtv, streamingmovies
FROM analytics.clean_customers;
