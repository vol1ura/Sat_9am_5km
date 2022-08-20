json.athletes @athletes, :name, :id, :parkrun_code, :fiveverst_code, :club if can? :read, Athlete
