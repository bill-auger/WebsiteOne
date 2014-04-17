class Event < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  include IceCube
  validates :name, :event_date, :start_time, :end_time, :time_zone, :repeats, :category, presence: true
  validates :url, uri: true, :allow_blank => true
  validates :repeats_every_n_weeks, :presence => true, :if => lambda { |e| e.repeats == 'weekly' }
  validate :must_have_at_least_one_repeats_weekly_each_days_of_the_week, :if => lambda { |e| e.repeats == 'weekly' }
  validate :from_must_come_before_to
  attr_accessor :next_occurrence_time

  RepeatsOptions = %w[never weekly]
  RepeatEndsOptions = %w[never on]
  DaysOfTheWeek = %w[monday tuesday wednesday thursday friday saturday sunday]

  def self.next_occurrence
    if Event.exists?
      @events = []
      Event.where(['category = ?', 'Scrum']).each do |event|
        @events << event.current_occurences
      end
      @events = @events.flatten.sort_by { |e| e[:time] }
      @events[0][:event].next_occurrence_time = @events[0][:time]
      return @events[0][:event]
    end
    nil
  end


  def repeats_weekly_each_days_of_the_week=(repeats_weekly_each_days_of_the_week)
    self.repeats_weekly_each_days_of_the_week_mask = (repeats_weekly_each_days_of_the_week & DaysOfTheWeek).map { |r| 2**DaysOfTheWeek.index(r) }.inject(0, :+)
  end
  def repeats_weekly_each_days_of_the_week
    DaysOfTheWeek.reject do |r|
      ((repeats_weekly_each_days_of_the_week_mask || 0) & 2**DaysOfTheWeek.index(r)).zero?
    end
  end

  def from
      ActiveSupport::TimeZone[time_zone].parse(event_date.to_datetime.strftime('%Y-%m-%d')).beginning_of_day + start_time.seconds_since_midnight
  end

  def to
      ActiveSupport::TimeZone[time_zone].parse(event_date.to_datetime.strftime('%Y-%m-%d')).beginning_of_day + end_time.seconds_since_midnight
  end

  def duration
    d = to - from - 1
  end

  def schedule(starts_at = nil, ends_at = nil)
    starts_at ||= from
    ends_at ||= to
    if duration > 0
      s = IceCube::Schedule.new(starts_at, :ends_time => ends_at, :duration => duration)
    else
      s = IceCube::Schedule.new(starts_at, :ends_time => ends_at)
    end
    case repeats
      when 'never'
        s.add_recurrence_time(starts_at)
      when 'weekly'
        days = repeats_weekly_each_days_of_the_week.map {|d| d.to_sym }
        s.add_recurrence_rule IceCube::Rule.weekly(repeats_every_n_weeks).day(*days)
    end
    s
  end

  def current_occurences
    [].tap do |occurences|
      self.schedule.occurrences_between(Date.today, Date.today + 10.days).each do |time|
        unless time <= DateTime.now
          occurences << {
              event: self,
              time: time
          }
        end
      end
    end
  end

  def start_time_with_timezone
    DateTime.parse(start_time.strftime('%k:%M ')).in_time_zone(time_zone)
  end

  private
  def must_have_at_least_one_repeats_weekly_each_days_of_the_week
    if repeats_weekly_each_days_of_the_week.empty?
      errors.add(:base, 'You must have at least one repeats weekly each days of the week')
    end
  end

  def from_must_come_before_to
    if from > to
      errors.add(:to_date, 'must come after the from date')
    end
  end

  def lazy_expire_event
    now = Time.now
    if self.end_time < now
      # reset hangout url
      self.url = ""

      # advance event datetimes if repeating
      unless self.repeat_ends && self.repeat_ends_on < now
        if self.repeats.eql? 'weekly'
#        next_occurrence_interval = self.repeats_every_n_weeks.week
#        self.event_date += next_occurrence_interval
#        self.start_time += next_occurrence_interval
#        self.end_time = += next_occurrence_interval
        else ; # is there an else ?
        end
#        self.save!
      end
    end
  end

end
