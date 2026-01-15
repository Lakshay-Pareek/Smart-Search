from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import search, documents, history, profile
from .db.database import engine
from .db.models import Base, Document, Profile as ProfileModel
from .services.search_engine import get_search_engine, IndexedDocument, Trie


def create_app() -> FastAPI:
  app = FastAPI(
      title="Smart Document Search Engine API",
      version="0.1.0",
  )

  @app.on_event("startup")
  def _startup() -> None:
    # Create tables
    Base.metadata.create_all(bind=engine)

    # Seed initial documents + profile (only if DB empty)
    from sqlalchemy.orm import Session
    from .db.database import SessionLocal

    db: Session = SessionLocal()
    try:
      # Seed profile
      if db.get(ProfileModel, 1) is None:
        db.add(
            ProfileModel(
                id=1,
                name="Jane Doe",
                email="jane.doe@example.com",
                role="Researcher",
                autocomplete=True,
                spell_correction=True,
                default_sort="balanced",
                use_local_cache=True,
                indexed_local_docs=132_450,
            )
        )
        db.commit()

      # Seed documents
      doc_count = db.query(Document).count()
      if doc_count == 0:
        seed_docs = [
            Document(
                title="Q4 2023 Financial Report – Consolidated Results",
                content=(
                    "This report summarizes the revenue growth and operating margin for Q4 2023 "
                    "with special focus on contracts signed in 2023 and projected cash flow."
                ),
                document_type="pdf",
                source="finance",
                path="Finance / Quarterly reports",
                updated_at="2024-01-12",
            ),
            Document(
                title="KMP Algorithm Notes – String Matching in O(n + m)",
                content=(
                    "The Knuth‑Morris‑Pratt (KMP) algorithm improves naive pattern matching by "
                    "precomputing a longest prefix‑suffix table. It runs in O(n + m) time."
                ),
                document_type="doc",
                source="research",
                path="Research / IR",
                updated_at="2023-11-03",
            ),
            Document(
                title="Edit Distance and Spell Correction using Dynamic Programming",
                content=(
                    "We implement Levenshtein edit distance using dynamic programming to suggest "
                    "spell corrections for user queries based on minimal character edits."
                ),
                document_type="md",
                source="research",
                path="Research / Algorithms",
                updated_at="2023-10-21",
            ),
        ]
        db.add_all(seed_docs)
        db.commit()

      # Sync DB docs into search engine index
      engine_service = get_search_engine()
      engine_service.documents.clear()
      engine_service.inverted_index.clear()
      engine_service.doc_freq.clear()
      engine_service.trie = Trie()

      for d in db.query(Document).all():
        engine_service.add_document(
            IndexedDocument(
                id=str(d.id),
                title=d.title,
                content=d.content,
                document_type=d.document_type,
                source=d.source,
                updated_at=d.updated_at,
            )
        )
    finally:
      db.close()

  app.add_middleware(
      CORSMiddleware,
      allow_origins=["*"],
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"],
  )

  app.include_router(search.router, prefix="/search", tags=["search"])
  app.include_router(documents.router, prefix="/documents", tags=["documents"])
  app.include_router(history.router, prefix="/history", tags=["history"])
  app.include_router(profile.router, prefix="/profile", tags=["profile"])

  return app


app = create_app()

