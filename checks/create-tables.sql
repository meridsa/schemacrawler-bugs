CREATE TABLE DB1.GUY (
    id varchar2(255) PRIMARY KEY,
    name varchar2(255) NOT NULL,
    favourite_vowel varchar2(1) NOT NULL CHECK (favourite_vowel IN ('A', 'E', 'I', 'O', 'U', 'Y'))
);

CREATE INDEX DB1.NAME_INDEX ON DB1.GUY (name);
