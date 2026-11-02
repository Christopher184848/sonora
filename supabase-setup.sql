-- Rode este arquivo no SQL Editor do seu projeto Supabase.
-- Cria um bucket privado e permite que cada conta veja/altere apenas a propria pasta.
insert into storage.buckets (id, name, public, file_size_limit)
values ('sonora-musicas', 'sonora-musicas', false, 104857600)
on conflict (id) do update
set public = false, file_size_limit = 104857600;

drop policy if exists "SONORA: listar e baixar arquivos da propria conta" on storage.objects;
drop policy if exists "SONORA: enviar arquivos para a propria conta" on storage.objects;
drop policy if exists "SONORA: apagar arquivos da propria conta" on storage.objects;

create policy "SONORA: listar e baixar arquivos da propria conta"
on storage.objects for select to authenticated
using (
  bucket_id = 'sonora-musicas'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "SONORA: enviar arquivos para a propria conta"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'sonora-musicas'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "SONORA: apagar arquivos da propria conta"
on storage.objects for delete to authenticated
using (
  bucket_id = 'sonora-musicas'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
