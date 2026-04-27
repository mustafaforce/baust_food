-- Food Items table
create table if not exists public.food_items (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  vendor_id uuid references auth.users(id) on delete cascade,
  name text not null,
  description text,
  price decimal not null,
  image_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.food_items enable row level security;

-- Food Items policies
drop policy if exists "Anyone can view available food items" on public.food_items;
create policy "Anyone can view available food items"
  on public.food_items
  for select
  using (is_available = true or auth.uid() is not null);

drop policy if exists "Vendors can insert food items" on public.food_items;
create policy "Vendors can insert food items"
  on public.food_items
  for insert
  with check (auth.uid() = vendor_id);

drop policy if exists "Vendors can update own food items" on public.food_items;
create policy "Vendors can update own food items"
  on public.food_items
  for update
  using (auth.uid() = vendor_id)
  with check (auth.uid() = vendor_id);

drop policy if exists "Vendors can delete own food items" on public.food_items;
create policy "Vendors can delete own food items"
  on public.food_items
  for delete
  using (auth.uid() = vendor_id);

-- Keep updated_at fresh
create or replace function public.set_food_items_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists food_items_set_updated_at on public.food_items;
create trigger food_items_set_updated_at
before update on public.food_items
for each row
execute function public.set_food_items_updated_at();