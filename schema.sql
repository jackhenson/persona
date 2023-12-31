CREATE TYPE age_range AS ENUM ('18-24', '25-35', '35-44',
    '45-54', '55-64', '65+');

CREATE TABLE businesses (
    id serial PRIMARY KEY,
    uuid uuid NOT NULL,
    name text NOT NULL
);

CREATE TABLE users (
    id serial PRIMARY KEY,
    name text NOT NULL,
    age age_range,
    bio text,
    love_phrase text NOT NULL,
    hate_phrase text NOT NULL,
    biz_id integer NOT NULL REFERENCES businesses (id) ON DELETE CASCADE
);

CREATE TABLE profiles (
    id serial PRIMARY KEY,
    need text NOT NULL,
    motivation text NOT NULL,
    challenge text NOT NULL,
    user_id integer NOT NULL REFERENCES users (id) ON DELETE CASCADE
);
