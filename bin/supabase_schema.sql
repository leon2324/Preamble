-- 建立精選/日常學習專題的資料表
CREATE TABLE IF NOT EXISTS public.learning_articles (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    topic_id integer,
    step_number integer,
    title text NOT NULL,
    category text NOT NULL,
    badge text NOT NULL,
    summary text NOT NULL,
    read_time text NOT NULL,
    hero_note text NOT NULL,
    key_points jsonb NOT NULL,
    sections jsonb NOT NULL,
    quiz_data jsonb NOT NULL,
    hero_image_url text,
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 建立索引以提升分類分頁查詢效能
CREATE INDEX IF NOT EXISTS idx_learning_articles_category ON public.learning_articles(category);
CREATE INDEX IF NOT EXISTS idx_learning_articles_topic_step ON public.learning_articles(topic_id, step_number);

-- 啟用 RLS (Row Level Security)，以便外網唯讀讀取
ALTER TABLE public.learning_articles ENABLE ROW LEVEL SECURITY;

-- 建立任何人皆可匿名讀取的 RLS 安全性原則
CREATE POLICY "Allow public read access" ON public.learning_articles
    FOR SELECT USING (true);
