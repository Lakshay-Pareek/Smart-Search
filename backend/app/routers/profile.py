from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..db.database import get_db
from ..db.models import Profile as ProfileModel

router = APIRouter()


class ProfileUpdate(BaseModel):
  autocomplete: bool | None = None
  spell_correction: bool | None = None
  default_sort: str | None = None
  use_local_cache: bool | None = None


@router.get("")
async def get_profile(db: Session = Depends(get_db)) -> dict:
  profile = db.get(ProfileModel, 1)
  if profile is None:
    profile = ProfileModel(id=1)
    db.add(profile)
    db.commit()
    db.refresh(profile)
  return {
      "name": profile.name,
      "email": profile.email,
      "role": profile.role,
      "preferences": {
          "autocomplete": profile.autocomplete,
          "spell_correction": profile.spell_correction,
          "default_sort": profile.default_sort,
      },
      "storage": {
          "use_local_cache": profile.use_local_cache,
          "indexed_local_docs": profile.indexed_local_docs,
      },
  }


@router.put("")
async def update_profile(
    payload: ProfileUpdate, db: Session = Depends(get_db)
) -> dict:
  profile = db.get(ProfileModel, 1)
  if profile is None:
    profile = ProfileModel(id=1)
    db.add(profile)

  if payload.autocomplete is not None:
    profile.autocomplete = payload.autocomplete
  if payload.spell_correction is not None:
    profile.spell_correction = payload.spell_correction
  if payload.default_sort is not None:
    profile.default_sort = payload.default_sort
  if payload.use_local_cache is not None:
    profile.use_local_cache = payload.use_local_cache

  db.commit()
  return {"ok": True}

