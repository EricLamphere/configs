"""Tests for add_meeting.py. Run: python3 -m pytest test_add_meeting.py"""

from datetime import date
from pathlib import Path

import pytest

import add_meeting as am

TEMPLATE = "# ToDo\n### Priority\n* [ ] \n\n---\n# Notes\n"
DAY = date(2026, 11, 9)


def spec(**overrides):
    base = {
        "date": DAY.isoformat(),
        "title": "Weekly Sync",
        "source_id": 7,
        "when": "2026-11-09 14:00:00",
        "who": ["Sarah"],
        "topics": [{"heading": "Budget", "bullets": ["Q1 is on track", {"text": "Hiring", "children": ["two roles"]}]}],
        "next_steps": [{"text": "Send the deck", "details": ["to Sarah by Friday"]}],
    }
    return am.parse_spec({**base, **overrides})


@pytest.fixture
def vault(tmp_path: Path) -> Path:
    template = tmp_path / am.TEMPLATE_PATH
    template.parent.mkdir(parents=True)
    template.write_text(TEMPLATE)
    return tmp_path


def note(vault: Path) -> Path:
    return am.daily_note_path(vault, DAY)


def test_daily_note_path_format(vault):
    assert note(vault) == vault / "journal/2026/11 - November/2026-11-09 Mon.md"


def test_creates_note_from_template_with_meetings_section(vault):
    result = am.run(spec(), vault, dry_run=False)
    text = note(vault).read_text()
    assert result["created_note"] is True
    assert text.startswith(TEMPLATE)
    assert text == TEMPLATE + (
        "\n## Meetings\n\n### Weekly Sync\n#meeting\n* When: 2026-11-09 14:00:00\n"
        "* Who: Eric, Sarah\n%% openwhispr-note: 7 %%\n\n"
        "#### Budget\n* Q1 is on track\n* Hiring\n\t* two roles\n"
        "#### Next Steps\n* Send the deck\n\t* to Sarah by Friday\n"
    )


def test_dry_run_writes_nothing(vault):
    result = am.run(spec(), vault, dry_run=True)
    assert result["status"] == "dry_run"
    assert not note(vault).exists()


def test_second_sync_is_skipped(vault):
    am.run(spec(), vault, dry_run=False)
    before = note(vault).read_text()
    assert am.run(spec(), vault, dry_run=False)["status"] == "already_synced"
    assert note(vault).read_text() == before


def test_second_meeting_goes_under_existing_meetings_heading(vault):
    am.run(spec(), vault, dry_run=False)
    am.run(spec(title="1:1 with Dan", source_id=8, who=["Dan"]), vault, dry_run=False)
    lines = note(vault).read_text().split("\n")
    assert lines.count("## Meetings") == 1
    assert lines.index("### Weekly Sync") < lines.index("### 1:1 with Dan")


def test_meetings_section_stays_before_later_level1_heading(vault):
    path = note(vault)
    path.parent.mkdir(parents=True)
    path.write_text(TEMPLATE + "### Errands\n* groceries\n# Later\n* keep me last\n")
    am.run(spec(), vault, dry_run=False)
    lines = path.read_text().split("\n")
    assert lines.index("* groceries") < lines.index("## Meetings") < lines.index("# Later")
    assert lines[-2:] == ["* keep me last", ""]


def test_merges_into_meeting_eric_already_started(vault):
    path = note(vault)
    path.parent.mkdir(parents=True)
    mine = (
        TEMPLATE + "## Meetings\n### weekly sync\n#meeting\n* Who: Eric, Sarah\n\n"
        "#### Notes\n* my own note\n#### Next Steps\n* \n\n### Other\n* untouched\n"
    )
    path.write_text(mine)
    result = am.run(spec(), vault, dry_run=False)
    text = path.read_text()
    assert result["merged_into_existing_section"] is True
    assert "* my own note" in text and "* untouched" in text
    lines = text.split("\n")
    assert lines.count("#### Next Steps") == 1
    assert lines.index("#### Budget") < lines.index("#### Next Steps")
    assert lines.index("* Send the deck") < lines.index("### Other")
    assert "%% openwhispr-note: 7 %%" in text
    assert "* " not in lines  # empty placeholder replaced


def test_merge_appends_to_matching_topic_without_duplicates(vault):
    path = note(vault)
    path.parent.mkdir(parents=True)
    path.write_text(TEMPLATE + "### Weekly Sync\n#### Budget\n* Q1 is on track\n")
    am.run(spec(next_steps=[]), vault, dry_run=False)
    lines = path.read_text().split("\n")
    assert lines.count("* Q1 is on track") == 1
    assert lines.count("#### Budget") == 1
    assert "* Hiring" in lines


def test_headings_inside_code_fences_are_ignored(vault):
    path = note(vault)
    path.parent.mkdir(parents=True)
    path.write_text(TEMPLATE + "```\n### Weekly Sync\n```\n")
    result = am.run(spec(), vault, dry_run=False)
    assert result["merged_into_existing_section"] is False
    assert "## Meetings" in path.read_text()


def test_safety_check_rejects_changed_lines():
    with pytest.raises(am.SafetyError):
        am.assert_only_added(["* keep", "* also"], ["* keep", "* changed"])
    am.assert_only_added(["a", "* ", "b"], ["a", "* new", "b"])


@pytest.mark.parametrize("bad", [
    {"title": ""},
    {"date": "11/09/2026"},
    {"topics": [], "next_steps": []},
    {"topics": [{"heading": "Next Steps", "bullets": ["x"]}]},
    {"source_id": "7"},
])
def test_invalid_specs_are_rejected(bad):
    with pytest.raises(am.SpecError):
        spec(**bad)
