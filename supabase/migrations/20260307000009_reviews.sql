-- Reviews table
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  food_item_id uuid not null references public.food_items(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  customer_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (order_id, food_item_id, customer_id)
);

create index if not exists reviews_food_item_idx on public.reviews(food_item_id);
create index if not exists reviews_customer_idx on public.reviews(customer_id);

alter table public.reviews enable row level security;

-- Anyone authenticated can read reviews
drop policy if exists "Reviews are publicly readable" on public.reviews;
create policy "Reviews are publicly readable"
  on public.reviews
  for select
  using (true);

-- Customer can insert review only if they own a delivered order containing the food_item
drop policy if exists "Customers can create reviews for delivered orders" on public.reviews;
create policy "Customers can create reviews for delivered orders"
  on public.reviews
  for insert
  with check (
    auth.uid() = customer_id
    and exists (
      select 1
      from public.orders o
      join public.order_items oi on oi.order_id = o.id
      where o.id = order_id
        and o.customer_id = auth.uid()
        and o.status = 'delivered'
        and oi.food_item_id = reviews.food_item_id
    )
  );

-- Customer can update / delete their own reviews
drop policy if exists "Customers can update own reviews" on public.reviews;
create policy "Customers can update own reviews"
  on public.reviews
  for update
  using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

drop policy if exists "Customers can delete own reviews" on public.reviews;
create policy "Customers can delete own reviews"
  on public.reviews
  for delete
  using (auth.uid() = customer_id);

-- Keep updated_at fresh
create or replace function public.set_reviews_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists reviews_set_updated_at on public.reviews;
create trigger reviews_set_updated_at
before update on public.reviews
for each row
execute function public.set_reviews_updated_at();

-- Snapshot customer_name from profiles on insert
create or replace function public.set_review_customer_name()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.customer_name is null then
    select full_name into new.customer_name
    from public.profiles
    where id = new.customer_id;
  end if;
  return new;
end;
$$;

drop trigger if exists reviews_set_customer_name on public.reviews;
create trigger reviews_set_customer_name
before insert on public.reviews
for each row
execute function public.set_review_customer_name();

-- Aggregate view for average rating per food_item
create or replace view public.food_item_ratings as
select
  food_item_id,
  round(avg(rating)::numeric, 2) as avg_rating,
  count(*)::int as rating_count
from public.reviews
group by food_item_id;

grant select on public.food_item_ratings to anon, authenticated;
