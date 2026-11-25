-- Kits PROPAG: banco de dados (rode uma vez no SQL Editor do Supabase)

create table if not exists public.turmas (
  id          uuid primary key default gen_random_uuid(),
  curso       text not null,
  grupo       text not null,
  inicio      date not null,
  turno       text not null default '',
  status      text not null default 'pendente'
              check (status in ('pendente','parcial','entregue')),
  nota        text not null default '',
  status_em   timestamptz,
  atualizado_por text,
  criado_em   timestamptz not null default now(),
  unique (curso, grupo, turno)
);

-- Libera a tabela na API só para usuários logados (visitantes sem login não têm acesso)
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.turmas to authenticated;
revoke all on public.turmas from anon;

-- Só usuários logados (a equipe) podem ver e alterar
alter table public.turmas enable row level security;

drop policy if exists "equipe pode ler" on public.turmas;
drop policy if exists "equipe pode adicionar" on public.turmas;
drop policy if exists "equipe pode alterar" on public.turmas;
drop policy if exists "equipe pode remover" on public.turmas;
create policy "equipe pode ler"       on public.turmas for select to authenticated using (true);
create policy "equipe pode adicionar" on public.turmas for insert to authenticated with check (true);
create policy "equipe pode alterar"   on public.turmas for update to authenticated using (true) with check (true);
create policy "equipe pode remover"   on public.turmas for delete to authenticated using (true);

-- Atualização em tempo real entre aparelhos
do $$ begin
  alter publication supabase_realtime add table public.turmas;
exception when duplicate_object then null; end $$;

-- Turmas da planilha PROPAG.xlsx
insert into public.turmas (curso, grupo, inicio, turno) values
('Técnico em Administração','2026.3P','2026-10-05','Tarde'),
('Técnico em Administração','2026.5P','2026-10-05','Manhã'),
('Técnico em Administração','2026.1P','2026-10-19','Tarde'),
('Técnico em Administração','2026.2P','2026-10-19','Manhã'),
('Técnico em Administração','2026.4P','2026-10-19','Noite'),
('Técnico em Logística','2026.1P','2026-10-19','Noite'),
('Técnico em Enfermagem','2026.1P','2026-10-19','Tarde'),
('Técnico em Estética','2026.1P','2026-10-19','Manhã'),
('Técnico em Estética','2026.2P','2026-10-26','Tarde'),
('Técnico em Enfermagem','2026.2P','2026-11-03','Tarde'),
('Técnico em Massoterapia','2026.1P','2026-11-03','Manhã'),
('Técnico em Enfermagem','2026.4P','2026-11-03','Manhã'),
('Técnico em Estética','2026.3P','2026-11-03','Noite'),
('Técnico em Massoterapia','2026.3P','2026-11-03','Noite'),
('Técnico em Logística','2026.5P','2026-11-09','Noite'),
('Técnico em Enfermagem','2026.3P','2026-11-16','Tarde'),
('Técnico em Massoterapia','2026.2P','2026-11-16','Tarde'),
('Técnico em Logística','2026.9P','2026-11-30','Tarde'),
('Técnico em Logística','2026.4P','2026-11-30','Tarde'),
('Técnico em Administração','2026.9P','2026-11-23','Noite'),
('Técnico em Administração','2026.10P','2026-11-23','Noite'),
('Técnico em Administração','2026.11P','2026-11-23','Noite'),
('Técnico em Logística','2026.8P','2026-11-23','Noite'),
('Técnico em Administração','2026.6P','2026-11-30','Tarde'),
('Técnico em Administração','2026.13P','2026-11-30','Manhã'),
('Técnico em Administração','2026.14P','2026-11-30','Tarde'),
('Técnico em Administração','2026.15P','2026-11-30','Noite'),
('Técnico em Administração','2026.7P','2026-11-30','Noite'),
('Técnico em Administração','2026.8P','2026-11-30','Noite'),
('Técnico em Administração','2026.12','2026-11-30','Manhã')
on conflict (curso, grupo, turno) do nothing;
