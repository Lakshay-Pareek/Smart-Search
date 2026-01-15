from typing import List, Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..db.database import get_db
from ..db.models import Document
from ..services.search_engine import IndexedDocument, get_search_engine

router = APIRouter()


class DocumentCreate(BaseModel):
  title: str = Field(..., min_length=1, max_length=300)
  content: str = Field("", max_length=200_000)
  document_type: Optional[str] = None
  source: Optional[str] = None
  path: Optional[str] = None
  updated_at: Optional[str] = None


@router.get("")
async def list_documents(db: Session = Depends(get_db)) -> List[dict]:
  docs = db.query(Document).order_by(Document.id.desc()).all()
  return [
      {
          "id": str(d.id),
          "title": d.title,
          "path": d.path or "",
          "source": d.source or "",
      }
      for d in docs
  ]


@router.post("")
async def create_document(
    payload: DocumentCreate, db: Session = Depends(get_db)
) -> dict:
  doc = Document(
      title=payload.title,
      content=payload.content,
      document_type=payload.document_type,
      source=payload.source,
      path=payload.path,
      updated_at=payload.updated_at,
  )
  db.add(doc)
  db.commit()
  db.refresh(doc)

  # add to search index immediately
  engine = get_search_engine()
  engine.add_document(
      IndexedDocument(
          id=str(doc.id),
          title=doc.title,
          content=doc.content,
          document_type=doc.document_type,
          source=doc.source,
          updated_at=doc.updated_at,
      )
  )

  return {"id": str(doc.id)}


@router.delete("/{document_id}")
async def delete_document(document_id: int, db: Session = Depends(get_db)) -> dict:
  doc = db.get(Document, document_id)
  if doc is None:
    return {"ok": False}
  db.delete(doc)
  db.commit()
  return {"ok": True}

