-- Journals: database schema. Run this once in Supabase -> SQL Editor -> New query -> Run.

-- ---------- tables ----------
create table if not exists public.entries (
  user_id     uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  id          text        not null,
  title       text        not null default '',
  content     text        not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  star        boolean     not null default false,
  trash       boolean     not null default false,
  template_id text,
  primary key (user_id, id)
);

create table if not exists public.templates (
  user_id    uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  id         text    not null,
  name       text    not null,
  icon       text    not null default '✦',
  sub        text    not null default '',
  content    text    not null default '',
  plain_text text,
  sort       integer not null default 0,
  primary key (user_id, id)
);

create table if not exists public.settings (
  user_id           uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  selected_template text,
  template_enabled  boolean not null default true,
  auto_template     boolean not null default true
);

create index if not exists entries_user_updated_idx on public.entries (user_id, updated_at desc);
create index if not exists templates_user_sort_idx  on public.templates (user_id, sort);

-- ---------- row level security: every user can only touch their own rows ----------
alter table public.entries   enable row level security;
alter table public.templates enable row level security;
alter table public.settings  enable row level security;

drop policy if exists "entries: own rows"   on public.entries;
drop policy if exists "templates: own rows" on public.templates;
drop policy if exists "settings: own rows"  on public.settings;

create policy "entries: own rows" on public.entries
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "templates: own rows" on public.templates
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "settings: own rows" on public.settings
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- ---------- privileges (anonymous visitors get nothing) ----------
revoke all on public.entries, public.templates, public.settings from anon;
grant select, insert, update, delete on public.entries, public.templates, public.settings to authenticated;
