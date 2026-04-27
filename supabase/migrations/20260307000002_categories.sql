-- Categories table
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  image_url text,
  created_at timestamptz not null default now()
);

alter table public.categories enable row level security;

-- Categories policies
drop policy if exists "Anyone can view categories" on public.categories;
create policy "Anyone can view categories"
  on public.categories
  for select
  using (true);

drop policy if exists "Vendors can insert categories" on public.categories;
create policy "Vendors can insert categories"
  on public.categories
  for insert
  with check (auth.uid() is not null);

drop policy if exists "Vendors can update categories" on public.categories;
create policy "Vendors can update categories"
  on public.categories
  for update
  using (auth.uid() is not null);

drop policy if exists "Vendors can delete categories" on public.categories;
create policy "Vendors can delete categories"
  on public.categories
  for delete
  using (auth.uid() is not null);