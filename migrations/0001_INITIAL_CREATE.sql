CREATE TABLE IF NOT EXISTS public.post_types(
    id INT PRIMARY KEY,
    name varchar(50) NOT NULL UNIQUE
);

INSERT INTO public.post_types (id, name) VALUES 
(1, 'posts'),
(2, 'projects'),
(3, 'freelance');

CREATE TABLE IF NOT EXISTS public.posts(
    id UUID DEFAULT uuidv7() PRIMARY KEY,
    slug VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    post_type INT NOT NULL DEFAULT 1 REFERENCES post_types(id),
    summary TEXT DEFAULT '',
    description TEXT DEFAULT '',
    published BOOLEAN NOT NULL DEFAULT false,
    starred BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tags(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag VARCHAR(255) NOT NULL UNIQUE    
);

CREATE TABLE IF NOT EXISTS public.post_tags(
    tag_id INT NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_posts_post_type ON public.posts(post_type);
CREATE INDEX idx_posts_published ON public.posts(published) WHERE published = true;
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);