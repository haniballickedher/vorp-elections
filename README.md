# vorp-elections
Elections 2.0
Based on  "Democracy" by Jeffy Detexas
Simple Elections script for VORP
Current Version allows config of city, regional or federal positions.
Players can enter their characters to run for a single office and vote. 
Election results are done via command but cleaning up for the next election is currently done via SQL script

Setup :
Add the elections folder to your resources
Add "ensure democracy" to your config
Run setup.SQL on your db.

Command to see election results is \electionresults

To reset the elections after a cycle, run the cleanup sql script.

Support DM hannibal_lickedher on Discord

Next Version:
-Election "ending" automation based on config
-Results stored for the purposes of term limits
-Languages file needs to be added
