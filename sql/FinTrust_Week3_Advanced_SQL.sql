-- FinTrust Week 3 Advanced SQL Analysis

-- A1: Channel volume, value, average and value share
SELECT Channel,COUNT(*) transaction_count,ROUND(SUM(Amount_NGN),2) total_value_ngn,ROUND(AVG(Amount_NGN),2) avg_value_ngn,ROUND(100.0*SUM(Amount_NGN)/(SELECT SUM(Amount_NGN) FROM transactions),1) value_share_pct FROM transactions GROUP BY Channel ORDER BY total_value_ngn DESC;

-- A2: Transaction type value ranking
WITH s AS (SELECT Transaction_Type,COUNT(*) transaction_count,ROUND(SUM(Amount_NGN),2) total_value_ngn,ROUND(AVG(Amount_NGN),2) avg_value_ngn FROM transactions GROUP BY Transaction_Type) SELECT *,RANK() OVER(ORDER BY total_value_ngn DESC) value_rank FROM s ORDER BY value_rank;

-- A3: Amount-band distribution
WITH b AS (SELECT CASE WHEN Amount_NGN<1000 THEN '<₦1k' WHEN Amount_NGN<5000 THEN '₦1k–₦5k' WHEN Amount_NGN<10000 THEN '₦5k–₦10k' WHEN Amount_NGN<50000 THEN '₦10k–₦50k' ELSE '>₦50k' END amount_band,Amount_NGN FROM transactions) SELECT amount_band,COUNT(*) transaction_count,ROUND(SUM(Amount_NGN),2) total_value_ngn,ROUND(100.0*SUM(Amount_NGN)/(SELECT SUM(Amount_NGN) FROM transactions),1) value_share_pct FROM b GROUP BY amount_band;

-- A4: IQR high-value transactions
SELECT Transaction_ID,Customer_ID,Transaction_Type,Channel,ROUND(Amount_NGN,2) amount_ngn FROM transactions WHERE Amount_NGN>53278.94 ORDER BY Amount_NGN DESC;

-- A5: Cumulative value concentration
WITH r AS (SELECT Transaction_ID,Amount_NGN,SUM(Amount_NGN) OVER(ORDER BY Amount_NGN DESC ROWS UNBOUNDED PRECEDING) cumulative_value,SUM(Amount_NGN) OVER() total_value,ROW_NUMBER() OVER(ORDER BY Amount_NGN DESC) value_rank FROM transactions) SELECT value_rank,Transaction_ID,ROUND(Amount_NGN,2) amount_ngn,ROUND(100.0*cumulative_value/total_value,1) cumulative_value_share_pct FROM r ORDER BY value_rank;

-- A6: Hourly value and volume ranking
WITH h AS (SELECT CAST(strftime('%H',Transaction_DateTime) AS INTEGER) hour,COUNT(*) transaction_count,SUM(Amount_NGN) total_value_ngn FROM transactions GROUP BY hour) SELECT hour,transaction_count,ROUND(total_value_ngn,2) total_value_ngn,RANK() OVER(ORDER BY total_value_ngn DESC) value_rank,RANK() OVER(ORDER BY transaction_count DESC) volume_rank FROM h ORDER BY hour;

-- A7: Customer key integrity
SELECT COUNT(*) total_transactions,SUM(CASE WHEN c.Customer_ID IS NOT NULL THEN 1 ELSE 0 END) matched_transactions,SUM(CASE WHEN c.Customer_ID IS NULL THEN 1 ELSE 0 END) unmatched_transactions,ROUND(100.0*SUM(CASE WHEN c.Customer_ID IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*),1) match_rate_pct FROM transactions t LEFT JOIN customers c ON t.Customer_ID=c.Customer_ID;

-- A8: Date coverage
SELECT DATE(Transaction_DateTime) transaction_date,COUNT(*) transaction_count,ROUND(SUM(Amount_NGN),2) total_value_ngn FROM transactions GROUP BY DATE(Transaction_DateTime);

-- A9: Channel/type value combinations
SELECT Channel,Transaction_Type,COUNT(*) transaction_count,ROUND(SUM(Amount_NGN),2) total_value_ngn,ROUND(AVG(Amount_NGN),2) avg_value_ngn FROM transactions GROUP BY Channel,Transaction_Type ORDER BY total_value_ngn DESC;

-- A10: Transaction-field completeness
SELECT COUNT(*) total_rows,SUM(CASE WHEN Transaction_ID IS NULL OR TRIM(Transaction_ID)='' THEN 1 ELSE 0 END) missing_transaction_id,SUM(CASE WHEN Customer_ID IS NULL OR TRIM(Customer_ID)='' THEN 1 ELSE 0 END) missing_customer_id,SUM(CASE WHEN Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime)='' THEN 1 ELSE 0 END) missing_datetime,SUM(CASE WHEN Transaction_Type IS NULL OR TRIM(Transaction_Type)='' THEN 1 ELSE 0 END) missing_transaction_type,SUM(CASE WHEN Amount_NGN IS NULL THEN 1 ELSE 0 END) missing_amount,SUM(CASE WHEN Channel IS NULL OR TRIM(Channel)='' THEN 1 ELSE 0 END) missing_channel FROM transactions;
