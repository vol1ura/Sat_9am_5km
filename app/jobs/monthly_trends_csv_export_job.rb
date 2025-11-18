class MonthlyTrendsCsvExportJob < ApplicationJob
  queue_as :low

  def perform(model_name, user_id)
    @model = model_name.to_s
    @user = User.find(user_id)
    return unless @user.telegram_id

    tempfile = generate_csv

    Telegram::Bot.call('sendDocument', form_data: multipart_form_data(tempfile))
  rescue StandardError => e
    Rollbar.error e, model: @model, user_id: @user.id
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  private

  def generate_csv
    tempfile = Tempfile.new
    CSV.open(tempfile.path, 'w') do |csv|
      stats = stats_for(@model)
      if @model == 'results'
        csv << %w[month activities_count total_results avg_results_per_activity newbies_count unique_athletes male_count female_count avg_total_time_seconds]
        stats.each do |row|
          csv << [
            row.month.strftime('%Y-%m'),
            row.activities_count,
            row.total_count,
            row.avg_count,
            row.newbies_count,
            row.unique_athletes,
            row.male_count,
            row.female_count,
            row.avg_total_time_seconds
          ]
        end
      else
        # volunteers
        csv << %w[month activities_count total_volunteers avg_volunteers_per_activity newbies_count unique_volunteers male_count female_count]
        stats.each do |row|
          csv << [
            row.month.strftime('%Y-%m'),
            row.activities_count,
            row.total_count,
            row.avg_count,
            row.newbies_count,
            row.unique_volunteers,
            row.male_count,
            row.female_count
          ]
        end
      end
    end
    tempfile.rewind
    tempfile
  end

  def stats_for(model)
    case model.to_s
    when 'results'
      Activity.find_by_sql(
        <<~SQL.squish
          WITH first_results AS (
            SELECT
              results.athlete_id,
              MIN(activities.date) as date
            FROM results
            JOIN activities ON results.activity_id = activities.id
            WHERE activities.published = true
            GROUP BY results.athlete_id
          )
          SELECT
            DATE_TRUNC('month', activities.date) AS month,
            COUNT(DISTINCT activities.id) AS activities_count,
            COUNT(results.id) AS total_count,
            ROUND(COUNT(results.id)::numeric / COUNT(DISTINCT activities.id), 1) AS avg_count,
            COUNT(DISTINCT results.athlete_id) FILTER (WHERE activities.date = first_results.date) AS newbies_count,
            COUNT(DISTINCT results.athlete_id) AS unique_athletes,
            SUM(CASE WHEN athletes.male IS TRUE THEN 1 ELSE 0 END) AS male_count,
            SUM(CASE WHEN athletes.male IS TRUE THEN 0 ELSE 1 END) AS female_count,
            ROUND(AVG(EXTRACT(EPOCH FROM results.total_time)))::int AS avg_total_time_seconds
          FROM activities
          INNER JOIN results ON results.activity_id = activities.id
          INNER JOIN athletes ON athletes.id = results.athlete_id
          INNER JOIN first_results ON first_results.athlete_id = results.athlete_id
          WHERE activities.published = true
            AND activities.date BETWEEN DATE_TRUNC('month', current_date - interval '12 months') AND current_date
          GROUP BY DATE_TRUNC('month', activities.date)
          ORDER BY month DESC
        SQL
      )
    when 'volunteers'
      Activity.find_by_sql(
        <<~SQL.squish
          WITH first_volunteers AS (
            SELECT
              volunteers.athlete_id,
              MIN(activities.date) as date
            FROM volunteers
            JOIN activities ON volunteers.activity_id = activities.id
            WHERE activities.published = true
            GROUP BY volunteers.athlete_id
          )
          SELECT
            DATE_TRUNC('month', activities.date) AS month,
            COUNT(DISTINCT activities.id) AS activities_count,
            COUNT(volunteers.id) AS total_count,
            ROUND(COUNT(volunteers.id)::numeric / COUNT(DISTINCT activities.id), 1) AS avg_count,
            COUNT(DISTINCT volunteers.athlete_id) FILTER (WHERE activities.date = first_volunteers.date) AS newbies_count,
            COUNT(DISTINCT volunteers.athlete_id) AS unique_volunteers,
            SUM(CASE WHEN athletes.male IS TRUE THEN 1 ELSE 0 END) AS male_count,
            SUM(CASE WHEN athletes.male IS TRUE THEN 0 ELSE 1 END) AS female_count
          FROM activities
          INNER JOIN volunteers ON volunteers.activity_id = activities.id
          INNER JOIN athletes ON athletes.id = volunteers.athlete_id
          INNER JOIN first_volunteers ON first_volunteers.athlete_id = volunteers.athlete_id
          WHERE activities.published = true
            AND activities.date BETWEEN DATE_TRUNC('month', current_date - interval '12 months') AND current_date
          GROUP BY DATE_TRUNC('month', activities.date)
          ORDER BY month DESC
        SQL
      )
    else
      # fallback to original behaviour for unknown model
      Activity.find_by_sql(
        <<~SQL.squish
          WITH first_#{model} AS (
            SELECT
              #{model}.athlete_id,
              MIN(activities.date) as date
            FROM #{model}
            JOIN activities ON #{model}.activity_id = activities.id
            WHERE activities.published = true
            GROUP BY #{model}.athlete_id
          )
          SELECT
            DATE_TRUNC('month', activities.date) AS month,
            COUNT(DISTINCT activities.id) AS activities_count,
            COUNT(#{model}.id) AS total_count,
            ROUND(COUNT(#{model}.id)::numeric / COUNT(DISTINCT activities.id), 1) AS avg_count,
            COUNT(DISTINCT #{model}.athlete_id) FILTER (WHERE activities.date = first_#{model}.date) AS newbies_count
          FROM activities
          INNER JOIN #{model} ON #{model}.activity_id = activities.id
          INNER JOIN first_#{model} ON first_#{model}.athlete_id = #{model}.athlete_id
          WHERE activities.published = true
            AND activities.date BETWEEN DATE_TRUNC('month', current_date - interval '12 months') AND current_date
          GROUP BY DATE_TRUNC('month', activities.date)
          ORDER BY month DESC
        SQL
      )
    end
  end

  def multipart_form_data(file)
    [
      [
        'document',
        file,
        {
          filename: "monthly_trends_#{@model}_#{Time.zone.now.to_i}.csv",
          content_type: 'text/csv'
        }
      ],
      ['caption', "Тренды за 12 месяцев по: #{@model}"],
      ['chat_id', @user.telegram_id.to_s]
    ]
  end
end
