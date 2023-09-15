  drop database WonderWomenFootball;
CREATE DATABASE WonderWomenFootball;
-- Switch to the database
USE WonderWomenFootball;
-- Create the League table
CREATE TABLE league (
league_id INT AUTO_INCREMENT PRIMARY KEY,
l_name VARCHAR (70),
season VARCHAR (50),
start_date DATE,
end_date DATE
);
-- Populate league table
INSERT INTO league
(l_name, season, start_date, end_date)
VALUES
('English Diva cup', 'Season 1', '2023-03-19' ,'2023-05-28');
SELECT * FROM league;
-- Create the Stadium table
CREATE TABLE stadium (
stadium_id INT PRIMARY KEY,
s_name VARCHAR (50),
location VARCHAR (50),
year_opened YEAR,
surface_type VARCHAR (50),
capacity INT
);
-- Populate stadium table
INSERT INTO stadium
VALUES
(101,'Rose Bowl', 'USA', '1922', 'Grass', 92542),
(201,'Olympiastadion', 'Germany', '1936', 'Grass', 74475),
(301,'Wembley Stadium', 'England', '2007', 'Turf', 90000),
(401,'Parc des Princes', 'France', '1972', 'Turf', 47929);
SELECT * FROM stadium;
-- Create the Team table
CREATE TABLE team (
team_id INT AUTO_INCREMENT PRIMARY KEY,
t_name VARCHAR(50) NOT NULL,
coach VARCHAR(50),
home_stadium INT,
league_id INT,
FOREIGN KEY (home_stadium) REFERENCES stadium (stadium_id),
FOREIGN KEY (league_id) REFERENCES league(league_id)
);
-- Populate the Team table
INSERT INTO team (t_name, coach, home_stadium, league_id)
-- notice that team_id is not mentioned here
VALUES
('USA Falcons', 'Alex Morgan', 101, 1),
('German Tigresses', 'Martina Mueller', 201, 1),
('English Lionesses', 'Karen Taylor', 301, 1),
('French Sirens', 'Eugenie Le Sommer', 401, 1);
-- We only have one league this season that has four teams meaning we will have 12 matches
SELECT * FROM team;
-- Create the Player table
CREATE TABLE player (
player_id VARCHAR(50) PRIMARY KEY,
p_name VARCHAR(50) NOT NULL,
p_position VARCHAR(20),
p_number INT,
team_id INT,
FOREIGN KEY (team_id) REFERENCES team (team_id)
);
-- Populate the Player table
INSERT INTO player
-- Players for US
VALUES
('US1', 'Emma Johnson', 'Forward', 9, 1),
('US2', 'Sophie Williams', 'Midfielder', 7, 1),
('US3', 'Olivia Smith', 'Defender', 5, 1),
('US4', 'Emily Davis', 'Goalkeeper', 1, 1),
-- Players for germany
('GR1', 'Lucy Wilson', 'Forward', 10, 2),
('GR2','Mia Taylor', 'Midfielder', 3, 2),
('GR3','Chloe Roberts', 'Defender', 8, 2),
('GR4','Oliver Green', 'Goalkeeper', 1, 2),
-- Players for england
('EN1', 'Ava Turner', 'Forward', 9, 3),
('EN2','Lily Anderson', 'Midfielder', 7, 3),
('EN3','Ella White', 'Defender', 4, 3),
('EN4','Isabella Harris', 'Goalkeeper', 1, 3),
-- Players for france
('FR1', 'Amelia Walker', 'Forward', 6, 4),
('FR2', 'Mia Roberts', 'Midfielder', 9, 4),
('FR3', 'Charlotte Turner', 'Defender', 2, 4),
('FR4', 'Grace Smith', 'Goalkeeper', 1, 4);
SELECT * FROM player;
 -- Create the Matches table
CREATE TABLE matches (
match_id INT PRIMARY KEY,
match_date DATE,
stadium_id INT,
attendees INT,
team1_id INT,
team2_id INT,
team1_score INT,
team2_score INT,
FOREIGN KEY (stadium_id) REFERENCES stadium (stadium_id),
FOREIGN KEY (team1_id) REFERENCES team(team_id),
FOREIGN KEY (team2_id) REFERENCES team(team_id)
);
-- Populate the Matches table
INSERT INTO matches
VALUES
(001, '2023-03-19', 101, 87000, 1, 2, 3, 2),
(002, '2023-03-27', 201, 40200, 2, 1, 1, 2),
(003, '2023-04-06', 101, 42000, 1, 3, 1, 2),
(004, '2023-04-15', 301, 89500, 3, 1, 1, 0),
(005, '2023-04-16', 401, 47900, 4, 1, 1, 1),
(006, '2023-04-24', 101, 40000, 1, 4, 2, 0),
(007, '2023-05-04', 301, 38000, 3, 2, 1, 3),
(008, '2023-05-13', 201, 73900, 2, 3, 2, 0),
(009, '2023-05-14', 401, 47920, 4, 2, 1, 0),
(010, '2023-05-22', 201, 32000, 2, 4, 1, 1),
(011, '2023-05-25', 301, 40650, 3, 4, 4, 5),
(012, '2023-05-28', 401, 47927, 4, 3, 2, 1);
-- Using the DDl (ALTER) and using a DATE function
ALTER TABLE Matches
ADD COLUMN day_of_week VARCHAR (20) AFTER match_date;
UPDATE matches
SET day_of_week = dayname(match_date);
SELECT * FROM matches;
-- Create league standings table
CREATE TABLE league_standings (
standings_id VARCHAR(5) PRIMARY KEY,
league_id INT,
team_id INT,
matches_played INT,
wins INT,
draws INT,
losses INT,
points INT,
FOREIGN KEY (league_id) REFERENCES league (league_id),
FOREIGN KEY (team_id) REFERENCES team (team_id)
);
INSERT INTO league_standings
VALUES
('S001', 1, 1, NULL, NULL, NULL, NULL, NULL),
('S002', 1 ,2, NULL, NULL, NULL, NULL, NULL),
('S003', 1 ,3, NULL, NULL, NULL, NULL, NULL),
('S004', 1 ,4, NULL, NULL, NULL, NULL, NULL);
-- Query for filling in the matches played column in the ls table
SELECT * FROM league_standings;
UPDATE league_standings ls
JOIN (
    SELECT
        team_id,
        COUNT(*) AS matches_played
    FROM (
        SELECT team1_id AS team_id FROM Matches
        UNION ALL
        SELECT team2_id AS team_id FROM Matches
    ) all_teams
    GROUP BY team_id
) match_counts
ON ls.team_id = match_counts.team_id
SET ls.matches_played = match_counts.matches_played;
SELECT * FROM league_standings;
-- Query to fill in the wins column
UPDATE league_standings ls
SET ls.wins = (
    SELECT COUNT(*)
    FROM Matches
    WHERE (
        (ls.team_id = team1_id AND team1_score > team2_score) OR
        (ls.team_id = team2_id AND team2_score > team1_score)
    )
);
SELECT * FROM league_standings;
-- Query to fill in the losses column
UPDATE league_standings ls
SET ls.losses = (
    SELECT COUNT(*)
    FROM Matches
    WHERE (
        (ls.team_id = team1_id AND team1_score < team2_score) OR
        (ls.team_id = team2_id AND team2_score < team1_score)
    )
);
SELECT * FROM league_standings;
-- Query to fll in the draws column
UPDATE league_standings ls
SET ls.draws = (
    SELECT COUNT(*)
    FROM Matches
    WHERE (
        (ls.team_id = team1_id AND team1_score = team2_score) OR
        (ls.team_id = team2_id AND team2_score = team1_score)
    )
);
SELECT * FROM league_standings;
-- Query to fill in the points column
UPDATE league_standings ls
SET ls.points = (ls.wins * 3) + ls.draws;
SELECT * FROM league_standings;
-- Create the PlayerStats table only for the year 2023
CREATE TABLE playerstats (
playerstats_id VARCHAR (5) PRIMARY KEY,
player_id VARCHAR(50),
match_id INT,
team_id INT,
goals_scored INT,
assists INT,
yellow_cards INT,
red_cards INT,
FOREIGN KEY (player_id) REFERENCES player (player_id),
FOREIGN KEY (match_id) REFERENCES matches (match_id),
FOREIGN KEY (team_id) REFERENCES team (team_id)
);
-- Populate the PlayerStats table
INSERT INTO PlayerStats
VALUES
('PS01', 'US1', 1, 1, 2, 1, 0, 0),
('PS02', 'US2', 1, 1, 1, 2, 0, 0),
('PS03', 'US3', 1, 1, 0, 0, 0, 0),
('PS04', 'US4', 1, 1, 0, 0, 0, 0),
('PS05', 'GR1', 1, 2, 2, 0, 1, 0),
('PS06', 'GR2', 1, 2, 0, 2, 0, 0),
('PS07', 'GR3', 1, 2, 0, 0, 0, 0),
('PS08', 'GR4', 1, 2, 0, 0, 1, 0),

('PS09', 'US1', 2, 1, 2, 0, 0, 0),
('PS10', 'US2', 2, 1, 0, 2, 0, 0),
('PS11', 'US3', 2, 1, 0, 0, 1, 0),
('PS12', 'US4', 2, 1, 0, 0, 0, 0),
('PS13', 'GR1', 2, 2, 0, 0, 0, 0),
('PS14', 'GR2', 2, 2, 1, 0, 0, 0),
('PS15', 'GR3', 2, 2, 0, 1, 0, 0),
('PS16', 'GR4', 2, 2, 0, 0, 0, 1),

('PS17', 'US1', 3, 1, 0, 1, 0, 0),
('PS18', 'US2', 3, 1, 1, 0, 0, 0),
('PS19', 'US3', 3, 1, 0, 0, 0, 0),
('PS20', 'US4', 3, 1, 0, 0, 0, 0),
('PS21', 'EN1', 3, 3, 1, 0, 0, 0),
('PS22', 'EN2', 3, 3, 1, 1, 1, 0),
('PS23', 'EN3', 3, 3, 0, 0, 0, 0),
('PS24', 'EN4', 3, 3, 0, 0, 0, 0),

('PS25', 'US1', 4, 1, 0, 0, 1, 0),
('PS26', 'US2', 4, 1, 0, 0, 0, 0),
('PS27', 'US3', 4, 1, 0, 0, 0, 0),
('PS28', 'US4', 4, 1, 0, 0, 0, 0),
('PS29', 'EN1', 4, 3, 1, 0, 1, 0),
('PS30', 'EN2', 4, 3, 0, 1, 0, 0),
('PS31', 'EN3', 4, 3, 0, 0, 0, 0),
('PS32', 'EN4', 4, 3, 0, 0, 0, 0),

('PS33', 'US1', 5, 1, 1, 0, 0, 0),
('PS34', 'US2', 5, 1, 0, 1, 1, 0),
('PS35', 'US3', 5, 1, 0, 0, 0, 0),
('PS36', 'US4', 5, 1, 0, 0, 0, 0),
('PS37', 'FR1', 5, 4, 1, 0, 0, 0),
('PS38', 'FR2', 5, 4, 0, 1, 2, 0),
('PS39', 'FR3', 5, 4, 0, 0, 0, 0),
('PS40', 'FR4', 5, 4, 0, 0, 0, 0),

('PS41', 'US1', 6, 1, 0, 1, 0, 0),
('PS42', 'US2', 6, 1, 1, 1, 0, 0),
('PS43', 'US3', 6, 1, 1, 0, 0, 0),
('PS44', 'US4', 6, 1, 0, 0, 0, 0),
('PS45', 'FR1', 6, 4, 0, 0, 0, 0),
('PS46', 'FR2', 6, 4, 0, 0, 0, 0),
('PS47', 'FR3', 6, 4, 0, 0, 0, 0),
('PS48', 'FR4', 6, 4, 0, 0, 0, 0),

('PS49', 'GR1', 7, 2, 1, 1, 0, 0),
('PS50', 'GR2', 7, 2, 1, 2, 0, 0),
('PS51', 'GR3', 7, 2, 1, 0, 1, 0),
('PS52', 'GR4', 7, 2, 0, 0, 0, 0),
('PS53', 'EN1', 7, 3, 1, 0, 0, 0),
('PS54', 'EN2', 7, 3, 0, 1, 0, 0),
('PS55', 'EN3', 7, 3, 0, 0, 0, 0),
('PS56', 'EN4', 7, 3, 0, 0, 0, 0),

('PS57', 'GR1', 8, 2, 1, 0, 0, 0),
('PS58', 'GR2', 8, 2, 1, 1, 0, 0),
('PS59', 'GR3', 8, 2, 0, 0, 0, 0),
('PS60', 'GR4', 8, 2, 0, 0, 0, 0),
('PS61', 'EN1', 8, 3, 0, 0, 0, 0),
('PS62', 'EN2', 8, 3, 0, 0, 0, 0),
('PS63', 'EN3', 8, 3, 0, 0, 0, 0),
('PS64', 'EN4', 8, 3, 0, 0, 0, 0),

('PS65', 'GR1', 9, 2, 0, 0, 0, 0),
('PS66', 'GR2', 9, 2, 0, 0, 0, 0),
('PS67', 'GR3', 9, 2, 0, 0, 0, 0),
('PS68', 'GR4', 9, 2, 0, 0, 1, 0),
('PS69', 'FR1', 9, 4, 1, 0, 0, 0),
('PS70', 'FR2', 9, 4, 0, 1, 0, 0),
('PS71', 'FR3', 9, 4, 0, 0, 0, 0),
('PS72', 'FR4', 9, 4, 0, 0, 0, 0),

('PS73', 'GR1', 10, 2, 0, 1, 0, 0),
('PS74', 'GR2', 10, 2, 1, 0, 0, 0),
('PS75', 'GR3', 10, 2, 0, 0, 0, 0),
('PS76', 'GR4', 10, 2, 0, 0, 0, 0),
('PS77', 'FR1', 10, 4, 1, 0, 0, 0),
('PS78', 'FR2', 10, 4, 0, 1, 1, 0),
('PS79', 'FR3', 10, 4, 0, 0, 0, 0),
('PS80', 'FR4', 10, 4, 0, 0, 0, 0),

('PS81', 'EN1', 11, 3, 2, 1, 0, 0),
('PS82', 'EN2', 11, 3, 1, 3, 0, 0),
('PS83', 'EN3', 11, 3, 1, 0, 0, 0),
('PS84', 'EN4', 11, 3, 0, 0, 0, 0),
('PS85', 'FR1', 11, 4, 3, 3, 2, 0),
('PS86', 'FR2', 11, 4, 1, 2, 3, 0),
('PS87', 'FR3', 11, 4, 0, 0, 0, 0),
('PS88', 'FR4', 11, 4, 0, 0, 0, 0),

('PS89', 'EN1', 12, 3, 1, 0, 0, 0),
('PS90', 'EN2', 12, 3, 0, 1, 0, 0),
('PS91', 'EN3', 12, 3, 0, 0, 0, 0),
('PS92', 'EN4', 12, 3, 0, 0, 0, 0),
('PS93', 'FR1', 12, 4, 2, 0, 0, 1),
('PS94', 'FR2', 12, 4, 0, 2, 0, 0),
('PS95', 'FR3', 12, 4, 0, 0, 0, 0),
('PS96', 'FR4', 12, 4, 0, 0, 0, 0);
SELECT * FROM playerstats;
-- Stored procedure to calcultae the attendance percentage per match in every stadium
DELIMITER $$
CREATE PROCEDURE `CalculateAttendancePercentage`()
BEGIN
    SELECT
        m.match_id,
        m.match_date,
        m.day_of_week,
        m.stadium_id,
        m.attendees,
        s.capacity,
        ROUND((m.attendees / s.capacity) * 100) AS AttendancePercentage
    FROM
        matches m
    JOIN
        stadium s ON m.stadium_id = s.stadium_id;
END $$
DELIMITER ;
CALL CalculateAttendancePercentage();
-- Create trigger that updates the league standings table whenever a match is inserted in the matches table
DELIMITER $$
CREATE TRIGGER after_insert_match
AFTER INSERT ON Matches
FOR EACH ROW
BEGIN
    UPDATE league_standings ls
    SET
        ls.wins = (
            SELECT COUNT(*)
            FROM Matches
            WHERE (
                (ls.team_id = NEW.team1_id AND team1_score > team2_score) OR
                (ls.team_id = NEW.team2_id AND team2_score > team1_score)
            )
        ),
        ls.losses = (
            SELECT COUNT(*)
            FROM Matches
            WHERE (
                (ls.team_id = NEW.team1_id AND team1_score < team2_score) OR
                (ls.team_id = NEW.team2_id AND team2_score < team1_score)
            )
        ),
        ls.draws = (
            SELECT COUNT(*)
            FROM Matches
            WHERE (
                (ls.team_id = NEW.team1_id AND team1_score = team2_score) OR
                (ls.team_id = NEW.team2_id AND team2_score = team1_score)
            )
        ),
        ls.points = (
            (ls.wins * 3) + ls.draws
        )
    WHERE ls.team_id = NEW.team1_id OR ls.team_id = NEW.team2_id;
END $$
DELIMITER ; 

-- List of teams ordered by points, showing red and yellow cards, finding the most aggressive team on the pitch
SELECT t.t_name, ls.points, SUM(ps.yellow_cards) AS yellow_cards, SUM(ps.red_cards) AS red_cards
FROM team AS t
JOIN league_standings AS ls
ON t.team_id = ls.team_id
JOIN playerstats AS ps
ON t.team_id = ps.team_id
GROUP BY t.t_name, ls.points
ORDER BY ls.points DESC;

-- average % attendance at matches by day of week
/* weekends seem to be popular for obvious reasons*/
SELECT m.day_of_week, ROUND(AVG(m.attendees/s.capacity*100)) AS average_percentage_attendance
FROM matches AS m
LEFT JOIN stadium AS s ON
m.stadium_id = s.stadium_id
GROUP BY day_of_week
ORDER BY average_percentage_attendance DESC;

-- List of players that scored goals in the league, highest scorer first
/*Forwards tend to score more, and midfielders assist (create opportunities for scoring, as evident in the table, player with more assists means she creates more opportunities for scoring)*/
CREATE VIEW highest_scorers_view AS
SELECT p.p_name as player_name, ANY_VALUE(t.t_name) as team, ANY_VALUE(p.p_position) as player_position, SUM(ps.goals_scored) as goals, SUM(ps.assists) as assists
FROM playerstats AS ps
JOIN player AS p
ON ps.player_id = p.player_id
JOIN team AS t
ON p.team_id = t.team_id
WHERE ps.goals_scored > 0
GROUP BY p.p_name
ORDER BY goals DESC;

SELECT * FROM highest_scorers_view;
-- simple query to extract information from highest_scorers_view, checking if any defenders scored goals
SELECT player_name, team, player_position, goals
FROM highest_scorers_view
WHERE player_position = 'Defender' AND goals > 0; 

/* total number of goals conceded by teams, which is different than the winning team, because winning team depends on number of matches won regardless of goals
France is the winning team based on number of matches won but conceded more goals than Germany */
SELECT
    t.t_name AS team_name, ls.points as team_points,
    SUM(CASE WHEN m.team1_id = t.team_id THEN m.team2_score ELSE m.team1_score END) AS goals_conceded
FROM team AS t
JOIN matches AS m ON t.team_id = m.team1_id OR t.team_id = m.team2_id
JOIN league_standings AS ls
ON t.team_id = ls.team_id
GROUP BY t.t_name, ls.points
ORDER BY goals_conceded DESC;
