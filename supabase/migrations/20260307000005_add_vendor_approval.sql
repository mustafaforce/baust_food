-- Add is_approved column for vendor approval workflow
alter table public.profiles add column if not exists is_approved boolean not null default true;

-- For vendors, set is_approved to false by default (they need admin approval)
do $$
begin
  -- Add is_approved column if it doesn't exist
  if not exists (select 1 from information_schema.columns where table_name = 'profiles' and column_name = 'is_approved') then
    alter table public.profiles add column is_approved boolean not null default true;
  end if;
end $$;