# frozen_string_literal: true

module Ui
  class GoalProgressComponent < ApplicationComponent
    renders_one :details

    def initialize(title:, current:, thresholds:, recent: false, icon: nil)
      super()
      @title = title
      @current = current
      @thresholds = Array(thresholds)
      @recent = recent
      @icon = icon
    end

    def target
      @thresholds.find { |threshold| @current < threshold } || @thresholds.last.to_i
    end

    def completed?
      @thresholds.any? && @current >= @thresholds.last
    end

    def percent
      return 100 if completed? || target.zero?

      ((100.0 * @current) / target).clamp(0, 100)
    end

    def remaining
      [target - @current, 0].max
    end

    def threshold_classes(threshold)
      [
        'inline-flex items-center justify-center rounded-full px-3 py-1 text-xs font-semibold tabular-nums',
        threshold_state_classes(threshold),
      ].join(' ')
    end

    private

    def threshold_state_classes(threshold)
      if threshold <= @current
        'bg-brand-fill/10 text-brand'
      elsif threshold == target && !completed?
        'border border-dashed border-brand/30 bg-surface text-brand'
      else
        'bg-line/70 text-ink-muted/45'
      end
    end
  end
end
