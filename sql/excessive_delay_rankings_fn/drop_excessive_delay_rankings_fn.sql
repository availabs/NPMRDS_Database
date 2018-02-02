BEGIN;

DROP FUNCTION IF EXISTS excessive_delay_rankings_fn (_t text, year INT, month INT, startRank INT, endRank INT);

COMMIT;
