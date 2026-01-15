from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import List


@dataclass
class HistoryEntry:
  id: str
  query: str
  timestamp: str
  results: int


class InMemoryStore:
  """
  Temporary in-memory store so the UI feels "real" immediately.
  Later: replace with PostgreSQL + SQLite caching.
  """

  def __init__(self) -> None:
    self.history: List[HistoryEntry] = []

  def add_history(self, query: str, results: int) -> None:
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    entry = HistoryEntry(
        id=f"h{len(self.history) + 1}",
        query=query,
        timestamp=now,
        results=results,
    )
    # newest first
    self.history.insert(0, entry)


_store = InMemoryStore()


def get_store() -> InMemoryStore:
  return _store

