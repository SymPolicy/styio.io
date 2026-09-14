# Golden Standard Test Suite

**Purpose:** Define the styio.io website and release-root test level that makes public site changes submittable.

`test / smoke` builds the static site and runs the site smoke script.

`test / golden-standard` runs the site smoke script plus release-root validation, ensuring install docs, static assets, release index, and hosted tool entrypoints remain coherent.

## Local Gate Profile

`styio-io-release-root-site-profile` is the repository-owned adaptation for the public website and release root. It is maintained in this repository through release-root validation, release index checks, hosted tool entrypoints, and install docs. The organization-level audit only verifies that this local profile is present and covered by `test / golden-standard`.

Required local markers: repo-owned adaptation, release-root validation, release index, hosted tool entrypoints, install docs.

## Industry Gate Group

`website / release-root` is the role-specific gate group for the public website and release root. It keeps static site generation, release-root validation, install docs, release index, and hosted tool entrypoints grouped under `test / golden-standard`.

Required evidence markers: static site, release-root validation, install docs, release index, hosted tool entrypoints.

## Submit Readiness

A styio.io version is submittable only when `test / smoke` and `test / golden-standard` both pass.
