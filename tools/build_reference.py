"""
Regenerates training/course_reference.html from LEARNING.md.

Run from anywhere:
    python tools/build_reference.py

Whenever LEARNING.md changes (days added/reworded/renumbered), re-run
this to keep the HTML companion in sync, then re-publish the artifact
if you want the hosted version updated too.
"""
import re, html, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "LEARNING.md"
TEMPLATE = Path(__file__).resolve().parent / "template.html"
OUT = ROOT / "training" / "course_reference.html"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from flags_ref import render as render_flags  # noqa: E402

text = SRC.read_text(encoding="utf-8")
lines = text.split("\n")

# ---------- inline markdown -> html ----------
def inline(s):
    s = html.escape(s, quote=False)
    s = re.sub(r"`([^`]+)`", r'<code>\1</code>', s)
    s = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2" target="_blank" rel="noopener">\1</a>', s)
    s = re.sub(r"\*\*([^*]+)\*\*", r'<strong>\1</strong>', s)
    s = re.sub(r"(?<!\*)\*([^*\n]+)\*(?!\*)", r'<em>\1</em>', s)
    return s

LABELS = [
    ("Objective", "objective"),
    ("Do this", "do"),
    ("You should see", "see"),
    ("Decode it", "decode"),
    ("What's happening / why", "why"),
    ("In the real world", "real"),
    ("Apply it", "apply"),
    ("Optional", "optional"),
    ("Check yourself", "check"),
    ("Self-check", "selfcheck"),
    ("Talk-it-through-live exercise", "talk"),
    ("Come back and tell me", "comeback"),
    ("Go here", "gohere"),
    ("Important", "important"),
]

def match_label(line):
    stripped = line.strip()
    m = re.match(r"^\*\*([^*]+?)\*\*", stripped)
    if not m:
        return None
    label_text = m.group(1)
    for key, cls in LABELS:
        if key.lower() in label_text.lower():
            return cls, label_text, stripped[m.end():].strip()
    return None

def render_prose_block(block_lines):
    out = []
    i = 0
    para = []
    def flush_para():
        nonlocal para
        if para:
            joined = " ".join(p.strip() for p in para if p.strip())
            if joined:
                out.append(f"<p>{inline(joined)}</p>")
            para = []
    while i < len(block_lines):
        ln = block_lines[i]
        if ln.strip().startswith("```"):
            flush_para()
            lang = ln.strip()[3:].strip() or "text"
            code_lines = []
            i += 1
            while i < len(block_lines) and not block_lines[i].strip().startswith("```"):
                code_lines.append(block_lines[i])
                i += 1
            code = "\n".join(code_lines)
            out.append(
                f'<div class="term" data-lang="{html.escape(lang)}"><div class="term-bar"><span class="term-dot"></span><span class="term-dot"></span><span class="term-dot"></span><span class="term-lang">{html.escape(lang)}</span></div><pre><code>{html.escape(code)}</code></pre></div>'
            )
            i += 1
            continue
        if re.match(r"^\s*[-*]\s+", ln):
            flush_para()
            items = []
            while i < len(block_lines) and re.match(r"^\s*[-*]\s+", block_lines[i]):
                item_text = re.sub(r"^\s*[-*]\s+", "", block_lines[i])
                i += 1
                while (i < len(block_lines)
                       and block_lines[i].strip() != ""
                       and not re.match(r"^\s*[-*]\s+", block_lines[i])
                       and not block_lines[i].strip().startswith("```")
                       and not match_label(block_lines[i])
                       and block_lines[i].strip() != "---"):
                    item_text += " " + block_lines[i].strip()
                    i += 1
                items.append(item_text)
            out.append("<ul>" + "".join(f"<li>{inline(it)}</li>" for it in items) + "</ul>")
            continue
        if ln.strip() == "---":
            flush_para()
            i += 1
            continue
        if re.match(r"^\s*>\s?", ln):
            flush_para()
            quote_lines = []
            while i < len(block_lines) and re.match(r"^\s*>\s?", block_lines[i]):
                quote_lines.append(re.sub(r"^\s*>\s?", "", block_lines[i]))
                i += 1
            out.append(f'<blockquote>{inline(" ".join(quote_lines))}</blockquote>')
            continue
        if ln.strip() == "":
            flush_para()
            i += 1
            continue
        para.append(ln)
        i += 1
    flush_para()
    return "\n".join(out)

# ---------- split into weeks / days ----------
DAY_RE = re.compile(r"^## Day (\d+) — (.+?)(\s*\*\*\(host\)\*\*)?\s*$")
WEEK_RE = re.compile(r"^# Week (\d+) — (.+?)\s*$")
WEEKREVIEW_RE = re.compile(r"^## Week (\d+) Review")

weeks = []
cur_week = None
cur_day = None
mode = None

for ln in lines:
    mw = WEEK_RE.match(ln)
    md = DAY_RE.match(ln)
    mr = WEEKREVIEW_RE.match(ln)
    if mw:
        cur_week = {"num": int(mw.group(1)), "title": mw.group(2), "days": [], "review": None}
        weeks.append(cur_week)
        cur_day = None
        mode = None
        continue
    if md:
        cur_day = {"num": int(md.group(1)), "title": md.group(2).strip(), "host": bool(md.group(3)), "body": []}
        cur_week["days"].append(cur_day)
        mode = "day"
        continue
    if mr:
        cur_day = None
        mode = "review"
        cur_week["review"] = []
        continue
    if mode == "day" and cur_day is not None:
        cur_day["body"].append(ln)
    elif mode == "review" and cur_week is not None and cur_week["review"] is not None:
        cur_week["review"].append(ln)

FIELD_META = {
    "objective": ("Objective", "field-objective"),
    "do": ("Do this", "field-do"),
    "see": ("You should see", "field-see"),
    "decode": ("Decode it", "field-decode"),
    "why": ("What's happening / why", "field-why"),
    "real": ("In the real world", "field-real"),
    "apply": ("Apply it", "field-apply"),
    "optional": ("Optional", "field-optional"),
    "check": ("Check yourself", "field-check"),
    "selfcheck": ("Self-check", "field-selfcheck"),
    "talk": ("Talk it through live", "field-talk"),
    "comeback": ("Come back and tell me", "field-comeback"),
    "gohere": ("Go here", "field-gohere"),
    "important": ("Important", "field-important"),
}

def group_fields(body_lines):
    fields = []
    cur = None
    for ln in body_lines:
        lab = match_label(ln)
        if lab:
            cls, label_text, rest = lab
            cur = [cls, label_text, []]
            if rest:
                cur[2].append(rest)
            fields.append(cur)
        else:
            if cur is None:
                cur = ["note", "", []]
                fields.append(cur)
            cur[2].append(ln)
    return fields

def bandit_badge(text_lines):
    joined = " ".join(text_lines)
    nums = re.findall(r"[Ll]evels?\s+(\d+)(?:\s*(?:-|and|,|through)\s*(\d+))?", joined)
    if not nums:
        return None
    a, b = nums[0]
    return f"Bandit {a}–{b}" if b else f"Bandit {a}"

def render_day(day):
    fields = group_fields(day["body"])
    apply_badge = None
    parts = []
    for cls, label, body_lines in fields:
        rendered = render_prose_block(body_lines)
        if not rendered.strip():
            continue
        if cls == "apply":
            apply_badge = bandit_badge(body_lines)
        label_disp, css = FIELD_META.get(cls, (None, "field-note"))
        if cls == "note":
            parts.append(f'<div class="field {css}">{rendered}</div>')
        else:
            parts.append(f'<div class="field {css}"><div class="field-label">{html.escape(label_disp)}</div>{rendered}</div>')
    host_badge = '<span class="badge badge-host">host</span>' if day["host"] else '<span class="badge badge-container">container</span>'
    apply_html = f'<span class="badge badge-bandit">{html.escape(apply_badge)}</span>' if apply_badge else ""
    body_html = "\n".join(parts)
    return f'''<details class="day" id="day-{day['num']}">
  <summary>
    <span class="day-check"><input type="checkbox" class="daydone" data-day="{day['num']}" aria-label="Mark Day {day['num']} done"></span>
    <span class="day-num">Day {day['num']}</span>
    <span class="day-title">{inline(day['title'])}</span>
    <span class="day-badges">{host_badge}{apply_html}</span>
    <span class="chev" aria-hidden="true"></span>
  </summary>
  <div class="day-body">
    {body_html}
  </div>
</details>'''

def render_review(review_lines, week_num):
    if not review_lines:
        return ""
    rendered = render_prose_block(review_lines)
    return f'<div class="review"><div class="review-label">Week {week_num} review</div>{rendered}</div>'

week_html_parts = []
nav_parts = []
for w in weeks:
    nav_days = "".join(f'<a href="#day-{d["num"]}" class="nav-day"><span class="nav-daynum">{d["num"]}</span>{inline(d["title"])}</a>' for d in w["days"])
    nav_parts.append(f'<div class="nav-week"><div class="nav-week-title">Week {w["num"]} · {html.escape(w["title"])}</div>{nav_days}</div>')
    days_html = "\n".join(render_day(d) for d in w["days"])
    review_html = render_review(w["review"], w["num"])
    week_html_parts.append(f'''<section class="week" id="week-{w['num']}">
  <h2 class="week-title"><span class="week-eyebrow">Week {w['num']}</span>{inline(w['title'])}</h2>
  <div class="days">{days_html}</div>
  {review_html}
</section>''')

WEEKS_HTML = "\n".join(week_html_parts)
NAV_HTML = "\n".join(nav_parts)
TOTAL_DAYS = sum(len(w["days"]) for w in weeks)
FLAGS_HTML = render_flags()

def strip_tags(s):
    return html.unescape(re.sub(r"<[^>]+>", "", s))

week_meta = []
for w in weeks:
    week_meta.append((w["num"], strip_tags(w["title"]).strip(), len(w["days"])))

W, H = 980, 150
n = len(week_meta)
margin = 60
step = (W - 2 * margin) / (n - 1) if n > 1 else 0
cy = 78
svg_parts = [f'<svg viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Nine week roadmap">']
svg_parts.append(f'<line x1="{margin}" y1="{cy}" x2="{W-margin}" y2="{cy}" stroke="var(--border)" stroke-width="2" />')
for i, (num, title, count) in enumerate(week_meta):
    cx = margin + step * i
    above = (i % 2 == 0)
    label_y = cy - 26 if above else cy + 40
    count_y = cy - 10 if above else cy + 24
    r = 16 if num != n else 18
    fill = "var(--accent)" if num != n else "var(--host)"
    svg_parts.append(f'<circle cx="{cx:.1f}" cy="{cy}" r="{r}" fill="{fill}" opacity="0.16" />')
    svg_parts.append(f'<circle cx="{cx:.1f}" cy="{cy}" r="6" fill="{fill}" />')
    svg_parts.append(f'<text x="{cx:.1f}" y="{label_y}" text-anchor="middle" class="roadmap-node-label" fill="var(--text)" font-weight="700">W{num}</text>')
    svg_parts.append(f'<text x="{cx:.1f}" y="{label_y + 14}" text-anchor="middle" class="roadmap-node-label" fill="var(--text-dim)" font-size="9.5">{html.escape(title)}</text>')
    day_label = f"{count} day" + ("" if count == 1 else "s")
    svg_parts.append(f'<text x="{cx:.1f}" y="{count_y}" text-anchor="middle" class="roadmap-node-label" fill="{fill}" font-size="9.5">{day_label}</text>')
svg_parts.append('</svg>')
ROADMAP_SVG = "\n".join(svg_parts)

template = TEMPLATE.read_text(encoding="utf-8")
out = template
out = out.replace("__TOTAL__", str(TOTAL_DAYS))
out = out.replace("__NAV__", NAV_HTML)
out = out.replace("__ROADMAP__", ROADMAP_SVG)
out = out.replace("__WEEKS__", WEEKS_HTML)
out = out.replace("__FLAGS__", FLAGS_HTML)

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(out, encoding="utf-8")
print(f"Wrote {OUT} ({len(out)} chars, {TOTAL_DAYS} days across {len(weeks)} weeks)")
