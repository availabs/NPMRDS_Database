BEGIN;

DROP FUNCTION IF EXISTS lottr_percentiles_rankings_fn (_t text, year INT, month INT, startRank INT, endRank INT);

COMMIT;
