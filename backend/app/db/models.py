from __future__ import annotations

from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
  pass


class Document(Base):
  __tablename__ = "documents"

  id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
  title: Mapped[str] = mapped_column(String(300), nullable=False)
  content: Mapped[str] = mapped_column(Text, nullable=False, default="")
  document_type: Mapped[str] = mapped_column(String(50), nullable=True)
  source: Mapped[str] = mapped_column(String(80), nullable=True)
  path: Mapped[str] = mapped_column(String(300), nullable=True)
  updated_at: Mapped[str] = mapped_column(String(30), nullable=True)


class History(Base):
  __tablename__ = "history"

  id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
  query: Mapped[str] = mapped_column(String(500), nullable=False)
  timestamp: Mapped[datetime] = mapped_column(
      DateTime(timezone=True), nullable=False, default=datetime.utcnow
  )
  results: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class Profile(Base):
  __tablename__ = "profile"

  # single-row profile for now; later tie to Firebase user uid
  id: Mapped[int] = mapped_column(Integer, primary_key=True)

  name: Mapped[str] = mapped_column(String(120), nullable=False, default="User")
  email: Mapped[str] = mapped_column(String(200), nullable=False, default="")
  role: Mapped[str] = mapped_column(String(60), nullable=False, default="User")

  autocomplete: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
  spell_correction: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
  default_sort: Mapped[str] = mapped_column(String(30), nullable=False, default="balanced")

  use_local_cache: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
  indexed_local_docs: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

