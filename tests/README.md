# Project checks

From the repository root, with Python 3.11+ and Rojo installed, run:

```sh
python3 tests/test_project_structure.py
```

On Windows, use `py -3` instead of `python3` if that is how Python is installed.
The checks use only Python's standard library; no `pip install` is needed.
They build a temporary Roblox place with the real Rojo tool, then inspect its
Explorer structure. They also check that source paths stay inside the repository,
that server and client folders have their own locations, and that development
documents are not copied into the game. Temporary files are removed afterward.

These are project/build checks, not Luau unit tests or gameplay tests. There is no
gameplay code yet. Once behavior is added, add appropriate behavior tests and a
documented Luau test runner here; do not replace these build checks with tests that
always pass. Follow `TEST_LOG.md` for the most recent recorded results.
