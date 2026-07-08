# Prometheus Metrics

This document describes the Prometheus metrics exposed by the Sat_9am_5km application.

## Endpoint

- **URL**: `/metrics`
- **Method**: GET
- **Authentication**: HTTP Basic Auth
- **Content-Type**: text/plain; charset=utf-8
- **Cache**: 5 minutes (via Rails.cache)

## Configuration

The metrics endpoint requires the following environment variables:

- `PROMETHEUS_USERNAME`: Username for HTTP Basic Auth
- `PROMETHEUS_PASSWORD`: Password for HTTP Basic Auth

If these credentials are not configured, the endpoint returns HTTP 503 Service Unavailable.

## Metrics

### Event Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_events_total` | `country`, `active` | Counter | Total number of events by country and active status |

### Activity Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_activities_total` | `event`, `country`, `published` | Counter | Total number of activities by event, country, and published status |
| `s95_activity_results_total` | `event`, `activity_date` | Counter | Number of results for each activity |
| `s95_activity_volunteers_total` | `event`, `activity_date` | Counter | Number of volunteers for each activity |
| `s95_activity_first_runs_total` | `event`, `activity_date` | Counter | Number of first runs (first participation) for each activity |
| `s95_activity_personal_bests_total` | `event`, `activity_date` | Counter | Number of personal bests for each activity |
| `s95_activity_average_time_seconds` | `event`, `activity_date` | Gauge | Average time of all results for each activity |
| `s95_activity_median_time_seconds` | `event`, `activity_date` | Gauge | Median time of all results for each activity |
| `s95_activity_best_time_seconds` | `event`, `activity_date`, `gender` | Gauge | Best time by gender for each activity |
| `s95_activity_pb_ratio` | `event`, `activity_date` | Gauge | Ratio of personal bests to total results |
| `s95_activity_first_run_ratio` | `event`, `activity_date` | Gauge | Ratio of first runs to total results |
| `s95_activity_correct` | `event`, `activity_date` | Gauge | 1 if results are correct, 0 otherwise |
| `s95_activity_has_results` | `event`, `activity_date` | Gauge | 1 if activity has results, 0 otherwise |
| `s95_activity_published` | `event`, `activity_date` | Gauge | 1 if activity is published, 0 otherwise |

### Athlete Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_athletes_total` | `event`, `country` | Counter | Total number of athletes registered for each event |
| `s95_athletes_with_user_total` | `event` | Counter | Number of athletes with a user account |
| `s95_athletes_with_gender_total` | `event`, `gender` | Counter | Number of athletes by gender |
| `s95_athletes_with_external_code_total` | `source` | Counter | Number of athletes with external codes (parkrun, parkzhrun, fiveverst, runpark) |
| `s95_athletes_going_to_event_total` | `event` | Counter | Number of athletes marked as going to the event |

### Volunteer Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_volunteers_total` | `event`, `activity_date` | Gauge | Total number of volunteers for each activity |
| `s95_volunteers_by_role_total` | `event`, `activity_date`, `role` | Counter | Number of volunteers by role for each activity |
| `s95_unique_volunteers_total` | `event`, `window` | Counter | Number of unique volunteers (all-time) for each event |
| `s95_volunteer_roles_covered_total` | `event`, `activity_date` | Gauge | Number of different roles covered for each activity |
| `s95_volunteer_position_coverage_ratio` | `event`, `activity_date` | Gauge | Ratio of covered positions to total positions |
| `s95_volunteer_bus_factor` | `event` | Gauge | Bus factor for volunteers (measures resilience to key person loss) |

### Community Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_active_community_total` | `event`, `window` | Counter | Number of active community members (athletes or volunteers) |
| `s95_unique_athletes_total` | `event`, `window` | Counter | Number of unique athletes who participated |
| `s95_returning_athletes_total` | `event`, `window` | Counter | Number of athletes who participated multiple times |
| `s95_sleeping_athletes_total` | `event`, `window` | Counter | Number of athletes not active in recent activities |

### Location Health Metrics

| Metric | Labels | Type | Description |
|--------|--------|------|-------------|
| `s95_location_health_score` | `event` | Gauge | Health score for the event location (0-100) |

## Location Health Score

The location health score is calculated based on four factors:

1. **Activity Frequency** (40%): Number of activities in the last 6 months compared to the expected 26 activities per year
2. **Volunteer Consistency** (20%): Ratio of recent volunteers to total volunteers in the last 6 months
3. **Athlete Retention** (30%): Combination of recent athlete participation and returning athlete ratio
4. **Results Quality** (10%): Ratio of correct results to total results

Score = (Activity Frequency * 0.4) + (Volunteer Consistency * 0.2) + (Athlete Retention * 0.3) + (Results Quality * 0.1)

## Metric Naming Convention

- `*_total`: Counters for cumulative counts
- `*_ratio`: Ratios between 0 and 1
- `*_seconds`: Time durations in seconds
- `*_score`: Health scores between 0 and 100

## Caching

All metrics are cached for 5 minutes using Rails.cache to reduce database load. The cache key is `s95_metrics`.

## Performance Considerations

- All metrics use aggregated SQL queries (no N+1)
- COUNT(DISTINCT ...) is used for unique counts
- Window functions are used for median calculations
- CTEs are used for complex aggregations
- No personal data is included in labels (no athlete_id, name, etc.)

## Troubleshooting

### 503 Service Unavailable
Check that `PROMETHEUS_USERNAME` and `PROMETHEUS_PASSWORD` environment variables are set.

### High Response Time
Check that caching is working and consider increasing the cache TTL. Monitor database performance.

### Missing Metrics
Verify that the application is running and the Prometheus client library is properly configured.
