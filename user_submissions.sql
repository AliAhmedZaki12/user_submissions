
IF OBJECT_ID('user_submissions', 'U') IS NOT NULL
    DROP TABLE user_submissions;

CREATE TABLE user_submissions (
    id INT IDENTITY PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at DATETIME,
    username NVARCHAR(50)
);

SELECT 
    username,
    COUNT(id) AS total_submissions,
    ISNULL(SUM(points), 0) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;

SELECT 
    CONVERT(DATE, submitted_at) AS day,
    username,
    CAST(AVG(CAST(points AS FLOAT)) AS DECIMAL(10, 2)) AS daily_avg_points
FROM user_submissions
GROUP BY CONVERT(DATE, submitted_at), username
ORDER BY username, day;

WITH daily_submissions AS (
    SELECT 
        CONVERT(DATE, submitted_at) AS daily,
        username,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions
    FROM user_submissions
    GROUP BY CONVERT(DATE, submitted_at), username
),
ranked_users AS (
    SELECT 
        daily,
        username,
        correct_submissions,
        RANK() OVER (PARTITION BY daily ORDER BY correct_submissions DESC) AS rank
    FROM daily_submissions
)
SELECT 
    daily,
    username,
    correct_submissions
FROM ranked_users
WHERE rank <= 3
ORDER BY daily, rank;

SELECT TOP 5
    username,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_submissions,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions,
    SUM(CASE WHEN points < 0 THEN points ELSE 0 END) AS incorrect_points,
    SUM(CASE WHEN points > 0 THEN points ELSE 0 END) AS correct_points,
    ISNULL(SUM(points), 0) AS total_points
FROM user_submissions
GROUP BY username
ORDER BY incorrect_submissions DESC;

WITH weekly_performance AS (
    SELECT 
        DATEPART(WEEK, submitted_at) AS week_no,
        username,
        SUM(points) AS total_points_earned
    FROM user_submissions
    GROUP BY DATEPART(WEEK, submitted_at), username
),
ranked_weekly AS (
    SELECT 
        week_no,
        username,
        total_points_earned,
        RANK() OVER (PARTITION BY week_no ORDER BY total_points_earned DESC) AS rank
    FROM weekly_performance
)
SELECT 
    week_no,
    username,
    total_points_earned
FROM ranked_weekly
WHERE rank <= 10
ORDER BY week_no, rank;