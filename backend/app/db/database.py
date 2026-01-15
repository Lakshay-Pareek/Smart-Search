import os
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session


def _default_sqlite_url() -> str:
  # store DB file in backend/ so it persists across restarts
  return "sqlite:///./smart_search.db"


DATABASE_URL = os.getenv("DATABASE_URL", _default_sqlite_url())

# SQLite needs check_same_thread=False for multi-threaded FastAPI usage.
connect_args = {}
if DATABASE_URL.startswith("sqlite"):
  connect_args = {"check_same_thread": False}

engine = create_engine(DATABASE_URL, connect_args=connect_args, future=True)

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, future=True)


def get_db() -> Generator[Session, None, None]:
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()

