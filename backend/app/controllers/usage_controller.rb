class UsageController < ApplicationController
  # POST /api/usage
  def create
    begin
      usage_data = JSON.parse(request.body.read)

      timestamp = usage_data['timestamp'] || Time.current
      apps = usage_data['apps'] || []

      # Get today's date for grouping
      date = timestamp.to_date

      saved_count = 0
      updated_count = 0
      errors = []

      apps.each do |app|
        # Find or create record for this app on this date
        usage = AppUsage.find_or_initialize_by(
          package_name: app['package'],
          recorded_at: date.beginning_of_day..date.end_of_day
        )

        # Update with latest values
        was_new = usage.new_record?
        usage.display_name = app['appName'] if app['appName']
        usage.total_time_ms = app['totalTimeMs']
        usage.recorded_at = timestamp

        if usage.save
          was_new ? saved_count += 1 : updated_count += 1
        else
          errors << { package: app['package'], errors: usage.errors.full_messages }
        end
      end

      render json: {
        success: true,
        saved_count: saved_count,
        updated_count: updated_count,
        total_apps: apps.length,
        timestamp: timestamp,
        errors: errors.any? ? errors : nil
      }, status: :created

    rescue JSON::ParserError => e
      render json: {
        success: false,
        error: 'Invalid JSON format',
        message: e.message
      }, status: :bad_request

    rescue StandardError => e
      render json: {
        success: false,
        error: 'Internal server error',
        message: e.message
      }, status: :internal_server_error
    end
  end

  # GET /api/usage
  def index
    begin
      # Parse query parameters
      days = params[:days]&.to_i || 7
      package = params[:package]

      # Build query - get latest record per day per package
      query = AppUsage.where('recorded_at >= ?', days.days.ago)
      query = query.for_package(package) if package.present?

      usages = query.recent.limit(1000)

      # Group by package and get latest per day, then sum across days
      stats = usages.group_by(&:package_name).map do |pkg, records|
        # Group by date and take latest record per day
        daily_totals = records.group_by { |r| r.recorded_at.to_date }
          .map { |date, day_records| day_records.max_by(&:recorded_at) }

        {
          package: pkg,
          app_name: daily_totals.first.app_name,
          total_time_ms: daily_totals.sum(&:total_time_ms),
          total_time_minutes: (daily_totals.sum(&:total_time_ms) / 60_000.0).round(2),
          total_time_hours: (daily_totals.sum(&:total_time_ms) / 3_600_000.0).round(2),
          record_count: daily_totals.count,
          first_seen: daily_totals.map(&:recorded_at).min,
          last_seen: daily_totals.map(&:recorded_at).max
        }
      end

      # Sort by total time
      stats.sort_by! { |s| -s[:total_time_ms] }

      render json: {
        success: true,
        days: days,
        total_packages: stats.length,
        stats: stats
      }, status: :ok

    rescue StandardError => e
      render json: {
        success: false,
        error: 'Failed to fetch usage data',
        message: e.message
      }, status: :internal_server_error
    end
  end

  # GET /api/usage/summary
  def summary
    begin
      days = params[:days]&.to_i || 7

      usages = AppUsage.where('recorded_at >= ?', days.days.ago)

      # Group by date and package, take latest per day
      daily_records = usages.group_by { |u| [u.recorded_at.to_date, u.package_name] }
        .map { |_, records| records.max_by(&:recorded_at) }

      total_time_ms = daily_records.sum(&:total_time_ms)
      total_apps = daily_records.map(&:package_name).uniq.count

      # Top 10 most used apps (sum across days)
      top_apps = daily_records.group_by(&:package_name)
        .map do |pkg, records|
          {
            package: pkg,
            app_name: records.first.display_name || pkg.split('.').last.titleize,
            total_time_ms: records.sum(&:total_time_ms),
            total_time_minutes: (records.sum(&:total_time_ms) / 60_000.0).round(0),
            total_time_hours: (records.sum(&:total_time_ms) / 3_600_000.0).round(2)
          }
        end
        .sort_by { |a| -a[:total_time_ms] }
        .first(10)

      render json: {
        success: true,
        days: days,
        total_time_ms: total_time_ms,
        total_time_hours: (total_time_ms / 3_600_000.0).round(2),
        total_apps: total_apps,
        top_apps: top_apps,
        average_daily_hours: (total_time_ms / 3_600_000.0 / days).round(2)
      }, status: :ok

    rescue StandardError => e
      render json: {
        success: false,
        error: 'Failed to generate summary',
        message: e.message
      }, status: :internal_server_error
    end
  end

  # GET /api/usage/today/:package
  def today
    begin
      package = params[:package]

      if package.blank?
        return render json: {
          success: false,
          error: 'Package name required'
        }, status: :bad_request
      end

      # Get today's latest record for this package
      today_usage = AppUsage
        .for_package(package)
        .where('recorded_at >= ?', Time.zone.now.beginning_of_day)
        .order(recorded_at: :desc)
        .first

      if today_usage
        render json: {
          success: true,
          package: today_usage.package_name,
          app_name: today_usage.app_name,
          total_time_ms: today_usage.total_time_ms,
          total_time_minutes: today_usage.time_in_minutes.round(0),
          total_time_hours: today_usage.time_in_hours.round(2),
          last_updated: today_usage.recorded_at,
          message: "You've been using #{today_usage.app_name} for #{today_usage.time_in_minutes.round(0)} minutes today"
        }, status: :ok
      else
        render json: {
          success: true,
          package: package,
          total_time_minutes: 0,
          message: "No usage data for #{package} today"
        }, status: :ok
      end

    rescue StandardError => e
      render json: {
        success: false,
        error: 'Failed to fetch today\'s usage',
        message: e.message
      }, status: :internal_server_error
    end
  end
end
