-- ============================================================================
-- guidewire_metrics.sql
-- Core P&C insurance KPIs on the Guidewire-modeled datasets:
--   pc_policy, cc_claim, cc_transaction
-- Written for PostgreSQL.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. LOSS RATIO (overall)
--    Loss Ratio = total Loss Payments / total earned premium
-- ----------------------------------------------------------------------------
WITH loss_payments AS (
    SELECT SUM(t.amount) AS total_losses
    FROM cc_transaction t
    WHERE t.transaction_type = 'Loss Payment'
),
premiums AS (
    SELECT SUM(p.earned_premium) AS total_earned_premium
    FROM pc_policy p
)
SELECT
    ROUND(l.total_losses, 2)              AS total_loss_payments,
    ROUND(p.total_earned_premium, 2)      AS total_earned_premium,
    ROUND(
        l.total_losses / NULLIF(p.total_earned_premium, 0),
        4
    )                                   AS loss_ratio
FROM loss_payments l
CROSS JOIN premiums p;


-- ----------------------------------------------------------------------------
-- 2. LOSS RATIO BY POLICY TYPE
--    Aggregates per policy first to avoid double-counting earned premium
--    when the claim -> transaction join fans out.
-- ----------------------------------------------------------------------------
WITH policy_losses AS (
    SELECT
        p.policy_type,
        p.policy_id,
        p.earned_premium,
        SUM(CASE
                WHEN t.transaction_type = 'Loss Payment' THEN t.amount
                ELSE 0
            END) AS loss_payments
    FROM pc_policy p
    LEFT JOIN cc_claim c       ON c.policy_id = p.policy_id
    LEFT JOIN cc_transaction t ON t.claim_id  = c.claim_id
    GROUP BY p.policy_type, p.policy_id, p.earned_premium
)
SELECT
    policy_type,
    COUNT(*)                                   AS policy_count,
    ROUND(SUM(earned_premium), 2)               AS total_earned_premium,
    ROUND(SUM(loss_payments), 2)               AS total_loss_payments,
    ROUND(
        SUM(loss_payments) / NULLIF(SUM(earned_premium), 0),
        4
    )                                          AS loss_ratio
FROM policy_losses
GROUP BY policy_type
ORDER BY loss_ratio DESC;


-- ----------------------------------------------------------------------------
-- 3. CLAIM SEVERITY BY CLAIM TYPE
--    Severity = average loss payment amount per claim
-- ----------------------------------------------------------------------------
WITH claim_losses AS (
    SELECT
        c.claim_id,
        c.claim_type,
        SUM(CASE
                WHEN t.transaction_type = 'Loss Payment' THEN t.amount
                ELSE 0
            END) AS loss_amount
    FROM cc_claim c
    LEFT JOIN cc_transaction t ON t.claim_id = c.claim_id
    GROUP BY c.claim_id, c.claim_type
)
SELECT
    claim_type,
    COUNT(*)                 AS claim_count,
    ROUND(AVG(loss_amount), 2) AS avg_severity,
    ROUND(MIN(loss_amount), 2) AS min_severity,
    ROUND(MAX(loss_amount), 2) AS max_severity
FROM claim_losses
GROUP BY claim_type
ORDER BY avg_severity DESC;


-- ----------------------------------------------------------------------------
-- 4. CLAIM CYCLE TIME (closed claims only)
--    Cycle Time = average days from reported_date to close_date
-- ----------------------------------------------------------------------------
SELECT
    claim_type,
    COUNT(*) AS closed_claim_count,
    ROUND(
        AVG((close_date::date - reported_date::date)),
        1
    ) AS avg_cycle_time_days,
    ROUND(
        MIN((close_date::date - reported_date::date)),
        1
    ) AS min_cycle_time_days,
    ROUND(
        MAX((close_date::date - reported_date::date)),
        1
    ) AS max_cycle_time_days
FROM cc_claim
WHERE claim_status = 'Closed'
  AND close_date IS NOT NULL
GROUP BY claim_type
ORDER BY avg_cycle_time_days DESC;


-- ----------------------------------------------------------------------------
-- 5. OVERALL CLAIM CYCLE TIME (single portfolio number)
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*) AS closed_claim_count,
    ROUND(
        AVG((close_date::date - reported_date::date)),
        1
    ) AS avg_cycle_time_days
FROM cc_claim
WHERE claim_status = 'Closed'
  AND close_date IS NOT NULL;
