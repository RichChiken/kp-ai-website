# KPS School Portal — Prototype

This project replaces the old K.P AI landing page with the KPS School Portal homepage. It includes a browser-only Lost & Found prototype, public approved notice board, staff review demo, and assembly announcement generator. K.P AI remains linked from the portal.

## Run locally

Open `index.html` in a browser, or use any static web server. No build step is required.

## Important: demo limitations

- Reports are saved in the current browser's `localStorage` only. They do not sync to other students' or teachers' devices.
- The staff dashboard is NOT protected by authentication. Anyone who can open the page can use it.
- Do not use this demo to collect real student personal information or publish it as a live school system.
- Before real use, obtain school approval and add a secure backend, verified student accounts, teacher/admin authentication, database access policies, backups, and a privacy notice. Keep names, classes and contact details private; publish only item details approved by staff.

## Suggested live architecture

Keep GitHub Pages for the static frontend and connect it to a backend such as Supabase. Use Supabase Auth for verified users, and Row Level Security (RLS) so students can create reports and read only their own report status, while authorized staff can review/update all reports. Public users should only read approved, non-sensitive notice fields. Never place service-role keys or admin passwords in HTML/JavaScript.

The current files are a working UI prototype, not a production-secure multi-user deployment.
