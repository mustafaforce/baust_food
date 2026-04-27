-- Add role column to profiles
alter table public.profiles add column if not exists role text not null default 'customer';

-- Update existing profiles to have 'customer' role
update public.profiles set role = 'customer' where role is null;

-- Create role enum values policy
drop policy if exists "Users can view own profile with role" on public.profiles;
create policy "Users can view own profile with role"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "Users can update own profile with role" on public.profiles;
create policy "Users can update own profile with role"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);