-- @up
CREATE TABLE IF NOT EXISTS kn_sessions (
  id          TEXT PRIMARY KEY,
  goal        TEXT NOT NULL,
  repo_root   TEXT NOT NULL,
  turn        INTEGER NOT NULL DEFAULT 0,
  done        INTEGER NOT NULL DEFAULT 0,
  summary     TEXT,
  state       TEXT NOT NULL,
  created_at  TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at  TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_kn_sessions_done
  ON kn_sessions (done);

-- @down
DROP INDEX IF EXISTS idx_kn_sessions_done;
DROP TABLE IF EXISTS kn_sessions;
