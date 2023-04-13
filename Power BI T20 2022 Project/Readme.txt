# Dashboard https://www.novypro.com/project/2022-world-cup-analysis

Project Overview:
The dataset used for this Power BI project is based on the 2022 T20 World Cup, containing match details of qualifiers and super 12. The goal of the project is to select the best players from the World Cup as a balanced team of 11, consisting of batsmen (power hitters, anchors, finishers), all-rounders, and bowlers (fast and spin). The project takes into consideration the position of the players, their performance in the World Cup, the parameters for each role, and the innings they played. The parameters are given in the "Parameter Scoping.pdf" file.

Data Gathering:
The data was scraped from ESPN using Bright Data in JSON format. The URL used for scraping was (https://stats.espncricinfo.com/ci/engine/records/team/match_results.html?id=14450;type=tournament). Next, the JSON files were cleaned and converted to CSV using Python and pandas. The data cleaning and manipulation process is fully explained in the file "T20 WorldCupData.ipynb". Finally, the CSVs were imported to Power BI where all the dashboard and analysis parts were built.


Dashboard Overview:
The dashboard contains Player Analysis pages, including Power Hitters, Anchors, Finishers, All Rounders, and Fast Bowlers. Users can get player details by hovering over their names. The Final 11 page allows users to select their dream 11 team and see the main stats of the players.

Power Hitters, Anchors, and Finishers Pages:
Each page includes a player stats table with columns for Name, Team, Batting Style, Innings Batted, Runs, Balls Faced, Strike Rate, Average Runs, Batting Position, and Boundary %. Additionally, each page includes graphs of Strike Rate, Average Runs, Boundary %, and Avg Balls Faced. Lastly, there is a scatter plot of Average Runs to Strike Rate.

All Rounders Page:
The All Rounders page includes a player stats table with columns for Name, Team, Batting Style, Bowling Style, Innings Batted, Runs, Strike Rate, Average Runs, Innings Bowled, Balls Bowled, Wickets, Economy, and Bowling Strike Rate. The page also includes graphs of Strike Rate, Average Runs, Bowling Strike Rate, and Economy. Lastly, there is a scatter plot of Bowling Strike Rate and Bowling Economy.

Bowlers Page:
The Bowlers page includes a player stats table with columns for Name, Team, Bowling Style, Innings Bowled, Balls Bowled, Runs Conceded, Wickets, Economy, Bowling Strike Rate, Dot Ball %, and Maidens. The page also includes graphs of Bowling Strike Rate, Bowling Economy, Bowling Average, and Dot Ball %. Lastly, there is a scatter plot of Bowling Strike Rate and Bowling Economy.

Final 11 Page:
The Final 11 page includes a Player Selection Slicer where users can select their own team and see the team's performance in terms of Average Runs, Strike Rate, Average Balls Faced, Batting Average, Bowling Average, Bowling Strike Rate, and Economy. Additionally, users can view the creator's dream 11 team on the dashboard.

We hope you find this Power BI project informative and helpful in selecting your own dream 11 team for the 2022 T20 World Cup.
