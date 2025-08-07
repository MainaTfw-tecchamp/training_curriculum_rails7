require 'json'
class CalendarsController < ApplicationController

  def index
    getweek

    @plan = Plan.new
  end

  def create
    Plan.create(plan_params)
    redirect_to action: :index
  end

  private

  def plan_params
    params.require(:plan).permit(:date, :plan)
  end

  def getweek
    @wdays = ['(日)','(月)','(火)','(水)','(木)','(金)','(土)']
    @todays_date = Date.today


    @week_days = []
    plans = Plan.where(date: @todays_date..@todays_date + 6)

    7.times do |x|
      date = @todays_date + x
      raw_plans = plans.select { |plan| plan.date == date }.map(&:plan)

      today_plans = []
      raw_plans.each do |plan_string|
        begin
          parsed = JSON.parse(plan_string)
          if parsed.is_a?(Array)
            today_plans.concat(parsed)
          else
            today_plans.push(parsed.to_s)
          end
        rescue JSON::ParserError
          today_plans.concat(plan_string.split(','))
        end
      end

      today_plans = today_plans.flatten.map(&:strip).uniq.reject(&:blank?)

      wday_num = date.wday
      days = {
        month: date.month,
        date: date.day,
        plans: today_plans,
        wday: wday_num
      }

      @week_days.push(days)
    end
  end
end