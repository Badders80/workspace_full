#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import json
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path


@dataclass(frozen=True)
class Source:
    key: str
    root: Path
    note: str


@dataclass(frozen=True)
class FileRecord:
    source: str
    root: str
    rel_path: str
    file_name: str
    size_bytes: int
    sha256: str
    bucket: str


WORKSPACE_ROOT = Path("/home/evo/workspace")
REPORT_ROOT = (
    WORKSPACE_ROOT / "projects" / "Evolution_Content" / "assets" / "library" / "_reports"
)

SOURCES = (
    Source(
        key="raw_bundle",
        root=WORKSPACE_ROOT
        / "projects"
        / "Evolution_Content"
        / "assets"
        / "library"
        / "originals",
        note="Recovered source bundle re-homed into the workspace library.",
    ),
    Source(
        key="content_factory_assets",
        root=Path("/mnt/s/Evolution-Content-Factory/assets"),
        note="Structured working library for content generation and horse media.",
    ),
    Source(
        key="platform_public_images",
        root=WORKSPACE_ROOT
        / "projects"
        / "Evolution_Platform"
        / "public"
        / "images",
        note="Live platform image/public asset copy.",
    ),
)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def iter_records() -> list[FileRecord]:
    records: list[FileRecord] = []
    for source in SOURCES:
        for path in sorted(source.root.rglob("*")):
            if not path.is_file():
                continue
            rel_path = path.relative_to(source.root).as_posix()
            bucket = rel_path.split("/", 1)[0]
            records.append(
                FileRecord(
                    source=source.key,
                    root=str(source.root),
                    rel_path=rel_path,
                    file_name=path.name,
                    size_bytes=path.stat().st_size,
                    sha256=sha256_file(path),
                    bucket=bucket,
                )
            )
    return records


def canonical_rank(record: FileRecord) -> tuple[int, str, str]:
    if record.source == "raw_bundle":
        if record.rel_path.startswith("Originals_DropBox/"):
            return (0, record.source, record.rel_path.lower())
        if record.rel_path.startswith("Website_Assets/"):
            return (1, record.source, record.rel_path.lower())
        if record.rel_path.startswith("press/"):
            return (2, record.source, record.rel_path.lower())
        if record.rel_path.startswith("Keep/"):
            return (3, record.source, record.rel_path.lower())
        return (9, record.source, record.rel_path.lower())
    if record.source == "content_factory_assets":
        if record.rel_path.startswith("brand/"):
            return (4, record.source, record.rel_path.lower())
        if record.rel_path.startswith("horses/"):
            return (5, record.source, record.rel_path.lower())
        if record.rel_path.startswith("overlays/"):
            return (6, record.source, record.rel_path.lower())
        if record.rel_path.startswith("templates/"):
            return (7, record.source, record.rel_path.lower())
        return (8, record.source, record.rel_path.lower())
    return (10, record.source, record.rel_path.lower())


def write_tsv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    REPORT_ROOT.mkdir(parents=True, exist_ok=True)

    records = iter_records()
    records_by_sha: dict[str, list[FileRecord]] = defaultdict(list)
    records_by_name: dict[str, list[FileRecord]] = defaultdict(list)
    for record in records:
        records_by_sha[record.sha256].append(record)
        records_by_name[record.file_name.lower()].append(record)

    count_by_source = Counter(record.source for record in records)
    unique_by_source = Counter()
    shared_groups_by_source = Counter()
    for sha256, sha_records in records_by_sha.items():
        sources_present = {record.source for record in sha_records}
        if len(sources_present) == 1:
            unique_by_source[next(iter(sources_present))] += len(sha_records)
        else:
            for source in sources_present:
                shared_groups_by_source[source] += 1

    inventory_rows = [asdict(record) for record in records]
    write_tsv(
        REPORT_ROOT / "inventory.tsv",
        [
            "source",
            "root",
            "rel_path",
            "file_name",
            "size_bytes",
            "sha256",
            "bucket",
        ],
        inventory_rows,
    )

    asset_map_rows: list[dict[str, object]] = []
    unique_rows: list[dict[str, object]] = []
    for sha256 in sorted(records_by_sha):
        sha_records = sorted(
            records_by_sha[sha256],
            key=lambda record: (record.source, record.rel_path.lower()),
        )
        canonical = min(sha_records, key=canonical_rank)
        sources_present = sorted({record.source for record in sha_records})
        locations = " | ".join(
            f"{record.source}:{record.rel_path}" for record in sha_records
        )
        row = {
            "sha256": sha256,
            "size_bytes": canonical.size_bytes,
            "occurrence_count": len(sha_records),
            "source_count": len(sources_present),
            "canonical_source": canonical.source,
            "canonical_rel_path": canonical.rel_path,
            "canonical_bucket": canonical.bucket,
            "sources_present": ",".join(sources_present),
            "locations": locations,
        }
        asset_map_rows.append(row)
        if len(sources_present) == 1:
            unique_rows.append(row)

    write_tsv(
        REPORT_ROOT / "asset_map.tsv",
        [
            "sha256",
            "size_bytes",
            "occurrence_count",
            "source_count",
            "canonical_source",
            "canonical_rel_path",
            "canonical_bucket",
            "sources_present",
            "locations",
        ],
        asset_map_rows,
    )

    write_tsv(
        REPORT_ROOT / "unique_by_source.tsv",
        [
            "sha256",
            "size_bytes",
            "occurrence_count",
            "source_count",
            "canonical_source",
            "canonical_rel_path",
            "canonical_bucket",
            "sources_present",
            "locations",
        ],
        unique_rows,
    )

    collision_rows: list[dict[str, object]] = []
    for file_name in sorted(records_by_name):
        name_records = records_by_name[file_name]
        sources_present = {record.source for record in name_records}
        hashes_present = {record.sha256 for record in name_records}
        if len(sources_present) > 1 and len(hashes_present) > 1:
            collision_rows.append(
                {
                    "file_name": file_name,
                    "distinct_hashes": len(hashes_present),
                    "sources_present": ",".join(sorted(sources_present)),
                    "locations": " | ".join(
                        f"{record.source}:{record.rel_path}:{record.sha256[:12]}"
                        for record in sorted(
                            name_records,
                            key=lambda record: (record.source, record.rel_path.lower()),
                        )
                    ),
                }
            )

    write_tsv(
        REPORT_ROOT / "name_collisions.tsv",
        ["file_name", "distinct_hashes", "sources_present", "locations"],
        collision_rows,
    )

    source_rows = []
    source_lookup = {source.key: source for source in SOURCES}
    for source_key in sorted(source_lookup):
        total_files = count_by_source[source_key]
        unique_files = unique_by_source[source_key]
        source_rows.append(
            {
                "source": source_key,
                "root": str(source_lookup[source_key].root),
                "note": source_lookup[source_key].note,
                "total_files": total_files,
                "unique_files": unique_files,
                "shared_files": total_files - unique_files,
                "shared_hash_groups": shared_groups_by_source[source_key],
            }
        )

    write_tsv(
        REPORT_ROOT / "source_summary.tsv",
        [
            "source",
            "root",
            "note",
            "total_files",
            "unique_files",
            "shared_files",
            "shared_hash_groups",
        ],
        source_rows,
    )

    summary = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_count": len(SOURCES),
        "file_count": len(records),
        "unique_hash_count": len(records_by_sha),
        "name_collision_count": len(collision_rows),
        "sources": source_rows,
        "pairwise_shared_hash_groups": {
            "raw_bundle__content_factory_assets": sum(
                1
                for sha_records in records_by_sha.values()
                if {"raw_bundle", "content_factory_assets"}
                <= {record.source for record in sha_records}
            ),
            "raw_bundle__platform_public_images": sum(
                1
                for sha_records in records_by_sha.values()
                if {"raw_bundle", "platform_public_images"}
                <= {record.source for record in sha_records}
            ),
            "content_factory_assets__platform_public_images": sum(
                1
                for sha_records in records_by_sha.values()
                if {"content_factory_assets", "platform_public_images"}
                <= {record.source for record in sha_records}
            ),
        },
    }
    with (REPORT_ROOT / "summary.json").open("w", encoding="utf-8") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
        handle.write("\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
