
# **User Submissions Analysis**

## **Project Overview**  
This project provides a comprehensive analysis of user submissions stored in a SQL database. The analysis focuses on tracking user performance, including the number of submissions, points earned, and rankings based on various metrics like daily and weekly performance. The results are generated using SQL queries and can be used for leaderboard generation, performance tracking, or general insights.

---

## **Database Schema**  
### **Table: `user_submissions`**  
The project uses a single table named `user_submissions` with the following structure:  
- **`id`**: Unique identifier for each submission (Primary Key).  
- **`user_id`**: Identifier for the user.  
- **`question_id`**: Identifier for the question.  
- **`points`**: Points earned or lost for each submission.  
- **`submitted_at`**: Date and time of the submission.  
- **`username`**: Username of the submitting user.  

---

## **Key Features and SQL Queries**  

### 1. **Total Submissions and Points Earned Per User**  
This query calculates the total submissions and total points earned by each user.  
```sql
SELECT 
    username,
    COUNT(id) AS total_submissions,
    ISNULL(SUM(points), 0) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;
```  

### 2. **Daily Average Points Per User**  
This query computes the daily average points for each user.  
```sql
SELECT 
    CONVERT(DATE, submitted_at) AS day,
    username,
    CAST(AVG(CAST(points AS FLOAT)) AS DECIMAL(10, 2)) AS daily_avg_points
FROM user_submissions
GROUP BY CONVERT(DATE, submitted_at), username
ORDER BY username, day;
```  

### 3. **Top 3 Users Daily (Based on Correct Submissions)**  
This query identifies the top 3 users daily, ranked by the number of correct submissions.  
```sql
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
```  

### 4. **Incorrect and Correct Submissions Statistics for Top 5 Users**  
This query provides statistics about incorrect and correct submissions for the top 5 users with the most incorrect submissions.  
```sql
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
```  

### 5. **Top 10 Weekly Performers (Based on Total Points Earned)**  
This query determines the top 10 users each week based on their total points earned.  
```sql
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
```  

---

## **How to Use This Project**  
1. **Setup the Database**:  
   - Create the `user_submissions` table using the provided schema.  
   - Insert the required data into the table.  

2. **Run the Queries**:  
   - Execute the SQL queries to analyze user performance.  
   - Use the results for leaderboard creation or performance insights.  

3. **Applications**:  
   - Generate reports on user activity.  
   - Identify top performers on a daily or weekly basis.  
   - Gain insights into user engagement and trends.  

