blockers = Activities::PublicationReadiness.call(activity)

json.ready blockers.empty?
json.blockers blockers
json.results_count activity.results.size
json.volunteers_count activity.volunteers.size
