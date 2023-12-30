CREATE TYPE age_range AS ENUM ('18-24', '25-35', '35-44',
    '45-54', '55-64', '65+');

CREATE TABLE businesses (
    id serial PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE users (
    id serial PRIMARY KEY,
    name text NOT NULL,
    age age_range,
    bio text,
    love_phrase varchar(15) NOT NULL,
    hate_phrase varchar(15) NOT NULL,
    biz_id integer NOT NULL REFERENCES businesses (id)
);

CREATE TABLE needs (
    id serial PRIMARY KEY,
    name text NOT NULL,
    user_id integer NOT NULL REFERENCES users (id)
);

CREATE TABLE motivations (
    id serial PRIMARY KEY,
    name text NOT NULL,
    user_id integer NOT NULL REFERENCES users (id)
);

CREATE TABLE challenges (
    id serial PRIMARY KEY,
    name text NOT NULL,
    user_id integer NOT NULL REFERENCES users (id)
);