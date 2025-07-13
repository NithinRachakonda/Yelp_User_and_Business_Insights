--------------------------- CREATING TABLES -----------------------------

CREATE TABLE Businesses ( 
    business_id CHAR(22) PRIMARY KEY, 
    business_name VARCHAR(127) NOT NULL, --- Name is must for a store review/delivery app ----
    street_address VARCHAR(127), --- VARCHAR is enough for this data as longest address had only 110 characters for a live database TEXT is preferred----
    city VARCHAR(63), --- longest city have only 52 characters and giving limit to nearest 2 power (128-1)---
    state VARCHAR(3),
    postal_code VARCHAR(7), --- even though the given value is 9, in the data, longest postal code had only 7 characters --------
    latitude NUMERIC(8,6) NOT NULL,  --- location is must for a store review/delivery app ----
    longitude NUMERIC(9,6) NOT NULL,  --- (6 decimal precision gives 11.1 cm accuracy which is enough) ----
    rating NUMERIC(2,1), ---0 to 5------------------------------------------------------------------------------------------------------------------------------------
    no_of_reviews SMALLINT,
    is_business_open BOOLEAN NOT NULL  --- open/close is required for a  store review/delivery app ----
);


CREATE TABLE Businesses_attributes ( 
    business_id CHAR(22), 
    attribute_name VARCHAR(31), --- Longest attribute_name have only 26 characters ---
    attribute_value VARCHAR(255), --- Longest attribute_value had only 168 Characters, hence VARCHAR instead of TEXT ---
    PRIMARY KEY (business_id, attribute_name)
);

CREATE TABLE Businesses_categories ( 
    business_id CHAR(22), 
    category_name VARCHAR(63) NOT NULL --- longest category_name have only 36 characters ----
);

CREATE TABLE Businesses_hours ( 
    business_id CHAR(22), 
    day VARCHAR(9) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    PRIMARY KEY (business_id, day)
);

CREATE TABLE Tips ( 
    user_id CHAR(22), 
    business_id CHAR(22) NOT NULL,
    tip_text VARCHAR(525) NOT NULL, --- longest tip has 524 characters, using varchar for project purposes, if its a live database I wouldve used TEXT ---
    tip_time TIMESTAMP NOT NULL,
    no_of_compliments SMALLINT DEFAULT 0
);

CREATE TABLE Users (
    user_id CHAR(22) PRIMARY KEY,
    name VARCHAR(32) , --- longest name have only 32 characters ---
    no_of_reviews SMALLINT DEFAULT 0,
    joined_timestamp TIMESTAMP,
    useful_votes INT DEFAULT 0,
    funny_votes INT DEFAULT 0, 
    cool_votes INT DEFAULT 0,
    no_of_fans SMALLINT DEFAULT 0,
    average_review NUMERIC(3,2), --- 0 to 5 ---
    hot_compliments SMALLINT DEFAULT 0, --- the highest value is 25784, I would give INT if this is a live database --- 
    more_compliments SMALLINT DEFAULT 0, --- 13501 ---
    profile_compliments SMALLINT DEFAULT 0, --- 14180 ---
    cute_compliments SMALLINT DEFAULT 0, --- 13654 ---
    list_compliments SMALLINT DEFAULT 0, --- 12669 ---
    note_compliments INT DEFAULT 0, --- 59031 ---
    plain_compliments INT DEFAULT 0, --- 101097 ---
    cool_compliments INT DEFAULT 0, --- 49967 ---
    funny_compliments INT DEFAULT 0, --- 49967 literally same data as cool compliments ---
    writer_compliments SMALLINT DEFAULT 0, --- 15937 ---
    photo_compliments INT DEFAULT 0 --- 82630 ---
);

CREATE TABLE User_elite_years (
    user_id CHAR(22),
    year SMALLINT,
    PRIMARY KEY (user_id, year)
);

CREATE TABLE Reviews (
    review_id CHAR(22) PRIMARY KEY,
    user_id CHAR(22),
    business_id CHAR(22),
    rating NUMERIC(2,1), --- 0 to 5 ---
    useful_markings SMALLINT DEFAULT 0,
    funny_markings SMALLINT DEFAULT 0,
    cool_markings SMALLINT DEFAULT 0,
    review_text TEXT, --- variable length between reviews is too high, hence TEXT instead of VARCHAR ---
    review_timestamp TIMESTAMP
);


CREATE TABLE temp_reviews (
    review_id CHAR(22),
    user_id CHAR(22),
    business_id CHAR(22),
    rating NUMERIC(2,1), --- 0 to 5 ---
    useful_markings SMALLINT DEFAULT 0,
    funny_markings SMALLINT DEFAULT 0,
    cool_markings SMALLINT DEFAULT 0,
    review_text TEXT, --- variable length between reviews is too high, hence TEXT instead of VARCHAR ---
    review_timestamp TIMESTAMP
);



------------------ ADDING CONSTRAINTS --------------------------

ALTER TABLE Businesses
ADD CONSTRAINT businesses_rating_range CHECK (rating >= 0 AND rating <= 5);

ALTER TABLE Reviews
ADD CONSTRAINT reviews_rating_range CHECK (rating >= 0 AND rating <= 5);

ALTER TABLE Users
ADD CONSTRAINT users_averagereview_range CHECK (average_review >= 0 AND average_review <= 5);

ALTER TABLE Users
ADD CONSTRAINT check_timestamp_users_joinedtimestamp
CHECK (joined_timestamp < LOCALTIMESTAMP);

ALTER TABLE Tips
ADD CONSTRAINT check_timestamp_tips_tiptime
CHECK (tip_time < LOCALTIMESTAMP);

ALTER TABLE Reviews
ADD CONSTRAINT check_timestamp_reviews_reviewtimestamp
CHECK (review_timestamp < LOCALTIMESTAMP);

ALTER TABLE Businesses_attributes 
ADD CONSTRAINT FK_Business_attributes_Businesses 
FOREIGN KEY (business_id) REFERENCES Businesses(business_id);

ALTER TABLE Businesses_categories 
ADD CONSTRAINT FK_Business_categories_Businesses 
FOREIGN KEY (business_id) REFERENCES Businesses(business_id);

ALTER TABLE Businesses_hours 
ADD CONSTRAINT FK_Business_hours_Businesses 
FOREIGN KEY (business_id) REFERENCES Businesses(business_id);

ALTER TABLE Tips 
ADD CONSTRAINT FK_Tips_Businesses 
FOREIGN KEY (business_id) REFERENCES Businesses(business_id);

ALTER TABLE Tips 
ADD CONSTRAINT FK_Tips_Users 
FOREIGN KEY (user_id) REFERENCES Users(user_id);

ALTER TABLE User_elite_years 
ADD CONSTRAINT FK_User_elite_years_Users 
FOREIGN KEY (user_id) REFERENCES Users(user_id);

ALTER TABLE Reviews
ADD CONSTRAINT FK_Reviews_Users 
FOREIGN KEY (user_id) REFERENCES Users(user_id);

ALTER TABLE Reviews 
ADD CONSTRAINT FK_Reviews_Businesses 
FOREIGN KEY (business_id) REFERENCES Businesses(business_id);

---------------------------- INSERTING DATA ---------------------------------------  
--- NOTE : I inserted reviews data into a temporary table and then transferred the data to review table because there were extra user_id s in the reviews data which were not in the users data
--- The query ran for transfer of data from temporary table to reviews table is given on lines 214 to 226

COPY Businesses FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/businesses.csv' CSV;

COPY Users FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/users/users/users_part0.csv' CSV;
COPY Users FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/users/users/users_part1.csv' CSV;
COPY Users FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/users/users/users_part2.csv' CSV;
CREATE INDEX idx_users_userid ON Users (user_id);

COPY Businesses_attributes FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_attributes.csv' CSV;

COPY Businesses_categories FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_categories.csv' CSV; ---
CREATE INDEX idx_businessid_categoryname ON Businesses_categories (business_id, category_name);

COPY Businesses_hours FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_hours.csv' CSV;

COPY Tips FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/tips.csv' CSV; ---
CREATE INDEX idx_tips_userid_tiptime ON Tips (user_id, tip_time);

COPY User_elite_years FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/user_elite_years.csv' CSV;

COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part0.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part1.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part2.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part3.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part4.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part5.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part6.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part7.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part8.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part9.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part10.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part11.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part12.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part13.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part14.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part15.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part16.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part17.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part18.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part19.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part20.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part21.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part22.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part23.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part24.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part25.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part26.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part27.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part28.csv' CSV;
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/15/data/msit-3860-final-project-data/business_reviews/business_reviews/business_reviews_part29.csv' CSV;


CREATE INDEX idx_tempreviews_reviewid ON temp_reviews (review_id);

INSERT INTO Reviews (review_id, user_id, business_id, rating, useful_markings, funny_markings, cool_markings, review_text, review_timestamp)
SELECT
    review_id, user_id, business_id, rating, useful_markings, funny_markings, cool_markings, review_text, review_timestamp
FROM
    temp_reviews
WHERE
    user_id IN (SELECT user_id FROM Users);

--- 6990280 to 6990250 if i wouldve opted manual insertion of user_id s in Users table, I wouldve inserted 30 user_id s and it wouldve also been a violation of user data's data integrity. so this method is better ---

CREATE INDEX idx_reviews_reviewid ON Reviews (review_id);

DROP TABLE temp_reviews;