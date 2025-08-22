
CREATE TABLE IF NOT EXISTS staging.telecom_raw (
  customerid TEXT,
  gender TEXT,
  tenure INTEGER,
  partner TEXT,
  dependents TEXT,
  phoneservice TEXT,
  multiplelines TEXT,
  internetservice TEXT,
  onlinesecurity TEXT,
  onlinebackup TEXT,
  deviceprotection TEXT,
  techsupport TEXT,
  streamingtv TEXT,
  streamingmovies TEXT,
  contract TEXT,
  paperlessbilling TEXT,
  paymentmethod TEXT,
  monthlycharges NUMERIC,
  totalcharges NUMERIC,
  churn TEXT
);
