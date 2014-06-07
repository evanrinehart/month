require "date"

class Month

  attr_reader :month, :year

  class ParseError < StandardError; end

  def initialize year, month
    raise ArgumentError, "bad month" if !month.is_a?(Integer)
    raise ArgumentError, "bad month" if month < 1 || month > 12
    raise ArgumentError, "bad year" if !year.is_a?(Integer)
    @month = month
    @year = year # proleptic gregorian calendar, 0 = 1BC
  end

  def to_s
    show
  end

  def encode
    first_day.strftime("%Y-%m-%d")
  end

  def show
    if year > 600
      "#{Month.name month} #{year}"
    elsif year > 0
      "#{Month.name month} #{year} AD"
    else
      "#{Month.name month} #{-(year-1)} BC"
    end
  end

  def inspect
    show
  end

  def + diff
    raise TypeError, "don't try to add two months" if diff.is_a?(Month)
    raise TypeError, "expected Integer" if !diff.is_a?(Integer)
    mplus = @month - 1 + diff
    years_diff = mplus / 12
    Month.new(
      @year + years_diff,
      mplus % 12 + 1
    )
  end

  def - arg
    if arg.is_a?(Month)
      v2 = Month.minus_origin self
      v1 = Month.minus_origin arg
      v2 - v1
    elsif arg.is_a?(Integer)
      self + (-arg)
    end
  end

  def <=> arg
    (self - arg) <=> 0
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
    Date.new year, month
  end

  def last_day
    (first_day >> 1) - 1
  end

  def on_day_clamp d
    raise ArgumentError, "out of range" if d < 1 || d > 31
    try = first_day + (d-1)
    if try.month != month
      last_day
    else
      try
    end
  end

  def on_day_rollover d
    raise ArgumentError, "out of range" if d < 1 || d > 31
    try = first_day + (d-1)
    if try.month != month
      (self + 1).first_day
    else
      try
    end
  end

  def on_day d
    raise ArgumentError, "out of range" if d > 28 || d < 1
    first_day + (d-1)
  end

  def self.from_date date
    Month.new(date.year, date.month)
  end

  def self.get_current
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
    Month.new(1890, 1) # can be any month
  end

  def self.minus_origin m
    o = Month.arbitrary_origin
    (m.year-o.year)*12 + (m.month-o.month)
  end

  def self.name m
    case m
      when 1 then 'January'
      when 2 then 'February'
      when 3 then 'March'
      when 4 then 'April'
      when 5 then 'May'
      when 6 then 'June'
      when 7 then 'July'
      when 8 then 'August'
      when 9 then 'September'
      when 10 then 'October'
      when 11 then 'November'
      when 12 then 'December'
    end
  end

end
