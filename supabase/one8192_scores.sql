-- 8192分の1 世界ランキング用テーブル
-- Supabaseプロジェクト kifnzvktwbomxthzvvgy の SQL Editor で一度だけ実行してください。
-- (このプロジェクトは隠語クイズ・めっちゃカメレオン・HOLD ON等と相乗りのため、
--  このサイト専用の接頭辞 "one8192_" のテーブルのみ扱います)

create table if not exists public.one8192_scores (
  id bigint generated always as identity primary key,
  name text not null check (char_length(trim(name)) between 1 and 12),
  -- 歴代最高連勝数（大きいほど上位。2^best_streak 分の1に到達したことを意味する）
  best_streak integer not null check (best_streak >= 1 and best_streak <= 60),
  created_at timestamptz not null default now()
);

alter table public.one8192_scores enable row level security;

-- 再実行しても安全なように、既存ポリシーがあれば削除してから作り直す
drop policy if exists "one8192_scores_public_read" on public.one8192_scores;
drop policy if exists "one8192_scores_public_insert" on public.one8192_scores;

-- 誰でも閲覧可能(世界ランキング表示のため)
-- ※ ロールを anon に限定しない。kaikomziu.github.io は全ゲーム共通オリジンで、
--   同プロジェクトを使う他ゲームにログイン中だと supabase-js が
--   authenticated ロールのJWTを送るため、to anon だとINSERTがRLSで弾かれる。
create policy "one8192_scores_public_read"
  on public.one8192_scores for select
  using (true);

-- 誰でも登録可能(妥当性はCHECK制約で担保、更新・削除は不可)
create policy "one8192_scores_public_insert"
  on public.one8192_scores for insert
  with check (true);

-- 上位取得を速くするためのインデックス
create index if not exists one8192_scores_best_streak_idx on public.one8192_scores (best_streak desc);
