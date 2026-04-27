-- Orders table
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.profiles(id) on delete cascade,
  status text not null default 'pending',
  total_amount decimal not null,
  delivery_address text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.orders enable row level security;

-- Orders policies
drop policy if exists "Customers can view own orders" on public.orders;
create policy "Customers can view own orders"
  on public.orders
  for select
  using (auth.uid() = customer_id);

drop policy if exists "Customers can create orders" on public.orders;
create policy "Customers can create orders"
  on public.orders
  for insert
  with check (auth.uid() = customer_id);

-- Keep updated_at fresh
create or replace function public.set_orders_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists orders_set_updated_at on public.orders;
create trigger orders_set_updated_at
before update on public.orders
for each row
execute function public.set_orders_updated_at();

-- Order Items table
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade,
  food_item_id uuid references public.food_items(id) on delete set null,
  quantity int not null,
  price_at_order decimal not null,
  created_at timestamptz not null default now()
);

alter table public.order_items enable row level security;

-- Order Items policies
drop policy if exists "Customers can view own order items" on public.order_items;
create policy "Customers can view own order items"
  on public.order_items
  for select
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_id
      and orders.customer_id = auth.uid()
    )
  );

drop policy if exists "Customers can create order items" on public.order_items;
create policy "Customers can create order items"
  on public.order_items
  for insert
  with check (
    exists (
      select 1 from public.orders
      where orders.id = order_id
      and orders.customer_id = auth.uid()
    )
  );
