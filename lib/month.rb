require "date"

class Month

  attr_reader :month, :year

  class ParseError < StandardError; end

  def initialize year, month
    raise ArgumentError, "bad month" if !month.is_a?(Fixnum)
    raise ArgumentError, "bad month" if month < 1 || month > 12
    raise ArgumentError, "bad year" if !year.is_a?(Fixnum)
    @month = month
    @year = year # proleptic gregorian calendar, 0 = 1BC
  end

  def to_s opt={}
    if opt[:date]
      first_day.strftime("%Y-%m-%d")
    else
      show
    end
  end

  def show
    month_name = first_day.strftime("%B")
    if year > 600
      "#{month_name} #{year}"
    elsif year > 0
      "#{month_name} #{year} AD"
    else
      "#{month_name} #{-(year-1)} BC"
    end
  end

  def + diff
    raise TypeError, "don't try to add two months" if diff.is_a?(Month)
    years_diff = ((@month-1) + diff) / 12
    Month.new(
      @year + years_diff,
      ((@month-1) + diff) % 12 + 1
    )
  end

  def - arg
    if arg.is_a?(Month)
      v2 = Month.minus_origin self
      v1 = Month.minus_origin arg
      v2 - v1
    elsif arg.is_a?(Fixnum)
      self + (-arg)
    end
  end

  def <=> arg
    case
      when @year > arg.year then 1
      when @year < arg.year then -1
      when @month > arg.month then 1
      when @month < arg.month then -1
      else 0
    end
  end

  def >= arg; (self <=> arg) >= 0; end
  def <= arg; (self <=> arg) <= 0; end
  def > arg; (self <=> arg) > 0; end
  def < arg; (self <=> arg) < 0; end

  def == arg
    self.year == arg.year && self.month == arg.month
  end

  def != arg
    !(self == arg)
  end

  def first_day
    Date.new(year, month, 1)
  end

  def last_day
    (first_day >> 1) - 1
  end

  def self.from_date date
    Month.new(date.year, date.month)
  end

  def self.current
    Month.from_date Date.today
  end

  def self.parse str
    raise ParseError, str if str !~ /\d+-\d+-\d+/
    begin
      Month.from_date Date.parse(str)
    rescue ArgumentError
      raise ParseError, str
    end
  end

  def self.try_parse str
    begin
      Month.parse(str)
    rescue ParseError
      nil
    end
  end

  private

  def self.arbitrary_origin
    Month.new(1890, 1)
  end

  def self.minus_origin m
    o = Month.arbitrary_origin
    if m >= o
      (m.year-o.year)*12 + (m.month-o.month)
    else
      -((o.year-m.year)*12 + (o.month-m.month))
    end
  end

end
