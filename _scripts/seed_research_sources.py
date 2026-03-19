#!/usr/bin/env python3
import json
import html
import re
from collections import OrderedDict
from datetime import UTC, datetime, timedelta
from html.parser import HTMLParser
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urlparse
from xml.etree import ElementTree as ET

import requests


WORKSPACE_ROOT = Path("/home/evo/workspace")
VAULT_ROOT = WORKSPACE_ROOT / "_sandbox" / "research_vault"
SOURCES_ROOT = VAULT_ROOT / "01_Sources"
CUTOFF = datetime.now(UTC) - timedelta(days=183)
HEADERS = {"User-Agent": "Mozilla/5.0 (Research Vault Seeder)"}


class TextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._skip = False
        self.parts: List[str] = []

    def handle_starttag(self, tag: str, attrs) -> None:
        if tag in {"script", "style", "noscript"}:
            self._skip = True

    def handle_endtag(self, tag: str) -> None:
        if tag in {"script", "style", "noscript"}:
            self._skip = False

    def handle_data(self, data: str) -> None:
        if not self._skip:
            cleaned = " ".join(data.split())
            if cleaned:
                self.parts.append(cleaned)


def iso_now() -> str:
    return datetime.now(UTC).replace(microsecond=0).isoformat()


def parse_dt(value: str) -> Optional[datetime]:
    if not value:
        return None
    for candidate in [value.strip(), value.strip().replace("Z", "+00:00"), value.strip().replace("+0000", "+00:00")]:
        try:
            return datetime.fromisoformat(candidate)
        except ValueError:
            continue
    return None


def slugify(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-") or "item"


def fetch(url: str) -> requests.Response:
    response = requests.get(url, headers=HEADERS, timeout=30)
    response.raise_for_status()
    return response


def meta_content(html: str, names: List[str]) -> str:
    patterns = []
    for name in names:
        patterns.append(rf'<meta[^>]+name="{re.escape(name)}"[^>]+content="([^"]*)"')
        patterns.append(rf'<meta[^>]+property="{re.escape(name)}"[^>]+content="([^"]*)"')
    for pattern in patterns:
        match = re.search(pattern, html, flags=re.IGNORECASE)
        if match:
            return html_unescape(match.group(1).strip())
    return ""


def title_from_html(html: str) -> str:
    match = re.search(r"<title>(.*?)</title>", html, flags=re.IGNORECASE | re.DOTALL)
    return html_unescape(" ".join(match.group(1).split())) if match else ""


def html_unescape(value: str) -> str:
    return html.unescape(value)


def humanize_slug(value: str) -> str:
    return " ".join(part.capitalize() for part in value.replace("-", " ").split())


def excerpt_from_html(html: str, limit: int = 900) -> str:
    parser = TextExtractor()
    parser.feed(html)
    text = " ".join(parser.parts)
    text = re.sub(r"\s+", " ", text).strip()
    return text[:limit]


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def context_chain() -> str:
    return (
        "## Context Chain\n"
        "<- inherits from: /home/evo/workspace/AGENTS.md\n"
        "-> overrides by: none\n"
        "-> live map: /home/evo/workspace/AI_SESSION_BOOTSTRAP.md\n"
        "-> conventions: /home/evo/workspace/DNA/ops/CONVENTIONS.md\n"
    )


def write_markdown(path: Path, content: str) -> None:
    ensure_dir(path.parent)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def write_json(path: Path, payload: Dict) -> None:
    ensure_dir(path.parent)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=True) + "\n", encoding="utf-8")


def seed_tokinvest_website() -> Dict:
    root = SOURCES_ROOT / "tokinvest_capital"
    ensure_dir(root)

    listing_html = fetch("https://tokinvest.capital/insights-and-news").text
    article_matches = re.findall(
        r'first_publication_date\\":\\"([^"]+)\\",\\"last_publication_date\\":\\"([^"]+)\\",\\"uid\\":\\"([^"]+)\\"',
        listing_html,
    )

    articles: "OrderedDict[str, Dict]" = OrderedDict()
    for first_published, last_published, uid in article_matches:
        published_dt = parse_dt(first_published)
        if published_dt is None or published_dt < CUTOFF:
            continue
        articles[uid] = {
            "uid": uid,
            "published_at": published_dt.isoformat(),
            "updated_at": parse_dt(last_published).isoformat() if parse_dt(last_published) else "",
            "url": f"https://tokinvest.capital/insights-and-news/{uid}",
        }

    enriched = []
    for article in articles.values():
        html = fetch(article["url"]).text
        article["title"] = (
            meta_content(html, ["og:title", "twitter:title"])
            or title_from_html(html)
            or humanize_slug(article["uid"])
        )
        article["description"] = meta_content(html, ["description", "og:description"])
        article["excerpt"] = excerpt_from_html(html)
        enriched.append(article)

    enriched.sort(key=lambda item: item["published_at"], reverse=True)
    write_json(
        root / "website_capture.json",
        {
            "source": "tokinvest_capital",
            "captured_at": iso_now(),
            "cutoff": CUTOFF.isoformat(),
            "items": enriched,
        },
    )

    bullets = "\n".join(
        f"- `{item['published_at'][:10]}` [{item['title']}]({item['url']})"
        for item in enriched
    ) or "- No articles found in the current six-month window."

    note = f"""# Tokinvest Capital - Last 6 Months

---
note_type: source_profile
status: normalized
source_type: website
source_title: Tokinvest Insights and News
source_url: https://tokinvest.capital/insights-and-news
author:
captured_at: {iso_now()}
published_at:
entities:
  - Tokinvest
topics:
  - rwa
  - investor-relations
confidence: 0.8
review_roles:
  - CEO
  - CTO
tags:
  - rwa
  - investor-relations
promotion_candidate: false
---

## Summary

Seeded the last six months of Tokinvest website content from the public Insights and News surface.

## Item Count

- {len(enriched)} articles captured since {CUTOFF.date().isoformat()}

## Captured Items

{bullets}

## Raw Capture

- `website_capture.json`

{context_chain()}"""
    write_markdown(root / "last-6-months.md", note)
    return {"source": "tokinvest_capital", "items": len(enriched)}


def seed_evolution_website() -> Dict:
    root = SOURCES_ROOT / "evolutionstables_website"
    ensure_dir(root)

    xml = fetch("https://www.evolutionstables.nz/sitemap.xml").text
    namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    tree = ET.fromstring(xml)

    items = []
    for url_node in tree.findall("sm:url", namespace):
        loc = url_node.findtext("sm:loc", default="", namespaces=namespace)
        lastmod = url_node.findtext("sm:lastmod", default="", namespaces=namespace)
        lastmod_dt = parse_dt(lastmod)
        if not loc or lastmod_dt is None or lastmod_dt < CUTOFF:
            continue

        html = fetch(loc).text
        items.append(
            {
                "url": loc,
                "lastmod": lastmod_dt.isoformat(),
                "title": meta_content(html, ["og:title", "twitter:title"]) or title_from_html(html) or humanize_slug(urlparse(loc).path or "home"),
                "description": meta_content(html, ["description", "og:description"]),
                "excerpt": excerpt_from_html(html),
            }
        )

    items.sort(key=lambda item: item["lastmod"], reverse=True)
    write_json(
        root / "website_capture.json",
        {
            "source": "evolutionstables_website",
            "captured_at": iso_now(),
            "cutoff": CUTOFF.isoformat(),
            "items": items,
        },
    )

    bullets = "\n".join(
        f"- `{item['lastmod'][:10]}` [{item['title']}]({item['url']})"
        for item in items
    ) or "- No pages found in the current six-month window."

    note = f"""# Evolution Stables Website - Last 6 Months

---
note_type: source_profile
status: normalized
source_type: website
source_title: Evolution Stables Website
source_url: https://www.evolutionstables.nz
author:
captured_at: {iso_now()}
published_at:
entities:
  - Evolution Stables
topics:
  - racehorse-ownership
  - investor-relations
confidence: 0.8
review_roles:
  - CEO
  - CTO
tags:
  - racehorse-ownership
  - investor-relations
promotion_candidate: false
---

## Summary

Seeded the last six months of publicly exposed Evolution Stables website pages from the live sitemap.

## Item Count

- {len(items)} pages captured since {CUTOFF.date().isoformat()}

## Captured Pages

{bullets}

## Raw Capture

- `website_capture.json`

{context_chain()}"""
    write_markdown(root / "last-6-months.md", note)
    return {"source": "evolutionstables_website", "items": len(items)}


def seed_profile_note(folder_name: str, title: str, url: str, entities: List[str], topics: List[str], note_text: str) -> Dict:
    root = SOURCES_ROOT / folder_name
    ensure_dir(root)

    status = "seeded_profile_only"
    description = ""
    page_title = ""
    response_status = None
    try:
        response = requests.get(url, headers=HEADERS, timeout=30)
        response_status = response.status_code
        if response.ok:
            page_title = title_from_html(response.text)
            description = meta_content(response.text, ["description", "og:description"])
    except requests.RequestException:
        pass

    payload = {
        "source": folder_name,
        "captured_at": iso_now(),
        "url": url,
        "http_status": response_status,
        "page_title": page_title,
        "description": description,
        "mode": status,
    }
    write_json(root / "capture.json", payload)

    topics_block = "\n".join(f"  - {topic}" for topic in topics)
    entities_block = "\n".join(f"  - {entity}" for entity in entities)
    tags_block = "\n".join(f"  - {topic}" for topic in topics[:2]) or "  - research-layer"

    note = f"""# {title} - Source Profile

---
note_type: source_profile
status: {status}
source_type: social
source_title: {title}
source_url: {url}
author:
captured_at: {iso_now()}
published_at:
entities:
{entities_block}
topics:
{topics_block}
confidence: 0.5
review_roles:
  - CEO
  - CTO
tags:
{tags_block}
promotion_candidate: false
---

## Summary

{note_text}

## Capture Status

- URL: {url}
- HTTP status: {response_status if response_status is not None else "unavailable"}
- Page title: {page_title or "not captured"}

## Raw Capture

- `capture.json`

{context_chain()}"""
    write_markdown(root / "source-profile.md", note)
    return {"source": folder_name, "items": 1}


def main() -> None:
    ensure_dir(SOURCES_ROOT)
    results = [
        seed_tokinvest_website(),
        seed_evolution_website(),
        seed_profile_note(
            "tokinvest_cap_x",
            "Tokinvest X",
            "https://x.com/Tokinvest_Cap",
            ["Tokinvest"],
            ["rwa", "investor-relations"],
            "Seeded the public Tokinvest X profile as a source surface. Timeline-level ingestion still needs a stronger social crawler path.",
        ),
        seed_profile_note(
            "evolutionstable_x",
            "Evolution Stable X",
            "https://x.com/EvolutionStable",
            ["Evolution Stables"],
            ["racehorse-ownership", "investor-relations"],
            "Seeded the public Evolution X profile as a source surface. Timeline-level ingestion still needs a stronger social crawler path.",
        ),
        seed_profile_note(
            "alex-baddeley_linkedin",
            "Alex Baddeley LinkedIn",
            "https://www.linkedin.com/in/alex-baddeley/",
            ["Alex Baddeley", "Evolution Stables"],
            ["investor-relations", "competitor"],
            "Seeded the public LinkedIn profile as a source surface. Richer extraction may require login or a dedicated LinkedIn-safe workflow later.",
        ),
        seed_profile_note(
            "evolution_linkedin_admin",
            "Evolution LinkedIn Admin Dashboard",
            "https://www.linkedin.com/company/104844946/admin/dashboard/",
            ["Evolution Stables"],
            ["investor-relations"],
            "Seeded the company LinkedIn admin URL as a tracked source surface. This is expected to be private or login-gated, so the first pass stores only the source reference and capture status.",
        ),
    ]

    write_json(
        SOURCES_ROOT / "research_seed_manifest.json",
        {
            "captured_at": iso_now(),
            "cutoff": CUTOFF.isoformat(),
            "results": results,
        },
    )


if __name__ == "__main__":
    main()
