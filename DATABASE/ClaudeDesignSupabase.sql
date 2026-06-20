-- ============================================================
-- LAWYERS DIARY · Supabase schema v1.2  (CORRECTED / CANONICAL)
-- Paste this whole file into Supabase → SQL Editor → New query → Run.
-- Safe to run once on a fresh project. uuid PKs, timestamptz timestamps,
-- multi-tenant via advocate_id, Row-Level Security on every table.
--
-- v1.2 adds the case-detail columns the frontend actually reads/writes
-- (received_date, court_order, today_todo, next_todo, notes, summary, …),
-- the case_parties.tag, the optional day_logs table, a Storage bucket for
-- documents, updated_at triggers, and a richer signup trigger.
-- ============================================================


-- ============================================================
-- SECTION 1 · CORE TABLES (MVP)
-- ============================================================

-- The advocate's profile. id matches the Supabase Auth user id.
create table advocates (
  id           uuid primary key references auth.users(id) on delete cascade,
  full_name    text,
  email        text,
  phone        text,
  theme        text default 'light',
  default_lang text default 'bn',
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create table clients (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  phone       text,
  address     text,
  role        text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table cases (
  id            uuid primary key default gen_random_uuid(),
  advocate_id   uuid not null references auth.users(id) on delete cascade,
  client_id     uuid references clients(id) on delete set null,   -- optional FK
  case_no       text,
  case_type     text,
  court         text,
  court_short   text,                 -- short court label shown in lists
  judge         text,
  stage         text,                 -- Evidence, Charge Hearing, Execution, …
  stage_type    text,                 -- pending / active / disposed (dot colour)
  priority      text,                 -- high / medium / low
  prev_date     date,
  next_date     date,
  received_date date,                 -- file received (trigger for a NEW matter)
  court_order   text,                 -- the court's order / proceeding
  next_todo     text,                 -- the PLAN for the next date
  today_todo    text,                 -- the "DO" box
  today_fee     numeric(12,2),        -- today's fee (also mirror into payments)
  notes         text,                 -- special notes
  summary       text,                 -- matter summary
  comm_name     text,                 -- communication person (from intake)
  comm_phone    text,
  care_name     text,                 -- care-of (c/o) person (from intake)
  care_phone    text,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

create table case_parties (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  case_id     uuid not null references cases(id) on delete cascade,
  client_id   uuid references clients(id) on delete set null,     -- optional FK
  side        text,                   -- petitioner / respondent / plaintiff / …
  position    text,
  tag         text,                   -- A1, A2, B1 … (display label)
  name        text,
  is_mine     boolean default false,
  phone       text,
  created_at  timestamptz default now()
);

create table hearings (
  id           uuid primary key default gen_random_uuid(),
  advocate_id  uuid not null references auth.users(id) on delete cascade,
  case_id      uuid not null references cases(id) on delete cascade,
  date         date not null,
  kind         text,                  -- sunani / todbir / filing / order …
  title        text,
  note         text,
  forwarded_to date,
  created_at   timestamptz default now()
);

create table reminders (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  case_id     uuid references cases(id) on delete cascade,        -- optional FK
  on_date     date not null,
  text        text,
  done        boolean default false,
  created_at  timestamptz default now()
);


-- ============================================================
-- SECTION 2 · LATER TABLES (cut-list; create now, fill in later)
-- ============================================================

create table opposing_counsel (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  case_id     uuid not null references cases(id) on delete cascade,
  name        text,
  phone       text,
  represents  int[],
  created_at  timestamptz default now()
);

create table payments (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  case_id     uuid not null references cases(id) on delete cascade,
  pay_type    text,
  label       text,
  amount      numeric(12,2),
  paid_on     date,
  created_at  timestamptz default now()
);

create table documents (
  id           uuid primary key default gen_random_uuid(),
  advocate_id  uuid not null references auth.users(id) on delete cascade,
  case_id      uuid references cases(id) on delete cascade,
  up_file_name text,
  storage_path text,                  -- path inside the 'case-files' bucket
  mime         text,
  docu_size    bigint,
  created_at   timestamptz default now()
);

create table notifications_log (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  case_id     uuid references cases(id) on delete set null,       -- optional FK
  channel     text,                   -- push / sms / in-app
  kind        text,
  sent_at     timestamptz default now()
);

-- OPTIONAL. The Day Summary is DERIVED from cases + hearings + payments,
-- so you do NOT need this table to show a day's summary. Create it only to
-- PERSIST an end-of-day note, a fee total, or a frozen snapshot that won't
-- change if a case is edited later.
create table day_logs (
  id          uuid primary key default gen_random_uuid(),
  advocate_id uuid not null references auth.users(id) on delete cascade,
  on_date     date not null,
  note        text,
  fees_total  numeric(12,2),
  snapshot    jsonb,
  created_at  timestamptz default now(),
  unique (advocate_id, on_date)
);


-- ============================================================
-- SECTION 3 · ROW-LEVEL SECURITY  (each advocate sees only their own rows)
-- ============================================================

alter table advocates         enable row level security;
alter table clients           enable row level security;
alter table cases             enable row level security;
alter table case_parties      enable row level security;
alter table hearings          enable row level security;
alter table reminders         enable row level security;
alter table opposing_counsel  enable row level security;
alter table payments          enable row level security;
alter table documents         enable row level security;
alter table notifications_log enable row level security;
alter table day_logs          enable row level security;

create policy "own profile" on advocates
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "own rows" on clients           for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on cases             for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on case_parties      for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on hearings          for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on reminders         for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on opposing_counsel  for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on payments          for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on documents         for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on notifications_log for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);
create policy "own rows" on day_logs          for all using (auth.uid() = advocate_id) with check (auth.uid() = advocate_id);


-- ============================================================
-- SECTION 4 · INDEXES
-- ============================================================

create index on clients          (advocate_id);
create index on cases            (advocate_id);
create index on cases            (client_id);
create index on cases            (next_date);          -- calendar / today's hearings
create index on cases            (received_date);      -- missing-date scan (new files)
create unique index cases_adv_caseno_uniq
                  on cases        (advocate_id, case_no) where case_no is not null;
create index on case_parties     (case_id);
create index on hearings         (case_id);
create index on hearings         (date);
create index on reminders        (advocate_id, on_date);
create index on opposing_counsel (case_id);
create index on payments         (case_id);
create index on documents        (case_id);
create index on notifications_log(advocate_id, sent_at);
create index on day_logs         (advocate_id, on_date);


-- ============================================================
-- SECTION 5 · STORAGE BUCKET for documents (files live in Storage, not a table)
-- Upload to a path that STARTS WITH the advocate's id, e.g.
--   <auth.uid()>/<case_id>/<filename>
-- ============================================================

insert into storage.buckets (id, name, public)
values ('case-files', 'case-files', false)
on conflict (id) do nothing;

create policy "own files - read" on storage.objects
  for select using (bucket_id = 'case-files' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own files - write" on storage.objects
  for insert with check (bucket_id = 'case-files' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own files - delete" on storage.objects
  for delete using (bucket_id = 'case-files' and (storage.foldername(name))[1] = auth.uid()::text);


-- ============================================================
-- SECTION 6 · updated_at — bump automatically on every UPDATE
-- ============================================================

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger trg_touch_advocates before update on advocates
  for each row execute function public.touch_updated_at();
create trigger trg_touch_clients   before update on clients
  for each row execute function public.touch_updated_at();
create trigger trg_touch_cases     before update on cases
  for each row execute function public.touch_updated_at();


-- ============================================================
-- SECTION 7 · AUTO-CREATE PROFILE ON SIGNUP
-- Carries full_name & phone if you pass them as auth metadata at signup.
-- ============================================================

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.advocates (id, email, full_name, phone)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', '')
  );
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
