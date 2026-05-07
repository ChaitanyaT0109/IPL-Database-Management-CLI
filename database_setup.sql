CREATE DATABASE if not exists CRICSTAR;

USE CRICSTAR;

CREATE TABLE LEAGUE (
    LEAGUE_ID INT PRIMARY KEY,
    LEAGUE_NAME VARCHAR(100) NOT NULL UNIQUE,
    START_DATE DATE NOT NULL,
    END_DATE DATE NOT NULL,
    CHECK (END_DATE >= START_DATE),
    LEAGUE_LOCATION VARCHAR(100) NOT NULL
);

CREATE TABLE MATCHES (
    MATCH_ID INT PRIMARY KEY,
    MATCH_DATE DATE NOT NULL,
    MATCH_TIME TIME NOT NULL,
    MATCH_FORMAT VARCHAR(20) CHECK (MATCH_FORMAT IN ('T20', 'ODI')),
    NO_OF_SPECTATORS INT
);

CREATE TABLE UMPIRES (
    UMPIRE_ID INT PRIMARY KEY,
    FNAME VARCHAR(50),
    MNAME VARCHAR(50),
    LNAME VARCHAR(50)
);

CREATE TABLE PLAYER (
    PLAYER_ID INT PRIMARY KEY,
    FNAME VARCHAR(50),
    MNAME VARCHAR(50),
    LNAME VARCHAR(50),
    NATIONALITY VARCHAR(50),
    BDATE DATE,
    PLAYER_ROLE VARCHAR(30) CHECK (PLAYER_ROLE IN ('BATSMAN', 'WK-BATSMAN' , 'BOWLER', 'ALLROUNDER'))
);

CREATE TABLE TEAM (
    TEAM_ID INT PRIMARY KEY,
    TEAM_NAME VARCHAR(100) UNIQUE,
    TEAM_OWNER VARCHAR(100) NOT NULL
);

CREATE TABLE STADIUM (
    STADIUM_NAME VARCHAR(100) PRIMARY KEY,
    LOCATION VARCHAR(100) NOT NULL,
    CAPACITY INT NOT NULL CHECK( CAPACITY >=0)
);

CREATE TABLE MATCH_UMPIRES (
    MATCH_ID INT NOT NULL,
    UMPIRE_ID INT NOT NULL,
    PRIMARY KEY (MATCH_ID, UMPIRE_ID),
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (UMPIRE_ID) REFERENCES UMPIRES(UMPIRE_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE HIGHLIGHTS (
    HIGHLIGHT_NO INT PRIMARY KEY,
    TITLE VARCHAR(200) NOT NULL,
    CLIP VARCHAR(200) NOT NULL,
    MATCH_ID INT NOT NULL,
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE POINTS_TABLE (
    LEAGUE_ID INT,
    TEAM_ID INT,
    MATCHES_PLAYED INT,
    CHECK(MATCHES_PLAYED>=0),
    MATCHES_WON INT,
    CHECK(MATCHES_WON>=0),
    MATCHES_LOST INT,
    CHECK(MATCHES_LOST>=0),
    POINTS INT,
    CHECK(POINTS>=0),
    PRIMARY KEY (LEAGUE_ID, TEAM_ID),
    FOREIGN KEY (LEAGUE_ID) REFERENCES LEAGUE(LEAGUE_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE PLAYER_STATS (
    PLAYER_ID INT NOT NULL,
    MATCH_ID INT NOT NULL,
    RUNS INT CHECK (RUNS >= 0),
    WICKETS INT CHECK (WICKETS >= 0),
    NO_OF_SIXES INT CHECK (NO_OF_SIXES >= 0),
    NO_OF_FOURS INT CHECK (NO_OF_FOURS >= 0),
    OVERS_BOWLED DECIMAL(3,1) CHECK (OVERS_BOWLED >= 0 AND OVERS_BOWLED <= 10),
    STRIKE_RATE DECIMAL(5,2) CHECK (STRIKE_RATE >= 0 AND STRIKE_RATE <= 600),
    BALLS_FACED INT CHECK (BALLS_FACED >= 0),
    ECONOMY DECIMAL(4,2) CHECK (ECONOMY >= 0 AND ECONOMY <= 72),
    PRIMARY KEY (PLAYER_ID, MATCH_ID),
    FOREIGN KEY (PLAYER_ID) REFERENCES PLAYER(PLAYER_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE TEAM_STATS (
    MATCH_ID INT NOT NULL,
    TEAM_ID INT NOT NULL,
    RUNS INT CHECK (RUNS >= 0),
    WICKETS INT CHECK (WICKETS >= 0),
    NO_OF_SIXES INT CHECK (NO_OF_SIXES >= 0),
    NO_OF_FOURS INT CHECK (NO_OF_FOURS >= 0),
    NO_OF_EXTRAS INT CHECK (NO_OF_EXTRAS >= 0),
    OVERS DECIMAL(3,1) CHECK (OVERS >= 0 AND OVERS <= 50),
    RUN_RATE DECIMAL(4,2) CHECK (RUN_RATE >= 0 AND RUN_RATE <= 50),  
    PRIMARY KEY (MATCH_ID, TEAM_ID),
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE MATCH_EVENT (
    LEAGUE_ID INT NOT NULL,
    MATCH_ID INT NOT NULL,
    TEAM_ID INT NOT NULL,
    PRIMARY KEY (LEAGUE_ID, MATCH_ID, TEAM_ID),
    FOREIGN KEY (LEAGUE_ID) REFERENCES LEAGUE(LEAGUE_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE MATCH_LOCATION (
    MATCH_ID INT NOT NULL,
    STADIUM_NAME VARCHAR(100) NOT NULL,
    PRIMARY KEY (MATCH_ID, STADIUM_NAME),
    FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(MATCH_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (STADIUM_NAME) REFERENCES STADIUM(STADIUM_NAME)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE TEAM_LEAGUE_PARTICIPATION (
    TEAM_ID INT NOT NULL ,
    PLAYER_ID INT NOT NULL,
    LEAGUE_ID INT NOT NULL,
    PRIMARY KEY (TEAM_ID, PLAYER_ID,LEAGUE_ID),
    FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (LEAGUE_ID) REFERENCES LEAGUE(LEAGUE_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (PLAYER_ID) REFERENCES PLAYER(PLAYER_ID)
		ON DELETE RESTRICT ON UPDATE CASCADE
);


INSERT INTO LEAGUE (LEAGUE_ID, LEAGUE_NAME, START_DATE, END_DATE, LEAGUE_LOCATION) VALUES
(1, 'ENGLAND TOUR OF AUSTRALIA', '2023-06-16', '2023-07-31', 'AUSTRALIA'),
(2, 'PAYTM TRI-SERIES', '2024-11-22', '2024-12-07', 'INDIA');
   
INSERT INTO TEAM (TEAM_ID, TEAM_NAME, TEAM_OWNER) VALUES
(1, 'India', 'Board of Control for Cricket in India'),
(2, 'Australia', 'Cricket Australia'),
(3, 'England', 'England and Wales Cricket Board'),
(4, 'Sri Lanka', 'Sri Lanka Cricket');


INSERT INTO STADIUM (STADIUM_NAME, LOCATION, CAPACITY) VALUES
('Wankhede Stadium', 'Mumbai', 33000),
('M. A. Chidambaram Stadium', 'Chennai', 50000),
('Narendra Modi Stadium', 'Ahmedabad', 132000),
('Eden Gardens', 'Kolkata', 66000),
('Melbourne Cricket Ground', 'Melbourne', 100024),
('Sydney Cricket Ground', 'Sydney', 48000),
('Optus Stadium', 'Perth', 60000),
('The Gabba', 'Brisbane, Australia', 42000);

INSERT INTO UMPIRES (UMPIRE_ID, FNAME, MNAME, LNAME) VALUES
(1, 'Saiyed', NULL, 'Khalid'),
(2, 'Virender', NULL, 'Sharma'),
(3, 'Nitin', NULL, 'Menon'),
(4, 'Nand', NULL, 'Kishore'),
(5, 'Anil', NULL, 'Chaudhary'),
(6, 'Bruce', NULL, 'Oxenford'),
(7, 'Chris', NULL, 'Brown'),
(8, 'Richard', NULL, 'Kettleborough');

INSERT INTO PLAYER (PLAYER_ID, FNAME, MNAME, LNAME, NATIONALITY, BDATE, PLAYER_ROLE)  VALUES
(1, 'Rohit', NULL, 'Sharma', 'Indian', '1987-04-30', 'BATSMAN'),
(2, 'Yashasvi', NULL, 'Jaiswal', 'Indian', '2001-12-28', 'BATSMAN'),
(3, 'Virat', NULL, 'Kohli', 'Indian', '1988-11-05', 'BATSMAN'),
(4, 'Rishabh', NULL, 'Pant', 'Indian', '1997-10-04', 'WK-BATSMAN'),
(5, 'Suryakumar', NULL, 'Yadav', 'Indian', '1990-09-14', 'BATSMAN'),
(6, 'Shivam', NULL, 'Dube', 'Indian', '1993-06-26', 'ALLROUNDER'),
(7, 'Hardik', NULL, 'Pandya', 'Indian', '1993-10-11', 'ALLROUNDER'),
(8, 'Ravindra', NULL, 'Jadeja', 'Indian', '1988-12-06', 'ALLROUNDER'),
(9, 'Axar', NULL, 'Patel', 'Indian', '1994-01-20', 'ALLROUNDER'),
(10, 'Jasprit', NULL, 'Bumrah', 'Indian', '1993-12-06', 'BOWLER'),
(11, 'Mohammed', NULL, 'Siraj', 'Indian', '1994-03-13', 'BOWLER'),
(12, 'Arshdeep', NULL, 'Singh', 'Indian', '1999-02-05', 'BOWLER'),
(13, 'Ben', NULL, 'Duckett', 'British', '1994-10-17', 'BATSMAN'),
(14, 'Zak', NULL, 'Crawley', 'British', '1998-02-03', 'BATSMAN'),
(15, 'Ollie', NULL, 'Pope', 'British', '1988-01-02', 'WK-BATSMAN'),
(16, 'Joe', NULL, 'Root', 'British', '1990-12-30', 'BATSMAN'),
(17, 'Harry', NULL, 'Brook', 'British', '1999-02-22', 'BATSMAN'),
(18, 'Ben', NULL, 'Stokes', 'British', '1991-06-04', 'ALLROUNDER'),
(19, 'Jonny', NULL, 'Bairstow', 'British', '1989-09-26', 'WK-BATSMAN'),
(20, 'Moeen', NULL, 'Ali', 'British', '1987-06-18', 'ALLROUNDER'),
(21, 'Stuart', NULL, 'Broad', 'British', '1986-06-24', 'BOWLER'),
(22, 'Ollie', NULL, 'Robinson', 'British', '1993-12-01', 'BOWLER'),
(23, 'James', NULL, 'Anderson', 'British', '1982-07-30', 'BOWLER'),
(24, 'David', NULL, 'Warner', 'Australian', '1986-10-27', 'BATSMAN'),
(25, 'Usman', NULL, 'Khwaja', 'Australian', '1986-12-18', 'BATSMAN'),
(26, 'Marnus', NULL, 'Labuschagne', 'Australian', '1994-06-22', 'BATSMAN'),
(27, 'Steven', NULL, 'Smith', 'Australian', '1989-06-02', 'BATSMAN'),
(28, 'Travis', NULL, 'Head', 'Australian', '1993-12-29', 'BATSMAN'),
(29, 'Cameron', NULL, 'Green', 'Australian', '1999-06-03', 'ALLROUNDER'),
(30, 'Alex', NULL, 'Carey', 'Australian', '1991-08-27', 'WK-BATSMAN'),
(31, 'Pat', NULL, 'Cummins', 'Australian', '1993-05-08', 'BOWLER'),
(32, 'Nathan', NULL, 'Lyon', 'Australian', '1987-11-20', 'BOWLER'),
(33, 'Josh', NULL, 'Hazelwood', 'Australian', '1991-01-08', 'BOWLER'),
(34, 'Scott', NULL, 'Boland', 'Australian', '1989-04-11', 'BOWLER'),
(35, 'Pathum', NULL, 'Nissanka', 'SriLankan', '1998-05-18', 'BATSMAN'),
(36, 'Kusal', NULL, 'Perera', 'SriLankan', '1990-08-17', 'BATSMAN'),
(37, 'Kusal', NULL, 'Mendis', 'SriLankan', '1995-02-02', 'WK-BATSMAN'),
(38, 'Sadeera', NULL, 'Samarawickrama', 'SriLankan', '1995-08-30', 'WK-BATSMAN'),
(39, 'Charith', NULL, 'Asalanka', 'SriLankan', '1997-06-29', 'ALLROUNDER'),
(40, 'Dhananjaya', 'de', 'Silva', 'SriLankan', '1991-09-06', 'ALLROUNDER'),
(41, 'Dasun', NULL, 'Shanaka', 'SriLankan', '1991-09-09', 'ALLROUNDER'),
(42, 'Dunith', NULL, 'Wellalage', 'SriLankan', '2003-01-09', 'ALLROUNDER'),
(43, 'Meheesh', NULL, 'Theekashana', 'SriLankan', '2000-08-01', 'BOWLER'),
(44, 'Matheesha', NULL, 'Pathirana', 'SriLankan', '2002-12-18', 'BOWLER'),
(45, 'Dilshan', NULL, 'Madhushanka', 'SriLankan', '2000-09-18', 'BOWLER');

INSERT INTO MATCHES (MATCH_ID, MATCH_DATE, MATCH_TIME, MATCH_FORMAT, NO_OF_SPECTATORS) VALUES
(1, '2023-06-16', '10:00:00', 'ODI', 25125),
(2, '2024-07-15', '20:00:00', 'T20', 65367),
(3, '2024-07-17', '20:00:00', 'T20', 55096),
(4, '2024-07-20', '20:00:00', 'T20', 83659);

INSERT INTO MATCH_UMPIRES (MATCH_ID, UMPIRE_ID) VALUES
(1, 5),
(1, 6),
(1, 1),
(2, 2),
(2, 3),
(2, 4),
(3, 8),
(3, 3),
(3, 4),
(4, 5),
(4, 6),
(4, 8);

INSERT INTO POINTS_TABLE (LEAGUE_ID, TEAM_ID, MATCH_PLAYED, MATCHES_WON, MATCHES_LOST, POINTS) VALUES
(1, 2, 1, 1, 0, 2),
(1, 3, 1, 0, 1, 0),
(2, 1, 2, 2, 0, 4),
(2, 3, 2, 1, 1, 2),
(2, 4, 2, 0, 2, 0);

INSERT INTO PLAYER_STATS (PLAYER_ID, MATCH_ID, RUNS, WICKETS, NO_OF_SIXES, NO_OF_FOURS, OVERS_BOWLED, STRIKE_RATE, BALLS_FACED, ECONOMY) VALUES
(13, 1, 33, 0, 1, 4, 0, 94.29, 35, 0),
(14, 1, 14, 0, 0, 2, 0, 58.83, 24, 0),
(15, 1, 77, 0, 1, 4, 0, 89.53, 86, 0),
(16, 1, 25, 0, 1, 4, 0, 156.25, 16, 0),
(17, 1, 11, 0, 0, 1, 9.2, 64.71, 17, 6.40),
(18, 1, 43, 0, 2, 2, 0, 102.38, 42, 0),
(19, 1, 20, 0, 0, 3, 3, 90.91, 22, 8.00),
(20, 1, 14, 1, 0, 0, 6, 73.68, 19, 7.80),
(21, 1, 11, 0, 0, 1, 6, 91.67, 12, 7.50),
(22, 1, 15, 0, 1, 0, 7, 115.38, 13, 6.70),
(23, 1, 13, 0, 0, 0, 5, 92.86, 14, 11.00),
(24, 1, 152, 0, 3, 16, 0, 125.62, 121, 0),
(25, 1, 0, 0, 0, 0, 0, 0, 1, 0),
(26, 1, 123, 1, 5, 11, 10, 128.12, 96, 7.60),
(27, 1, 0, 0, 0, 0, 0, 0, 0, 0),
(28, 1, 0, 0, 0, 0, 0, 0, 0, 0),
(29, 1, 0, 2, 0, 0, 3, 0, 0, 5.70),
(30, 1, 0, 0, 0, 0, 0, 0, 0, 0),
(31, 1, 0, 0, 0, 0, 7, 0, 0, 8.00),
(32, 1, 0, 2, 0, 0, 10, 0, 0, 3.70),
(33, 1, 0, 3, 0, 0, 10, 0, 0, 4.80),
(34, 1, 0, 1, 0, 0, 10, 0, 0, 4.80),
(1, 2, 37, 0, 2, 3, 0, 127.59, 29, 0),
(2, 2, 7, 0, 0, 1, 0, 140.00, 5, 0),
(3, 2, 7, 0, 0, 1, 0, 70.00, 10, 0),
(4, 2, 5, 0, 0, 0, 0, 83.33, 6, 0),
(5, 2, 29, 0, 0, 4, 3, 107.41, 27, 4.00),
(6, 2, 41, 0, 4, 1, 0, 178.26, 23, 0),
(7, 2, 31, 0, 1, 3, 3, 155.00, 20, 10.30),
(8, 2, 0, 2, 0, 0, 4, 0, 0, 10.20),
(9, 2, 0, 4, 0, 0, 4, 0, 0, 5.50),
(10, 2, 0, 2, 0, 0, 4, 0, 0, 6.80),
(11, 2, 0, 2, 0, 0, 2, 0, 0, 13.00),
(35, 2, 1, 0, 0, 0, 0, 33.33, 3, 0),
(36, 2, 28, 0, 0, 5, 0, 112.00, 25, 0),
(37, 2, 8, 1, 0, 2, 1, 133.33, 6, 6.00),
(38, 2, 12, 0, 1, 1, 0, 80.00, 15, 0),
(39, 2, 10, 0, 0, 1, 0, 90.91, 11, 0),
(40, 2, 45, 0, 3, 3, 0, 166.67, 27, 0),
(41, 2, 21, 1, 2, 1, 4, 210.00, 10, 5.50),
(42, 2, 23, 1, 2, 0, 3, 143.75, 16, 7.30),
(43, 2, 1, 1, 0, 0, 4, 25.00, 4, 7.20),
(44, 2, 5, 0, 0, 0, 4, 125.00, 4, 11.80),
(45, 2, 0, 1, 0, 0, 4, 0, 0, 8.80),
(35, 3, 11, 0, 0, 2, 0, 110.00, 10, 0),
(36, 3, 19, 0, 1, 1, 0, 118.75, 16, 0),
(37, 3, 6, 0, 0, 1, 0, 200.00, 3, 0),
(38, 3, 51, 1, 2, 5, 2, 127.50, 40, 7.00),
(39, 3, 59, 0, 0, 9, 0, 168.57, 35, 0),
(40, 3, 17, 0, 1, 1, 0, 154.55, 11, 0),
(41, 3, 1, 1, 0, 0, 4, 100.00, 1, 9.50),
(42, 3, 4, 0, 0, 1, 2, 133.33, 3, 13.50),
(43, 3, 4, 2, 0, 1, 4, 400.00, 1, 7.80),
(44, 3, 0, 1, 0, 0, 3.1, 0, 0, 8.50),
(45, 3, 0, 0, 0, 0, 4, 0, 0, 9.20),
(13, 3, 63, 0, 1, 11, 0, 190.91, 33, 0),
(14, 3, 50, 0, 4, 5, 0, 178.57, 28, 0),
(15, 3, 7, 0, 0, 1, 0, 116.67, 6, 0),
(16, 3, 19, 0, 0, 1, 4, 118.75, 16, 7.20),
(17, 3, 13, 0, 0, 1, 0, 72.22, 18, 0),
(18, 3, 14, 0, 0, 1, 0, 116.67, 12, 0),
(19, 3, 1, 2, 0, 0, 4, 50.00, 2, 9.80),
(20, 3, 0, 1, 0, 0, 2, 0, 0, 12.50),
(21, 3, 0, 1, 0, 0, 4, 0, 0, 10.00),
(22, 3, 0, 1, 0, 0, 2, 0, 0, 8.00),
(23, 3, 0, 1, 0, 0, 4, 0, 0, 6.80),
(1, 4, 57, 0, 2, 6, 0, 146.15, 39, 0),
(2, 4, 9, 0, 1, 0, 0, 100.00, 9, 0),
(3, 4, 4, 0, 0, 0, 0, 66.67, 6, 0),
(4, 4, 47, 0, 2, 4, 0, 130.56, 36, 0),
(5, 4, 23, 0, 2, 1, 1, 176.92, 13, 14.00),
(6, 4, 17, 0, 0, 2, 3, 188.89, 9, 5.30),
(7, 4, 0, 0, 0, 0, 0, 0, 1, 0),
(8, 4, 10, 3, 1, 0, 4, 166.67, 6, 5.80),
(9, 4, 1, 0, 0, 0, 2, 100.00, 1, 8.50),
(10, 4, 0, 3, 0, 0, 4, 0, 0, 4.80),
(11, 4, 0, 2, 0, 0, 2.4, 0, 0, 4.50),
(13, 4, 5, 0, 0, 0, 0, 62.50, 8, 0),
(14, 4, 23, 0, 0, 4, 0, 153.33, 15, 0),
(15, 4, 8, 0, 0, 0, 0, 80.00, 10, 0),
(16, 4, 0, 0, 0, 0, 0, 0, 3, 0),
(17, 4, 25, 0, 0, 3, 0, 131.58, 19, 0),
(18, 4, 2, 1, 0, 0, 2, 50.00, 4, 12.50),
(19, 4, 11, 0, 0, 0, 4, 68.75, 16, 6.00),
(20, 4, 1, 3, 0, 0, 3, 20.00, 5, 12.30),
(21, 4, 21, 1, 2, 1, 4, 140.00, 15, 8.20),
(22, 4, 2, 1, 0, 0, 4, 100.00, 2, 6.20),
(23, 4, 3, 1, 0, 0, 3, 100.00, 3, 8.30);

INSERT INTO TEAM_STATS (MATCH_ID, TEAM_ID, RUNS, WICKETS, NO_OF_SIXES, NO_OF_FOURS, NO_OF_EXTRAS, OVERS, RUN_RATE) VALUES
(1, 3, 282, 9, 6, 21, 6, 50, 5.78),
(1, 2, 283, 1, 8, 30, 8, 36.2, 7.82),
(2, 1, 162, 5, 7, 13, 5, 20, 8.10),
(2, 4, 160, 10, 8, 14, 6, 20, 8.00),
(3, 4, 179, 7, 4, 21, 7, 20, 8.95),
(3, 3, 180, 5, 5, 20, 13, 19.1, 9.39),
(4, 1, 171, 7, 8, 13, 3, 20, 8.55),
(4, 3, 103, 10, 2, 8, 2, 16.4, 6.28);

INSERT INTO MATCH_EVENT (LEAGUE_ID, MATCH_ID, TEAM_ID) VALUES
(1, 1, 2),
(1, 1, 3),
(2, 2, 4),
(2, 2, 1),
(2, 3, 4),
(2, 3, 3),
(2, 4, 1),
(2, 4, 3);

INSERT INTO MATCH_LOCATION (MATCH_ID, STADIUM_NAME) VALUES
(1, 'Sydney Cricket Ground'),
(2, 'Wankhede Stadium'),
(3, 'Eden Gardens'),
(4, 'Narendra Modi Stadium');

INSERT INTO TEAM_LEAGUE_PARTICIPATION (TEAM_ID, PLAYER_ID, LEAGUE_ID) VALUES 
(1, 1, 2), (1, 2, 2), (1, 3, 2), (1, 4, 2), (1, 5, 2), (1, 6, 2),
(1, 7, 2), (1, 8, 2), (1, 9, 2), (1, 10, 2), (1, 11, 2),
(2, 24, 1), (2, 25, 1), (2, 26, 1), (2, 27, 1), (2, 28, 1), (2, 29, 1),
(2, 30, 1), (2, 31, 1), (2, 32, 1), (2, 33, 1), (2, 34, 1),
(3, 13, 1), (3, 14, 1), (3, 15, 1), (3, 16, 1), (3, 17, 1), (3, 18, 1),
(3, 19, 1), (3, 20, 1), (3, 21, 1), (3, 22, 1), (3, 23, 1),
(3, 13, 2), (3, 14, 2), (3, 15, 2), (3, 16, 2), (3, 17, 2), (3, 18, 2),
(3, 19, 2), (3, 20, 2), (3, 21, 2), (3, 22, 2), (3, 23, 2),
(4, 35, 2), (4, 36, 2), (4, 37, 2), (4, 38, 2), (4, 39, 2), (4, 40, 2),
(4, 41, 2), (4, 42, 2), (4, 43, 2), (4, 44, 2), (4, 45, 2);

INSERT INTO HIGHLIGHTS (HIGHLIGHT_NO, TITLE, CLIP, MATCH_ID)
VALUES 
(1, 'ENGLAND VS AUSTRALIA', 'https://youtu.be/MZbvx1wUMXc?si=8SdRuMvsgstSGweE', 1),
(2, 'INDIA VS SRILANKA PAYTM TRI-SERIES', 'https://youtu.be/X4gfyBUcJtE?si=aH3Jb9qiqiPnV8Nw', 2),
(3, 'SRILANKA VS ENGLAND PAYTM TRI-SERIES', 'https://youtu.be/MMU3-nsKhEs?si=8690mK0l_DaKgEZW', 3),
(4, 'INDIA VS ENGLAND PAYTM TRI-SERIES', 'https://youtu.be/gL_LIAm22Mc?si=d1uD-csn-h3W_5rr', 4);