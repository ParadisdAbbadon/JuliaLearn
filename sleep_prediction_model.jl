# sleep_prediction_model.jl
using XLSX
using DataFrames
using Dates
using Statistics


"""
    calculate_sleep_durations(df::DataFrame) -> DataFrame

Calculate sleep duration from bedtime and wake time data.

# Arguments
- `df`: DataFrame with `Date`, `Time_Awakened`, and `Approx_Time_to_Sleep` columns

# Returns
- DataFrame with `date`, `sleep` (hours), and `day_of_week` columns
"""
function calculate_sleep_durations(df::DataFrame)
    # Filter to rows with valid sleep time
    df_valid = filter(row -> !ismissing(row.Approx_Time_to_Sleep), df)

    sleep_data = DataFrame(date=Date[], sleep=Float64[], day_of_week=Int[])

    for i in 2:nrow(df_valid)
        bedtime = df_valid[i-1, :Approx_Time_to_Sleep]
        wake_date = df_valid[i, :Date]
        wake_time = df_valid[i, :Time_Awakened]

        # Combine date and time for wake datetime
        wake_datetime = DateTime(wake_date) + wake_time

        # Calculate duration in hours
        duration = Dates.value(wake_datetime - bedtime) / (1000 * 60 * 60)

        # Only include valid durations (0-16 hours)
        if 0 < duration < 16
            push!(sleep_data, (
                date=Date(wake_date),
                sleep=duration,
                day_of_week=dayofweek(wake_date)
            ))
        end
    end

    return sort(sleep_data, :date)
end


"""
    ewma(values::Vector{Float64}; span::Int=7) -> Float64

Calculate exponentially weighted moving average.

# Arguments
- `values`: Vector of values
- `span`: Span for EWMA calculation (default: 7)

# Returns
- EWMA value for the last observation
"""
function ewma(values::Vector{Float64}; span::Int=7)
    α = 2.0 / (span + 1)
    result = values[1]
    for i in 2:length(values)
        result = α * values[i] + (1 - α) * result
    end
    return result
end


"""
    linear_regression(x::Vector, y::Vector) -> NamedTuple

Simple linear regression returning slope and intercept.

# Arguments
- `x`: Independent variable vector
- `y`: Dependent variable vector

# Returns
- NamedTuple with `slope` and `intercept`
"""
function linear_regression(x::Vector, y::Vector)
    n = length(x)
    x_mean = mean(x)
    y_mean = mean(y)

    numerator = sum((x .- x_mean) .* (y .- y_mean))
    denominator = sum((x .- x_mean) .^ 2)

    slope = numerator / denominator
    intercept = y_mean - slope * x_mean

    return (slope=slope, intercept=intercept)
end


"""
Sleep prediction model struct containing fitted parameters.
"""
struct SleepPredictor
    sleep_df::DataFrame
    overall_mean::Float64
    overall_std::Float64
    dow_effects::Dict{Int,Float64}
    trend_slope::Float64
    trend_intercept::Float64
    trend_start_idx::Int
    ewma_value::Float64
    recent_std::Float64
    last_date::Date
end


"""
    fit(::Type{SleepPredictor}, sleep_df::DataFrame) -> SleepPredictor

Fit a sleep prediction model to historical data.

# Arguments
- `sleep_df`: DataFrame with `date`, `sleep`, and `day_of_week` columns

# Returns
- Fitted SleepPredictor model
"""
function fit(::Type{SleepPredictor}, sleep_df::DataFrame)
    overall_mean = mean(sleep_df.sleep)
    overall_std = std(sleep_df.sleep)

    # Calculate day-of-week effects (deviation from overall mean)
    dow_effects = Dict{Int,Float64}()
    for dow in 1:7
        dow_data = filter(row -> row.day_of_week == dow, sleep_df)
        if nrow(dow_data) > 0
            dow_effects[dow] = mean(dow_data.sleep) - overall_mean
        else
            dow_effects[dow] = 0.0
        end
    end

    # Calculate recent trend (last 14 days)
    recent_14 = last(sleep_df, 14)
    x = collect(0:nrow(recent_14)-1) .|> Float64
    y = recent_14.sleep
    reg = linear_regression(x, y)

    # Calculate EWMA
    ewma_value = ewma(sleep_df.sleep, span=7)

    # Recent standard deviation
    recent_std = std(last(sleep_df, 30).sleep)

    # Last date
    last_date = maximum(sleep_df.date)

    return SleepPredictor(
        sleep_df,
        overall_mean,
        overall_std,
        dow_effects,
        reg.slope,
        reg.intercept,
        nrow(recent_14),
        ewma_value,
        recent_std,
        last_date
    )
end


"""
    predict(model::SleepPredictor; days_ahead::Int=4, weights::NamedTuple=nothing) -> DataFrame

Predict sleep duration for future days.

# Arguments
- `model`: Fitted SleepPredictor
- `days_ahead`: Number of days to predict (default: 4)
- `weights`: NamedTuple with weights (ewma, trend, dow). Default: (ewma=0.4, trend=0.3, dow=0.3)

# Returns
- DataFrame with predictions and confidence intervals
"""
function predict(model::SleepPredictor;
    days_ahead::Int=4,
    weights::NamedTuple=(ewma=0.40, trend=0.30, dow=0.30))

    predictions = DataFrame(
        date=Date[],
        day_name=String[],
        prediction=Float64[],
        ci_low=Float64[],
        ci_high=Float64[],
        ewma_component=Float64[],
        trend_component=Float64[],
        dow_component=Float64[]
    )

    for i in 1:days_ahead
        pred_date = model.last_date + Day(i)
        dow = dayofweek(pred_date)

        # Component 1: EWMA (captures recent level)
        ewma_component = model.ewma_value

        # Component 2: Trend projection
        trend_component = model.trend_intercept + model.trend_slope * (model.trend_start_idx + i)

        # Component 3: Day-of-week adjusted mean
        dow_component = model.overall_mean + get(model.dow_effects, dow, 0.0)

        # Weighted combination
        prediction = (
            weights.ewma * ewma_component +
            weights.trend * trend_component +
            weights.dow * dow_component
        )

        # 95% Confidence intervals
        ci_low = max(prediction - 1.96 * model.recent_std, 3.0)   # Floor at 3 hours
        ci_high = min(prediction + 1.96 * model.recent_std, 12.0)  # Cap at 12 hours

        push!(predictions, (
            date=pred_date,
            day_name=Dates.dayname(pred_date),
            prediction=round(prediction, digits=2),
            ci_low=round(ci_low, digits=2),
            ci_high=round(ci_high, digits=2),
            ewma_component=round(ewma_component, digits=2),
            trend_component=round(trend_component, digits=2),
            dow_component=round(dow_component, digits=2)
        ))
    end

    return predictions
end


"""
    get_model_stats(model::SleepPredictor) -> Dict

Return summary statistics about the fitted model.
"""
function get_model_stats(model::SleepPredictor)
    dow_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    dow_effects_named = Dict(
        dow_names[i] => round(model.dow_effects[i], digits=2)
        for i in 1:7
    )

    return Dict(
        "data_points" => nrow(model.sleep_df),
        "date_range" => Dict(
            "start" => string(minimum(model.sleep_df.date)),
            "end" => string(maximum(model.sleep_df.date))
        ),
        "overall_mean" => round(model.overall_mean, digits=2),
        "overall_std" => round(model.overall_std, digits=2),
        "recent_7day_mean" => round(mean(last(model.sleep_df, 7).sleep), digits=2),
        "recent_14day_mean" => round(mean(last(model.sleep_df, 14).sleep), digits=2),
        "trend_per_week" => round(model.trend_slope * 7, digits=2),
        "ewma" => round(model.ewma_value, digits=2),
        "day_of_week_effects" => dow_effects_named
    )
end


"""
    print_predictions(predictions::DataFrame)

Pretty print predictions to console.
"""
function print_predictions(predictions::DataFrame)
    println("="^60)
    println("PREDICTIONS")
    println("="^60)

    for row in eachrow(predictions)
        println()
        println("$(Dates.format(row.date, "u dd")) ($(row.day_name)):")
        println("  Predicted: $(row.prediction) hours")
        println("  95% CI: $(row.ci_low) – $(row.ci_high) hours")
    end
end


"""
    print_model_stats(model::SleepPredictor)

Pretty print model statistics to console.
"""
function print_model_stats(model::SleepPredictor)
    stats = get_model_stats(model)

    println("="^60)
    println("MODEL STATISTICS")
    println("="^60)
    println("Data points: $(stats["data_points"])")
    println("Date range: $(stats["date_range"]["start"]) to $(stats["date_range"]["end"])")
    println("Overall mean: $(stats["overall_mean"]) hrs")
    println("Recent 7-day mean: $(stats["recent_7day_mean"]) hrs")
    trend_sign = stats["trend_per_week"] >= 0 ? "+" : ""
    println("Trend: $(trend_sign)$(stats["trend_per_week"]) hrs/week")
    println()
    println("Day-of-week effects (deviation from mean):")
    for (day, effect) in sort(collect(stats["day_of_week_effects"]), by=x -> findfirst(==(x[1]),
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]))
        effect_sign = effect >= 0 ? "+" : ""
        println("  $day: $(effect_sign)$effect hrs")
    end
end


# =============================================================================
# EXAMPLE USAGE
# =============================================================================

function main(filepath::String)
    # Load data from Excel
    println("Loading data from: $filepath")
    xf = XLSX.readxlsx(filepath)
    sheet = xf[XLSX.sheetnames(xf)[1]]

    # Convert to DataFrame
    df = DataFrame(XLSX.gettable(sheet))

    # Rename columns to remove special characters
    rename!(df,
        "Time Awakened" => :Time_Awakened,
        "Approximate Time 'to Sleep'" => :Approx_Time_to_Sleep
    )

    # Calculate sleep durations
    println("Calculating sleep durations...")
    sleep_df = calculate_sleep_durations(df)
    println("Found $(nrow(sleep_df)) valid sleep records.\n")

    # Fit model
    model = fit(SleepPredictor, sleep_df)

    # Print statistics
    print_model_stats(model)

    # Make predictions
    println()
    predictions = predict(model, days_ahead=4)
    print_predictions(predictions)

    # Example with custom weights
    println("\n" * "="^60)
    println("PREDICTIONS WITH CUSTOM WEIGHTS (heavier on recent trend)")
    println("="^60)
    custom_predictions = predict(model,
        days_ahead=4,
        weights=(ewma=0.30, trend=0.50, dow=0.20)
    )
    for row in eachrow(custom_predictions)
        println("$(Dates.format(row.date, "u dd")): $(row.prediction) hrs")
    end

    return model, predictions
end


# Run if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) >= 1
        main(ARGS[1])
    else
        println("Usage: julia sleep_prediction_model.jl <excel_file_path>")
        println("Example: julia sleep_prediction_model.jl Health_Visualization_Export_1_.xlsx")
    end
end
