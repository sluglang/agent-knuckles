-- @up
CREATE TABLE IF NOT EXISTS kn_turns (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  TEXT    NOT NULL REFERENCES kn_sessions(id),
  turn_num    INTEGER NOT NULL,
  role        TEXT    NOT NULL,
  content     TEXT    NOT NULL,
  created_at  TEXT    DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_kn_turns_session
  ON kn_turns (session_id, turn_num);

-- @down
DROP INDEX IF EXISTS idx_kn_turns_session;
DROP TABLE IF EXISTS kn_turns;
