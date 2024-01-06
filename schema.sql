CREATE TYPE age_range AS ENUM ('18-24', '25-34', '35-44',
    '45-54', '55-64', '65+');

CREATE TABLE businesses (
    id serial PRIMARY KEY,
    uuid uuid NOT NULL,
    name text NOT NULL
);

CREATE TABLE users (
    id serial PRIMARY KEY,
    name text NOT NULL,
    age age_range NOT NULL,
    bio text NOT NULL,
    love_phrase text NOT NULL,
    hate_phrase text NOT NULL,
    need text NOT NULL,
    motivation text NOT NULL,
    challenge text NOT NULL,
    biz_id int NOT NULL REFERENCES businesses (id) ON DELETE CASCADE
);

