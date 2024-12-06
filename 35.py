import subprocess as sp
import pymysql
import pymysql.cursors
from prettytable import PrettyTable

# Utility function to display data in a table format
def display_table(data):
    if not data:
        print("No data found.")
        return
    table = PrettyTable()
    table.field_names = data[0].keys()
    for row in data:
        table.add_row(row.values())
    print(table)

# Sub-options for the League functionality
def league_options(con, league_id):
    while True:
        sp.call('cls', shell=True)
        print("League Options")
        print("1. Matches")
        print("2. League Information")
        print("3. Teams Information")
        print("4. Achievements")
        print("   a. Players with Most Runs")
        print("   b. Players with Most Wickets")
        print("5. Team Standings")
        print("6. Back to Main Menu")
        
        option = input("Enter your choice: ").strip().lower()

        try:
            with con.cursor() as cur:
                if option == "1":  # Matches
                    query = f"""
                    SELECT DISTINCT m.MATCH_ID, m.MATCH_DATE, m.MATCH_FORMAT
                    FROM MATCHES m
                    JOIN MATCH_EVENT me ON m.MATCH_ID = me.MATCH_ID
                    WHERE me.LEAGUE_ID = {league_id}
                    ORDER BY m.MATCH_DATE;
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "2":  # League Information
                    query = f"""
                    SELECT * FROM LEAGUE WHERE LEAGUE_ID = {league_id};
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "3":  # Teams Information
                    query = "SELECT * FROM TEAM;"
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "4":  # Achievements
                    sub_option = input("Choose a: Most Runs or b: Most Wickets: ").strip().lower()
                    if sub_option == "a":
                        query = f"""
                        SELECT CONCAT(FNAME, ' ', LNAME) AS PlayerName, SUM(RUNS) AS TotalRuns 
                        FROM PLAYER_STATS ps 
                        JOIN PLAYER p ON ps.PLAYER_ID = p.PLAYER_ID 
                        JOIN MATCH_EVENT me ON ps.MATCH_ID = me.MATCH_ID
                        GROUP BY me.LEAGUE_ID, p.PLAYER_ID
                        HAVING me.LEAGUE_ID = {league_id} 
                        ORDER BY TotalRuns DESC LIMIT 5;
                        """
                        cur.execute(query)
                        result = cur.fetchall()
                        display_table(result)
                    elif sub_option == "b":
                        query = f"""
                        SELECT CONCAT(FNAME, ' ', LNAME) AS PlayerName, SUM(WICKETS) AS Wickets 
                        FROM PLAYER_STATS ps 
                        JOIN PLAYER p ON ps.PLAYER_ID = p.PLAYER_ID 
                        JOIN MATCH_EVENT me ON ps.MATCH_ID = me.MATCH_ID
                        GROUP BY me.LEAGUE_ID, p.PLAYER_ID
                        HAVING me.LEAGUE_ID = {league_id} 
                        ORDER BY Wickets DESC LIMIT 5;
                        """
                        cur.execute(query)
                        result = cur.fetchall()
                        display_table(result)
                    else:
                        print("Invalid sub-option. Try again.")

                elif option == "5":  # Team Standings
                    query = f"""
                    SELECT t.TEAM_NAME, pt.MATCH_PLAYED, pt.MATCHES_WON, pt.MATCHES_LOST, pt.POINTS 
                    FROM POINTS_TABLE pt 
                    JOIN TEAM t ON pt.TEAM_ID = t.TEAM_ID 
                    WHERE pt.LEAGUE_ID = {league_id} 
                    ORDER BY pt.POINTS DESC;
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "6":  # Back to Main Menu
                    break

                else:
                    print("Invalid option. Please try again.")
        except Exception as e:
            print("An error occurred:", e)
        input("Press any key to continue...")

def match_options(con):
    while True:
        sp.call('cls', shell=True)
        print("Match Options")
        print("1. Match Information")
        print("2. Scorecard")
        print("3. Highlights")
        print("4. Back to Main Menu")
        
        option = input("Enter your choice: ").strip().lower()

        try:
            with con.cursor() as cur:
                if option == "1":  # Match Information
                    query = """
                    SELECT m.MATCH_ID, m.MATCH_DATE, m.MATCH_TIME, m.MATCH_FORMAT, 
                           pm.match_teams
                    FROM MATCHES m
                    JOIN PROPER_MATCH pm ON m.MATCH_ID = pm.MATCH_ID
                    ORDER BY m.MATCH_ID, m.MATCH_DATE, m.MATCH_TIME, m.MATCH_FORMAT;
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "2":  # Scorecard
                    match_id = input("Enter the MATCH_ID for the scorecard: ").strip()

                    # Query to get team stats for the given match_id
                    query = f"""
                    SELECT t.TEAM_NAME, ts.RUNS, ts.WICKETS, ts.NO_OF_FOURS, ts.NO_OF_SIXES, 
                           ts.OVERS, ts.RUN_RATE
                    FROM TEAM_STATS ts
                    JOIN TEAM t ON ts.TEAM_ID = t.TEAM_ID
                    WHERE ts.MATCH_ID = {match_id};
                    """
                    cur.execute(query)
                    scorecard = cur.fetchall()
                    display_table(scorecard)

                    # Best Batsman of the match
                    query_batsman = f"""
                    SELECT CONCAT(p.FNAME, ' ', p.LNAME) AS PlayerName, SUM(ps.RUNS) AS TotalRuns
                    FROM PLAYER_STATS ps
                    JOIN PLAYER p ON ps.PLAYER_ID = p.PLAYER_ID
                    WHERE ps.MATCH_ID = {match_id}
                    GROUP BY ps.PLAYER_ID
                    ORDER BY TotalRuns DESC LIMIT 1;
                    """
                    cur.execute(query_batsman)
                    best_batsman = cur.fetchall()
                    print("\nBest Batsman:")
                    display_table(best_batsman)

                    # Best Bowler of the match
                    query_bowler = f"""
                    SELECT CONCAT(p.FNAME, ' ', p.LNAME) AS PlayerName, SUM(ps.WICKETS) AS TotalWickets
                    FROM PLAYER_STATS ps
                    JOIN PLAYER p ON ps.PLAYER_ID = p.PLAYER_ID
                    WHERE ps.MATCH_ID = {match_id}
                    GROUP BY ps.PLAYER_ID
                    ORDER BY TotalWickets DESC LIMIT 1;
                    """
                    cur.execute(query_bowler)
                    best_bowler = cur.fetchall()
                    print("\nBest Bowler:")
                    display_table(best_bowler)

                elif option == "3":  # Highlights
                    match_id = input("Enter the MATCH_ID for highlights: ").strip()

                    # Query to fetch highlights for the given match_id
                    query = f"""
                    SELECT h.HIGHLIGHT_TEXT, h.TIMESTAMP
                    FROM HIGHLIGHTS h
                    WHERE h.MATCH_ID = {match_id}
                    ORDER BY h.TIMESTAMP;
                    """
                    cur.execute(query)
                    highlights = cur.fetchall()
                    print("\nHighlights:")
                    display_table(highlights)

                elif option == "4":  # Back to Main Menu
                    break

                else:
                    print("Invalid option. Please try again.")
        except Exception as e:
            print("An error occurred:", e)
        input("Press any key to continue...")

# Sub-options for the Player functionality
def player_options(con):
    while True:
        sp.call('cls', shell=True)
        print("Player Options")
        print("1. Player Statistics")
        print("2. Search Player")
        print("3. Back to Main Menu")
        
        option = input("Enter your choice: ").strip().lower()

        try:
            with con.cursor() as cur:
                if option == "1":  # Player Statistics
                    # Query to get all player statistics (no user input needed)
                    query = """
                    SELECT p.PLAYER_ID, CONCAT(p.FNAME, ' ', p.LNAME) AS PlayerName,
                           ps.MATCH_ID, ps.RUNS, ps.WICKETS, ps.NO_OF_SIXES, ps.NO_OF_FOURS, ps.OVERS_BOWLED, ps.STRIKE_RATE, ps.BALLS_FACED, ps.ECONOMY
                    FROM PLAYER p
                    JOIN PLAYER_STATS ps ON ps.PLAYER_ID = p.PLAYER_ID
                    ORDER BY ps.MATCH_ID;
                    """
                    cur.execute(query)
                    stats = cur.fetchall()
                    display_table(stats)

                elif option == "2":  # Search Player
                    search_substring = input("Enter a substring to search in player's name: ").strip()

                    query = f"""
                    SELECT p.PLAYER_ID, CONCAT(p.FNAME, ' ', p.LNAME) AS PlayerName,
                           ps.MATCH_ID, ps.RUNS, ps.WICKETS, ps.NO_OF_SIXES, ps.NO_OF_FOURS, ps.OVERS_BOWLED, ps.STRIKE_RATE, ps.BALLS_FACED, ps.ECONOMY 
                    FROM PLAYER p
                    JOIN PLAYER_STATS ps ON ps.PLAYER_ID = p.PLAYER_ID
                    WHERE CONCAT(FNAME, ' ', LNAME) LIKE '%{search_substring}%';
                    """
                    cur.execute(query)
                    players = cur.fetchall()

                    if not players:
                        print(f"No players found matching the substring '{search_substring}'.")
                    else:
                        print(f"Players matching '{search_substring}':")
                        display_table(players)

                elif option == "3":  # Back to Main Menu
                    break

                else:
                    print("Invalid option. Please try again.")
        except Exception as e:
            print("An error occurred:", e)
        input("Press any key to continue...")

# Sub-options for the Venue functionality
def venue_options(con):
    while True:
        sp.call('cls', shell=True)
        print("Venue Options")
        print("1. Matches Played")
        print("2. Venue Popularity")
        print("3. Back to Main Menu")
        
        option = input("Enter your choice: ").strip().lower()

        try:
            with con.cursor() as cur:
                if option == "1":  # Matches Played
                    query = f"""
                    SELECT s.STADIUM_NAME, s.LOCATION, m.MATCH_ID, m.MATCH_DATE, m.MATCH_FORMAT, m.NO_OF_SPECTATORS
                    FROM MATCH_LOCATION ml
                    JOIN STADIUM s ON ml.STADIUM_NAME = s.STADIUM_NAME
                    JOIN MATCHES m ON ml.MATCH_ID = m.MATCH_ID
                    ORDER BY m.MATCH_DATE;
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "2":  # Venue Popularity
                    # Query to order stadiums by the number of matches played in each venue
                    query = """
                    SELECT s.STADIUM_NAME, s.LOCATION, COUNT(ml.MATCH_ID) AS MatchesPlayed
                    FROM MATCH_LOCATION ml
                    JOIN STADIUM s ON ml.STADIUM_NAME = s.STADIUM_NAME
                    GROUP BY s.STADIUM_NAME
                    ORDER BY MatchesPlayed DESC;
                    """
                    cur.execute(query)
                    result = cur.fetchall()
                    display_table(result)

                elif option == "3":  # Back to Main Menu
                    break

                else:
                    print("Invalid option. Please try again.")
        except Exception as e:
            print("An error occurred:", e)
        input("Press any key to continue...")

# Main execution logic
def viewer_menu():
    while True:
        sp.call('cls', shell=True)

        print("Welcome to CRICSTAR!")
        print("1. League")
        print("2. Match")
        print("3. Player")
        # print("4. Team")
        print("4. Venue")
        print("5. Exit")

        choice = input("Enter your choice: ").strip()

        if not choice.isdigit():
            print("Invalid choice. Please enter a number.")
            input("Press any key to continue...")
            continue

        choice = int(choice)

        if choice == 5:
            print("Exiting the application. Goodbye!")
            break

        try:
            # Database connection
            con = pymysql.connect(
                host='localhost',
                port=3306,
                user="root",
                password="SriSairam@123",
                db='CRICSTAR1',
                cursorclass=pymysql.cursors.DictCursor
            )

            if con.open:
                print("Connected to the database.")

            if choice == 4:  # Venue
                venue_options(con)

            elif choice == 1:  # League
                try:
                    with con.cursor() as cur:
                        query = "SELECT LEAGUE_ID, LEAGUE_NAME FROM LEAGUE;"
                        cur.execute(query)
                        leagues = cur.fetchall()
                        display_table(leagues)

                        league_id = input("Enter the League ID to view details: ").strip()

                        if not league_id.isdigit():
                            print("Invalid League ID. Please enter a number.")
                            input("Press any key to continue...")
                            continue

                        league_id = int(league_id)
                        league_options(con, league_id)

                except Exception as e:
                    print("Error in League functionality:", e)
                    input("Press any key to continue...")


            elif choice == 2:  # Match
                match_options(con)

            elif choice == 3:  # Player
                player_options(con)

            else:
                print(f"Option {choice} functionality is under construction.")

        except Exception as e:
            print("Error connecting to the database:", e)
        finally:
            if 'con' in locals() and con.open:
                con.close()

def main():
    while True:
        sp.call('cls', shell=True)

        print("Welcome to CRICSTAR!")
        print("1. Viewer")
        print("2. Administrator")
        print("3. Exit")

        user_role = input("Enter your role (1 for Viewer, 2 for Administrator): ").strip()

        if user_role not in ['1', '2', '3']:
            print("Invalid choice. Please enter 1, 2, or 3.")
            input("Press any key to continue...")
            continue

        user_role = int(user_role)

        if user_role == 3:
            print("Exiting the application. Goodbye!")
            break

        if user_role == 1:
            viewer_menu()
        elif user_role == 2:
            administrator_menu()
# //////////////////////////////



def administrator_menu():
    while True:
        sp.call('cls', shell=True)

        print("Administrator Menu")
        print("1. Insert")
        print("2. Update")
        print("3. Exit")

        choice = input("Enter your choice: ").strip()

        if not choice.isdigit() or int(choice) not in range(1, 4):
            print("Invalid choice. Please enter a number between 1 and 3.")
            input("Press any key to continue...")
            continue

        choice = int(choice)

        if choice == 3:
            break

        try:
            con = pymysql.connect(
                host='localhost',
                port=3306,
                user="root",
                password="SriSairam@123",
                db='CRICSTAR1',
                cursorclass=pymysql.cursors.DictCursor
            )

            if choice == 1:
                insert_menu(con)
            elif choice == 2:
                update_menu(con)

        except Exception as e:
            print("Error connecting to the database:", e)
        finally:
            if 'con' in locals() and con.open:
                con.close()


def insert_menu(con):
    while True:
        sp.call('cls', shell=True)

        print("Insert Menu")
        # print("1. Insert into League")
        print("1. Insert into Player")
        print("2. Insert into Stadium")
        # print("4. Insert into Match")
        print("3. Back to Administrator Menu")

        choice = input("Enter your choice: ").strip()

        if not choice.isdigit() or int(choice) not in range(1, 6):
            print("Invalid choice. Please enter a number between 1 and 5.")
            input("Press any key to continue...")
            continue

        choice = int(choice)

        if choice == 3:
            break

        # if choice == 1:
        #     insert_league(con)
        elif choice == 1:
            insert_new_player(con)
        elif choice == 2:
            insert_new_stadium(con)
        # elif choice == 4:
        #     insert_match(con)

def insert_new_player(con):
   """Insert a new player into the PLAYER table."""
   try:
    #    player_id = int(input("Enter Player ID: "))
       fname = input("Enter first name: ")
       mname = input("Enter middle name (or press enter if none): ")
       lname = input("Enter last name: ")
       nationality = input("Enter nationality: ")
       bdate = input("Enter birth date (YYYY-MM-DD): ")
       role = input("Enter player role: ")

       query = f"""
       INSERT INTO PLAYER (FNAME, MNAME, LNAME, NATIONALITY, BDATE, PLAYER_ROLE) 
       VALUES ( '{fname}', '{mname}', '{lname}', '{nationality}', '{bdate}', '{role}');
       """
       
       with con.cursor() as cur:
           cur.execute(query)
           con.commit()
           print("Player inserted successfully.")
   except Exception as e:
       con.rollback()
       print("Failed to insert player:", e)

def insert_new_stadium(con):
   """Insert a new stadium into the stadium table."""
   try:
       sname = (input("Enter Stadium name: "))
       location = input("Enter location name: ")
       capacity = input("Enter capacity of the table: ")

       query = f"""
       INSERT INTO STADIUM (STADIUM_NAME, LOCATION, CAPACITY) 
       VALUES ('{sname}', '{location}', '{capacity}');
       """
       
       with con.cursor() as cur:
           cur.execute(query)
           con.commit()
           print("Stadium inserted successfully.")
   except Exception as e:
       con.rollback()
       print("Failed to insert stadium:", e)

def update_menu(con):
    while True:
        sp.call('cls', shell=True)

        print("Update Menu")
        print("1. Update Stadium")
        print("2. Back to Administrator Menu")

        choice = input("Enter your choice: ").strip()

        if not choice.isdigit() or int(choice) not in range(1, 3):
            print("Invalid choice. Please enter a number between 1 and 2.")
            input("Press any key to continue...")
            continue

        choice = int(choice)

        if choice == 2:
            break

        if choice == 1:
            update_stadium(con)



def update_stadium(con):
    stadium_name = input("Enter the Stadium Name to update: ").strip()
    
    print("Enter new details (leave blank to keep unchanged):")
    new_city = input("New City: ").strip()
    new_capacity = input("New Capacity: ").strip()
    
    query = "UPDATE STADIUM SET "
    params = []
    
    if new_city:
        query += "LOCATION = %s, "
        params.append(new_city)
    if new_capacity:
        if not new_capacity.isdigit():
            print("Invalid capacity. Please enter a number.")
            return
        query += "CAPACITY = %s, "
        params.append(int(new_capacity))
    
    if not params:
        print("No updates provided.")
        return
    
    query = query.rstrip(", ") + " WHERE STADIUM_NAME = %s"
    params.append(stadium_name)
    
    try:
        with con.cursor() as cur:
            cur.execute(query, params)
            con.commit()
            print("Stadium updated successfully.")
    except Exception as e:
        print("Error updating Stadium:", e)


main()