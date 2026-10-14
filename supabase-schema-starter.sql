-- STARTER ONLY: review and adapt with the school before production use.
-- Assumes Supabase Auth users have a profiles row with role='student' or 'staff'.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  class_name text,
  role text not null default 'student' check (role in ('student','staff')),
  created_at timestamptz not null default now()
);

create table if not exists public.lost_found_reports (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  item_type text not null check (item_type in ('lost','found')),
  item_name text not null check (char_length(item_name) between 1 and 80),
  item_date date not null,
  location text not null check (char_length(location) between 1 and 120),
  description text not null check (char_length(description) between 1 and 600),
  private_contact text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','returned')),
  created_at timestamptz not null default now(),
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz
);

alter table public.profiles enable row level security;
alter table public.lost_found_reports enable row level security;

-- Users may read only their own profile. Staff role assignment must be controlled
-- by a trusted administrator, not by a public sign-up form.
create policy "users read own profile" on public.profiles
for select to authenticated using (id = auth.uid());

-- Students can submit reports only as themselves.
create policy "students submit own reports" on public.lost_found_reports
for insert to authenticated
with check (student_id = auth.uid() and status = 'pending');

-- Students can see their own report status; staff can see all reports.
create policy "students see own reports or staff see all" on public.lost_found_reports
for select to authenticated using (
  student_id = auth.uid() or exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = 'staff'
  )
);

-- Only staff can review/update reports. Ensure profiles.role='staff' is assigned
-- through a trusted admin workflow; do not let users update their own role.
create policy "staff review reports" on public.lost_found_reports
for update to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'staff'))
with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'staff'));

-- Public notice board should use a separate safe view/table that excludes names,
-- classes, student_id, private_contact and any other identifying information.
-- Do not expose this base reports table anonymously. A carefully granted view or
-- server endpoint should return only approved, non-sensitive item fields.
