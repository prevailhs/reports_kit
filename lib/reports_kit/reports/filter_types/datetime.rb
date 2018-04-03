module ReportsKit
  module Reports
    module FilterTypes
      class Datetime < Base
        DEFAULT_CRITERIA = {
          operator: 'between'
        }
        SEPARATOR = ' - '

        def apply_conditions(records)
          case criteria[:operator]
          when 'between'
            # records.where.not(column => nil).where(column => start_at..end_at)
            records.where(column => start_at..end_at).where("#{column} IS NOT NULL")
          else
            raise ArgumentError.new("Unsupported operator: '#{criteria[:operator]}'")
          end
        end

        def start_at_end_at
          @start_at_end_at ||= valid? ? adjust_range_to_dimension(*Reports::Data::Utils.parse_date_range(value, type: Array)) : nil
        end

        def start_at
          start_at_end_at.try(:[], 0)
        end

        def end_at
          start_at_end_at.try(:[], 1)
        end

        def adjust_range_to_dimension(start_at, end_at)
          return [start_at.beginning_of_day, end_at.end_of_day] unless primary_dimension.configured_by_time?
          return [start_at.beginning_of_day, end_at.end_of_day] if primary_dimension.granularity == 'day'
          return [
            start_at.beginning_of_week(ReportsKit.configuration.first_day_of_week),
            end_at.end_of_week(ReportsKit.configuration.first_day_of_week)
          ] if primary_dimension.granularity == 'week'
          return [
            start_at.beginning_of_month,
            end_at.end_of_month
          ] if primary_dimension.granularity == 'month'
          [start_at, end_at]
        end

        def valid?
          value.present?
        end
      end
    end
  end
end
