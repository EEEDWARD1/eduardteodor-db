CREATE TYPE post_type AS ENUM ('project', 'post', 'freelance');

CREATE TABLE IF NOT EXISTS posts(
    id UUID DEFAULT uuidv7() PRIMARY KEY,
    slug VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    post_type post_type NOT NUll DEFAULT 'post',
    summary TEXT,
    description TEXT,
    published BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tags(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS post_tags(
    tag_id INT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
)