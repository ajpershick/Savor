class ChartsController < ApplicationController

  def days_in_month(month, year)
    days = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
     if month == 2 && Date.gregorian_leap?(year) then return 29 end
     return days[month]
  end

  def index
    @categories = {
      "dining"        => {icon: "cutlery",        color: "#2980b9"},
      "clothing"      => {icon: "shopping-bag",   color: "#27ae60"},
      "groceries"     => {icon: "shopping-cart",  color: "#f1c40f"},
      "automotive"    => {icon: "car",            color: "#e74c3c"},
      "gifts"         => {icon: "gift",           color: "#D2527F"},
      "entertainment" => {icon: "film",           color: "#8e44ad"},
      "recreation"    => {icon: "futbol-o",       color: "#16a085"},
      "transit"       => {icon: "bus",            color: "#59ABE3"},
      "utilities"     => {icon: "bolt",           color: "#f39c12"},
      "maintenance"   => {icon: "wrench",         color: "#7f8c8d"},
      "medical"       => {icon: "medkit",         color: "#c0392b"},
      "debt"          => {icon: "university",     color: "#95a5a6"},
      "luxury"        => {icon: "diamond",        color: "#9b59b6"},
      "education"     => {icon: "book",           color: "#2ecc71"},
      "pets"          => {icon: "paw",            color: "#795548"},
      "insurance"     => {icon: "shield",         color: "#4183D7"},
      "supplies"      => {icon: "paperclip",      color: "#F4D03F"},
      "housing"       => {icon: "home",           color: "#26A65B"},
      "charity"       => {icon: "heart",          color: "#E08283"},
      "savings"       => {icon: "usd",            color: "#1E824C"},
      "travel"        => {icon: "plane",          color: "#e67e22"},
      "personal care" => {icon: "bath",           color: "#947CB0"},
      "taxes"         => {icon: "envelope-open-o",color: "#d35400"},
      "miscellaneous" => {icon: "thumb-tack",     color: "#2c3e50"},
    }

    @category_order = [
      "dining",
      "clothing",
      "groceries",
      "automotive",
      "gifts",
      "entertainment",
      "recreation",
      "transit",
      "utilities",
      "maintenance",
      "medical",
      "debt",
      "luxury",
      "education",
      "pets",
      "insurance",
      "supplies",
      "housing",
      "charity",
      "savings",
      "travel",
      "personal care",
      "taxes",
      "miscellaneous",
    ]

    # Get the current logged in user
    user = User.find(session[:user_id])
    # Get all the user's transactions
    transactions = user.transactions.order(:date => :asc)

    # User has no transactions
    if transactions.length == 0 then
      @empty = true
      return
    end
    @empty = false

    earliest_date = transactions[0].date.to_date
    latest_date = transactions[-1].date.to_date

    # Creates an array of all months, or all years, from the user's first transaction to their latest transaction
    @month_range = (earliest_date..latest_date).map{|d| {year: d.year.to_s, month: d.month.to_s}}.uniq.reverse
    @year_range = (earliest_date..latest_date).map{|d| d.year.to_s}.uniq.reverse




    #
    if params[:categories].blank? then
      @enabled_categories = 2 ** 24 - 1
    else
      @enabled_categories = params[:categories].to_i
    end

    if params[:month].blank? then
      @selected_month = latest_date.month.to_s
    else
      @selected_month = params[:month]
    end

    if params[:year].blank? then
      @selected_year = latest_date.year.to_s
    else
      @selected_year = params[:year]
    end

    # Convert number to binary string of length 24
    # Each bit represents a category
    binary = @enabled_categories.to_s(2).rjust(24, "0")

    @enabled = {
      "dining"        => (binary[0] == "1"),
      "clothing"      => (binary[1] == "1"),
      "groceries"     => (binary[2] == "1"),
      "automotive"    => (binary[3] == "1"),
      "gifts"         => (binary[4] == "1"),
      "entertainment" => (binary[5] == "1"),
      "recreation"    => (binary[6] == "1"),
      "transit"       => (binary[7] == "1"),
      "utilities"     => (binary[8] == "1"),
      "maintenance"   => (binary[9] == "1"),
      "medical"       => (binary[10] == "1"),
      "debt"          => (binary[11] == "1"),
      "luxury"        => (binary[12] == "1"),
      "education"     => (binary[13] == "1"),
      "pets"          => (binary[14] == "1"),
      "insurance"     => (binary[15] == "1"),
      "supplies"      => (binary[16] == "1"),
      "housing"       => (binary[17] == "1"),
      "charity"       => (binary[18] == "1"),
      "savings"       => (binary[19] == "1"),
      "travel"        => (binary[20] == "1"),
      "personal care" => (binary[21] == "1"),
      "taxes"         => (binary[22] == "1"),
      "miscellaneous" => (binary[23] == "1"),
    }


    # year
    # month
    # enabled
    # current_transactions

    @data = {}



    @year_view = (@selected_month == "0")


    #@year_view = true


    # If showing graph for a single month, find the total days in the month
    if !@yearview then @total_days = days_in_month(@selected_month.to_i, @selected_year.to_i) end

    @transaction_set = []
    @transaction_set << {}
    limit = (@year_view) ? 12 : @total_days
    (1..limit).each do
      @transaction_set << {
        "all"           => 0.0,
        "dining"        => 0.0,
        "clothing"      => 0.0,
        "groceries"     => 0.0,
        "automotive"    => 0.0,
        "gifts"         => 0.0,
        "entertainment" => 0.0,
        "recreation"    => 0.0,
        "transit"       => 0.0,
        "utilities"     => 0.0,
        "maintenance"   => 0.0,
        "medical"       => 0.0,
        "debt"          => 0.0,
        "luxury"        => 0.0,
        "education"     => 0.0,
        "pets"          => 0.0,
        "insurance"     => 0.0,
        "supplies"      => 0.0,
        "housing"       => 0.0,
        "charity"       => 0.0,
        "savings"       => 0.0,
        "travel"        => 0.0,
        "personal care" => 0.0,
        "taxes"         => 0.0,
        "miscellaneous" => 0.0,
      }
    end
    if @year_view then
      current_transactions = transactions.where('extract(year from date) = ?', @selected_year)

      transaction_index = 0;
      month_index = 1;

      # Processes each transaction, adding its amount value to the relevant category in the relevant month
      while (transaction_index < current_transactions.length) do

        transaction_temp = current_transactions[transaction_index]

        if transaction_temp.date.month != month_index then
          month_index = transaction_temp.date.month
          puts transaction_temp.date.month
        end
        @transaction_set[month_index][transaction_temp.category] += transaction_temp.amount
        @transaction_set[month_index]["all"] += transaction_temp.amount
        transaction_index += 1
      end

    else
      current_transactions = transactions.where('extract(year from date) = ?', @selected_year).where('extract(month from date) = ?', @selected_month)

      transaction_index = 0;
      day_index = 1;

      # Processes each transaction, adding its amount value to the relevant category in the relevant month
      while (transaction_index < current_transactions.length) do

        transaction_temp = current_transactions[transaction_index]

        if transaction_temp.date.day != day_index then
          day_index = transaction_temp.date.day
        end
        @transaction_set[day_index][transaction_temp.category] += transaction_temp.amount
        @transaction_set[day_index]["all"] += transaction_temp.amount
        transaction_index += 1
      end

    end

    # Set labels to months of the year, or days of the month depending on current selection
    @data[:labels] = []
    if @year_view then

      (1..12).each do |month|
        @data[:labels] << Date::MONTHNAMES[month].to_s
      end
    else

      (1..@total_days).each do |day|
        @data[:labels] << day
      end

    end

    # Generate the datasets for each enabled category
    @data[:datasets] = []
    (0..@category_order.length - 1).each do |index|

      if binary[index] == "0" then next end

      category = @category_order[index]

      dataset = {}
      dataset[:label] = category.capitalize
      dataset[:fill] = false
      dataset[:border_color] = @categories[category][:color]
      dataset[:background_color] = @categories[category][:color]
      dataset[:data] = []

      if @year_view then

        (1..12).each do |m|
          dataset[:data] << @transaction_set[m][@category_order[index]]
        end

      else

        (1.. @total_days).each do |d|
          dataset[:data] << @transaction_set[d][@category_order[index]]
        end

      end
      @data[:datasets] << dataset

    end

    # @data = {
    #   labels: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
    #   datasets: [
    #     {
    #         label: "My First dataset",
    #         background_color: "#F00F0F55",
    #         border_color: "rgba(220,220,220,1)",
    #         data: [65, 59, 80, 81, 56, 55, 40, 0, 0, 0, 0, 0]
    #     },
    #     {
    #         label: "My Second dataset",
    #         background_color: "rgba(151,187,205,0.2)",
    #         border_color: "rgba(151,187,205,1)",
    #         data: [28, 48, 40, 19, 86, 0, 0, 0, 0, 0, 0, 0]
    #     },
    #
    #   ]
    # }
    @options = {
      class: "chart-canvas",
      responsive: true,
      height: 300,
      maintainAspectRatio: false,
      animation: false,
      elements: {
        line: {
          tension: 0
        }
      }
    }


    test = 1234
    binary = test.to_s(2).rjust(24, '0')
    puts binary.to_i(2)
  end

end
